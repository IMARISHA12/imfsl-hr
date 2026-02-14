/**
 * HR Performance Review — Edge Function
 *
 * Operations:
 *   - create_cycle:      Create a new review cycle (quarterly/annual)
 *   - assign_reviews:    Assign reviews to employees in a cycle
 *   - self_review:       Submit self-assessment scores
 *   - manager_review:    Submit manager assessment & finalize
 *   - calculate_kpis:    Auto-calculate KPI scores for loan officers
 *   - cycle_summary:     Get summary of a review cycle
 *   - employee_history:  Get review history for an employee
 *
 * Authentication: service role JWT or authorized user
 */

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import { requireAuth, requireRole, type AuthUser } from "../_shared/auth.ts";

const FUNCTION_NAME = "hr-performance-review";

// Operations requiring manager/admin role
const ADMIN_OPS = new Set(["create_cycle", "assign_reviews", "manager_review", "calculate_kpis", "cycle_summary"]);

interface ReviewRequest {
  operation: string;
  cycle_id?: string;
  review_id?: string;
  employee_id?: string;
  // Cycle creation
  cycle_name?: string;
  cycle_type?: string;
  period_start?: string;
  period_end?: string;
  review_deadline?: string;
  created_by?: string;
  // Assignment
  employee_ids?: string[];
  reviewer_id?: string;
  // Self-review scores
  quality?: number;
  productivity?: number;
  teamwork?: number;
  initiative?: number;
  attendance?: number;
  comments?: string;
  // Manager review extras
  recommendations?: string;
  development_plan?: string;
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

    const body: ReviewRequest = await req.json();
    const { operation } = body;

    if (!operation) {
      return jsonResponse({ error: "Missing 'operation' field" }, 400);
    }

    // Enforce role for admin operations
    if (ADMIN_OPS.has(operation)) {
      const denied = requireRole(user, ["manager", "hr_admin", "admin"]);
      if (denied) return denied;
    }

    // For self-service: enforce employee_id matches caller
    if (operation === "employee_history" && body.employee_id) {
      if (body.employee_id !== user.id && !["manager", "hr_admin", "admin"].includes(user.role ?? "")) {
        return jsonResponse({ error: "Forbidden: can only view own performance history" }, 403);
      }
    }

    const supabase = getServiceClient();

