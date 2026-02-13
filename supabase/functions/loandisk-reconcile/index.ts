/**
 * Loandisk Reconciliation — Compare LoanDisk vs Local Data
 *
 * Compares aggregate totals between LoanDisk and the local database
 * to detect discrepancies. Creates reconciliation snapshots for audit.
 *
 * Reconciliation checks:
 *   1. Total customers (LoanDisk borrowers vs local clients)
 *   2. Total loans (LoanDisk loans vs local loans)
 *   3. Total disbursed amounts
 *   4. Total outstanding balances
 *   5. Total repayments received
 *
 * Results are stored in loandisk_reconciliation_snapshots with
 * variance calculations and status (reconciled / variance_detected).
 *
 * Authentication: x-webhook-secret header
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import { createLoandiskClient } from "../_shared/loandisk-api.ts";
import {
  authenticateWebhook,
  logAuthFailure,
  recordMetric,
} from "../_shared/webhook-helpers.ts";

const FUNCTION_NAME = "loandisk-reconcile";

// ─── Main Handler ────────────────────────────────────────────────────

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
      .from("loandisk_integrations")
      .select("*")
      .eq("is_active", true)
      .limit(1)
      .maybeSingle();

    if (!integration) {
      throw new Error("No active LoanDisk integration configured");
    }

    // ── Gather LoanDisk-side totals ────────────────────────────────
    const api = createLoandiskClient();

    const [ldBorrowers, ldLoans, ldRepayments] = await Promise.all([
      api.fetchAll("borrowers").catch(() => []),
      api.fetchAll("loans").catch(() => []),
      api.fetchAll("repayments").catch(() => []),
    ]);

    const ldTotalCustomers = ldBorrowers.length;
    const ldTotalLoans = ldLoans.length;
    const ldTotalDisbursed = ldLoans.reduce(
      (sum, l) => sum + (Number(l.principal_amount || l.amount || 0) || 0),
      0,
    );
    const ldTotalOutstanding = ldLoans.reduce(
      (sum, l) => sum + (Number(l.outstanding_balance || l.balance || 0) || 0),
      0,
    );
    const ldTotalRepayments = ldRepayments.reduce(
      (sum, r) => sum + (Number(r.amount_paid || r.amount || r.payment_amount || 0) || 0),
      0,
    );

    // ── Gather local-side totals ───────────────────────────────────

    // Count clients with LD- external reference (LoanDisk-sourced)
    const { data: clientCount } = await supabase
      .from("clients")
      .select("id", { count: "exact", head: true })
      .like("external_reference_id", "LD-%");
    const sysTotalCustomers = (clientCount as unknown as { count: number })?.count ?? 0;

    // Count loans with LD- loan numbers
    const { data: loanRows } = await supabase
      .from("loans")
      .select("amount_principal, outstanding_balance")
      .like("loan_number", "LD-%");
    const sysTotalLoans = loanRows?.length ?? 0;
    const sysTotalDisbursed = (loanRows || []).reduce(
      (sum: number, l: { amount_principal: number }) => sum + (l.amount_principal || 0),
      0,
    );
    const sysTotalOutstanding = (loanRows || []).reduce(
      (sum: number, l: { outstanding_balance: number | null }) => sum + (l.outstanding_balance || 0),
      0,
    );

    // Sum repayments for LD-sourced loans
    const { data: repaymentRows } = await supabase
      .from("repayments")
      .select("amount_paid, loan_id");
    // Filter repayments to only LD-sourced loans
    const ldLoanIds = new Set((loanRows || []).map((l: { id?: string }) => l?.id).filter(Boolean));
    const sysTotalRepayments = (repaymentRows || [])
      .filter((r: { loan_id: string }) => ldLoanIds.has(r.loan_id))
      .reduce((sum: number, r: { amount_paid: number }) => sum + (r.amount_paid || 0), 0);

    // ── Calculate variances ────────────────────────────────────────
    const varianceCustomers = ldTotalCustomers - sysTotalCustomers;
    const varianceLoans = ldTotalLoans - sysTotalLoans;
    const varianceDisbursed = ldTotalDisbursed - sysTotalDisbursed;
    const varianceOutstanding = ldTotalOutstanding - sysTotalOutstanding;
    const varianceRepayments = ldTotalRepayments - sysTotalRepayments;

    const hasVariance =
      Math.abs(varianceCustomers) > 0 ||
      Math.abs(varianceLoans) > 0 ||
      Math.abs(varianceDisbursed) > 1 ||
      Math.abs(varianceOutstanding) > 1 ||
      Math.abs(varianceRepayments) > 1;

    const status = hasVariance ? "variance_detected" : "reconciled";

    // ── Store reconciliation snapshot ──────────────────────────────
    const { data: snapshot, error: snapErr } = await supabase
      .from("loandisk_reconciliation_snapshots")
      .insert({
        reconciliation_date: now.toISOString(),
        period_start: periodStart,
        period_end: periodEnd,
        ld_total_customers: ldTotalCustomers,
        ld_total_loans: ldTotalLoans,
        ld_total_disbursed: ldTotalDisbursed,
        ld_total_outstanding: ldTotalOutstanding,
        ld_total_repayments: ldTotalRepayments,
        sys_total_customers: sysTotalCustomers,
        sys_total_loans: sysTotalLoans,
        sys_total_disbursed: sysTotalDisbursed,
        sys_total_outstanding: sysTotalOutstanding,
        sys_total_repayments: sysTotalRepayments,
        variance_loans: varianceLoans,
        variance_disbursed: varianceDisbursed,
        variance_outstanding: varianceOutstanding,
        variance_repayments: varianceRepayments,
        status,
        variance_notes: hasVariance
          ? `Detected variances — Customers: ${varianceCustomers}, Loans: ${varianceLoans}, Disbursed: ${varianceDisbursed.toFixed(2)}, Outstanding: ${varianceOutstanding.toFixed(2)}, Repayments: ${varianceRepayments.toFixed(2)}`
          : "All totals match between LoanDisk and local system",
        ld_snapshot_data: {
          borrowers_count: ldTotalCustomers,
          loans_count: ldTotalLoans,
          total_disbursed: ldTotalDisbursed,
          total_outstanding: ldTotalOutstanding,
          total_repayments: ldTotalRepayments,
        },
        sys_snapshot_data: {
          clients_count: sysTotalCustomers,
          loans_count: sysTotalLoans,
          total_disbursed: sysTotalDisbursed,
          total_outstanding: sysTotalOutstanding,
          total_repayments: sysTotalRepayments,
        },
        variance_details: {
          customers: varianceCustomers,
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
        loandisk: {
          customers: ldTotalCustomers,
          loans: ldTotalLoans,
          disbursed: ldTotalDisbursed,
          outstanding: ldTotalOutstanding,
          repayments: ldTotalRepayments,
        },
        local: {
          customers: sysTotalCustomers,
          loans: sysTotalLoans,
          disbursed: sysTotalDisbursed,
          outstanding: sysTotalOutstanding,
          repayments: sysTotalRepayments,
        },
        variance: {
          customers: varianceCustomers,
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
