/**
 * Loandisk Webhook — Repayment Events
 *
 * Receives webhook callbacks from Loandisk when repayment records are
 * created, updated, or reversed/deleted.
 *
 * Pipeline:
 *   1. Authenticate via x-webhook-secret header
 *   2. Store raw payload in webhook_events
 *   3. Upsert into raw_repayments (staging — keyed on loandisk_id + branch_id)
 *   4. Resolve local loan_id from loan external ref
 *   5. Transform & insert into repayments (canonical)
 *   6. Update loan balance (total_paid, outstanding_balance, last_payment_date)
 *   7. Update client risk assessment
 *   8. Record sync lineage
 *   9. Record invocation metrics
 *
 * Verified table schemas:
 *
 *   raw_repayments:
 *     id(uuid) | loandisk_id(bigint,NOT NULL) | branch_id(bigint,NOT NULL)
 *     loan_loandisk_id(bigint) | payload(jsonb) | source(text,default:'backfill')
 *     fetched_at | created_at | updated_at
 *     UNIQUE(loandisk_id, branch_id)
 *
 *   repayments:
 *     id(uuid) | loan_id(uuid,FK→loans,NOT NULL) | amount_paid(NOT NULL)
 *     payment_method(default:'cash') | receipt_ref | collected_by | paid_at
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import type { LoandiskRepayment, WebhookPayload } from "../_shared/loandisk-types.ts";
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
  validateRepayment,
  transformRepayment,
  assessRisk,
} from "../_shared/business-logic.ts";

const FUNCTION_NAME = "loandisk-webhook-repayment";

// ─── Data Extraction ─────────────────────────────────────────────────

function resolveRepaymentData(payload: WebhookPayload): LoandiskRepayment {
  if (payload.data && typeof payload.data === "object") return payload.data as LoandiskRepayment;
  if (payload.repayment && typeof payload.repayment === "object") return payload.repayment;
  const { event, event_type, action, ...rest } = payload;
  return rest as LoandiskRepayment;
}

// ─── Main Handler ────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();
  const supabase = getServiceClient();
  let eventKey = "repayment.unknown";

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
    eventKey = resolveEventKey(payload, "repayment");
    const repayment = resolveRepaymentData(payload);

    const loandiskId = resolveNumericId(repayment.repayment_id ?? repayment.id);
    if (loandiskId === null) {
      throw new Error("Payload missing repayment identifier (repayment_id or id)");
    }

    const branchId = resolveBranchId(repayment.branch_id);
    const loanLoandiskId = resolveNumericId(repayment.loan_id);
    const externalRef = `LD-REPAY-${loandiskId}`;
    const action = mapAction(eventKey);

    // ── 3. Store raw webhook event ─────────────────────────────────
    await logWebhookEvent(supabase, "loandisk", eventKey, payload);

    // ── 4. Upsert raw_repayments ───────────────────────────────────
    const { error: rawErr } = await supabase
      .from("raw_repayments")
      .upsert(
        {
          loandisk_id: loandiskId,
          branch_id: branchId,
          loan_loandisk_id: loanLoandiskId,
          payload: payload,
          source: "webhook",
          fetched_at: new Date().toISOString(),
        },
        { onConflict: "loandisk_id,branch_id" },
      );

    if (rawErr) console.error("raw_repayments upsert error:", rawErr.message);

    // ── 5. Resolve local loan_id ───────────────────────────────────
    let localLoanId: string | null = null;
    let localId: string | null = null;

    if (loanLoandiskId) {
      const loanRef = `LD-${loanLoandiskId}`;
      // Look up loan by loan_number
      const { data: loanRecord } = await supabase
        .from("loans")
        .select("id")
        .eq("loan_number", loanRef)
        .limit(1)
        .maybeSingle();

      localLoanId = loanRecord?.id || null;

      // Fallback: look up via raw_loans
      if (!localLoanId) {
        const { data: rawLoan } = await supabase
          .from("raw_loans")
          .select("loandisk_id")
          .eq("loandisk_id", loanLoandiskId)
          .limit(1)
          .maybeSingle();

        if (rawLoan) {
          // Try loan_number pattern LD-LOAN-{id}
          const { data: loan2 } = await supabase
            .from("loans")
            .select("id")
            .eq("loan_number", `LD-LOAN-${loanLoandiskId}`)
            .limit(1)
            .maybeSingle();

          localLoanId = loan2?.id || null;
        }
      }
    }

    // ── 6. Transform & insert repayment ────────────────────────────
    if (action !== "deleted" && localLoanId) {
      const validationErr = validateRepayment(repayment);
      if (validationErr) {
        console.error("Repayment validation failed:", validationErr);
        await recordSyncLineage(
          supabase,
          { action, localId: null, externalRef, entityType: "repayment" },
          payload,
          `Validation failed: ${validationErr}`,
        );
        await logAccess(supabase, req, action, `repayment/${loandiskId}`, {
          event_key: eventKey,
          local_id: null,
          branch_id: branchId,
          validation_error: validationErr,
        });
        const durationMs = Date.now() - startTime;
        recordMetric(supabase, FUNCTION_NAME, startTime, "validation_failed", req, {
          event_key: eventKey,
          loandisk_id: loandiskId,
        }, validationErr);
        return new Response(
          JSON.stringify({
            success: false,
            error: `Validation failed: ${validationErr}`,
            event: eventKey,
            loandisk_id: loandiskId,
            duration_ms: durationMs,
          }),
          { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      const repaymentFields = transformRepayment(repayment, localLoanId);

      // Check if repayment already exists by receipt_ref
      let existing = null;
      if (repaymentFields.receipt_ref) {
        const { data } = await supabase
          .from("repayments")
          .select("id")
          .eq("receipt_ref", repaymentFields.receipt_ref)
          .limit(1)
          .maybeSingle();
        existing = data;
      }

      if (existing) {
        // Update existing repayment
        const { error: updateErr } = await supabase
          .from("repayments")
          .update(repaymentFields)
          .eq("id", existing.id);

        if (updateErr) {
          console.error("repayments update error:", updateErr.message);
        } else {
          localId = existing.id;
        }
      } else {
        // Insert new repayment
        const { data: newRepayment, error: insertErr } = await supabase
          .from("repayments")
          .insert(repaymentFields)
          .select("id")
          .single();

        if (insertErr) {
          console.error("repayments insert error:", insertErr.message);
        } else {
          localId = newRepayment?.id || null;
        }
      }

      // ── 6b. Update loan balance ────────────────────────────────
      if (localId && localLoanId) {
        // Sum all repayments for this loan
        const { data: allRepayments } = await supabase
          .from("repayments")
          .select("amount_paid")
          .eq("loan_id", localLoanId);

        if (allRepayments) {
          const totalPaid = allRepayments.reduce(
            (sum: number, r: { amount_paid: number }) => sum + (r.amount_paid || 0),
            0,
          );

          const { data: loanData } = await supabase
            .from("loans")
            .select("total_due, amount_principal")
            .eq("id", localLoanId)
            .single();

          const totalDue = loanData?.total_due || loanData?.amount_principal || 0;
          const outstanding = Math.max(0, totalDue - totalPaid);

          await supabase
            .from("loans")
            .update({
              total_paid: totalPaid,
              outstanding_balance: outstanding,
              last_payment_date: repaymentFields.paid_at,
              days_overdue: outstanding <= 0 ? 0 : undefined,
              status: outstanding <= 0 ? "closed" : undefined,
            })
            .eq("id", localLoanId);
        }
      }

      // ── 6c. Update client risk assessment ──────────────────────
      if (localId && localLoanId) {
        const { data: loanRecord } = await supabase
          .from("loans")
          .select("borrower_id, status, days_overdue")
          .eq("id", localLoanId)
          .single();

        if (loanRecord?.borrower_id) {
          // Find client by borrower phone
          const { data: borrowerRecord } = await supabase
            .from("borrowers")
            .select("phone_number")
            .eq("id", loanRecord.borrower_id)
            .single();

          if (borrowerRecord) {
            const { data: clientRecord } = await supabase
              .from("clients")
              .select("id, credit_score, risk_level")
              .eq("phone_number", borrowerRecord.phone_number)
              .limit(1)
              .maybeSingle();

            if (clientRecord) {
              const { credit_score, risk_level } = assessRisk(
                clientRecord.credit_score ?? 50,
                clientRecord.risk_level ?? "Medium",
                loanRecord.days_overdue ?? 0,
                loanRecord.status,
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
        }
      }
    } else if (action === "deleted" && localLoanId) {
      // Repayment reversal: delete the repayment and recalculate loan balance
      if (repayment.receipt_number || repayment.receipt_ref || repayment.reference) {
        const ref = repayment.receipt_number || repayment.receipt_ref || repayment.reference;
        const { data: existing } = await supabase
          .from("repayments")
          .select("id, amount_paid")
          .eq("receipt_ref", ref)
          .eq("loan_id", localLoanId)
          .limit(1)
          .maybeSingle();

        if (existing) {
          localId = existing.id;
          await supabase.from("repayments").delete().eq("id", existing.id);

          // Recalculate loan balance
          const { data: allRepayments } = await supabase
            .from("repayments")
            .select("amount_paid")
            .eq("loan_id", localLoanId);

          const totalPaid = (allRepayments || []).reduce(
            (sum: number, r: { amount_paid: number }) => sum + (r.amount_paid || 0),
            0,
          );

          const { data: loanData } = await supabase
            .from("loans")
            .select("total_due, amount_principal")
            .eq("id", localLoanId)
            .single();

          const totalDue = loanData?.total_due || loanData?.amount_principal || 0;
          const outstanding = Math.max(0, totalDue - totalPaid);

          await supabase
            .from("loans")
            .update({
              total_paid: totalPaid,
              outstanding_balance: outstanding,
              status: outstanding > 0 ? "active" : "closed",
            })
            .eq("id", localLoanId);
        }
      }
    } else if (!localLoanId) {
      console.error(`Cannot link repayment ${loandiskId}: no local loan found for LD loan ${loanLoandiskId}`);
    }

    // ── 7. Record sync lineage ─────────────────────────────────────
    await recordSyncLineage(
      supabase,
      { action, localId, externalRef, entityType: "repayment" },
      payload,
      rawErr?.message,
    );

    // ── 8. Log access & return ─────────────────────────────────────
    await logAccess(supabase, req, action, `repayment/${loandiskId}`, {
      event_key: eventKey,
      local_id: localId,
      branch_id: branchId,
      loan_loandisk_id: loanLoandiskId,
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
        loan_resolved: !!localLoanId,
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
