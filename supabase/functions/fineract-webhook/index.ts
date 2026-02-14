/**
 * Fineract Universal Webhook Handler
 *
 * Receives webhook (hook) notifications from Apache Fineract when
 * entities are created, updated, or deleted. Fineract hooks send
 * POST requests with entity/action information.
 *
 * Supported entities:
 *   - CLIENT: Create/Update/Delete → borrowers + clients
 *   - LOAN: Create/Update/Approve/Disburse/Close → loans
 *   - LOAN_TRANSACTION: Repayment/Waiver/WriteOff → repayments
 *   - SAVINGSACCOUNT: Create/Update → savings_accounts
 *
 * Pipeline per entity:
 *   webhook → raw_fineract_* → canonical tables → risk assessment
 *
 * Authentication: x-webhook-secret header
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import { createFineractClient } from "../_shared/fineract-api.ts";
import type {
  FineractClient,
  FineractLoan,
  FineractLoanTransaction,
  FineractHookPayload,
} from "../_shared/fineract-types.ts";
import {
  transformFineractClient,
  transformFineractToClient,
  transformFineractLoan,
  transformFineractTransaction,
  assessRisk,
} from "../_shared/fineract-business-logic.ts";
import {
  recordMetric,
} from "../_shared/webhook-helpers.ts";

const FUNCTION_NAME = "fineract-webhook";

// ─── Authentication ─────────────────────────────────────────────────

function authenticateRequest(req: Request): boolean {
  const secret = Deno.env.get("FINERACT_WEBHOOK_SECRET");
  if (!secret) return false;
  const incoming =
    req.headers.get("x-webhook-secret") ||
    req.headers.get("authorization")?.replace(/^Bearer\s+/i, "");
  return incoming === secret;
}

// ─── Entity Routing ─────────────────────────────────────────────────

async function handleClient(
  supabase: ReturnType<typeof getServiceClient>,
  payload: FineractHookPayload,
): Promise<{ localId: string | null; action: string; entity: string }> {
  const fineractId = payload.resourceId;
  if (!fineractId) throw new Error("Missing resourceId for CLIENT hook");

  const action = payload.action?.toLowerCase() || "create";
  const externalRef = `FN-${fineractId}`;
  const now = new Date().toISOString();

  // Fetch full client from Fineract API to get complete data
  let clientData: FineractClient;
  try {
    const api = createFineractClient();
    clientData = await api.getClient(fineractId);
  } catch (err) {
    // If we can't fetch, use the body data
    clientData = { id: fineractId, ...(payload.body || {}) } as FineractClient;
  }

  // Store raw
  await supabase
    .from("raw_fineract_clients")
    .upsert(
      { fineract_id: fineractId, office_id: clientData.officeId || null, payload: clientData, source: "webhook", fetched_at: now },
      { onConflict: "fineract_id" },
    );

  let localId: string | null = null;

  if (action.includes("delete")) {
    // Soft delete
    await supabase.from("borrowers").update({ status: "inactive", updated_at: now }).eq("fineract_id", fineractId);
    const { data: client } = await supabase.from("clients").select("id").eq("fineract_id", fineractId).limit(1).maybeSingle();
    if (client) {
      localId = client.id;
      await supabase.from("clients").update({ status: "inactive", updated_at: now }).eq("id", client.id);
    }
  } else {
    // Upsert borrowers
    const borrowerFields = transformFineractClient(clientData);
    const { data: existingBorrower } = await supabase
      .from("borrowers").select("id").eq("fineract_id", fineractId).limit(1).maybeSingle();

    if (existingBorrower) {
      await supabase.from("borrowers").update(borrowerFields).eq("id", existingBorrower.id);
    } else {
      await supabase.from("borrowers").insert(borrowerFields);
    }

    // Upsert clients
    const clientFields = transformFineractToClient(clientData);
    const { data: existingClient } = await supabase
      .from("clients").select("id").eq("fineract_id", fineractId).limit(1).maybeSingle();

    if (existingClient) {
      await supabase.from("clients").update(clientFields).eq("id", existingClient.id);
      localId = existingClient.id;
    } else {
      const { data: newClient } = await supabase.from("clients").insert(clientFields).select("id").single();
      localId = newClient?.id || null;
    }
  }

  // Record sync lineage
  await recordSyncItem(supabase, "client", String(fineractId), action.includes("delete") ? "deleted" : action.includes("create") ? "created" : "updated", localId, clientData);

  return { localId, action, entity: "client" };
}

async function handleLoan(
  supabase: ReturnType<typeof getServiceClient>,
  payload: FineractHookPayload,
): Promise<{ localId: string | null; action: string; entity: string }> {
  const fineractId = payload.resourceId;
  if (!fineractId) throw new Error("Missing resourceId for LOAN hook");

  const action = payload.action?.toLowerCase() || "create";
  const now = new Date().toISOString();

  // Fetch full loan from Fineract
  let loanData: FineractLoan;
  try {
    const api = createFineractClient();
    loanData = await api.getLoan(fineractId);
  } catch {
    loanData = { id: fineractId, ...(payload.body || {}) } as FineractLoan;
  }

  // Store raw
  await supabase
    .from("raw_fineract_loans")
    .upsert(
      { fineract_id: fineractId, client_fineract_id: loanData.clientId || null, payload: loanData, source: "webhook", fetched_at: now },
      { onConflict: "fineract_id" },
    );

  let localId: string | null = null;

  // Resolve local borrower
  let localBorrowerId: string | null = null;
  if (loanData.clientId) {
    const { data: borrower } = await supabase
      .from("borrowers").select("id").eq("fineract_id", loanData.clientId).limit(1).maybeSingle();
    localBorrowerId = borrower?.id || null;
  }

  if (!localBorrowerId) {
    console.warn(`No local borrower for Fineract client ${loanData.clientId}`);
    return { localId: null, action, entity: "loan" };
  }

  // Upsert loan
  const loanFields = transformFineractLoan(loanData, localBorrowerId);
  const { data: existingLoan } = await supabase
    .from("loans").select("id").eq("fineract_id", fineractId).limit(1).maybeSingle();

  if (existingLoan) {
    await supabase.from("loans").update(loanFields).eq("id", existingLoan.id);
    localId = existingLoan.id;
  } else {
    const { data: newLoan } = await supabase.from("loans").insert(loanFields).select("id").single();
    localId = newLoan?.id || null;
  }

  // Sync repayment schedule if available
  if (localId && loanData.repaymentSchedule?.periods) {
    await syncLoanSchedule(supabase, localId, loanData);
  }

  // Record lifecycle event
  if (localId) {
    const eventType = action.includes("approve") ? "approval" :
      action.includes("disburse") ? "disbursement" :
      action.includes("close") ? "closure" :
      action.includes("writeoff") || action.includes("write_off") ? "write_off" :
      action.includes("create") ? "application" : "update";

    await supabase.from("loan_lifecycle_events").insert({
      loan_id: localId,
      event_type: eventType,
      to_status: loanFields.status,
      amount: loanFields.amount_principal,
      performed_by: `fineract-webhook`,
      notes: `Fineract hook: ${payload.action}`,
      fineract_transaction_id: null,
    });
  }

  // Update client risk assessment
  if (localId && loanData.clientId) {
    await updateClientRisk(supabase, loanData.clientId, loanFields.days_overdue, loanFields.status, loanFields.is_npa);
  }

  await recordSyncItem(supabase, "loan", String(fineractId), existingLoan ? "updated" : "created", localId, loanData);
  return { localId, action, entity: "loan" };
}

async function handleLoanTransaction(
  supabase: ReturnType<typeof getServiceClient>,
  payload: FineractHookPayload,
): Promise<{ localId: string | null; action: string; entity: string }> {
  const loanFineractId = payload.resourceId;
  const transactionId = payload.subresourceId;
  if (!loanFineractId || !transactionId) throw new Error("Missing resourceId/subresourceId for LOAN_TRANSACTION hook");

  const action = payload.action?.toLowerCase() || "create";
  const now = new Date().toISOString();

  // Fetch transaction details
  let txnData: FineractLoanTransaction;
  try {
    const api = createFineractClient();
    const loan = await api.getLoan(loanFineractId);
    const transactions = (loan as unknown as { transactions?: FineractLoanTransaction[] }).transactions || [];
    txnData = transactions.find((t) => t.id === transactionId) || { id: transactionId };
  } catch {
    txnData = { id: transactionId, ...(payload.body || {}) } as FineractLoanTransaction;
  }

  // Store raw
  await supabase
    .from("raw_fineract_transactions")
    .upsert(
      {
        fineract_id: transactionId,
        loan_fineract_id: loanFineractId,
        transaction_type: txnData.type?.value || "unknown",
        payload: txnData,
        source: "webhook",
        fetched_at: now,
      },
      { onConflict: "fineract_id" },
    );

  // Resolve local loan
  const { data: localLoan } = await supabase
    .from("loans").select("id, borrower_id, fineract_id").eq("fineract_id", loanFineractId).limit(1).maybeSingle();

  if (!localLoan) {
    console.warn(`No local loan for Fineract loan ${loanFineractId}`);
    return { localId: null, action, entity: "transaction" };
  }

  let localId: string | null = null;

  // Only process repayment-type transactions (not disbursements, etc.)
  const txnType = txnData.type?.code?.toLowerCase() || "";
  if (txnType.includes("repayment") || txnType.includes("recovery")) {
    const repaymentFields = transformFineractTransaction(txnData, localLoan.id);
    const { data: existing } = await supabase
      .from("repayments").select("id").eq("fineract_id", transactionId).limit(1).maybeSingle();

    if (existing) {
      await supabase.from("repayments").update(repaymentFields).eq("id", existing.id);
      localId = existing.id;
    } else {
      const { data: newR } = await supabase.from("repayments").insert(repaymentFields).select("id").single();
      localId = newR?.id || null;
    }

    // Update loan balance from transaction
    if (txnData.outstandingLoanBalance != null) {
      await supabase.from("loans").update({
        outstanding_balance: txnData.outstandingLoanBalance,
        last_payment_date: repaymentFields.paid_at,
        updated_at: now,
      }).eq("id", localLoan.id);
    }
  }

  // Record lifecycle event
  await supabase.from("loan_lifecycle_events").insert({
    loan_id: localLoan.id,
    event_type: txnType.includes("repayment") ? "repayment" :
      txnType.includes("disbursement") ? "disbursement" :
      txnType.includes("waive") ? "waiver" :
      txnType.includes("writeoff") ? "write_off" : "transaction",
    amount: txnData.amount,
    performed_by: "fineract-webhook",
    fineract_transaction_id: transactionId,
    notes: `Fineract txn: ${txnData.type?.value || "unknown"}`,
  });

  await recordSyncItem(supabase, "transaction", String(transactionId), existing ? "updated" : "created", localId, txnData);
  return { localId, action, entity: "transaction" };
}

// ─── Helpers ────────────────────────────────────────────────────────

async function syncLoanSchedule(
  supabase: ReturnType<typeof getServiceClient>,
  localLoanId: string,
  loanData: FineractLoan,
): Promise<void> {
  const periods = loanData.repaymentSchedule?.periods || [];
  const { transformSchedulePeriod } = await import("../_shared/fineract-business-logic.ts");

  // Delete existing schedule for this loan and replace
  await supabase.from("loan_schedule").delete().eq("loan_id", localLoanId);

  const rows = periods
    .map((p) => transformSchedulePeriod(p, localLoanId))
    .filter(Boolean);

  if (rows.length > 0) {
    await supabase.from("loan_schedule").insert(rows);
  }
}

async function updateClientRisk(
  supabase: ReturnType<typeof getServiceClient>,
  fineractClientId: number,
  daysOverdue: number,
  loanStatus: string,
  isNPA: boolean,
): Promise<void> {
  const { data: client } = await supabase
    .from("clients")
    .select("id, credit_score, risk_level")
    .eq("fineract_id", fineractClientId)
    .limit(1)
    .maybeSingle();

  if (!client) return;

  const { credit_score, risk_level } = assessRisk(
    client.credit_score ?? 50,
    client.risk_level ?? "Medium",
    daysOverdue,
    loanStatus,
    isNPA,
  );

  if (credit_score !== client.credit_score || risk_level !== client.risk_level) {
    await supabase.from("clients").update({
      credit_score,
      risk_level,
      updated_at: new Date().toISOString(),
    }).eq("id", client.id);
  }
}

async function recordSyncItem(
  supabase: ReturnType<typeof getServiceClient>,
  entityType: string,
  externalId: string,
  action: string,
  localId: string | null,
  sourceData: unknown,
): Promise<void> {
  // Find active integration
  const { data: integration } = await supabase
    .from("fineract_integrations").select("id").eq("is_active", true).limit(1).maybeSingle();
  if (!integration) return;

  const now = new Date().toISOString();
  const { data: syncRun } = await supabase
    .from("fineract_sync_runs")
    .insert({
      integration_id: integration.id,
      run_type: "webhook",
      started_at: now,
      completed_at: now,
      status: localId ? "completed" : "partial",
      records_fetched: 1,
      records_created: action === "created" ? 1 : 0,
      records_updated: action === "updated" ? 1 : 0,
      records_failed: localId ? 0 : 1,
      entity_types: [entityType],
    })
    .select("id")
    .single();

  if (syncRun) {
    await supabase.from("fineract_sync_items").insert({
      sync_run_id: syncRun.id,
      entity_type: entityType,
      external_id: externalId,
      action,
      local_id: localId,
      source_data: sourceData as Record<string, unknown>,
      synced_at: now,
    });
  }
}

// ─── Main Handler ───────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();
  const supabase = getServiceClient();

  try {
    // Authentication
    if (!authenticateRequest(req)) {
      return new Response(
        JSON.stringify({ success: false, error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const payload: FineractHookPayload = await req.json();
    const entity = (payload.entity || "").toUpperCase();

    // Log webhook event
    await supabase.from("webhook_events").insert({
      provider: "fineract",
      event_key: `${entity}.${payload.action}`,
      received_at: new Date().toISOString(),
      payload,
    });

    let result: { localId: string | null; action: string; entity: string };

    switch (entity) {
      case "CLIENT":
        result = await handleClient(supabase, payload);
        break;
      case "LOAN":
        result = await handleLoan(supabase, payload);
        break;
      case "LOAN_TRANSACTION":
      case "LOANTRANSACTION":
        result = await handleLoanTransaction(supabase, payload);
        break;
      default:
        result = { localId: null, action: payload.action || "unknown", entity };
        console.log(`Unhandled Fineract entity: ${entity}`);
    }

    const durationMs = Date.now() - startTime;
    recordMetric(supabase, FUNCTION_NAME, startTime, "success", req, {
      entity: result.entity,
      action: result.action,
      local_id: result.localId,
    });

    return new Response(
      JSON.stringify({
        success: true,
        entity: result.entity,
        action: result.action,
        local_id: result.localId,
        fineract_id: payload.resourceId,
        duration_ms: durationMs,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : String(err);
    console.error(`${FUNCTION_NAME} error:`, errorMessage);
    recordMetric(supabase, FUNCTION_NAME, startTime, "error", req, {}, errorMessage);

    return new Response(
      JSON.stringify({
        success: false,
        error: errorMessage,
        duration_ms: Date.now() - startTime,
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
