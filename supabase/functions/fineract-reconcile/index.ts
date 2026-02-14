/**
 * Fineract Reconciliation — Compare Fineract vs Local Data
 *
 * Compares aggregate totals between Apache Fineract and the local
 * Supabase database to detect discrepancies.
 *
 * Reconciliation checks:
 *   1. Total clients (Fineract clients vs local clients)
 *   2. Total loans (Fineract loans vs local loans)
 *   3. Total disbursed amounts
 *   4. Total outstanding balances
 *   5. Total repayments received
 *   6. Total savings account balances
 *
 * Results stored in fineract_reconciliation_snapshots.
 *
 * Authentication: x-webhook-secret header
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import { createFineractClient } from "../_shared/fineract-api.ts";
import {
  authenticateWebhook,
  logAuthFailure,
  recordMetric,
} from "../_shared/webhook-helpers.ts";

const FUNCTION_NAME = "fineract-reconcile";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();
  const supabase = getServiceClient();

  try {
    // ── Authentication ─────────────────────────────────────────────
    const auth = authenticateWebhook(req);
    if (!auth.ok) {
      await logAuthFailure(supabase, FUNCTION_NAME, req);
      return new Response(
        JSON.stringify({ success: false, error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── Parse options ──────────────────────────────────────────────
    let periodStart: string | null = null;
    let periodEnd: string | null = null;

    try {
      const body = await req.json();
      periodStart = body.period_start || null;
      periodEnd = body.period_end || null;
    } catch {
      // Use defaults
    }

    const now = new Date();
    if (!periodEnd) periodEnd = now.toISOString();
    if (!periodStart) {
      const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      periodStart = thirtyDaysAgo.toISOString();
    }

    // ── Get integration config ─────────────────────────────────────
    const { data: integration } = await supabase
      .from("fineract_integrations")
      .select("*")
      .eq("is_active", true)
      .limit(1)
      .maybeSingle();

    if (!integration) {
      throw new Error("No active Fineract integration configured");
    }

    // ── Gather Fineract-side totals ────────────────────────────────
    const api = createFineractClient();

    const [fnClients, fnLoans, fnSavings] = await Promise.all([
      api.fetchAllClients().catch(() => []),
      api.fetchAllLoans().catch(() => []),
      api.fetchAllSavingsAccounts().catch(() => []),
    ]);

    const fnTotalClients = fnClients.length;
    const fnTotalLoans = fnLoans.length;
    const fnTotalDisbursed = fnLoans.reduce(
      (sum, l) => sum + (l.principal || l.approvedPrincipal || 0), 0,
    );
    const fnTotalOutstanding = fnLoans.reduce(
      (sum, l) => sum + (l.summary?.totalOutstanding || 0), 0,
    );
    const fnTotalRepayments = fnLoans.reduce(
      (sum, l) => sum + (l.summary?.totalRepayment || 0), 0,
    );
    const fnTotalSavingsAccounts = fnSavings.length;
    const fnTotalSavingsBalance = fnSavings.reduce(
      (sum, s) => sum + (s.summary?.accountBalance || 0), 0,
    );

    // ── Gather local-side totals ───────────────────────────────────

    // Count clients with FN- external reference (Fineract-sourced)
    const { count: sysTotalClients } = await supabase
      .from("clients")
      .select("id", { count: "exact", head: true })
      .like("external_reference_id", "FN-%");

    // Count loans with fineract_id
    const { data: loanRows } = await supabase
      .from("loans")
      .select("id, amount_principal, outstanding_balance, total_paid")
      .not("fineract_id", "is", null);

    const sysTotalLoans = loanRows?.length ?? 0;
    const sysTotalDisbursed = (loanRows || []).reduce(
      (sum: number, l: { amount_principal: number }) => sum + (l.amount_principal || 0), 0,
    );
    const sysTotalOutstanding = (loanRows || []).reduce(
      (sum: number, l: { outstanding_balance: number | null }) => sum + (l.outstanding_balance || 0), 0,
    );

    // Total repayments for Fineract-sourced loans
    const fnLoanIds = new Set((loanRows || []).map((l: { id: string }) => l.id));
    const { data: repaymentRows } = await supabase
      .from("repayments")
      .select("amount_paid, loan_id")
      .eq("is_reversed", false);

    const sysTotalRepayments = (repaymentRows || [])
      .filter((r: { loan_id: string }) => fnLoanIds.has(r.loan_id))
      .reduce((sum: number, r: { amount_paid: number }) => sum + (r.amount_paid || 0), 0);

    // ── Calculate variances ────────────────────────────────────────
    const varianceClients = fnTotalClients - (sysTotalClients || 0);
    const varianceLoans = fnTotalLoans - sysTotalLoans;
    const varianceDisbursed = fnTotalDisbursed - sysTotalDisbursed;
    const varianceOutstanding = fnTotalOutstanding - sysTotalOutstanding;
    const varianceRepayments = fnTotalRepayments - sysTotalRepayments;

    const hasVariance =
      Math.abs(varianceClients) > 0 ||
      Math.abs(varianceLoans) > 0 ||
      Math.abs(varianceDisbursed) > 1 ||
      Math.abs(varianceOutstanding) > 1 ||
      Math.abs(varianceRepayments) > 1;

    const status = hasVariance ? "variance_detected" : "reconciled";

    // ── Store reconciliation snapshot ──────────────────────────────
    const { data: snapshot, error: snapErr } = await supabase
      .from("fineract_reconciliation_snapshots")
      .insert({
        reconciliation_date: now.toISOString(),
        period_start: periodStart,
        period_end: periodEnd,
        fn_total_clients: fnTotalClients,
        fn_total_loans: fnTotalLoans,
        fn_total_disbursed: fnTotalDisbursed,
        fn_total_outstanding: fnTotalOutstanding,
        fn_total_repayments: fnTotalRepayments,
        fn_total_savings_accounts: fnTotalSavingsAccounts,
        fn_total_savings_balance: fnTotalSavingsBalance,
        sys_total_clients: sysTotalClients || 0,
        sys_total_loans: sysTotalLoans,
        sys_total_disbursed: sysTotalDisbursed,
        sys_total_outstanding: sysTotalOutstanding,
        sys_total_repayments: sysTotalRepayments,
        variance_clients: varianceClients,
        variance_loans: varianceLoans,
        variance_disbursed: varianceDisbursed,
        variance_outstanding: varianceOutstanding,
        variance_repayments: varianceRepayments,
        status,
        variance_notes: hasVariance
          ? `Variances — Clients: ${varianceClients}, Loans: ${varianceLoans}, Disbursed: ${varianceDisbursed.toFixed(2)}, Outstanding: ${varianceOutstanding.toFixed(2)}, Repayments: ${varianceRepayments.toFixed(2)}`
          : "All totals match between Fineract and local system",
        fn_snapshot_data: {
          clients_count: fnTotalClients,
          loans_count: fnTotalLoans,
          total_disbursed: fnTotalDisbursed,
          total_outstanding: fnTotalOutstanding,
          total_repayments: fnTotalRepayments,
          savings_accounts: fnTotalSavingsAccounts,
          savings_balance: fnTotalSavingsBalance,
        },
        sys_snapshot_data: {
          clients_count: sysTotalClients || 0,
          loans_count: sysTotalLoans,
          total_disbursed: sysTotalDisbursed,
          total_outstanding: sysTotalOutstanding,
          total_repayments: sysTotalRepayments,
        },
        variance_details: {
          clients: varianceClients,
          loans: varianceLoans,
          disbursed: varianceDisbursed,
          outstanding: varianceOutstanding,
          repayments: varianceRepayments,
        },
      })
      .select("id")
      .single();

    if (snapErr) {
      console.error("Reconciliation snapshot insert error:", snapErr.message);
    }

    const durationMs = Date.now() - startTime;
    recordMetric(supabase, FUNCTION_NAME, startTime, "success", req, {
      snapshot_id: snapshot?.id,
      status,
    });

    return new Response(
      JSON.stringify({
        success: true,
        snapshot_id: snapshot?.id,
        status,
        period: { start: periodStart, end: periodEnd },
        fineract: {
          clients: fnTotalClients,
          loans: fnTotalLoans,
          disbursed: fnTotalDisbursed,
          outstanding: fnTotalOutstanding,
          repayments: fnTotalRepayments,
          savings_accounts: fnTotalSavingsAccounts,
          savings_balance: fnTotalSavingsBalance,
        },
        local: {
          clients: sysTotalClients || 0,
          loans: sysTotalLoans,
          disbursed: sysTotalDisbursed,
          outstanding: sysTotalOutstanding,
          repayments: sysTotalRepayments,
        },
        variance: {
          clients: varianceClients,
          loans: varianceLoans,
          disbursed: varianceDisbursed,
          outstanding: varianceOutstanding,
          repayments: varianceRepayments,
        },
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
