/**
 * LoanDisk REST API Client
 *
 * Used by the batch sync Edge Function to pull data from LoanDisk's
 * REST API on a scheduled basis.
 *
 * LoanDisk API docs: https://api.loandisk.com
 * Authentication: API Key via x-api-key header
 *
 * Endpoints used:
 *   GET /api/v1/borrowers          - List all borrowers
 *   GET /api/v1/borrowers/:id      - Get single borrower
 *   GET /api/v1/loans              - List all loans
 *   GET /api/v1/loans/:id          - Get single loan
 *   GET /api/v1/repayments         - List all repayments
 *   GET /api/v1/repayments/:id     - Get single repayment
 *
 * Pagination: offset + limit query params (default limit: 100)
 */

export interface LoandiskApiConfig {
  baseUrl: string;
  apiKey: string;
  branchId?: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  offset: number;
  limit: number;
  has_more: boolean;
}

export class LoandiskApiClient {
  private baseUrl: string;
  private apiKey: string;
  private branchId: number;

  constructor(config: LoandiskApiConfig) {
    this.baseUrl = config.baseUrl.replace(/\/+$/, "");
    this.apiKey = config.apiKey;
    this.branchId = config.branchId ?? 1;
  }

  private async request<T>(path: string, params: Record<string, string> = {}): Promise<T> {
    const url = new URL(`${this.baseUrl}${path}`);
    for (const [k, v] of Object.entries(params)) {
      url.searchParams.set(k, v);
    }

    const resp = await fetch(url.toString(), {
      method: "GET",
      headers: {
        "x-api-key": this.apiKey,
        "Accept": "application/json",
      },
    });

    if (!resp.ok) {
      const body = await resp.text().catch(() => "");
      throw new Error(`LoanDisk API ${resp.status}: ${path} — ${body}`);
    }

    return resp.json();
  }

  /**
   * Fetch all borrowers with pagination.
   * Handles LoanDisk API response variations:
   *   { data: [...] }  or  { borrowers: [...] }  or  [...]
   */
  async fetchBorrowers(
    offset = 0,
    limit = 100,
    modifiedSince?: string,
  ): Promise<PaginatedResponse<Record<string, unknown>>> {
    const params: Record<string, string> = {
      offset: String(offset),
      limit: String(limit),
      branch_id: String(this.branchId),
    };
    if (modifiedSince) params.modified_since = modifiedSince;

    const resp = await this.request<Record<string, unknown>>("/api/v1/borrowers", params);
    return this.normalizePaginatedResponse(resp, "borrowers", limit, offset);
  }

  async fetchLoans(
    offset = 0,
    limit = 100,
    modifiedSince?: string,
  ): Promise<PaginatedResponse<Record<string, unknown>>> {
    const params: Record<string, string> = {
      offset: String(offset),
      limit: String(limit),
      branch_id: String(this.branchId),
    };
    if (modifiedSince) params.modified_since = modifiedSince;

    const resp = await this.request<Record<string, unknown>>("/api/v1/loans", params);
    return this.normalizePaginatedResponse(resp, "loans", limit, offset);
  }

  async fetchRepayments(
    offset = 0,
    limit = 100,
    modifiedSince?: string,
  ): Promise<PaginatedResponse<Record<string, unknown>>> {
    const params: Record<string, string> = {
      offset: String(offset),
      limit: String(limit),
      branch_id: String(this.branchId),
    };
    if (modifiedSince) params.modified_since = modifiedSince;

    const resp = await this.request<Record<string, unknown>>("/api/v1/repayments", params);
    return this.normalizePaginatedResponse(resp, "repayments", limit, offset);
  }

  /**
   * Normalize LoanDisk's varying API response format into a
   * consistent paginated structure.
   */
  private normalizePaginatedResponse(
    resp: unknown,
    key: string,
    limit: number,
    offset: number,
  ): PaginatedResponse<Record<string, unknown>> {
    // Handle: array response
    if (Array.isArray(resp)) {
      return {
        data: resp,
        total: resp.length,
        offset,
        limit,
        has_more: resp.length >= limit,
      };
    }

    const obj = resp as Record<string, unknown>;

    // Handle: { data: [...] } or { borrowers: [...] }
    const items = (obj.data || obj[key] || []) as Record<string, unknown>[];
    const total = (obj.total || obj.count || items.length) as number;

    return {
      data: Array.isArray(items) ? items : [],
      total,
      offset,
      limit,
      has_more: items.length >= limit,
    };
  }

  /**
   * Fetch ALL pages of an entity type. Automatically paginates
   * through all results.
   */
  async fetchAll(
    entityType: "borrowers" | "loans" | "repayments",
    modifiedSince?: string,
    pageSize = 100,
  ): Promise<Record<string, unknown>[]> {
    const all: Record<string, unknown>[] = [];
    let offset = 0;
    let hasMore = true;

    const fetcher =
      entityType === "borrowers"
        ? this.fetchBorrowers.bind(this)
        : entityType === "loans"
        ? this.fetchLoans.bind(this)
        : this.fetchRepayments.bind(this);

    while (hasMore) {
      const page = await fetcher(offset, pageSize, modifiedSince);
      all.push(...page.data);
      hasMore = page.has_more;
      offset += pageSize;

      // Safety: prevent infinite loops
      if (offset > 100_000) break;
    }

    return all;
  }
}

/**
 * Create a LoanDisk API client from environment variables.
 */
export function createLoandiskClient(): LoandiskApiClient {
  const baseUrl = Deno.env.get("LOANDISK_API_BASE_URL") || "https://api.loandisk.com";
  const apiKey = Deno.env.get("LOANDISK_API_KEY");

  if (!apiKey) {
    throw new Error("LOANDISK_API_KEY environment variable is required for batch sync");
  }

  return new LoandiskApiClient({ baseUrl, apiKey });
}
