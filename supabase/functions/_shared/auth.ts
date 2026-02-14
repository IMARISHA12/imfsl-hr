import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { jsonResponse } from "./cors.ts";

export interface AuthUser {
  id: string;
  email?: string;
  role?: string;
}

/**
 * Extracts and validates the JWT from the Authorization header.
 * Returns the authenticated user or a 401 Response.
 */
export async function requireAuth(
  req: Request
): Promise<AuthUser | Response> {
  const authHeader = req.headers.get("Authorization");

  if (!authHeader?.startsWith("Bearer ")) {
    return jsonResponse({ error: "Missing or invalid Authorization header" }, 401);
  }

  const token = authHeader.replace("Bearer ", "");

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // Create a client with the user's JWT to verify it
  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: { user }, error } = await userClient.auth.getUser(token);

  if (error || !user) {
    return jsonResponse({ error: "Invalid or expired token" }, 401);
  }

  // Extract role from user metadata or app_metadata
  const role = user.app_metadata?.role ?? user.user_metadata?.role ?? "staff";

  return { id: user.id, email: user.email, role };
}

/**
 * Checks if the authenticated user has one of the required roles.
 * Returns null if authorized, or a 403 Response if not.
 */
export function requireRole(
  user: AuthUser,
  allowedRoles: string[]
): Response | null {
  if (!allowedRoles.includes(user.role ?? "")) {
    return jsonResponse(
      { error: `Forbidden: requires one of [${allowedRoles.join(", ")}]` },
      403
    );
  }
  return null;
}
