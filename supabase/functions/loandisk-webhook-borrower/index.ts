import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";

/**
 * Loandisk Webhook — Borrower Events
 *
 * Receives webhook callbacks from Loandisk when borrower records are
 * created, updated, or deleted.
 *
 * Pipeline:
 *   1. Authenticate via x-webhook-secret header
 *   2. Store raw payload in webhook_events
 *   3. Upsert into raw_borrowers (immutable staging)
 *   4. Transform & upsert into clients (canonical)
 *   5. Record sync lineage in loandisk_sync_runs / loandisk_sync_items
 *   6. Record invocation metrics in edge_function_invocations
 */

// ─── Types ───────────────────────────────────────────────────────────

interface LoandiskBorrower {
  borrower_id?: string;
  id?: string;
  first_name?: string;
  last_name?: string;
  middle_name?: string;
  full_name?: string;
  phone_number?: string;
  mobile?: string;
  email?: string;
  nida_number?: string;
  national_id?: string;
  gender?: string;
  date_of_birth?: string;
  address?: string;
  city?: string;
  region?: string;
  district?: string;
  street?: string;
  business_type?: string;
  business_name?: string;
  business_location?: string;
  revenue_estimate?: number;
  next_of_kin_name?: string;
  next_of_kin_relationship?: string;
  next_of_kin_phone?: string;
  photo_url?: string;
  status?: string;
  created_at?: string;
  updated_at?: string;
  [key: string]: unknown;
}

interface WebhookPayload {
  event?: string;
  event_type?: string;
  action?: string;
  data?: LoandiskBorrower;
  borrower?: LoandiskBorrower;
  // Loandisk may send flat payloads (fields at root level)
  [key: string]: unknown;
}

// ─── Helpers ─────────────────────────────────────────────────────────

function resolveEventKey(payload: WebhookPayload): string {
  return (
    payload.event ||
    payload.event_type ||
    payload.action ||
    "borrower.unknown"
  );
}

function resolveBorrowerData(payload: WebhookPayload): LoandiskBorrower {
  // Loandisk may nest data under "data", "borrower", or send flat
  if (payload.data && typeof payload.data === "object") return payload.data;
  if (payload.borrower && typeof payload.borrower === "object")
    return payload.borrower;

  // Fall back: treat root payload as borrower (minus meta fields)
  const { event, event_type, action, ...rest } = payload;
  return rest as LoandiskBorrower;
}

function resolveExternalId(b: LoandiskBorrower): string | null {
  return (
    (b.borrower_id as string) ||
    (b.id as string) ||
    null
  );
}

function buildFullName(b: LoandiskBorrower): string {
  if (b.full_name) return b.full_name.trim();
  const parts = [b.first_name, b.middle_name, b.last_name].filter(Boolean);
  return parts.join(" ").trim() || "Unknown";
}

function resolvePhone(b: LoandiskBorrower): string {
  return (b.phone_number || b.mobile || "").trim();
}

function resolveNida(b: LoandiskBorrower): string | null {
  return (b.nida_number || b.national_id || null);
}

function mapAction(eventKey: string): string {
  if (eventKey.includes("create") || eventKey.includes("new")) return "created";
  if (eventKey.includes("update") || eventKey.includes("edit")) return "updated";
  if (eventKey.includes("delete") || eventKey.includes("remove")) return "deleted";
  return "upserted";
}

