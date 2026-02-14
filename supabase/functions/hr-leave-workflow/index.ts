/**
 * HR Leave Workflow — Edge Function
 *
 * Operations:
 *   - submit:      Submit a new leave request (validates & creates)
 *   - approve:     Approve a pending leave request
 *   - reject:      Reject a pending leave request
 *   - cancel:      Cancel a pending/approved leave request
 *   - balance:     Get leave balance for a user
 *   - init_year:   Initialize annual leave balances for all staff
 *   - team_calendar: Get team leave calendar for a date range
 *
 * Authentication: service role JWT or authorized user
 */

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";

const FUNCTION_NAME = "hr-leave-workflow";

interface LeaveRequest {
  operation: string;
  user_id?: string;
  request_id?: string;
  leave_type_id?: string;
  start_date?: string;
  end_date?: string;
  reason?: string;
  attachment_url?: string;
  manager_comment?: string;
  processed_by?: string;
  year?: number;
  department?: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();

  try {
    const body: LeaveRequest = await req.json();
    const { operation } = body;

    if (!operation) {
      return jsonResponse({ error: "Missing 'operation' field" }, 400);
    }

    const supabase = getServiceClient();

    switch (operation) {
      case "submit": {
        if (!body.user_id || !body.leave_type_id || !body.start_date || !body.end_date) {
          return jsonResponse({ error: "Missing required fields: user_id, leave_type_id, start_date, end_date" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_submit_leave_request", {
          p_user_id: body.user_id,
          p_leave_type_id: body.leave_type_id,
          p_start_date: body.start_date,
          p_end_date: body.end_date,
          p_reason: body.reason ?? null,
          p_attachment_url: body.attachment_url ?? null,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "approve": {
        if (!body.request_id) {
          return jsonResponse({ error: "Missing request_id" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_process_leave_request", {
          p_request_id: body.request_id,
          p_action: "approve",
          p_manager_comment: body.manager_comment ?? null,
          p_processed_by: body.processed_by ?? null,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "reject": {
        if (!body.request_id) {
          return jsonResponse({ error: "Missing request_id" }, 400);
        }

        if (!body.manager_comment) {
          return jsonResponse({ error: "Rejection requires a manager_comment" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_process_leave_request", {
          p_request_id: body.request_id,
          p_action: "reject",
          p_manager_comment: body.manager_comment,
          p_processed_by: body.processed_by ?? null,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "cancel": {
        if (!body.request_id) {
          return jsonResponse({ error: "Missing request_id" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_cancel_leave_request", {
          p_request_id: body.request_id,
          p_cancelled_by: body.user_id ?? null,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "balance": {
        if (!body.user_id) {
          return jsonResponse({ error: "Missing user_id" }, 400);
        }

        const year = body.year ?? new Date().getFullYear();

        const { data, error } = await supabase
          .from("leave_balances")
          .select(`
            id, year, annual_entitlement, used_days, remaining_days,
            leave_types!inner(leave_type)
          `)
          .eq("user_id", body.user_id)
          .eq("year", year);

        if (error) throw error;

        // Get pending requests
        const { data: pending } = await supabase
          .from("leave_requests")
          .select("id, start_date, end_date, days_count, leave_types!inner(leave_type)")
          .eq("user_id", body.user_id)
          .eq("status", "pending");

        return jsonResponse({
          success: true,
          user_id: body.user_id,
          year,
          balances: data ?? [],
          pending_requests: pending ?? [],
          duration_ms: Date.now() - startTime,
        });
      }

      case "init_year": {
        const year = body.year ?? new Date().getFullYear();

        const { data, error } = await supabase.rpc("rpc_initialize_leave_balances", {
          p_year: year,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "team_calendar": {
        if (!body.start_date || !body.end_date) {
          return jsonResponse({ error: "Missing start_date and end_date" }, 400);
        }

        // Use v_leave_dashboard view which properly joins employees via user_id
        let query = supabase
          .from("v_leave_dashboard")
          .select("request_id, employee_name, employee_code, department, leave_type, start_date, end_date, days_count, status, reason")
          .eq("status", "approved")
          .gte("end_date", body.start_date)
          .lte("start_date", body.end_date);

        if (body.department) {
          query = query.eq("department", body.department);
        }

        const { data, error } = await query;

        if (error) throw error;

        return jsonResponse({
          success: true,
          period: { start: body.start_date, end: body.end_date },
          leave_entries: data ?? [],
          total: (data ?? []).length,
          duration_ms: Date.now() - startTime,
        });
      }

      default:
        return jsonResponse(
          { error: `Unknown operation: ${operation}. Valid: submit, approve, reject, cancel, balance, init_year, team_calendar` },
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

