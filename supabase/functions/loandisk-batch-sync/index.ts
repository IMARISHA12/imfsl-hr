/**
 * Loandisk Batch Sync — Scheduled Full/Incremental Sync
 *
 * Pulls borrowers, loans, and repayments from the LoanDisk REST API
 * and syncs them into the local database. Can be triggered:
 *   - On a schedule (via pg_cron or external cron)
 *   - Manually via POST request
 *
 * Supports incremental sync using the last sync timestamp stored
 * in loandisk_integrations.last_sync_at.
 *
 * Pipeline per entity:
 *   1. Fetch from LoanDisk API (paginated)
 *   2. Upsert into raw_* staging table
 *   3. Transform & upsert into canonical table
 *   4. Record sync lineage
 *
 * Authentication: x-webhook-secret header (same secret as webhooks)
 * or service role JWT
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import { createLoandiskClient } from "../_shared/loandisk-api.ts";
import type { LoandiskBorrower, LoandiskLoan, LoandiskRepayment } from "../_shared/loandisk-types.ts";
import {
  authenticateWebhook,
  logAuthFailure,
  recordMetric,
} from "../_shared/webhook-helpers.ts";
import {
  transformBorrower,
  transformClient,
  buildFullName,
  resolvePhone,
  transformLoan,
  transformRepayment,
  validateBorrower,
  validateLoan,
  validateRepayment,
  assessRisk,
} from "../_shared/business-logic.ts";

const FUNCTION_NAME = "loandisk-batch-sync";

interface SyncCounters {
  fetched: number;
  created: number;
  updated: number;
  skipped: number;
  failed: number;
}

function newCounters(): SyncCounters {
  return { fetched: 0, created: 0, updated: 0, skipped: 0, failed: 0 };
}

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
    let syncTypes = ["borrowers", "loans", "repayments"];
    let forceFullSync = false;

    try {
      const body = await req.json();
      if (body.entity_types && Array.isArray(body.entity_types)) {
        syncTypes = body.entity_types;
      }
      if (body.full_sync === true) forceFullSync = true;
    } catch {
      // Empty body = full sync of all types
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

    const modifiedSince =
      forceFullSync || !integration.last_sync_at
        ? undefined
        : integration.last_sync_at;

    // ── Create LoanDisk API client ─────────────────────────────────
    const api = createLoandiskClient();
    const now = new Date().toISOString();
    const entityTypes: string[] = [];
    const allCounters: Record<string, SyncCounters> = {};

    // ── Create sync run ────────────────────────────────────────────
    const { data: syncRun } = await supabase
      .from("loandisk_sync_runs")
      .insert({
        integration_id: integration.id,
        run_type: "scheduled",
        started_at: now,
        status: "running",
        entity_types: syncTypes,
        records_fetched: 0,
        records_created: 0,
        records_updated: 0,
        records_skipped: 0,
        records_failed: 0,
      })
      .select("id")
      .single();

    const syncRunId = syncRun?.id;

    // ── Sync Borrowers ─────────────────────────────────────────────
    if (syncTypes.includes("borrowers") && integration.sync_customers) {
      entityTypes.push("borrower");
      const counters = newCounters();

      try {
        const borrowers = await api.fetchAll("borrowers", modifiedSince);
        counters.fetched = borrowers.length;

        for (const raw of borrowers) {
          try {
            const b = raw as unknown as LoandiskBorrower;
            const loandiskId = Number(b.borrower_id ?? b.id);
            if (!Number.isFinite(loandiskId)) {
              counters.skipped++;
              continue;
            }

            const branchId = Number(b.branch_id) || 1;
            const externalRef = `LD-${loandiskId}`;

            // Upsert raw_borrowers
            await supabase
              .from("raw_borrowers")
              .upsert(
                {
                  loandisk_id: loandiskId,
                  branch_id: branchId,
                  payload: raw,
                  source: "backfill",
                  fetched_at: now,
                },
                { onConflict: "loandisk_id,branch_id" },
              );

            // Upsert borrowers table
            const borrowerFields = { ...transformBorrower(b), external_reference_id: externalRef };
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
            const clientFields = transformClient(b, externalRef);
            const { data: existingClient } = await supabase
              .from("clients")
              .select("id")
              .eq("external_reference_id", externalRef)
              .limit(1)
              .maybeSingle();

            if (existingClient) {
              await supabase.from("clients").update(clientFields).eq("id", existingClient.id);
              counters.updated++;
            } else {
              await supabase.from("clients").insert(clientFields);
              counters.created++;
            }

            // Record sync item
            if (syncRunId) {
              await supabase.from("loandisk_sync_items").insert({
                sync_run_id: syncRunId,
                entity_type: "borrower",
                external_id: String(loandiskId),
                action: existingClient ? "updated" : "created",
                local_id: existingClient?.id || null,
                source_data: raw,
                synced_at: now,
              });
            }
          } catch (err) {
            counters.failed++;
            console.error("Borrower sync error:", err);
          }
        }
      } catch (err) {
        console.error("Borrowers fetch error:", err);
      }

      allCounters.borrowers = counters;
    }

    // ── Sync Loans ─────────────────────────────────────────────────
    if (syncTypes.includes("loans") && integration.sync_loans) {
      entityTypes.push("loan");
      const counters = newCounters();

      try {
        const loans = await api.fetchAll("loans", modifiedSince);
        counters.fetched = loans.length;

        for (const raw of loans) {
          try {
            const l = raw as unknown as LoandiskLoan;
            const loandiskId = Number(l.loan_id ?? l.id);
            if (!Number.isFinite(loandiskId)) {
              counters.skipped++;
              continue;
            }

            const branchId = Number(l.branch_id) || 1;
            const borrowerLoandiskId = Number(l.borrower_id);

            // Upsert raw_loans
            await supabase
              .from("raw_loans")
              .upsert(
                {
                  loandisk_id: loandiskId,
                  branch_id: branchId,
                  borrower_loandisk_id: Number.isFinite(borrowerLoandiskId) ? borrowerLoandiskId : null,
                  payload: raw,
                  source: "backfill",
                  fetched_at: now,
                },
                { onConflict: "loandisk_id,branch_id" },
              );

            // Resolve local borrower
            let localBorrowerId: string | null = null;
            if (Number.isFinite(borrowerLoandiskId)) {
              const borrowerRef = `LD-${borrowerLoandiskId}`;
              const { data: client } = await supabase
                .from("clients")
                .select("phone_number")
                .eq("external_reference_id", borrowerRef)
                .limit(1)
                .maybeSingle();

              if (client?.phone_number) {
                const { data: borrower } = await supabase
                  .from("borrowers")
                  .select("id")
                  .eq("phone_number", client.phone_number)
                  .limit(1)
                  .maybeSingle();
                localBorrowerId = borrower?.id || null;
              }
            }

            if (!localBorrowerId) {
              counters.skipped++;
              continue;
            }

            // Upsert loan
            const loanFields = transformLoan(l, localBorrowerId);
            const loanNumber = l.loan_number || `LD-${loandiskId}`;
            const { data: existingLoan } = await supabase
              .from("loans")
              .select("id")
              .eq("loan_number", loanNumber)
              .limit(1)
              .maybeSingle();

            if (existingLoan) {
              await supabase.from("loans").update({ ...loanFields, loan_number: loanNumber }).eq("id", existingLoan.id);
              counters.updated++;
            } else {
              await supabase.from("loans").insert({ ...loanFields, loan_number: loanNumber });
              counters.created++;
            }

            if (syncRunId) {
              await supabase.from("loandisk_sync_items").insert({
                sync_run_id: syncRunId,
                entity_type: "loan",
                external_id: String(loandiskId),
                action: existingLoan ? "updated" : "created",
                local_id: existingLoan?.id || null,
                source_data: raw,
                synced_at: now,
              });
            }
          } catch (err) {
            counters.failed++;
            console.error("Loan sync error:", err);
          }
        }
      } catch (err) {
        console.error("Loans fetch error:", err);
      }

      allCounters.loans = counters;
    }

    // ── Sync Repayments ────────────────────────────────────────────
    if (syncTypes.includes("repayments") && integration.sync_repayments) {
      entityTypes.push("repayment");
      const counters = newCounters();

      try {
        const repayments = await api.fetchAll("repayments", modifiedSince);
        counters.fetched = repayments.length;

        for (const raw of repayments) {
          try {
            const r = raw as unknown as LoandiskRepayment;
            const loandiskId = Number(r.repayment_id ?? r.id);
            if (!Number.isFinite(loandiskId)) {
              counters.skipped++;
              continue;
            }

            const branchId = Number(r.branch_id) || 1;
            const loanLoandiskId = Number(r.loan_id);

            // Upsert raw_repayments
            await supabase
              .from("raw_repayments")
              .upsert(
                {
                  loandisk_id: loandiskId,
                  branch_id: branchId,
                  loan_loandisk_id: Number.isFinite(loanLoandiskId) ? loanLoandiskId : null,
                  payload: raw,
                  source: "backfill",
                  fetched_at: now,
                },
                { onConflict: "loandisk_id,branch_id" },
              );

            // Resolve local loan
            let localLoanId: string | null = null;
            if (Number.isFinite(loanLoandiskId)) {
              const loanRef = `LD-${loanLoandiskId}`;
              const { data: loan } = await supabase
                .from("loans")
                .select("id")
                .eq("loan_number", loanRef)
                .limit(1)
                .maybeSingle();
              localLoanId = loan?.id || null;
            }

            if (!localLoanId) {
              counters.skipped++;
              continue;
            }

            // Insert/update repayment
            const repaymentFields = transformRepayment(r, localLoanId);
            let existingRepayment = null;
            if (repaymentFields.receipt_ref) {
              const { data } = await supabase
                .from("repayments")
                .select("id")
                .eq("receipt_ref", repaymentFields.receipt_ref)
                .limit(1)
                .maybeSingle();
              existingRepayment = data;
            }

            if (existingRepayment) {
              await supabase.from("repayments").update(repaymentFields).eq("id", existingRepayment.id);
              counters.updated++;
            } else {
              await supabase.from("repayments").insert(repaymentFields);
              counters.created++;
            }

            if (syncRunId) {
              await supabase.from("loandisk_sync_items").insert({
                sync_run_id: syncRunId,
                entity_type: "repayment",
                external_id: String(loandiskId),
                action: existingRepayment ? "updated" : "created",
                source_data: raw,
                synced_at: now,
              });
            }
          } catch (err) {
            counters.failed++;
            console.error("Repayment sync error:", err);
          }
        }
      } catch (err) {
        console.error("Repayments fetch error:", err);
      }

      allCounters.repayments = counters;
    }

    // ── Finalize sync run ──────────────────────────────────────────
    const totals = Object.values(allCounters).reduce(
      (acc, c) => ({
        fetched: acc.fetched + c.fetched,
        created: acc.created + c.created,
        updated: acc.updated + c.updated,
        skipped: acc.skipped + c.skipped,
        failed: acc.failed + c.failed,
      }),
      newCounters(),
    );

    const finalStatus = totals.failed > 0 ? "partial" : "completed";

    if (syncRunId) {
      await supabase
        .from("loandisk_sync_runs")
        .update({
          completed_at: new Date().toISOString(),
          status: finalStatus,
          records_fetched: totals.fetched,
          records_created: totals.created,
          records_updated: totals.updated,
          records_skipped: totals.skipped,
          records_failed: totals.failed,
          entity_types: entityTypes,
        })
        .eq("id", syncRunId);
    }

    // Update integration last_sync_at
    await supabase
      .from("loandisk_integrations")
      .update({
        last_sync_at: new Date().toISOString(),
        last_sync_status: finalStatus,
        updated_at: new Date().toISOString(),
      })
      .eq("id", integration.id);

    const durationMs = Date.now() - startTime;
    recordMetric(supabase, FUNCTION_NAME, startTime, "success", req, {
      sync_run_id: syncRunId,
      ...totals,
    });

    return new Response(
      JSON.stringify({
        success: true,
        sync_run_id: syncRunId,
        status: finalStatus,
        entity_types: entityTypes,
        totals,
        details: allCounters,
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