    switch (operation) {
      case "create_cycle": {
        if (!body.cycle_name || !body.period_start || !body.period_end) {
          return jsonResponse({ error: "Missing required: cycle_name, period_start, period_end" }, 400);
        }

        const { data, error } = await supabase
          .from("performance_review_cycles")
          .insert({
            cycle_name: body.cycle_name,
            cycle_type: body.cycle_type ?? "quarterly",
            period_start: body.period_start,
            period_end: body.period_end,
            review_deadline: body.review_deadline,
            status: "draft",
            created_by: body.created_by ?? "system",
          })
          .select("id")
          .single();

        if (error) throw error;

        return jsonResponse({
          success: true,
          cycle_id: data.id,
          cycle_name: body.cycle_name,
          status: "draft",
          duration_ms: Date.now() - startTime,
        });
      }

      case "assign_reviews": {
        if (!body.cycle_id) {
          return jsonResponse({ error: "Missing cycle_id" }, 400);
        }

        // Get employees to assign - either specified or all active
        let employeeIds = body.employee_ids;

        if (!employeeIds || employeeIds.length === 0) {
          const { data: employees } = await supabase
            .from("employees")
            .select("id")
            .or("status.eq.active,employment_status.eq.active");

          employeeIds = (employees ?? []).map((e: { id: string }) => e.id);
        }

        const reviews = employeeIds.map((empId: string) => ({
          cycle_id: body.cycle_id,
          employee_id: empId,
          reviewer_id: body.reviewer_id ?? null,
          status: "pending",
        }));

        const { data, error } = await supabase
          .from("performance_reviews")
          .upsert(reviews, { onConflict: "cycle_id,employee_id" })
          .select("id, employee_id");

        if (error) throw error;

        // Activate the cycle
        await supabase
          .from("performance_review_cycles")
          .update({ status: "active", updated_at: new Date().toISOString() })
          .eq("id", body.cycle_id);

        return jsonResponse({
          success: true,
          cycle_id: body.cycle_id,
          reviews_assigned: (data ?? []).length,
          duration_ms: Date.now() - startTime,
        });
      }

      case "self_review": {
        if (!body.review_id) {
          return jsonResponse({ error: "Missing review_id" }, 400);
        }
        if (!body.quality || !body.productivity || !body.teamwork || !body.initiative || !body.attendance) {
          return jsonResponse({ error: "All scores required: quality, productivity, teamwork, initiative, attendance" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_submit_self_review", {
          p_review_id: body.review_id,
          p_quality: body.quality,
          p_productivity: body.productivity,
          p_teamwork: body.teamwork,
          p_initiative: body.initiative,
          p_attendance: body.attendance,
          p_comments: body.comments ?? null,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "manager_review": {
        if (!body.review_id) {
          return jsonResponse({ error: "Missing review_id" }, 400);
        }
        if (!body.quality || !body.productivity || !body.teamwork || !body.initiative || !body.attendance) {
          return jsonResponse({ error: "All scores required: quality, productivity, teamwork, initiative, attendance" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_submit_manager_review", {
          p_review_id: body.review_id,
          p_quality: body.quality,
          p_productivity: body.productivity,
          p_teamwork: body.teamwork,
          p_initiative: body.initiative,
          p_attendance: body.attendance,
          p_comments: body.comments ?? null,
          p_recommendations: body.recommendations ?? null,
          p_development_plan: body.development_plan ?? null,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "calculate_kpis": {
        if (!body.cycle_id) {
          return jsonResponse({ error: "Missing cycle_id" }, 400);
        }

        const { data, error } = await supabase.rpc("rpc_calculate_kpi_scores", {
          p_cycle_id: body.cycle_id,
        });

        if (error) throw error;

        return jsonResponse({ ...data, duration_ms: Date.now() - startTime });
      }

      case "cycle_summary": {
        if (!body.cycle_id) {
          return jsonResponse({ error: "Missing cycle_id" }, 400);
        }

        // Get cycle details
        const { data: cycle, error: cycleError } = await supabase
          .from("performance_review_cycles")
          .select("*")
          .eq("id", body.cycle_id)
          .single();

        if (cycleError) throw cycleError;

        // Get reviews with employee details
        let reviewQuery = supabase
          .from("v_performance_dashboard")
          .select("*")
          .eq("cycle_name", cycle.cycle_name);

        if (body.department) {
          reviewQuery = reviewQuery.eq("department", body.department);
        }

        const { data: reviews } = await reviewQuery;

        const allReviews = reviews ?? [];
        const summary = {
          total_reviews: allReviews.length,
          pending: allReviews.filter((r) => r.review_status === "pending").length,
          self_review: allReviews.filter((r) => r.review_status === "self_review").length,
          manager_review: allReviews.filter((r) => r.review_status === "manager_review").length,
          completed: allReviews.filter((r) => r.review_status === "completed").length,
          avg_score: allReviews.filter((r) => r.overall_score)
            .reduce((sum, r, _, arr) => sum + ((r.overall_score ?? 0) / arr.length), 0),
          grade_distribution: {
            A: allReviews.filter((r) => r.overall_grade === "A").length,
            B: allReviews.filter((r) => r.overall_grade === "B").length,
            C: allReviews.filter((r) => r.overall_grade === "C").length,
            D: allReviews.filter((r) => r.overall_grade === "D").length,
            F: allReviews.filter((r) => r.overall_grade === "F").length,
          },
        };

        return jsonResponse({
          success: true,
          cycle,
          summary,
          reviews: allReviews,
          duration_ms: Date.now() - startTime,
        });
      }

      case "employee_history": {
        if (!body.employee_id) {
          return jsonResponse({ error: "Missing employee_id" }, 400);
        }

        const { data, error } = await supabase
          .from("v_performance_dashboard")
          .select("*")
          .eq("employee_id", body.employee_id)
          .order("period_start", { ascending: false });

        if (error) throw error;

        return jsonResponse({
          success: true,
          employee_id: body.employee_id,
          reviews: data ?? [],
          duration_ms: Date.now() - startTime,
        });
      }

      default:
        return jsonResponse(
          { error: `Unknown operation: ${operation}. Valid: create_cycle, assign_reviews, self_review, manager_review, calculate_kpis, cycle_summary, employee_history` },
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

