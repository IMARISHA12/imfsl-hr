/**
 * HR Payroll Processor — Edge Function
 *
 * Operations:
 *   - generate:    Generate payslips for a payroll run (calls rpc_generate_payslips)
 *   - approve:     Approve a payroll run (calls rpc_approve_payroll)
 *   - bank_export: Generate bank payment file (calls rpc_payroll_bank_export)
 *   - create_run:  Create a new payroll run record
 *   - mark_paid:   Mark payslips as paid after bank transfer
 *
 * Authentication: service role JWT or authorized user
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";

const FUNCTION_NAME = "hr-payroll-processor";

interface PayrollRequest {
  operation: string;
  payroll_run_id?: string;
  month?: number;
  year?: number;
  approved_by?: string;
  payment_references?: Record<string, string>; // employee_id → payment_ref
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();

  try {
    const body: PayrollRequest = await req.json();
    const { operation } = body;

    if (!operation) {
      return jsonResponse({ error: "Missing 'operation' field" }, 400);
    }

    const supabase = getServiceClient();

    switch (operation) {
      case "create_run": {
        const month = body.month ?? new Date().getMonth() + 1;
        const year = body.year ?? new Date().getFullYear();
        const monthNames = [
          "January", "February", "March", "April", "May", "June",
          "July", "August", "September", "October", "November", "December",
        ];

        const { data, error } = await supabase
          .from("payroll_runs")
          .insert({
            run_period_month: month,
            run_period_year: year,
            month: `${monthNames[month - 1]} ${year}`,
            status: "draft",
            run_date: new Date().toISOString().split("T")[0],
            prepared_by: body.approved_by ?? "system",
          })
          .select("id")
          .single();

        if (error) throw error;

        return jsonResponse({
          success: true,
          payroll_run_id: data.id,
          period: `${monthNames[month - 1]} ${year}`,
          status: "draft",
          duration_ms: Date.now() - startTime,
        });
      }

      case "generate": {
        if (!body.payroll_run_id) {
          return jsonResponse({ error: "Missing payroll_run_id" }, 400);
        }

        // Get payroll run details for month/year
        const { data: run, error: runError } = await supabase
          .from("payroll_runs")
          .select("run_period_month, run_period_year")
          .eq("id", body.payroll_run_id)
          .single();

        if (runError || !run) {
          return jsonResponse({ error: "Payroll run not found" }, 404);
        }

        const { data, error } = await supabase.rpc("rpc_generate_payslips", {
          p_payroll_run_id: body.payroll_run_id,
          p_month: run.run_period_month,
          p_year: run.run_period_year,
        });

        if (error) throw error;

        return jsonResponse({
          ...data,
          duration_ms: Date.now() - startTime,
        });
      }

      case "approve": {
        if (!body.payroll_run_id) {
          return jsonResponse({ error: "Missing payroll_run_id" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_approve_payroll", {
          p_payroll_run_id: body.payroll_run_id,
          p_approved_by: body.approved_by ?? "system",
        });

        if (error) throw error;

        return jsonResponse({
          ...data,
          duration_ms: Date.now() - startTime,
        });
      }

      case "bank_export": {
        if (!body.payroll_run_id) {
          return jsonResponse({ error: "Missing payroll_run_id" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_payroll_bank_export", {
          p_payroll_run_id: body.payroll_run_id,
        });

        if (error) throw error;

        return jsonResponse({
          ...data,
          duration_ms: Date.now() - startTime,
        });
      }

      case "mark_paid": {
        if (!body.payroll_run_id) {
          return jsonResponse({ error: "Missing payroll_run_id" }, 400);
        }

        // Update all payslips to paid
        const { error: payslipError } = await supabase
          .from("payslips")
          .update({
            payment_status: "paid",
            paid_at: new Date().toISOString(),
          })
          .eq("payroll_run_id", body.payroll_run_id)
          .eq("payment_status", "pending");

        if (payslipError) throw payslipError;

        // Update individual payment references if provided
        if (body.payment_references) {
          for (const [employeeId, ref] of Object.entries(body.payment_references)) {
            await supabase
              .from("payslips")
              .update({ payment_reference: ref })
              .eq("payroll_run_id", body.payroll_run_id)
              .eq("employee_id", employeeId);
          }
        }

        // Update payroll run status
        const { error: runError } = await supabase
          .from("payroll_runs")
          .update({ status: "paid" })
          .eq("id", body.payroll_run_id);

        if (runError) throw runError;

        // Update staff salary loans (deduct monthly payments)
        const { data: payslips } = await supabase
          .from("payslips")
          .select("employee_id, loan_deduction")
          .eq("payroll_run_id", body.payroll_run_id)
          .gt("loan_deduction", 0);

        if (payslips) {
          for (const ps of payslips) {
            const { data: loans } = await supabase
              .from("staff_salary_loans")
              .select("id, outstanding_balance, monthly_deduction")
              .eq("employee_id", ps.employee_id)
              .eq("status", "active");

            if (loans) {
              for (const loan of loans) {
                const newBalance = Math.max(0, loan.outstanding_balance - loan.monthly_deduction);
                await supabase
                  .from("staff_salary_loans")
                  .update({
                    outstanding_balance: newBalance,
                    status: newBalance <= 0 ? "completed" : "active",
                    updated_at: new Date().toISOString(),
                  })
                  .eq("id", loan.id);
              }
            }
          }
        }

        return jsonResponse({
          success: true,
          payroll_run_id: body.payroll_run_id,
          status: "paid",
          duration_ms: Date.now() - startTime,
        });
      }

      default:
        return jsonResponse(
          { error: `Unknown operation: ${operation}. Valid: create_run, generate, approve, bank_export, mark_paid` },
          400
        );
    }
  } catch (err) {
    console.error(`[${FUNCTION_NAME}] Error:`, err);
    return jsonResponse(
      { error: err instanceof Error ? err.message : "Internal server error" },
      500
    );
  }
});

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