// ─── Main Handler ────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();
  const supabase = getServiceClient();
  let eventKey = "borrower.unknown";
  let errorMessage: string | null = null;

  try {
    // ── 1. Authentication ──────────────────────────────────────────

    const webhookSecret = Deno.env.get("LOANDISK_WEBHOOK_SECRET");
    if (!webhookSecret) {
      throw new Error("LOANDISK_WEBHOOK_SECRET is not configured");
    }

    const incomingSecret =
      req.headers.get("x-webhook-secret") ||
      req.headers.get("authorization")?.replace(/^Bearer\s+/i, "");

    if (incomingSecret !== webhookSecret) {
      // Log failed auth attempt for audit
      await supabase.from("loandisk_access_log").insert({
        user_id: "webhook",
        action: "webhook_auth_failed",
        resource: "loandisk-webhook-borrower",
        ip_address: req.headers.get("x-forwarded-for") || req.headers.get("cf-connecting-ip") || "unknown",
        user_agent: req.headers.get("user-agent") || "unknown",
        accessed_at: new Date().toISOString(),
        metadata: { reason: "invalid_secret" },
      });

      return new Response(
        JSON.stringify({ success: false, error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 2. Parse payload ───────────────────────────────────────────

    const payload: WebhookPayload = await req.json();
    eventKey = resolveEventKey(payload);
    const borrower = resolveBorrowerData(payload);
    const externalId = resolveExternalId(borrower);

    if (!externalId) {
      throw new Error("Payload missing borrower identifier (borrower_id or id)");
    }

    // ── 3. Store raw webhook event ─────────────────────────────────

    const { error: webhookErr } = await supabase
      .from("webhook_events")
      .insert({
        provider: "loandisk",
        event_key: eventKey,
        received_at: new Date().toISOString(),
        payload: payload,
      });

    if (webhookErr) {
      console.error("webhook_events insert error:", webhookErr.message);
    }

    // ── 4. Upsert raw_borrowers (immutable staging layer) ──────────

    const { error: rawErr } = await supabase
      .from("raw_borrowers")
      .upsert(
        {
          external_id: externalId,
          provider: "loandisk",
          raw_data: payload,
          first_name: borrower.first_name || null,
          last_name: borrower.last_name || null,
          full_name: buildFullName(borrower),
          phone_number: resolvePhone(borrower),
          nida_number: resolveNida(borrower),
          email: borrower.email || null,
          status: borrower.status || "active",
          received_at: new Date().toISOString(),
        },
        { onConflict: "external_id,provider" }
      );

    if (rawErr) {
      console.error("raw_borrowers upsert error:", rawErr.message);
      // Non-fatal — continue to try canonical upsert
    }

    // ── 5. Transform & upsert canonical client record ──────────────

    const action = mapAction(eventKey);
    let localId: string | null = null;

    if (action !== "deleted") {
      const clientPayload = {
        first_name: borrower.first_name || buildFullName(borrower).split(" ")[0] || "Unknown",
        last_name: borrower.last_name || buildFullName(borrower).split(" ").slice(1).join(" ") || "",
        phone_number: resolvePhone(borrower),
        nida_number: resolveNida(borrower),
        business_type: borrower.business_type || null,
        business_location: borrower.business_location || null,
        revenue_estimate: borrower.revenue_estimate || null,
        status: borrower.status || "active",
        external_reference_id: externalId,
        next_of_kin_name: borrower.next_of_kin_name || null,
        next_of_kin_relationship: borrower.next_of_kin_relationship || null,
        next_of_kin_phone: borrower.next_of_kin_phone || null,
        photo_url: borrower.photo_url || null,
        region: borrower.region || null,
        district: borrower.district || null,
        street: borrower.street || borrower.address || null,
        updated_at: new Date().toISOString(),
      };

      const { data: clientData, error: clientErr } = await supabase
        .from("clients")
        .upsert(clientPayload, { onConflict: "external_reference_id" })
        .select("id")
        .single();

      if (clientErr) {
        console.error("clients upsert error:", clientErr.message);
      } else {
        localId = clientData?.id || null;
      }
    } else {
      // Soft-delete: mark client as inactive
      const { data: existing } = await supabase
        .from("clients")
        .select("id")
        .eq("external_reference_id", externalId)
        .maybeSingle();

      if (existing) {
        localId = existing.id;
        await supabase
          .from("clients")
          .update({ status: "inactive", updated_at: new Date().toISOString() })
          .eq("id", existing.id);
      }
    }

    // ── 6. Record sync lineage ─────────────────────────────────────

    // Find active integration (or use default)
    const { data: integration } = await supabase
      .from("loandisk_integrations")
      .select("id")
      .eq("is_active", true)
      .limit(1)
      .maybeSingle();

    const integrationId = integration?.id || "00000000-0000-0000-0000-000000000000";

    // Create sync run
    const now = new Date().toISOString();
    const { data: syncRun, error: syncRunErr } = await supabase
      .from("loandisk_sync_runs")
      .insert({
        integration_id: integrationId,
        run_type: "webhook",
        started_at: now,
        completed_at: now,
        status: rawErr || !localId ? "partial" : "completed",
        records_fetched: 1,
        records_created: action === "created" && localId ? 1 : 0,
        records_updated: action === "updated" && localId ? 1 : 0,
        records_skipped: 0,
        records_failed: localId ? 0 : 1,
        entity_types: ["borrower"],
        triggered_by: "loandisk-webhook",
        error_message: rawErr?.message || null,
      })
      .select("id")
      .single();

    if (syncRun) {
      await supabase.from("loandisk_sync_items").insert({
        sync_run_id: syncRun.id,
        entity_type: "borrower",
        external_id: externalId,
        action: action,
        local_id: localId,
        source_data: payload,
        transformed_data: localId ? { client_id: localId } : null,
        error_message: rawErr?.message || null,
        synced_at: now,
      });
    } else if (syncRunErr) {
      console.error("loandisk_sync_runs insert error:", syncRunErr.message);
    }

    // ── 7. Log access ──────────────────────────────────────────────

    await supabase.from("loandisk_access_log").insert({
      user_id: "webhook",
      action: `webhook_${action}`,
      resource: `borrower/${externalId}`,
      ip_address: req.headers.get("x-forwarded-for") || req.headers.get("cf-connecting-ip") || "unknown",
      user_agent: req.headers.get("user-agent") || "unknown",
      accessed_at: now,
      metadata: { event_key: eventKey, local_id: localId },
    });

    // ── 8. Return success ──────────────────────────────────────────

    const durationMs = Date.now() - startTime;

    // Record invocation metric (non-blocking)
    supabase.from("edge_function_invocations").insert({
      function_name: "loandisk-webhook-borrower",
      invoked_at: now,
      duration_ms: durationMs,
      status: "success",
      request_size_bytes: Number(req.headers.get("content-length") || 0),
      response_size_bytes: 0,
      metadata: { event_key: eventKey, external_id: externalId, local_id: localId },
    });

    return new Response(
      JSON.stringify({
        success: true,
        event: eventKey,
        external_id: externalId,
        local_id: localId,
        action: action,
        duration_ms: durationMs,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    errorMessage = err instanceof Error ? err.message : String(err);
    console.error("loandisk-webhook-borrower error:", errorMessage);

    const durationMs = Date.now() - startTime;

    // Record failed invocation (non-blocking)
    try {
      const supabase = getServiceClient();
      supabase.from("edge_function_invocations").insert({
        function_name: "loandisk-webhook-borrower",
        invoked_at: new Date().toISOString(),
        duration_ms: durationMs,
        status: "error",
        error_message: errorMessage,
        request_size_bytes: Number(req.headers.get("content-length") || 0),
        metadata: { event_key: eventKey },
      });
    } catch (_) {
      // Silently fail metric recording
    }

    return new Response(
      JSON.stringify({
        success: false,
        error: errorMessage,
        event: eventKey,
        duration_ms: durationMs,
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
