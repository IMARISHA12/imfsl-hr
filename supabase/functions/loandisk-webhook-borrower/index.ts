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
 *   3. Upsert into raw_borrowers (staging — keyed on loandisk_id + branch_id)
 *   4. Transform & upsert into clients (canonical — keyed on external_reference_id)
 *   5. Record sync lineage in loandisk_sync_runs / loandisk_sync_items
 *   6. Record invocation metrics in edge_function_invocations
 *
 * Verified table schemas (2026-02-13):
 *
 *   raw_borrowers:
 *     id(uuid) | loandisk_id(bigint,NOT NULL) | branch_id(bigint,NOT NULL)
 *     payload(jsonb,NOT NULL) | source(text,default:'backfill')
 *     fetched_at | created_at | updated_at
 *     UNIQUE(loandisk_id, branch_id)
 *
 *   clients:
 *     id(uuid) | first_name | middle_name | last_name | phone_number
 *     nida_number | business_type | business_location | revenue_estimate
 *     status | external_reference_id | next_of_kin_name | next_of_kin_relationship
 *     next_of_kin_phone | region | district | street | photo_url
 *     credit_score(default:50) | risk_level(default:'Medium')
 *     created_at | updated_at | ...
 */

// ─── Types ───────────────────────────────────────────────────────────

interface LoandiskBorrower {
  borrower_id?: number | string;
  id?: number | string;
  branch_id?: number | string;
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
  [key: string]: unknown;
}

interface WebhookPayload {
  event?: string;
  event_type?: string;
  action?: string;
  data?: LoandiskBorrower;
  borrower?: LoandiskBorrower;
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
  if (payload.data && typeof payload.data === "object") return payload.data;
  if (payload.borrower && typeof payload.borrower === "object")
    return payload.borrower;
  const { event, event_type, action, ...rest } = payload;
  return rest as LoandiskBorrower;
}

/** Loandisk borrower_id is a bigint. Coerce to number. */
function resolveLoandiskId(b: LoandiskBorrower): number | null {
  const raw = b.borrower_id ?? b.id;
  if (raw == null) return null;
  const num = Number(raw);
  return Number.isFinite(num) ? num : null;
}

/** Branch ID from payload, defaults to 1 if not present. */
function resolveBranchId(b: LoandiskBorrower): number {
  const raw = b.branch_id;
  if (raw == null) return 1;
  const num = Number(raw);
  return Number.isFinite(num) ? num : 1;
}

function buildFullName(b: LoandiskBorrower): string {
  if (b.full_name) return b.full_name.trim();
  const parts = [b.first_name, b.middle_name, b.last_name].filter(Boolean);
  return parts.join(" ").trim() || "Unknown";
}

function splitName(b: LoandiskBorrower): { first: string; middle: string; last: string } {
  if (b.first_name || b.last_name) {
    return {
      first: b.first_name || "Unknown",
      middle: b.middle_name || "",
      last: b.last_name || "",
    };
  }
  const full = buildFullName(b);
  const parts = full.split(/\s+/);
  if (parts.length >= 3) {
    return { first: parts[0], middle: parts.slice(1, -1).join(" "), last: parts[parts.length - 1] };
  }
  if (parts.length === 2) {
    return { first: parts[0], middle: "", last: parts[1] };
  }
  return { first: parts[0] || "Unknown", middle: "", last: "" };
}

function resolvePhone(b: LoandiskBorrower): string {
  return (b.phone_number || b.mobile || "").trim();
}

function resolveNida(b: LoandiskBorrower): string | null {
  return b.nida_number || b.national_id || null;
}

function mapAction(eventKey: string): string {
  if (eventKey.includes("create") || eventKey.includes("new")) return "created";
  if (eventKey.includes("update") || eventKey.includes("edit")) return "updated";
  if (eventKey.includes("delete") || eventKey.includes("remove")) return "deleted";
  return "upserted";
}

