/**
 * HR Attendance — Edge Function
 *
 * Uses REAL Supabase tables:
 *   - staff_attendance_v3 (with geofence, biometric, GPS)
 *   - attendance_v2_today (view for today's status)
 *   - attendance_settings (geofence config)
 *   - staff (active staff list)
 *
 * Operations:
 *   - clock_in:    Insert/upsert into staff_attendance_v3
 *   - clock_out:   Update clock_out_time in staff_attendance_v3
 *   - my_records:  Get attendance records for a specific staff member
 *   - today:       Get today's attendance from attendance_v2_today view
 */

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import { requireAuth, requireRole, type AuthUser } from "../_shared/auth.ts";

const FUNCTION_NAME = "hr-attendance";

const ADMIN_OPS = new Set(["today"]);

interface AttendanceRequest {
  operation: string;
  staff_id?: string;
  latitude?: number;
  longitude?: number;
  geofence_id?: string;
  device_id?: string;
  photo_path?: string;
  notes?: string;
  month?: number;
  year?: number;
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

    const body: AttendanceRequest = await req.json();
    const { operation } = body;

    if (!operation) {
      return jsonResponse({ error: "Missing 'operation' field" }, 400);
    }

    if (ADMIN_OPS.has(operation)) {
      const denied = requireRole(user, ["manager", "hr_admin", "admin"]);
      if (denied) return denied;
    }

    // Self-service: enforce staff_id matches caller
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

        const now = new Date();
        const today = now.toISOString().split("T")[0];

        // Check attendance_settings for late detection
        const { data: settings } = await supabase
          .from("attendance_settings")
          .select("work_start_time, grace_period_minutes, is_geofencing_enabled")
          .limit(1)
          .maybeSingle();

        // Upsert into staff_attendance_v3 (unique on staff_id + work_date)
        const { data, error } = await supabase
          .from("staff_attendance_v3")
          .upsert({
            staff_id: body.staff_id,
            work_date: today,
            clock_in_time: now.toISOString(),
            clock_in_latitude: body.latitude ?? null,
            clock_in_longitude: body.longitude ?? null,
            clock_in_geofence_id: body.geofence_id ?? null,
            clock_in_device_id: body.device_id ?? null,
            clock_in_photo_path: body.photo_path ?? null,
            status: "present",
          }, { onConflict: "staff_id,work_date" })
          .select()
          .single();

        if (error) throw error;

        return jsonResponse({
          success: true,
          record: data,
          settings_applied: !!settings,
          duration_ms: Date.now() - startTime,
        });
      }

      case "clock_out": {
        if (!body.staff_id) {
          return jsonResponse({ error: "Missing staff_id" }, 400);
        }

        const now = new Date();
        const today = now.toISOString().split("T")[0];

        const { data, error } = await supabase
          .from("staff_attendance_v3")
          .update({
            clock_out_time: now.toISOString(),
            clock_out_latitude: body.latitude ?? null,
            clock_out_longitude: body.longitude ?? null,
            clock_out_device_id: body.device_id ?? null,
            notes: body.notes ?? null,
          })
          .eq("staff_id", body.staff_id)
          .eq("work_date", today)
          .select()
          .single();

        if (error) throw error;

        return jsonResponse({
          success: true,
          record: data,
          duration_ms: Date.now() - startTime,
        });
      }

      case "my_records": {
        if (!body.staff_id) {
          return jsonResponse({ error: "Missing staff_id" }, 400);
        }

        const month = body.month ?? new Date().getMonth() + 1;
        const year = body.year ?? new Date().getFullYear();
        const startDate = `${year}-${String(month).padStart(2, "0")}-01`;
        const endDate = month === 12
          ? `${year + 1}-01-01`
          : `${year}-${String(month + 1).padStart(2, "0")}-01`;

        const { data, error } = await supabase
          .from("staff_attendance_v3")
          .select("*")
          .eq("staff_id", body.staff_id)
          .gte("work_date", startDate)
          .lt("work_date", endDate)
          .order("work_date", { ascending: false });

        if (error) throw error;

        const records = data ?? [];
        const summary = {
          days_present: records.filter((r) => r.clock_in_time).length,
          days_late: records.filter((r) => r.is_late).length,
          total_work_minutes: records.reduce((sum, r) => sum + (r.work_minutes ?? 0), 0),
          total_overtime_minutes: records.reduce((sum, r) => sum + (r.overtime_minutes ?? 0), 0),
        };

        return jsonResponse({
          success: true,
          staff_id: body.staff_id,
          month, year, records, summary,
          duration_ms: Date.now() - startTime,
        });
      }

      case "today": {
        // Use existing attendance_v2_today VIEW
        const { data, error } = await supabase
          .from("attendance_v2_today")
          .select("*")
          .order("full_name");

        if (error) throw error;

        // Get all active staff for absent detection
        const { data: allStaff } = await supabase
          .from("staff")
          .select("id, full_name, email")
          .eq("active", true);

        const presentIds = new Set((data ?? []).map((r: { staff_id?: string }) => r.staff_id));
        const absent = (allStaff ?? []).filter((s: { id: string }) => !presentIds.has(s.id));

        return jsonResponse({
          success: true,
          present: data ?? [],
          absent,
          stats: {
            total_staff: (allStaff ?? []).length,
            present_count: (data ?? []).length,
            absent_count: absent.length,
          },
          duration_ms: Date.now() - startTime,
        });
      }

      default:
        return jsonResponse(
          { error: `Unknown operation: ${operation}. Valid: clock_in, clock_out, my_records, today` },
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
