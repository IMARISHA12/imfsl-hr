/**
 * Shared webhook helpers used by all LoanDisk webhook Edge Functions.
 *
 * Provides authentication, event resolution, sync lineage recording,
 * access logging, and metric tracking.
 */

import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import type { WebhookPayload, SyncResult } from "./loandisk-types.ts";

// ─── Authentication ──────────────────────────────────────────────────

export function authenticateWebhook(req: Request): { ok: true } | { ok: false; reason: string } {
  const secret = Deno.env.get("LOANDISK_WEBHOOK_SECRET");
  if (!secret) return { ok: false, reason: "LOANDISK_WEBHOOK_SECRET not configured" };

  const incoming =
    req.headers.get("x-webhook-secret") ||
    req.headers.get("authorization")?.replace(/^Bearer\s+/i, "");

  if (incoming !== secret) return { ok: false, reason: "invalid_secret" };
  return { ok: true };
}

// ─── Event Resolution ────────────────────────────────────────────────

export function resolveEventKey(payload: WebhookPayload, defaultEntity: string): string {
  return payload.event || payload.event_type || payload.action || `${defaultEntity}.unknown`;
}

export function mapAction(eventKey: string): string {
  if (eventKey.includes("create") || eventKey.includes("new")) return "created";
  if (eventKey.includes("update") || eventKey.includes("edit")) return "updated";
  if (eventKey.includes("delete") || eventKey.includes("remove")) return "deleted";
  return "upserted";
}

// ─── ID Resolution ───────────────────────────────────────────────────

export function resolveNumericId(raw: unknown): number | null {
  if (raw == null) return null;
  const num = Number(raw);
  return Number.isFinite(num) ? num : null;
}

export function resolveBranchId(raw: unknown): number {
  if (raw == null) return 1;
  const num = Number(raw);
  return Number.isFinite(num) ? num : 1;
}

// ─── Request Metadata ────────────────────────────────────────────────

export function getRequestMeta(req: Request) {
  return {
    ip: req.headers.get("x-forwarded-for") || req.headers.get("cf-connecting-ip") || "unknown",
    userAgent: req.headers.get("user-agent") || "unknown",
    contentLength: Number(req.headers.get("content-length") || 0),
  };
}

// ─── Webhook Event Logging ───────────────────────────────────────────

export async function logWebhookEvent(
  supabase: SupabaseClient,
  provider: string,
  eventKey: string,
  payload: WebhookPayload,
): Promise<void> {
  const { error } = await supabase.from("webhook_events").insert({
    provider,
    event_key: eventKey,
    received_at: new Date().toISOString(),
    payload,
  });
  if (error) console.error("webhook_events insert error:", error.message);
}

// ─── Auth Failure Logging ────────────────────────────────────────────

/**
 * Log an authentication failure via webhook_failures table.
 * Note: loandisk_access_log requires a user_id UUID FK, so we use
 * webhook_failures for anonymous/failed webhook requests instead.
 */
export async function logAuthFailure(
  supabase: SupabaseClient,
  functionName: string,
  req: Request,
): Promise<void> {
  const meta = getRequestMeta(req);
  const { error } = await supabase.from("webhook_failures").insert({
    error_message: `Auth failed for ${functionName}`,
    raw_payload: { ip: meta.ip, user_agent: meta.userAgent },
  });
  if (error) console.error("webhook_failures insert error:", error.message);
}

// ─── Access Logging ──────────────────────────────────────────────────

/**
 * Log a successful webhook access. Uses edge_function_invocations since
 * loandisk_access_log requires a user_id UUID FK (it's designed for
 * authenticated user auditing, not anonymous webhook calls).
 */
export async function logAccess(
  supabase: SupabaseClient,
  _req: Request,
  action: string,
  resource: string,
  extra: Record<string, unknown> = {},
): Promise<void> {
  // Access details are already captured in:
  //  - webhook_events (raw payload)
  //  - loandisk_sync_items (sync lineage)
  //  - edge_function_invocations (metrics)
  // So we just log a console message for debugging
  console.log(`webhook_access: ${action} ${resource}`, extra);
}

// ─── Sync Lineage Recording ─────────────────────────────────────────

export async function recordSyncLineage(
  supabase: SupabaseClient,
  result: SyncResult,
  payload: WebhookPayload,
  errorMessage?: string,
): Promise<void> {
  const { data: integration } = await supabase
    .from("loandisk_integrations")
    .select("id")
    .eq("is_active", true)
    .limit(1)
    .maybeSingle();

  const integrationId = integration?.id || "00000000-0000-0000-0000-000000000000";
  const now = new Date().toISOString();

  const { data: syncRun, error: syncRunErr } = await supabase
    .from("loandisk_sync_runs")
    .insert({
      integration_id: integrationId,
      run_type: "manual",
      started_at: now,
      completed_at: now,
      status: errorMessage || !result.localId ? "partial" : "completed",
      records_fetched: 1,
      records_created: result.action === "created" && result.localId ? 1 : 0,
      records_updated: (result.action === "updated" || result.action === "upserted") && result.localId ? 1 : 0,
      records_skipped: 0,
      records_failed: result.localId ? 0 : 1,
      entity_types: [result.entityType],
      error_message: errorMessage || null,
    })
    .select("id")
    .single();

  if (syncRun) {
    await supabase.from("loandisk_sync_items").insert({
      sync_run_id: syncRun.id,
      entity_type: result.entityType,
      external_id: result.externalRef,
      action: result.action,
      local_id: result.localId,
      source_data: payload,
      transformed_data: result.localId
        ? { [`${result.entityType}_id`]: result.localId, external_ref: result.externalRef }
        : null,
      error_message: errorMessage || null,
      synced_at: now,
    });
  } else if (syncRunErr) {
    console.error("loandisk_sync_runs insert error:", syncRunErr.message);
  }
}

// ─── Invocation Metrics ──────────────────────────────────────────────

export function recordMetric(
  supabase: SupabaseClient,
  functionName: string,
  startTime: number,
  status: "success" | "error",
  req: Request,
  extra: Record<string, unknown> = {},
  errorMessage?: string,
): void {
  const durationMs = Date.now() - startTime;
  const meta = getRequestMeta(req);
  // Fire-and-forget
  supabase.from("edge_function_invocations").insert({
    function_name: functionName,
    invoked_at: new Date().toISOString(),
    duration_ms: durationMs,
    status,
    error_message: errorMessage || null,
    request_size_bytes: meta.contentLength,
    response_size_bytes: 0,
    metadata: extra,
  });
}
