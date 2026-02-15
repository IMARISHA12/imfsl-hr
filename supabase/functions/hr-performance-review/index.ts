/**
 * HR Performance Review — Edge Function
 *
 * Uses REAL Supabase tables:
 *   - staff_performance_monthly (monthly KPI snapshots with scores and grades)
 *   - staff_performance (period-based KPI data: disbursement, collection, PAR30)
 *   - staff (staff directory for names)
 *
 * Operations:
 *   - my_performance:    Get my monthly performance records
 *   - my_kpis:           Get latest KPI data
 *   - team_performance:  Get team performance summary (manager view)
 */

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import { requireAuth, requireRole, type AuthUser } from "../_shared/auth.ts";

const FUNCTION_NAME = "hr-performance-review";

const ADMIN_OPS = new Set(["team_performance"]);

interface ReviewRequest {
  operation: string;
  staff_id?: string;
  year?: number;
  month?: number;
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

    const body: ReviewRequest = await req.json();
    const { operation } = body;

    if (!operation) {
      return jsonResponse({ error: "Missing 'operation' field" }, 400);
    }

    if (ADMIN_OPS.has(operation)) {
      const denied = requireRole(user, ["manager", "hr_admin", "admin"]);
      if (denied) return denied;
    }

    // Self-service: enforce staff_id matches caller
    if ((operation === "my_performance" || operation === "my_kpis") && body.staff_id) {
      if (body.staff_id !== user.id && !["manager", "hr_admin", "admin"].includes(user.role ?? "")) {
        return jsonResponse({ error: "Forbidden: can only view own performance data" }, 403);
      }
    }

    const supabase = getServiceClient();

    switch (operation) {
      case "my_performance": {
        if (!body.staff_id) {
          return jsonResponse({ error: "Missing staff_id" }, 400);
        }

        let query = supabase
          .from("staff_performance_monthly")
          .select("*")
          .eq("staff_id", body.staff_id);

        if (body.year) {
          query = query.eq("year", body.year);
        }

        const { data, error } = await query
          .order("year", { ascending: false })
          .order("month", { ascending: false })
          .limit(12);

        if (error) throw error;

        return jsonResponse({
          success: true,
          staff_id: body.staff_id,
          records: data ?? [],
          duration_ms: Date.now() - startTime,
        });
      }

      case "my_kpis": {
        if (!body.staff_id) {
          return jsonResponse({ error: "Missing staff_id" }, 400);
        }

        // Get latest KPI data from staff_performance
        const { data: kpiData, error: kpiError } = await supabase
          .from("staff_performance")
          .select("*")
          .eq("staff_id", body.staff_id)
          .order("calculated_at", { ascending: false })
          .limit(1)
          .maybeSingle();

        if (kpiError) throw kpiError;

        // Get latest monthly score
        const { data: monthlyData } = await supabase
          .from("staff_performance_monthly")
          .select("*")
          .eq("staff_id", body.staff_id)
          .order("year", { ascending: false })
          .order("month", { ascending: false })
          .limit(1)
          .maybeSingle();

        return jsonResponse({
          success: true,
          staff_id: body.staff_id,
          kpis: kpiData,
          latest_monthly: monthlyData,
          duration_ms: Date.now() - startTime,
        });
      }

      case "team_performance": {
        const year = body.year ?? new Date().getFullYear();
        const month = body.month ?? new Date().getMonth() + 1;

        const { data, error } = await supabase
          .from("staff_performance_monthly")
          .select("*")
          .eq("year", year)
          .eq("month", month)
          .order("overall_score", { ascending: false });

        if (error) throw error;

        const records = data ?? [];
        const summary = {
          total_staff: records.length,
          avg_score: records.length > 0
            ? records.reduce((sum, r) => sum + (r.overall_score ?? 0), 0) / records.length
            : 0,
          grade_distribution: {
            A: records.filter((r) => r.grade === "A").length,
            B: records.filter((r) => r.grade === "B").length,
            C: records.filter((r) => r.grade === "C").length,
            D: records.filter((r) => r.grade === "D").length,
            F: records.filter((r) => r.grade === "F").length,
          },
        };

        return jsonResponse({
          success: true,
          year, month,
          records,
          summary,
          duration_ms: Date.now() - startTime,
        });
      }

      default:
        return jsonResponse(
          { error: `Unknown operation: ${operation}. Valid: my_performance, my_kpis, team_performance` },
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
