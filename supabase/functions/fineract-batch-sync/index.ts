/**
 * Fineract Batch Sync — Scheduled Full/Incremental Sync
 *
 * Pulls clients, loans, transactions, loan products, savings, staff,
 * and offices from Apache Fineract's REST API and syncs them into
 * the local Supabase database.
 *
 * Trigger methods:
 *   - Schedule (pg_cron or external cron)
 *   - Manual POST request
 *
 * Sync order (dependency-aware):
 *   1. Offices & Staff (organizational structure)
 *   2. Loan Products (catalog)
 *   3. Clients → borrowers + clients tables
 *   4. Loans → loans table + schedule
 *   5. Transactions → repayments table
 *   6. Savings Accounts → savings_accounts table
 *
 * Authentication: x-webhook-secret header or service role JWT
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import { createFineractClient } from "../_shared/fineract-api.ts";
import type {
  FineractClient,
  FineractLoan,
  FineractLoanTransaction,
  FineractSavingsAccount,
} from "../_shared/fineract-types.ts";
import {
  transformFineractClient,
  transformFineractToClient,
  transformFineractLoan,
  transformFineractTransaction,
  transformLoanProduct,
  transformSavingsAccount,
  transformOffice,
  transformStaff,
  transformSchedulePeriod,
  assessRisk,
  validateClient,
  validateLoan,
} from "../_shared/fineract-business-logic.ts";
import {
  authenticateWebhook,
  logAuthFailure,
  recordMetric,
} from "../_shared/webhook-helpers.ts";

const FUNCTION_NAME = "fineract-batch-sync";

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
    let syncTypes = ["offices", "staff", "loan_products", "clients", "loans", "transactions", "savings"];
    try {
      const body = await req.json();
      if (body.entity_types && Array.isArray(body.entity_types)) {
        syncTypes = body.entity_types;
      }
    } catch {
      // Empty body = full sync of all types
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

    // ── Create Fineract API client ─────────────────────────────────
    const api = createFineractClient();
    const now = new Date().toISOString();
    const allCounters: Record<string, SyncCounters> = {};

    // ── Create sync run ────────────────────────────────────────────
    const { data: syncRun } = await supabase
      .from("fineract_sync_runs")
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

    // ── 1. Sync Offices ────────────────────────────────────────────
    if (syncTypes.includes("offices")) {
      const counters = newCounters();
      try {
        const offices = await api.getOffices();
        counters.fetched = offices.length;
        for (const office of offices) {
          try {
            const fields = transformOffice(office);
            const { data: existing } = await supabase
              .from("fineract_offices").select("id").eq("fineract_id", office.id).limit(1).maybeSingle();
            if (existing) {
              await supabase.from("fineract_offices").update(fields).eq("id", existing.id);
              counters.updated++;
            } else {
              await supabase.from("fineract_offices").insert(fields);
              counters.created++;
            }
          } catch { counters.failed++; }
        }
      } catch (err) { console.error("Offices sync error:", err); }
      allCounters.offices = counters;
    }

    // ── 2. Sync Staff ──────────────────────────────────────────────
    if (syncTypes.includes("staff")) {
      const counters = newCounters();
      try {
        const staffList = await api.getStaff();
        counters.fetched = staffList.length;
        for (const s of staffList) {
          try {
            const fields = transformStaff(s);
            const { data: existing } = await supabase
              .from("fineract_staff").select("id").eq("fineract_id", s.id).limit(1).maybeSingle();
            if (existing) {
              await supabase.from("fineract_staff").update(fields).eq("id", existing.id);
              counters.updated++;
            } else {
              await supabase.from("fineract_staff").insert(fields);
              counters.created++;
            }
          } catch { counters.failed++; }
        }
      } catch (err) { console.error("Staff sync error:", err); }
      allCounters.staff = counters;
    }

    // ── 3. Sync Loan Products ──────────────────────────────────────
    if (syncTypes.includes("loan_products")) {
      const counters = newCounters();
      try {
        const products = await api.getLoanProducts();
        counters.fetched = products.length;
        for (const p of products) {
          try {
            const fields = transformLoanProduct(p);
            const { data: existing } = await supabase
              .from("loan_products").select("id").eq("fineract_id", p.id).limit(1).maybeSingle();
            if (existing) {
              await supabase.from("loan_products").update(fields).eq("id", existing.id);
              counters.updated++;
            } else {
              await supabase.from("loan_products").insert(fields);
              counters.created++;
            }
          } catch { counters.failed++; }
        }
      } catch (err) { console.error("Loan products sync error:", err); }
      allCounters.loan_products = counters;
    }

    // ── 4. Sync Clients ────────────────────────────────────────────
    if (syncTypes.includes("clients") && integration.sync_clients) {
      const counters = newCounters();
      try {
        const clients = await api.fetchAllClients();
        counters.fetched = clients.length;

        for (const c of clients) {
          try {
            const err = validateClient(c);
            if (err) { counters.skipped++; continue; }

            const externalRef = `FN-${c.id}`;

            // Raw staging
            await supabase.from("raw_fineract_clients").upsert(
              { fineract_id: c.id, office_id: c.officeId || null, payload: c, source: "backfill", fetched_at: now },
              { onConflict: "fineract_id" },
            );

            // Borrowers
            const borrowerFields = transformFineractClient(c);
            const { data: existingBorrower } = await supabase
              .from("borrowers").select("id").eq("fineract_id", c.id).limit(1).maybeSingle();
            if (existingBorrower) {
              await supabase.from("borrowers").update(borrowerFields).eq("id", existingBorrower.id);
            } else {
              await supabase.from("borrowers").insert(borrowerFields);
            }

            // Clients
            const clientFields = transformFineractToClient(c);
            const { data: existingClient } = await supabase
              .from("clients").select("id").eq("fineract_id", c.id).limit(1).maybeSingle();
            if (existingClient) {
              await supabase.from("clients").update(clientFields).eq("id", existingClient.id);
              counters.updated++;
            } else {
              await supabase.from("clients").insert(clientFields);
              counters.created++;
            }

            // Sync item
            if (syncRunId) {
              await supabase.from("fineract_sync_items").insert({
                sync_run_id: syncRunId,
                entity_type: "client",
                external_id: String(c.id),
                action: existingClient ? "updated" : "created",
                local_id: existingClient?.id || null,
                source_data: c as unknown as Record<string, unknown>,
                synced_at: now,
              });
            }
          } catch (err) {
            counters.failed++;
            console.error(`Client ${c.id} sync error:`, err);
          }
        }
      } catch (err) { console.error("Clients fetch error:", err); }
      allCounters.clients = counters;
    }

    // ── 5. Sync Loans ──────────────────────────────────────────────
    if (syncTypes.includes("loans") && integration.sync_loans) {
      const counters = newCounters();
      try {
        const loans = await api.fetchAllLoans();
        counters.fetched = loans.length;

        for (const l of loans) {
          try {
            const err = validateLoan(l);
            if (err) { counters.skipped++; continue; }

            // Raw staging
            await supabase.from("raw_fineract_loans").upsert(
              { fineract_id: l.id, client_fineract_id: l.clientId || null, payload: l, source: "backfill", fetched_at: now },
              { onConflict: "fineract_id" },
            );

            // Resolve local borrower
            let localBorrowerId: string | null = null;
            if (l.clientId) {
              const { data: borrower } = await supabase
                .from("borrowers").select("id").eq("fineract_id", l.clientId).limit(1).maybeSingle();
              localBorrowerId = borrower?.id || null;
            }

            if (!localBorrowerId) { counters.skipped++; continue; }

            // Upsert loan
            const loanFields = transformFineractLoan(l, localBorrowerId);

            // Link to loan product
            if (l.loanProductId) {
              const { data: product } = await supabase
                .from("loan_products").select("id").eq("fineract_id", l.loanProductId).limit(1).maybeSingle();
              if (product) {
                (loanFields as Record<string, unknown>).loan_product_id = product.id;
              }
            }

            const { data: existingLoan } = await supabase
              .from("loans").select("id").eq("fineract_id", l.id).limit(1).maybeSingle();

            let localLoanId: string | null = null;
            if (existingLoan) {
              await supabase.from("loans").update(loanFields).eq("id", existingLoan.id);
              localLoanId = existingLoan.id;
              counters.updated++;
            } else {
              const { data: newLoan } = await supabase.from("loans").insert(loanFields).select("id").single();
              localLoanId = newLoan?.id || null;
              counters.created++;
            }

            // Sync schedule (get full loan details)
            if (localLoanId) {
              try {
                const fullLoan = await api.getLoan(l.id);
                if (fullLoan.repaymentSchedule?.periods) {
                  await supabase.from("loan_schedule").delete().eq("loan_id", localLoanId);
                  const rows = fullLoan.repaymentSchedule.periods
                    .map((p) => transformSchedulePeriod(p, localLoanId!))
                    .filter(Boolean);
                  if (rows.length > 0) {
                    await supabase.from("loan_schedule").insert(rows);
                  }
                }

                // Sync transactions for this loan
                const transactions = (fullLoan as unknown as { transactions?: FineractLoanTransaction[] }).transactions || [];
                for (const txn of transactions) {
                  if (txn.manuallyReversed || txn.reversed) continue;
                  const txnType = txn.type?.code?.toLowerCase() || "";
                  if (!txnType.includes("repayment") && !txnType.includes("recovery")) continue;

                  try {
                    const repFields = transformFineractTransaction(txn, localLoanId!);
                    const { data: existingTxn } = await supabase
                      .from("repayments").select("id").eq("fineract_id", txn.id).limit(1).maybeSingle();
                    if (existingTxn) {
                      await supabase.from("repayments").update(repFields).eq("id", existingTxn.id);
                    } else {
                      await supabase.from("repayments").insert(repFields);
                    }

                    // Raw staging for transaction
                    await supabase.from("raw_fineract_transactions").upsert(
                      {
                        fineract_id: txn.id,
                        loan_fineract_id: l.id,
                        transaction_type: txn.type?.value || "unknown",
                        payload: txn,
                        source: "backfill",
                        fetched_at: now,
                      },
                      { onConflict: "fineract_id" },
                    );
                  } catch (txnErr) {
                    console.error(`Transaction ${txn.id} sync error:`, txnErr);
                  }
                }
              } catch (detailErr) {
                console.error(`Loan ${l.id} detail fetch error:`, detailErr);
              }
            }

            // Update client risk
            if (l.clientId) {
              const { data: clientRecord } = await supabase
                .from("clients").select("id, credit_score, risk_level").eq("fineract_id", l.clientId).limit(1).maybeSingle();
              if (clientRecord) {
                const { credit_score, risk_level } = assessRisk(
                  clientRecord.credit_score ?? 50,
                  clientRecord.risk_level ?? "Medium",
                  loanFields.days_overdue,
                  loanFields.status,
                  loanFields.is_npa,
                );
                if (credit_score !== clientRecord.credit_score || risk_level !== clientRecord.risk_level) {
                  await supabase.from("clients").update({ credit_score, risk_level, updated_at: now }).eq("id", clientRecord.id);
                }
              }
            }

            if (syncRunId) {
              await supabase.from("fineract_sync_items").insert({
                sync_run_id: syncRunId,
                entity_type: "loan",
                external_id: String(l.id),
                action: existingLoan ? "updated" : "created",
                local_id: localLoanId,
                source_data: l as unknown as Record<string, unknown>,
                synced_at: now,
              });
            }
          } catch (err) {
            counters.failed++;
            console.error(`Loan ${l.id} sync error:`, err);
          }
        }
      } catch (err) { console.error("Loans fetch error:", err); }
      allCounters.loans = counters;
    }

    // ── 6. Sync Savings Accounts ───────────────────────────────────
    if (syncTypes.includes("savings") && integration.sync_savings) {
      const counters = newCounters();
      try {
        const accounts = await api.fetchAllSavingsAccounts();
        counters.fetched = accounts.length;

        for (const s of accounts) {
          try {
            // Resolve local client & borrower
            let localClientId: string | null = null;
            let localBorrowerId: string | null = null;
            if (s.clientId) {
              const { data: client } = await supabase
                .from("clients").select("id").eq("fineract_id", s.clientId).limit(1).maybeSingle();
              localClientId = client?.id || null;
              const { data: borrower } = await supabase
                .from("borrowers").select("id").eq("fineract_id", s.clientId).limit(1).maybeSingle();
              localBorrowerId = borrower?.id || null;
            }

            const fields = transformSavingsAccount(s, localClientId, localBorrowerId);

            // Raw staging
            await supabase.from("raw_fineract_savings").upsert(
              { fineract_id: s.id, client_fineract_id: s.clientId || null, payload: s, source: "backfill", fetched_at: now },
              { onConflict: "fineract_id" },
            );

            const { data: existing } = await supabase
              .from("savings_accounts").select("id").eq("fineract_id", s.id).limit(1).maybeSingle();
            if (existing) {
              await supabase.from("savings_accounts").update(fields).eq("id", existing.id);
              counters.updated++;
            } else {
              await supabase.from("savings_accounts").insert(fields);
              counters.created++;
            }

            // Link to client
            if (localClientId && s.id) {
              await supabase.from("clients").update({ savings_account_id: existing?.id || null }).eq("id", localClientId);
            }
          } catch { counters.failed++; }
        }
      } catch (err) { console.error("Savings fetch error:", err); }
      allCounters.savings = counters;
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
        .from("fineract_sync_runs")
        .update({
          completed_at: new Date().toISOString(),
          status: finalStatus,
          records_fetched: totals.fetched,
          records_created: totals.created,
          records_updated: totals.updated,
          records_skipped: totals.skipped,
          records_failed: totals.failed,
          entity_types: Object.keys(allCounters),
        })
        .eq("id", syncRunId);
    }

    // Update integration last_sync_at
    await supabase
      .from("fineract_integrations")
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
        entity_types: Object.keys(allCounters),
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