// ─── Main Handler ────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();
  const supabase = getServiceClient();
  let eventKey = "borrower.unknown";

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
    const loandiskId = resolveLoandiskId(borrower);

    if (loandiskId === null) {
      throw new Error("Payload missing borrower identifier (borrower_id or id must be a number)");
    }

    const branchId = resolveBranchId(borrower);
    const externalRef = `LD-${loandiskId}`;

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

    // ── 4. Upsert raw_borrowers ────────────────────────────────────
    // Schema: id, loandisk_id(bigint), branch_id(bigint), payload(jsonb),
    //         source(text), fetched_at, created_at, updated_at
    // Unique: (loandisk_id, branch_id)

    const { error: rawErr } = await supabase
      .from("raw_borrowers")
      .upsert(
        {
          loandisk_id: loandiskId,
          branch_id: branchId,
          payload: payload,
          source: "webhook",
          fetched_at: new Date().toISOString(),
        },
        { onConflict: "loandisk_id,branch_id" }
      );

    if (rawErr) {
      console.error("raw_borrowers upsert error:", rawErr.message);
    }

    // ── 5. Transform & upsert canonical client record ──────────────
    // clients has no unique constraint on external_reference_id,
    // so we use select-then-insert/update pattern.

    const action = mapAction(eventKey);
    let localId: string | null = null;
    const names = splitName(borrower);
    const now = new Date().toISOString();

    if (action !== "deleted") {
      const clientFields = {
        first_name: names.first,
        middle_name: names.middle || null,
        last_name: names.last,
        phone_number: resolvePhone(borrower) || "0000000000",
        nida_number: resolveNida(borrower),
        business_type: borrower.business_type || null,
        business_location: borrower.business_location || null,
        revenue_estimate: borrower.revenue_estimate ?? null,
        status: borrower.status || "active",
        external_reference_id: externalRef,
        next_of_kin_name: borrower.next_of_kin_name || null,
        next_of_kin_relationship: borrower.next_of_kin_relationship || null,
        next_of_kin_phone: borrower.next_of_kin_phone || null,
        photo_url: borrower.photo_url || null,
        region: borrower.region || null,
        district: borrower.district || null,
        street: borrower.street || borrower.address || null,
        updated_at: now,
      };

      // Check if client already exists by external_reference_id
      const { data: existing } = await supabase
        .from("clients")
        .select("id")
        .eq("external_reference_id", externalRef)
        .limit(1)
        .maybeSingle();

      if (existing) {
        // Update existing client
        const { error: updateErr } = await supabase
          .from("clients")
          .update(clientFields)
          .eq("id", existing.id);

        if (updateErr) {
          console.error("clients update error:", updateErr.message);
        } else {
          localId = existing.id;
        }
      } else {
        // Insert new client
        const { data: newClient, error: insertErr } = await supabase
          .from("clients")
          .insert(clientFields)
          .select("id")
          .single();

        if (insertErr) {
          console.error("clients insert error:", insertErr.message);
        } else {
          localId = newClient?.id || null;
        }
      }
    } else {
      // Soft-delete: mark client as inactive
      const { data: existing } = await supabase
        .from("clients")
        .select("id")
        .eq("external_reference_id", externalRef)
        .limit(1)
        .maybeSingle();

      if (existing) {
        localId = existing.id;
        await supabase
          .from("clients")
          .update({ status: "inactive", updated_at: now })
          .eq("id", existing.id);
      }
    }

    // ── 6. Record sync lineage ─────────────────────────────────────

    const { data: integration } = await supabase
      .from("loandisk_integrations")
      .select("id")
      .eq("is_active", true)
      .limit(1)
      .maybeSingle();

    const integrationId = integration?.id || "00000000-0000-0000-0000-000000000000";

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
        records_updated: (action === "updated" || action === "upserted") && localId ? 1 : 0,
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
        external_id: String(loandiskId),
        action: action,
        local_id: localId,
        source_data: payload,
        transformed_data: localId ? { client_id: localId, external_ref: externalRef } : null,
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
      resource: `borrower/${loandiskId}`,
      ip_address: req.headers.get("x-forwarded-for") || req.headers.get("cf-connecting-ip") || "unknown",
      user_agent: req.headers.get("user-agent") || "unknown",
      accessed_at: now,
      metadata: { event_key: eventKey, local_id: localId, branch_id: branchId },
    });

    // ── 8. Return success ──────────────────────────────────────────

    const durationMs = Date.now() - startTime;

    // Record invocation metric (fire-and-forget)
    supabase.from("edge_function_invocations").insert({
      function_name: "loandisk-webhook-borrower",
      invoked_at: now,
      duration_ms: durationMs,
      status: "success",
      request_size_bytes: Number(req.headers.get("content-length") || 0),
      response_size_bytes: 0,
      metadata: { event_key: eventKey, loandisk_id: loandiskId, local_id: localId },
    });

    return new Response(
      JSON.stringify({
        success: true,
        event: eventKey,
        loandisk_id: loandiskId,
        local_id: localId,
        action: action,
        duration_ms: durationMs,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : String(err);
    console.error("loandisk-webhook-borrower error:", errorMessage);

    const durationMs = Date.now() - startTime;

    try {
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
