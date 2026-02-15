/**
 * HR Leave Workflow — Edge Function
 *
 * Uses REAL Supabase tables:
 *   - leave_requests_v2 (staff_id, leave_type TEXT, status)
 *   - leave_requests_v2_enriched (view with staff_name, is_active_now)
 *   - leave_types (code, name, days_allowed)
 *   - leave_balances (user_id, leave_type_id UUID, year)
 *
 * Operations:
 *   - submit:        Insert into leave_requests_v2
 *   - approve:       Update status to 'approved'
 *   - reject:        Update status to 'rejected'
 *   - cancel:        Update status to 'cancelled'
 *   - my_requests:   Get leave requests for a staff member
 *   - pending:       Get pending requests (manager view)
 *   - team_calendar: Get approved leaves for a date range
 */

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import { requireAuth, requireRole, type AuthUser } from "../_shared/auth.ts";

const FUNCTION_NAME = "hr-leave-workflow";

const ADMIN_OPS = new Set(["approve", "reject", "pending"]);

interface LeaveBody {
  operation: string;
  staff_id?: string;
  request_id?: string;
  leave_type?: string;
  start_date?: string;
  end_date?: string;
  reason?: string;
  approved_by?: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();

  try {
    const authResult = await requireAuth(req);
    if (authResult instanceof Response) return authResult;
    const user: AuthUser = authResult;

    const body: LeaveBody = await req.json();
    const { operation } = body;

    if (!operation) {
      return jsonResponse({ error: "Missing 'operation' field" }, 400);
    }

    if (ADMIN_OPS.has(operation)) {
      const denied = requireRole(user, ["manager", "hr_admin", "admin"]);
      if (denied) return denied;
    }

    // Self-service: enforce staff_id matches caller
    if ((operation === "submit" || operation === "cancel" || operation === "my_requests") && body.staff_id) {
      if (body.staff_id !== user.id && !["manager", "hr_admin", "admin"].includes(user.role ?? "")) {
        return jsonResponse({ error: "Forbidden: can only access own leave data" }, 403);
      }
    }

    const supabase = getServiceClient();

    switch (operation) {
      case "submit": {
        if (!body.staff_id || !body.leave_type || !body.start_date || !body.end_date) {
          return jsonResponse({ error: "Missing required: staff_id, leave_type, start_date, end_date" }, 400);
        }

        // Validate leave_type exists
        const { data: leaveType } = await supabase
          .from("leave_types")
          .select("code, name, days_allowed")
          .eq("name", body.leave_type)
          .maybeSingle();

        if (!leaveType) {
          // Also try by code
          const { data: ltByCode } = await supabase
            .from("leave_types")
            .select("code, name, days_allowed")
            .eq("code", body.leave_type)
            .maybeSingle();
          if (!ltByCode) {
            return jsonResponse({ error: `Unknown leave type: ${body.leave_type}` }, 400);
          }
        }

        // Insert into leave_requests_v2
        const { data, error } = await supabase
          .from("leave_requests_v2")
          .insert({
            staff_id: body.staff_id,
            leave_type: body.leave_type,
            start_date: body.start_date,
            end_date: body.end_date,
            reason: body.reason ?? null,
            status: "pending",
          })
          .select()
          .single();

        if (error) throw error;

        return jsonResponse({
          success: true,
          request: data,
          duration_ms: Date.now() - startTime,
        });
      }

      case "approve": {
        if (!body.request_id) {
          return jsonResponse({ error: "Missing request_id" }, 400);
        }

        const { data, error } = await supabase
          .from("leave_requests_v2")
          .update({
            status: "approved",
            approved_by: user.email ?? user.id,
          })
          .eq("id", body.request_id)
          .eq("status", "pending")
          .select()
          .single();

        if (error) throw error;

        return jsonResponse({
          success: true,
          request: data,
          duration_ms: Date.now() - startTime,
        });
      }

      case "reject": {
        if (!body.request_id) {
          return jsonResponse({ error: "Missing request_id" }, 400);
        }

        const { data, error } = await supabase
          .from("leave_requests_v2")
          .update({
            status: "rejected",
            approved_by: user.email ?? user.id,
          })
          .eq("id", body.request_id)
          .eq("status", "pending")
          .select()
          .single();

        if (error) throw error;

        return jsonResponse({
          success: true,
          request: data,
          duration_ms: Date.now() - startTime,
        });
      }

      case "cancel": {
        if (!body.request_id) {
          return jsonResponse({ error: "Missing request_id" }, 400);
        }

        const { data, error } = await supabase
          .from("leave_requests_v2")
          .update({ status: "cancelled" })
          .eq("id", body.request_id)
          .in("status", ["pending", "approved"])
          .select()
          .single();

        if (error) throw error;

        return jsonResponse({
          success: true,
          request: data,
          duration_ms: Date.now() - startTime,
        });
      }

      case "my_requests": {
        if (!body.staff_id) {
          return jsonResponse({ error: "Missing staff_id" }, 400);
        }

        const { data, error } = await supabase
          .from("leave_requests_v2")
          .select("*")
          .eq("staff_id", body.staff_id)
          .order("start_date", { ascending: false })
          .limit(50);

        if (error) throw error;

        return jsonResponse({
          success: true,
          requests: data ?? [],
          duration_ms: Date.now() - startTime,
        });
      }

      case "pending": {
        // Manager view: use enriched view with staff names
        const { data, error } = await supabase
          .from("leave_requests_v2_enriched")
          .select("*")
          .eq("status", "pending")
          .order("start_date", { ascending: false })
          .limit(100);

        if (error) throw error;

        return jsonResponse({
          success: true,
          requests: data ?? [],
          total: (data ?? []).length,
          duration_ms: Date.now() - startTime,
        });
      }

      case "team_calendar": {
        if (!body.start_date || !body.end_date) {
          return jsonResponse({ error: "Missing start_date and end_date" }, 400);
        }

        const { data, error } = await supabase
          .from("leave_requests_v2_enriched")
          .select("*")
          .eq("status", "approved")
          .gte("end_date", body.start_date)
          .lte("start_date", body.end_date);

        if (error) throw error;

        return jsonResponse({
          success: true,
          period: { start: body.start_date, end: body.end_date },
          leave_entries: data ?? [],
          duration_ms: Date.now() - startTime,
        });
      }

      default:
        return jsonResponse(
          { error: `Unknown operation: ${operation}. Valid: submit, approve, reject, cancel, my_requests, pending, team_calendar` },
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
