/**
 * HR Attendance — Edge Function
 *
 * Operations:
 *   - clock_in:    Clock in with optional GPS coordinates (geofence)
 *   - clock_out:   Clock out with optional daily report
 *   - rate:        Manager rates a staff member's daily attendance
 *   - summary:     Get monthly attendance summary for all staff
 *   - my_records:  Get attendance records for a specific staff member
 *   - today:       Get today's attendance status for all staff
 *
 * Authentication: service role JWT or authorized user
 */

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import { requireAuth, requireRole, type AuthUser } from "../_shared/auth.ts";

const FUNCTION_NAME = "hr-attendance";

// Operations that require manager/admin role
const ADMIN_OPS = new Set(["rate", "summary", "today"]);

interface AttendanceRequest {
  operation: string;
  staff_id?: string;
  latitude?: number;
  longitude?: number;
  daily_report?: string;
  record_id?: string;
  rating?: number;
  manager_notes?: string;
  rated_by?: string;
  month?: number;
  year?: number;
  department?: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();

  try {
    // Authenticate the caller
    const authResult = await requireAuth(req);
    if (authResult instanceof Response) return authResult;
    const user: AuthUser = authResult;

    const body: AttendanceRequest = await req.json();
    const { operation } = body;

    if (!operation) {
      return jsonResponse({ error: "Missing 'operation' field" }, 400);
    }

    // Enforce role for admin operations
    if (ADMIN_OPS.has(operation)) {
      const denied = requireRole(user, ["manager", "hr_admin", "admin"]);
      if (denied) return denied;
    }

    // For self-service ops, enforce that staff_id matches the caller
    if ((operation === "clock_in" || operation === "clock_out" || operation === "my_records") && body.staff_id) {
      if (body.staff_id !== user.id && !["manager", "hr_admin", "admin"].includes(user.role ?? "")) {
        return jsonResponse({ error: "Forbidden: can only access own attendance records" }, 403);
      }
    }

    const supabase = getServiceClient();

    switch (operation) {
      case "clock_in": {
        if (!body.staff_id) {
          return jsonResponse({ error: "Missing staff_id" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_clock_in", {
          p_staff_id: body.staff_id,
          p_latitude: body.latitude ?? null,
          p_longitude: body.longitude ?? null,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "clock_out": {
        if (!body.staff_id) {
          return jsonResponse({ error: "Missing staff_id" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_clock_out", {
          p_staff_id: body.staff_id,
          p_daily_report: body.daily_report ?? null,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "rate": {
        if (!body.record_id || !body.rating) {
          return jsonResponse({ error: "Missing record_id or rating" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_rate_attendance", {
          p_record_id: body.record_id,
          p_rating: body.rating,
          p_manager_notes: body.manager_notes ?? null,
          p_rated_by: body.rated_by ?? null,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "summary": {
        const month = body.month ?? new Date().getMonth() + 1;
        const year = body.year ?? new Date().getFullYear();

        const { data, error } = await supabase.rpc("rpc_attendance_summary", {
          p_month: month,
          p_year: year,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "my_records": {
        if (!body.staff_id) {
          return jsonResponse({ error: "Missing staff_id" }, 400);
        }

        const month = body.month ?? new Date().getMonth() + 1;
        const year = body.year ?? new Date().getFullYear();

        const { data, error } = await supabase
          .from("attendance_records")
          .select("*")
          .eq("staff_id", body.staff_id)
          .gte("work_date", `${year}-${String(month).padStart(2, "0")}-01`)
          .lt("work_date", month === 12
            ? `${year + 1}-01-01`
            : `${year}-${String(month + 1).padStart(2, "0")}-01`)
          .order("work_date", { ascending: false });

        if (error) throw error;

        // Calculate summary stats
        const records = data ?? [];
        const summary = {
          days_present: records.filter((r) => r.clock_in).length,
          days_late: records.filter((r) => r.is_late).length,
          total_hours: records.reduce((sum, r) => sum + (r.hours_worked ?? 0), 0),
          overtime_hours: records.reduce(
            (sum, r) => sum + Math.max(0, (r.hours_worked ?? 0) - 8),
            0
          ),
          avg_rating: records.filter((r) => r.manager_rating)
            .reduce((sum, r, _, arr) => sum + (r.manager_rating ?? 0) / arr.length, 0),
        };

        return jsonResponse({
          success: true,
          staff_id: body.staff_id,
          month,
          year,
          records,
          summary,
          duration_ms: Date.now() - startTime,
        });
      }

      case "today": {
        const today = new Date().toISOString().split("T")[0];

        let query = supabase
          .from("v_attendance_dashboard")
          .select("*")
          .eq("work_date", today);

        if (body.department) {
          query = query.eq("department", body.department);
        }

        const { data, error } = await query.order("staff_name");

        if (error) throw error;

        // Get all active staff for absent detection
        const { data: allStaff } = await supabase
          .from("staff")
          .select("id, full_name, department")
          .eq("active", true);

        const presentIds = new Set((data ?? []).map((r: { staff_id?: string }) => r.staff_id));
        const absent = (allStaff ?? []).filter((s: { id: string }) => !presentIds.has(s.id));

        return jsonResponse({
          success: true,
          date: today,
          present: data ?? [],
          absent,
          stats: {
            total_staff: (allStaff ?? []).length,
            present_count: (data ?? []).length,
            absent_count: absent.length,
            late_count: (data ?? []).filter((r: { is_late?: boolean }) => r.is_late).length,
          },
          duration_ms: Date.now() - startTime,
        });
      }

      default:
        return jsonResponse(
          { error: `Unknown operation: ${operation}. Valid: clock_in, clock_out, rate, summary, my_records, today` },
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

