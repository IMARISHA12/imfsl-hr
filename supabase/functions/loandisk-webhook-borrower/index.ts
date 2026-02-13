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
 *   4. Transform & upsert into borrowers (canonical borrower record)
 *   5. Transform & upsert into clients (canonical client record with richer fields)
 *   6. On delete: cascade soft-delete to borrowers, clients, and active loans
 *   7. Record sync lineage in loandisk_sync_runs / loandisk_sync_items
 *   8. Record invocation metrics in edge_function_invocations
 *
 * Verified table schemas (2026-02-13):
 *
 *   raw_borrowers:
 *     id(uuid) | loandisk_id(bigint,NOT NULL) | branch_id(bigint,NOT NULL)
 *     payload(jsonb,NOT NULL) | source(text,default:'backfill')
 *     fetched_at | created_at | updated_at
 *     UNIQUE(loandisk_id, branch_id)
 *
 *   borrowers:
 *     id(uuid) | full_name(NOT NULL) | phone_number(NOT NULL)
 *     nida_number | location_gps | status(default:'active')
 *     created_by | created_at
 *
 *   clients:
 *     id(uuid) | first_name | middle_name | last_name | phone_number
 *     nida_number | business_type | business_location | revenue_estimate
 *     status | external_reference_id | next_of_kin_* | region | district
 *     street | photo_url | credit_score(default:50) | risk_level(default:'Medium')
 *     created_at | updated_at | ...
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase-client.ts";
import type { LoandiskBorrower, WebhookPayload } from "../_shared/loandisk-types.ts";
import {
  authenticateWebhook,
  resolveEventKey,
  mapAction,
  resolveNumericId,
  resolveBranchId,
  logWebhookEvent,
  logAuthFailure,
  logAccess,
  recordSyncLineage,
  recordMetric,
} from "../_shared/webhook-helpers.ts";
import {
  transformBorrower,
  transformClient,
  buildFullName,
  resolvePhone,
} from "../_shared/business-logic.ts";

const FUNCTION_NAME = "loandisk-webhook-borrower";

// ─── Data Extraction ─────────────────────────────────────────────────

function resolveBorrowerData(payload: WebhookPayload): LoandiskBorrower {
  if (payload.data && typeof payload.data === "object") return payload.data as LoandiskBorrower;
  if (payload.borrower && typeof payload.borrower === "object") return payload.borrower;
  const { event, event_type, action, ...rest } = payload;
  return rest as LoandiskBorrower;
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
    const auth = authenticateWebhook(req);
    if (!auth.ok) {
      await logAuthFailure(supabase, FUNCTION_NAME, req);
      return new Response(
        JSON.stringify({ success: false, error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 2. Parse payload ───────────────────────────────────────────
    const payload: WebhookPayload = await req.json();
    eventKey = resolveEventKey(payload, "borrower");
    const borrower = resolveBorrowerData(payload);
    const loandiskId = resolveNumericId(borrower.borrower_id ?? borrower.id);

    if (loandiskId === null) {
      throw new Error("Payload missing borrower identifier (borrower_id or id must be a number)");
    }

    const branchId = resolveBranchId(borrower.branch_id);
    const externalRef = `LD-${loandiskId}`;

    // ── 3. Store raw webhook event ─────────────────────────────────
    await logWebhookEvent(supabase, "loandisk", eventKey, payload);

    // ── 4. Upsert raw_borrowers ────────────────────────────────────
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
        { onConflict: "loandisk_id,branch_id" },
      );

    if (rawErr) console.error("raw_borrowers upsert error:", rawErr.message);

    // ── 5. Transform & upsert records ──────────────────────────────
    const action = mapAction(eventKey);
    let localId: string | null = null;
    const now = new Date().toISOString();

    if (action !== "deleted") {
      // ── 5a. Upsert borrowers table ─────────────────────────────
      const borrowerFields = transformBorrower(borrower);
      const { data: existingBorrower } = await supabase
        .from("borrowers")
        .select("id")
        .eq("phone_number", borrowerFields.phone_number)
        .limit(1)
        .maybeSingle();

      if (existingBorrower) {
        await supabase.from("borrowers").update(borrowerFields).eq("id", existingBorrower.id);
      } else {
        await supabase.from("borrowers").insert(borrowerFields);
      }

      // ── 5b. Upsert clients table ──────────────────────────────
      const clientFields = transformClient(borrower, externalRef);

      const { data: existingClient } = await supabase
        .from("clients")
        .select("id")
        .eq("external_reference_id", externalRef)
        .limit(1)
        .maybeSingle();

      if (existingClient) {
        const { error: updateErr } = await supabase
          .from("clients")
          .update(clientFields)
          .eq("id", existingClient.id);

        if (updateErr) {
          console.error("clients update error:", updateErr.message);
        } else {
          localId = existingClient.id;
        }
      } else {
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
      // ── 6. Deletion cascade ────────────────────────────────────
      // Soft-delete borrower, client, and cancel active loans
      const phone = resolvePhone(borrower);

      // 6a. Deactivate borrower
      if (phone && phone !== "0000000000") {
        await supabase
          .from("borrowers")
          .update({ status: "inactive" })
          .eq("phone_number", phone);
      }

      // 6b. Deactivate client
      const { data: existingClient } = await supabase
        .from("clients")
        .select("id")
        .eq("external_reference_id", externalRef)
        .limit(1)
        .maybeSingle();

      if (existingClient) {
        localId = existingClient.id;
        await supabase
          .from("clients")
          .update({ status: "inactive", updated_at: now })
          .eq("id", existingClient.id);
      }

      // 6c. Cancel active loans for this borrower
      if (phone && phone !== "0000000000") {
        const { data: borrowerRecord } = await supabase
          .from("borrowers")
          .select("id")
          .eq("phone_number", phone)
          .limit(1)
          .maybeSingle();

        if (borrowerRecord) {
          await supabase
            .from("loans")
            .update({ status: "cancelled" })
            .eq("borrower_id", borrowerRecord.id)
            .in("status", ["pending", "active"]);
        }
      }
    }

    // ── 7. Record sync lineage ─────────────────────────────────────
    await recordSyncLineage(
      supabase,
      { action, localId, externalRef, entityType: "borrower" },
      payload,
      rawErr?.message,
    );

    // ── 8. Log access ──────────────────────────────────────────────
    await logAccess(supabase, req, action, `borrower/${loandiskId}`, {
      event_key: eventKey,
      local_id: localId,
      branch_id: branchId,
    });

    const durationMs = Date.now() - startTime;
    recordMetric(supabase, FUNCTION_NAME, startTime, "success", req, {
      event_key: eventKey,
      loandisk_id: loandiskId,
      local_id: localId,
    });

    return new Response(
      JSON.stringify({
        success: true,
        event: eventKey,
        loandisk_id: loandiskId,
        local_id: localId,
        action,
        duration_ms: durationMs,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : String(err);
    console.error(`${FUNCTION_NAME} error:`, errorMessage);
    recordMetric(supabase, FUNCTION_NAME, startTime, "error", req, { event_key: eventKey }, errorMessage);

    return new Response(
      JSON.stringify({
        success: false,
        error: errorMessage,
        event: eventKey,
        duration_ms: Date.now() - startTime,
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
