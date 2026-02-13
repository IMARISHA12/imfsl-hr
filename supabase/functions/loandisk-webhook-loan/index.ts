/**
 * Loandisk Webhook — Loan Events
 *
 * Receives webhook callbacks from Loandisk when loan records are
 * created, updated, or deleted.
 *
 * Pipeline:
 *   1. Authenticate via x-webhook-secret header
 *   2. Store raw payload in webhook_events
 *   3. Upsert into raw_loans (staging — keyed on loandisk_id + branch_id)
 *   4. Resolve local borrower_id from borrower external ref
 *   5. Transform & upsert into loans (canonical)
 *   6. Update client risk assessment if loan is overdue/defaulted
 *   7. Record sync lineage in loandisk_sync_runs / loandisk_sync_items
 *   8. Record invocation metrics
 *
 * Verified table schemas:
 *
 *   raw_loans:
 *     id(uuid) | loandisk_id(bigint,NOT NULL) | branch_id(bigint)
 *     borrower_loandisk_id(bigint) | payload(jsonb) | source(text,default:'backfill')
 *     fetched_at | created_at | updated_at
 *     UNIQUE(loandisk_id, branch_id)
 *
 *   loans:
 *     id(uuid) | borrower_id(uuid,FK→borrowers,NOT NULL) | amount_principal(NOT NULL)
 *     interest_rate(NOT NULL) | duration_months(NOT NULL) | total_due
 *     start_date | status(default:'pending') | approved_by | created_at
 *     loan_number | officer_id | outstanding_balance | total_paid(default:0)
 *     days_overdue(default:0) | last_payment_date | product_type(default:'sme_group')
 *     disbursed_at | branch
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import type { LoandiskLoan, WebhookPayload } from "../_shared/loandisk-types.ts";
import {
  authenticateWebhook,
  resolveEventKey,
  mapAction,
  resolveNumericId,
  resolveBranchId,
  logWebhookEvent,
  logAuthFailure,
  logAccess,
  recordSyncLineage,
  recordMetric,
} from "../_shared/webhook-helpers.ts";
import {
  validateLoan,
  transformLoan,
  mapLoanStatus,
  assessRisk,
} from "../_shared/business-logic.ts";

const FUNCTION_NAME = "loandisk-webhook-loan";

// ─── Data Extraction ─────────────────────────────────────────────────

function resolveLoanData(payload: WebhookPayload): LoandiskLoan {
  if (payload.data && typeof payload.data === "object") return payload.data as LoandiskLoan;
  if (payload.loan && typeof payload.loan === "object") return payload.loan;
  const { event, event_type, action, ...rest } = payload;
  return rest as LoandiskLoan;
}

// ─── Main Handler ────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();
  const supabase = getServiceClient();
  let eventKey = "loan.unknown";

  try {
    // ── 1. Authentication ──────────────────────────────────────────
    const auth = authenticateWebhook(req);
    if (!auth.ok) {
      await logAuthFailure(supabase, FUNCTION_NAME, req);
      return new Response(
        JSON.stringify({ success: false, error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 2. Parse payload ───────────────────────────────────────────
    const payload: WebhookPayload = await req.json();
    eventKey = resolveEventKey(payload, "loan");
    const loan = resolveLoanData(payload);

    const loandiskId = resolveNumericId(loan.loan_id ?? loan.id);
    if (loandiskId === null) {
      throw new Error("Payload missing loan identifier (loan_id or id)");
    }

    const branchId = resolveBranchId(loan.branch_id);
    const borrowerLoandiskId = resolveNumericId(loan.borrower_id);
    const externalRef = `LD-LOAN-${loandiskId}`;
    const action = mapAction(eventKey);

    // ── 3. Store raw webhook event ─────────────────────────────────
    await logWebhookEvent(supabase, "loandisk", eventKey, payload);

    // ── 4. Upsert raw_loans ────────────────────────────────────────
    const { error: rawErr } = await supabase
      .from("raw_loans")
      .upsert(
        {
          loandisk_id: loandiskId,
          branch_id: branchId,
          borrower_loandisk_id: borrowerLoandiskId,
          payload: payload,
          source: "webhook",
          fetched_at: new Date().toISOString(),
        },
        { onConflict: "loandisk_id,branch_id" },
      );

    if (rawErr) console.error("raw_loans upsert error:", rawErr.message);

    // ── 5. Resolve local borrower_id ───────────────────────────────
    let localBorrowerId: string | null = null;
    let localId: string | null = null;

    if (borrowerLoandiskId) {
      // Look up borrower via raw_borrowers → clients linkage
      const borrowerRef = `LD-${borrowerLoandiskId}`;

      // First try clients table (has external_reference_id)
      const { data: client } = await supabase
        .from("clients")
        .select("id")
        .eq("external_reference_id", borrowerRef)
        .limit(1)
        .maybeSingle();

      if (client) {
        // Now find corresponding borrower record (same phone or name)
        const { data: clientFull } = await supabase
          .from("clients")
          .select("phone_number, first_name, last_name")
          .eq("id", client.id)
          .single();

        if (clientFull) {
          const { data: borrower } = await supabase
            .from("borrowers")
            .select("id")
            .eq("phone_number", clientFull.phone_number)
            .limit(1)
            .maybeSingle();

          localBorrowerId = borrower?.id || null;
        }
      }

      // Fallback: try raw_borrowers to find the phone, then match in borrowers
      if (!localBorrowerId) {
        const { data: rawBorrower } = await supabase
          .from("raw_borrowers")
          .select("payload")
          .eq("loandisk_id", borrowerLoandiskId)
          .limit(1)
          .maybeSingle();

        if (rawBorrower?.payload) {
          const p = rawBorrower.payload as Record<string, unknown>;
          const phone = (p.phone_number || p.mobile || "") as string;
          if (phone) {
            const { data: borrower } = await supabase
              .from("borrowers")
              .select("id")
              .eq("phone_number", phone.trim())
              .limit(1)
              .maybeSingle();
            localBorrowerId = borrower?.id || null;
          }
        }
      }
    }

    // ── 6. Transform & upsert loan ─────────────────────────────────
    if (action !== "deleted" && localBorrowerId) {
      const validationErr = validateLoan(loan);
      if (validationErr) {
        console.error("Loan validation failed:", validationErr);
      }

      const loanFields = transformLoan(loan, localBorrowerId);

      // Check if loan already exists by loan_number
      const loanNumber = loan.loan_number || `LD-${loandiskId}`;
      const { data: existing } = await supabase
        .from("loans")
        .select("id")
        .eq("loan_number", loanNumber)
        .limit(1)
        .maybeSingle();

      if (existing) {
        const { error: updateErr } = await supabase
          .from("loans")
          .update({ ...loanFields, loan_number: loanNumber })
          .eq("id", existing.id);

        if (updateErr) {
          console.error("loans update error:", updateErr.message);
        } else {
          localId = existing.id;
        }
      } else {
        const { data: newLoan, error: insertErr } = await supabase
          .from("loans")
          .insert({ ...loanFields, loan_number: loanNumber })
          .select("id")
          .single();

        if (insertErr) {
          console.error("loans insert error:", insertErr.message);
        } else {
          localId = newLoan?.id || null;
        }
      }

      // ── 6b. Update client risk assessment ──────────────────────
      if (localId && borrowerLoandiskId) {
        const borrowerRef = `LD-${borrowerLoandiskId}`;
        const { data: clientRecord } = await supabase
          .from("clients")
          .select("id, credit_score, risk_level")
          .eq("external_reference_id", borrowerRef)
          .limit(1)
          .maybeSingle();

        if (clientRecord) {
          const daysOverdue = loanFields.days_overdue || 0;
          const loanStatus = loanFields.status;
          const { credit_score, risk_level } = assessRisk(
            clientRecord.credit_score ?? 50,
            clientRecord.risk_level ?? "Medium",
            daysOverdue,
            loanStatus,
          );

          if (
            credit_score !== clientRecord.credit_score ||
            risk_level !== clientRecord.risk_level
          ) {
            await supabase
              .from("clients")
              .update({
                credit_score,
                risk_level,
                updated_at: new Date().toISOString(),
              })
              .eq("id", clientRecord.id);
          }
        }
      }
    } else if (action === "deleted") {
      // Soft-delete: cancel the loan
      const loanNumber = loan.loan_number || `LD-${loandiskId}`;
      const { data: existing } = await supabase
        .from("loans")
        .select("id")
        .eq("loan_number", loanNumber)
        .limit(1)
        .maybeSingle();

      if (existing) {
        localId = existing.id;
        await supabase
          .from("loans")
          .update({ status: "cancelled" })
          .eq("id", existing.id);
      }
    } else if (!localBorrowerId) {
      console.error(`Cannot link loan ${loandiskId}: no local borrower found for LD borrower ${borrowerLoandiskId}`);
    }

    // ── 7. Record sync lineage ─────────────────────────────────────
    await recordSyncLineage(
      supabase,
      {
        action,
        localId,
        externalRef,
        entityType: "loan",
      },
      payload,
      rawErr?.message,
    );

    // ── 8. Log access & return ─────────────────────────────────────
    await logAccess(supabase, req, action, `loan/${loandiskId}`, {
      event_key: eventKey,
      local_id: localId,
      branch_id: branchId,
      borrower_loandisk_id: borrowerLoandiskId,
    });

    const durationMs = Date.now() - startTime;
    recordMetric(supabase, FUNCTION_NAME, startTime, "success", req, {
      event_key: eventKey,
      loandisk_id: loandiskId,
      local_id: localId,
    });

    return new Response(
      JSON.stringify({
        success: true,
        event: eventKey,
        loandisk_id: loandiskId,
        local_id: localId,
        action,
        borrower_resolved: !!localBorrowerId,
        duration_ms: durationMs,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : String(err);
    console.error(`${FUNCTION_NAME} error:`, errorMessage);
    recordMetric(supabase, FUNCTION_NAME, startTime, "error", req, { event_key: eventKey }, errorMessage);

    return new Response(
      JSON.stringify({
        success: false,
        error: errorMessage,
        event: eventKey,
        duration_ms: Date.now() - startTime,
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
