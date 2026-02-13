/**
 * Loandisk Universal Webhook Handler
 *
 * Single Edge Function that handles ALL LoanDisk entity types:
 * borrowers, loans, and repayments. LoanDisk sends all webhooks
 * to this one URL.
 *
 * Entity detection (in order):
 *   1. payload.entity_type field
 *   2. Event key prefix: "borrower.*", "loan.*", "repayment.*"
 *   3. Payload shape: has borrower_id → borrower, loan_id → loan, etc.
 *
 * Pipeline per entity type:
 *
 *   Borrower:
 *     webhook_events → raw_borrowers → borrowers + clients
 *     Delete cascade: borrower→inactive, client→inactive, loans→cancelled
 *
 *   Loan:
 *     webhook_events → raw_loans → loans (linked to borrower)
 *     Risk update: overdue/defaulted → client credit_score adjusted
 *
 *   Repayment:
 *     webhook_events → raw_repayments → repayments (linked to loan)
 *     Balance update: loan.total_paid, outstanding_balance recalculated
 *     Auto-close: fully paid loans → status 'closed'
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import type {
  LoandiskBorrower,
  LoandiskLoan,
  LoandiskRepayment,
  WebhookPayload,
} from "../_shared/loandisk-types.ts";
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
  transformBorrower,
  transformClient,
  resolvePhone,
  transformLoan,
  transformRepayment,
  assessRisk,
} from "../_shared/business-logic.ts";

const FUNCTION_NAME = "loandisk-webhook-borrower";

// ─── Entity Type Detection ───────────────────────────────────────────

type EntityType = "borrower" | "loan" | "repayment";

function detectEntityType(payload: WebhookPayload): EntityType {
  // 1. Explicit entity_type field
  const explicit = payload.entity_type as string | undefined;
  if (explicit) {
    if (explicit.includes("borrower") || explicit.includes("customer")) return "borrower";
    if (explicit.includes("loan")) return "loan";
    if (explicit.includes("repayment") || explicit.includes("payment")) return "repayment";
  }

  // 2. Event key prefix
  const eventKey = (payload.event || payload.event_type || payload.action || "").toLowerCase();
  if (eventKey.startsWith("borrower") || eventKey.startsWith("customer")) return "borrower";
  if (eventKey.startsWith("repayment") || eventKey.startsWith("payment")) return "repayment";
  if (eventKey.startsWith("loan")) return "loan";

  // 3. Payload shape
  const data = (payload.data || {}) as Record<string, unknown>;
  if (payload.repayment || data.repayment_id || data.payment_amount) return "repayment";
  if (payload.loan || data.loan_id || data.principal_amount) return "loan";
  if (payload.borrower || data.borrower_id || data.first_name || data.full_name) return "borrower";

  // 4. Check nested keys
  if (data.loan_id && data.amount_paid) return "repayment";
  if (data.borrower_id && data.principal_amount) return "loan";

  return "borrower"; // default
}

// ─── Data Extraction ─────────────────────────────────────────────────

function extractData(payload: WebhookPayload): Record<string, unknown> {
  if (payload.data && typeof payload.data === "object") return payload.data;
  if (payload.borrower && typeof payload.borrower === "object") return payload.borrower as Record<string, unknown>;
  if (payload.loan && typeof payload.loan === "object") return payload.loan as Record<string, unknown>;
  if (payload.repayment && typeof payload.repayment === "object") return payload.repayment as Record<string, unknown>;
  const { event, event_type, action, entity_type, ...rest } = payload;
  return rest;
}

// ─── Borrower Handler ────────────────────────────────────────────────

async function handleBorrower(
  supabase: ReturnType<typeof getServiceClient>,
  payload: WebhookPayload,
  req: Request,
): Promise<{ localId: string | null; action: string; externalRef: string; eventKey: string }> {
  const eventKey = resolveEventKey(payload, "borrower");
  const borrower = extractData(payload) as LoandiskBorrower;
  const loandiskId = resolveNumericId(borrower.borrower_id ?? borrower.id);

  if (loandiskId === null) {
    throw new Error("Payload missing borrower identifier (borrower_id or id)");
  }

  const branchId = resolveBranchId(borrower.branch_id);
  const externalRef = `LD-${loandiskId}`;
  const action = mapAction(eventKey);
  const now = new Date().toISOString();

  // Store raw
  await logWebhookEvent(supabase, "loandisk", eventKey, payload);
  const { error: rawErr } = await supabase
    .from("raw_borrowers")
    .upsert(
      { loandisk_id: loandiskId, branch_id: branchId, payload, source: "webhook", fetched_at: now },
      { onConflict: "loandisk_id,branch_id" },
    );
  if (rawErr) console.error("raw_borrowers upsert error:", rawErr.message);

  let localId: string | null = null;

  if (action !== "deleted") {
    // Upsert borrowers table
    const borrowerFields = transformBorrower(borrower);
    const { data: existingBorrower } = await supabase
      .from("borrowers")
      .select("id")
      .eq("phone_number", borrowerFields.phone_number)
      .limit(1)
      .maybeSingle();

    if (existingBorrower) {
      await supabase.from("borrowers").update(borrowerFields).eq("id", existingBorrower.id);
    } else {
      await supabase.from("borrowers").insert(borrowerFields);
    }

    // Upsert clients table
    const clientFields = transformClient(borrower, externalRef);
    const { data: existingClient } = await supabase
      .from("clients")
      .select("id")
      .eq("external_reference_id", externalRef)
      .limit(1)
      .maybeSingle();

    if (existingClient) {
      const { error } = await supabase.from("clients").update(clientFields).eq("id", existingClient.id);
      if (!error) localId = existingClient.id;
    } else {
      const { data: newClient, error } = await supabase.from("clients").insert(clientFields).select("id").single();
      if (!error) localId = newClient?.id || null;
    }
  } else {
    // Deletion cascade: borrower→inactive, client→inactive, loans→cancelled
    const phone = resolvePhone(borrower);

    if (phone && phone !== "0000000000") {
      await supabase.from("borrowers").update({ status: "inactive" }).eq("phone_number", phone);

      const { data: borrowerRecord } = await supabase
        .from("borrowers").select("id").eq("phone_number", phone).limit(1).maybeSingle();
      if (borrowerRecord) {
        await supabase.from("loans").update({ status: "cancelled" })
          .eq("borrower_id", borrowerRecord.id).in("status", ["pending", "active"]);
      }
    }

    const { data: existingClient } = await supabase
      .from("clients").select("id").eq("external_reference_id", externalRef).limit(1).maybeSingle();
    if (existingClient) {
      localId = existingClient.id;
      await supabase.from("clients").update({ status: "inactive", updated_at: now }).eq("id", existingClient.id);
    }
  }

  await recordSyncLineage(supabase, { action, localId, externalRef, entityType: "borrower" }, payload, rawErr?.message);
  await logAccess(supabase, req, action, `borrower/${loandiskId}`, { event_key: eventKey, local_id: localId, branch_id: branchId });

  return { localId, action, externalRef, eventKey };
}

// ─── Loan Handler ────────────────────────────────────────────────────

async function handleLoan(
  supabase: ReturnType<typeof getServiceClient>,
  payload: WebhookPayload,
  req: Request,
): Promise<{ localId: string | null; action: string; externalRef: string; eventKey: string }> {
  const eventKey = resolveEventKey(payload, "loan");
  const loan = extractData(payload) as LoandiskLoan;
  const loandiskId = resolveNumericId(loan.loan_id ?? loan.id);

  if (loandiskId === null) {
    throw new Error("Payload missing loan identifier (loan_id or id)");
  }

  const branchId = resolveBranchId(loan.branch_id);
  const borrowerLoandiskId = resolveNumericId(loan.borrower_id);
  const externalRef = `LD-LOAN-${loandiskId}`;
  const action = mapAction(eventKey);
  const now = new Date().toISOString();

  await logWebhookEvent(supabase, "loandisk", eventKey, payload);
  const { error: rawErr } = await supabase
    .from("raw_loans")
    .upsert(
      { loandisk_id: loandiskId, branch_id: branchId, borrower_loandisk_id: borrowerLoandiskId, payload, source: "webhook", fetched_at: now },
      { onConflict: "loandisk_id,branch_id" },
    );
  if (rawErr) console.error("raw_loans upsert error:", rawErr.message);

  let localId: string | null = null;

  // Resolve local borrower_id
  let localBorrowerId: string | null = null;
  if (borrowerLoandiskId) {
    const borrowerRef = `LD-${borrowerLoandiskId}`;
    const { data: client } = await supabase
      .from("clients").select("phone_number").eq("external_reference_id", borrowerRef).limit(1).maybeSingle();

    if (client?.phone_number) {
      const { data: borrower } = await supabase
        .from("borrowers").select("id").eq("phone_number", client.phone_number).limit(1).maybeSingle();
      localBorrowerId = borrower?.id || null;
    }

    // Fallback: look up via raw_borrowers payload
    if (!localBorrowerId) {
      const { data: rawB } = await supabase.from("raw_borrowers").select("payload").eq("loandisk_id", borrowerLoandiskId).limit(1).maybeSingle();
      if (rawB?.payload) {
        const p = rawB.payload as Record<string, unknown>;
        const phone = ((p.phone_number || p.mobile || "") as string).trim();
        if (phone) {
          const { data: borrower } = await supabase.from("borrowers").select("id").eq("phone_number", phone).limit(1).maybeSingle();
          localBorrowerId = borrower?.id || null;
        }
      }
    }
  }

  const loanNumber = loan.loan_number || `LD-${loandiskId}`;

  if (action !== "deleted" && localBorrowerId) {
    const loanFields = transformLoan(loan, localBorrowerId);
    const { data: existing } = await supabase.from("loans").select("id").eq("loan_number", loanNumber).limit(1).maybeSingle();

    if (existing) {
      const { error } = await supabase.from("loans").update({ ...loanFields, loan_number: loanNumber }).eq("id", existing.id);
      if (!error) localId = existing.id;
    } else {
      const { data: newLoan, error } = await supabase.from("loans").insert({ ...loanFields, loan_number: loanNumber }).select("id").single();
      if (!error) localId = newLoan?.id || null;
    }

    // Update client risk assessment
    if (localId && borrowerLoandiskId) {
      const borrowerRef = `LD-${borrowerLoandiskId}`;
      const { data: clientRecord } = await supabase
        .from("clients").select("id, credit_score, risk_level").eq("external_reference_id", borrowerRef).limit(1).maybeSingle();

      if (clientRecord) {
        const { credit_score, risk_level } = assessRisk(
          clientRecord.credit_score ?? 50, clientRecord.risk_level ?? "Medium",
          loanFields.days_overdue || 0, loanFields.status,
        );
        if (credit_score !== clientRecord.credit_score || risk_level !== clientRecord.risk_level) {
          await supabase.from("clients").update({ credit_score, risk_level, updated_at: now }).eq("id", clientRecord.id);
        }
      }
    }
  } else if (action === "deleted") {
    const { data: existing } = await supabase.from("loans").select("id").eq("loan_number", loanNumber).limit(1).maybeSingle();
    if (existing) {
      localId = existing.id;
      await supabase.from("loans").update({ status: "cancelled" }).eq("id", existing.id);
    }
  }

  await recordSyncLineage(supabase, { action, localId, externalRef, entityType: "loan" }, payload, rawErr?.message);
  await logAccess(supabase, req, action, `loan/${loandiskId}`, { event_key: eventKey, local_id: localId, branch_id: branchId });

  return { localId, action, externalRef, eventKey };
}

// ─── Repayment Handler ───────────────────────────────────────────────

async function handleRepayment(
  supabase: ReturnType<typeof getServiceClient>,
  payload: WebhookPayload,
  req: Request,
): Promise<{ localId: string | null; action: string; externalRef: string; eventKey: string }> {
  const eventKey = resolveEventKey(payload, "repayment");
  const repayment = extractData(payload) as LoandiskRepayment;
  const loandiskId = resolveNumericId(repayment.repayment_id ?? repayment.id);

  if (loandiskId === null) {
    throw new Error("Payload missing repayment identifier (repayment_id or id)");
  }

  const branchId = resolveBranchId(repayment.branch_id);
  const loanLoandiskId = resolveNumericId(repayment.loan_id);
  const externalRef = `LD-REPAY-${loandiskId}`;
  const action = mapAction(eventKey);
  const now = new Date().toISOString();

  await logWebhookEvent(supabase, "loandisk", eventKey, payload);
  const { error: rawErr } = await supabase
    .from("raw_repayments")
    .upsert(
      { loandisk_id: loandiskId, branch_id: branchId, loan_loandisk_id: loanLoandiskId, payload, source: "webhook", fetched_at: now },
      { onConflict: "loandisk_id,branch_id" },
    );
  if (rawErr) console.error("raw_repayments upsert error:", rawErr.message);

  let localId: string | null = null;

  // Resolve local loan_id
  let localLoanId: string | null = null;
  if (loanLoandiskId) {
    for (const ref of [`LD-${loanLoandiskId}`, `LD-LOAN-${loanLoandiskId}`]) {
      const { data: loan } = await supabase.from("loans").select("id").eq("loan_number", ref).limit(1).maybeSingle();
      if (loan) { localLoanId = loan.id; break; }
    }
  }

  if (action !== "deleted" && localLoanId) {
    const repaymentFields = transformRepayment(repayment, localLoanId);

    let existing = null;
    if (repaymentFields.receipt_ref) {
      const { data } = await supabase.from("repayments").select("id").eq("receipt_ref", repaymentFields.receipt_ref).limit(1).maybeSingle();
      existing = data;
    }

    if (existing) {
      const { error } = await supabase.from("repayments").update(repaymentFields).eq("id", existing.id);
      if (!error) localId = existing.id;
    } else {
      const { data: newR, error } = await supabase.from("repayments").insert(repaymentFields).select("id").single();
      if (!error) localId = newR?.id || null;
    }

    // Recalculate loan balance
    if (localId) {
      await recalculateLoanBalance(supabase, localLoanId, repaymentFields.paid_at);
    }
  } else if (action === "deleted" && localLoanId) {
    // Repayment reversal
    const ref = repayment.receipt_number || repayment.receipt_ref || repayment.reference;
    if (ref) {
      const { data: existing } = await supabase.from("repayments").select("id").eq("receipt_ref", ref).eq("loan_id", localLoanId).limit(1).maybeSingle();
      if (existing) {
        localId = existing.id;
        await supabase.from("repayments").delete().eq("id", existing.id);
        await recalculateLoanBalance(supabase, localLoanId);
      }
    }
  }

  await recordSyncLineage(supabase, { action, localId, externalRef, entityType: "repayment" }, payload, rawErr?.message);
  await logAccess(supabase, req, action, `repayment/${loandiskId}`, { event_key: eventKey, local_id: localId, branch_id: branchId });

  return { localId, action, externalRef, eventKey };
}

/** Recalculate loan total_paid and outstanding_balance after repayment changes */
async function recalculateLoanBalance(
  supabase: ReturnType<typeof getServiceClient>,
  loanId: string,
  lastPaymentDate?: string,
): Promise<void> {
  const { data: allRepayments } = await supabase.from("repayments").select("amount_paid").eq("loan_id", loanId);
  const totalPaid = (allRepayments || []).reduce(
    (sum: number, r: { amount_paid: number }) => sum + (r.amount_paid || 0), 0,
  );

  const { data: loanData } = await supabase.from("loans").select("total_due, amount_principal").eq("id", loanId).single();
  const totalDue = loanData?.total_due || loanData?.amount_principal || 0;
  const outstanding = Math.max(0, totalDue - totalPaid);

  const update: Record<string, unknown> = {
    total_paid: totalPaid,
    outstanding_balance: outstanding,
  };
  if (lastPaymentDate) update.last_payment_date = lastPaymentDate;
  if (outstanding <= 0) {
    update.status = "closed";
    update.days_overdue = 0;
  }

  await supabase.from("loans").update(update).eq("id", loanId);
}

// ─── Main Handler ────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();
  const supabase = getServiceClient();
  let eventKey = "unknown";

  try {
    // Authentication
    const auth = authenticateWebhook(req);
    if (!auth.ok) {
      await logAuthFailure(supabase, FUNCTION_NAME, req);
      return new Response(
        JSON.stringify({ success: false, error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Parse and detect entity type
    const payload: WebhookPayload = await req.json();
    const entityType = detectEntityType(payload);

    // Route to the correct handler
    let result: { localId: string | null; action: string; externalRef: string; eventKey: string };

    switch (entityType) {
      case "loan":
        result = await handleLoan(supabase, payload, req);
        break;
      case "repayment":
        result = await handleRepayment(supabase, payload, req);
        break;
      default:
        result = await handleBorrower(supabase, payload, req);
        break;
    }

    eventKey = result.eventKey;
    const durationMs = Date.now() - startTime;

    recordMetric(supabase, FUNCTION_NAME, startTime, "success", req, {
      event_key: result.eventKey,
      entity_type: entityType,
      local_id: result.localId,
    });

    return new Response(
      JSON.stringify({
        success: true,
        entity_type: entityType,
        event: result.eventKey,
        action: result.action,
        local_id: result.localId,
        external_ref: result.externalRef,
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
