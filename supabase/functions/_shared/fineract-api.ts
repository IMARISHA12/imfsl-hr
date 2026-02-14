/**
 * Apache Fineract REST API Client
 *
 * Connects to Apache Fineract's REST API v1 for:
 *   - Client management (CRUD)
 *   - Loan lifecycle (apply, approve, disburse, repay, close)
 *   - Loan products
 *   - Savings accounts
 *   - Staff and offices
 *   - Repayment schedule
 *
 * Authentication: HTTP Basic Auth + Fineract-Platform-TenantId header
 * API docs: https://fineract.apache.org/docs/current
 */

import type {
  FineractClient,
  FineractLoan,
  FineractLoanTransaction,
  FineractLoanProduct,
  FineractSavingsAccount,
  FineractOffice,
  FineractStaff,
} from "./fineract-types.ts";

export interface FineractApiConfig {
  baseUrl: string;
  username: string;
  password: string;
  tenantId: string;
}

export interface PaginatedResponse<T> {
  totalFilteredRecords: number;
  pageItems: T[];
}

export class FineractApiClient {
  private baseUrl: string;
  private authHeader: string;
  private tenantId: string;

  constructor(config: FineractApiConfig) {
    this.baseUrl = config.baseUrl.replace(/\/+$/, "");
    this.authHeader = "Basic " + btoa(`${config.username}:${config.password}`);
    this.tenantId = config.tenantId;
  }

  private async request<T>(
    method: string,
    path: string,
    params: Record<string, string> = {},
    body?: unknown,
  ): Promise<T> {
    const url = new URL(`${this.baseUrl}/fineract-provider/api/v1${path}`);
    for (const [k, v] of Object.entries(params)) {
      url.searchParams.set(k, v);
    }

    const headers: Record<string, string> = {
      "Authorization": this.authHeader,
      "Fineract-Platform-TenantId": this.tenantId,
      "Accept": "application/json",
    };

    const init: RequestInit = { method, headers };

    if (body && (method === "POST" || method === "PUT")) {
      headers["Content-Type"] = "application/json";
      init.body = JSON.stringify(body);
    }

    const resp = await fetch(url.toString(), init);

    if (!resp.ok) {
      const errorBody = await resp.text().catch(() => "");
      throw new Error(`Fineract API ${resp.status} ${method} ${path}: ${errorBody}`);
    }

    if (resp.status === 204) return {} as T;
    return resp.json();
  }

  // ─── Clients ──────────────────────────────────────────────────────

  async getClients(offset = 0, limit = 200): Promise<PaginatedResponse<FineractClient>> {
    return this.request("GET", "/clients", {
      offset: String(offset),
      limit: String(limit),
      orderBy: "id",
      sortOrder: "ASC",
    });
  }

  async getClient(clientId: number): Promise<FineractClient> {
    return this.request("GET", `/clients/${clientId}`);
  }

  async searchClients(query: string): Promise<PaginatedResponse<FineractClient>> {
    return this.request("GET", "/clients", {
      displayName: query,
      limit: "50",
    });
  }

  async createClient(data: Record<string, unknown>): Promise<{ clientId: number; resourceId: number }> {
    return this.request("POST", "/clients", {}, data);
  }

  async updateClient(clientId: number, data: Record<string, unknown>): Promise<{ clientId: number }> {
    return this.request("PUT", `/clients/${clientId}`, {}, data);
  }

  async getClientAccounts(clientId: number): Promise<{
    loanAccounts?: FineractLoan[];
    savingsAccounts?: FineractSavingsAccount[];
  }> {
    return this.request("GET", `/clients/${clientId}/accounts`);
  }

  // ─── Loans ────────────────────────────────────────────────────────

  async getLoans(offset = 0, limit = 200): Promise<PaginatedResponse<FineractLoan>> {
    return this.request("GET", "/loans", {
      offset: String(offset),
      limit: String(limit),
      orderBy: "id",
      sortOrder: "ASC",
    });
  }

  async getLoan(loanId: number): Promise<FineractLoan> {
    return this.request("GET", `/loans/${loanId}`, {
      associations: "all",
    });
  }

  async createLoanApplication(data: Record<string, unknown>): Promise<{ loanId: number; resourceId: number }> {
    return this.request("POST", "/loans", {}, data);
  }

  async approveLoan(loanId: number, approvedOnDate: string, note?: string): Promise<{ loanId: number }> {
    return this.request("POST", `/loans/${loanId}`, { command: "approve" }, {
      approvedOnDate,
      approvedLoanAmount: undefined,
      note: note || "",
      dateFormat: "dd MMMM yyyy",
      locale: "en",
    });
  }

  async disburseLoan(
    loanId: number,
    actualDisbursementDate: string,
    note?: string,
  ): Promise<{ loanId: number }> {
    return this.request("POST", `/loans/${loanId}`, { command: "disburse" }, {
      actualDisbursementDate,
      note: note || "",
      dateFormat: "dd MMMM yyyy",
      locale: "en",
    });
  }

  async makeRepayment(
    loanId: number,
    transactionDate: string,
    transactionAmount: number,
    paymentTypeId?: number,
    note?: string,
  ): Promise<{ resourceId: number }> {
    return this.request("POST", `/loans/${loanId}/transactions`, { command: "repayment" }, {
      transactionDate,
      transactionAmount,
      paymentTypeId,
      note: note || "",
      dateFormat: "dd MMMM yyyy",
      locale: "en",
    });
  }

  async closeLoan(loanId: number, closedOnDate: string, note?: string): Promise<{ loanId: number }> {
    return this.request("POST", `/loans/${loanId}`, { command: "close" }, {
      transactionDate: closedOnDate,
      note: note || "",
      dateFormat: "dd MMMM yyyy",
      locale: "en",
    });
  }

  async writeOffLoan(loanId: number, writtenOffOnDate: string, note?: string): Promise<{ resourceId: number }> {
    return this.request("POST", `/loans/${loanId}/transactions`, { command: "writeoff" }, {
      transactionDate: writtenOffOnDate,
      note: note || "",
      dateFormat: "dd MMMM yyyy",
      locale: "en",
    });
  }

  // ─── Loan Transactions ────────────────────────────────────────────

  async getLoanTransactions(loanId: number): Promise<FineractLoanTransaction[]> {
    const loan = await this.getLoan(loanId);
    return (loan as unknown as { transactions?: FineractLoanTransaction[] }).transactions || [];
  }

  // ─── Loan Products ────────────────────────────────────────────────

  async getLoanProducts(): Promise<FineractLoanProduct[]> {
    return this.request("GET", "/loanproducts");
  }

  async getLoanProduct(productId: number): Promise<FineractLoanProduct> {
    return this.request("GET", `/loanproducts/${productId}`);
  }

  // ─── Savings ──────────────────────────────────────────────────────

  async getSavingsAccounts(offset = 0, limit = 200): Promise<PaginatedResponse<FineractSavingsAccount>> {
    return this.request("GET", "/savingsaccounts", {
      offset: String(offset),
      limit: String(limit),
    });
  }

  async getSavingsAccount(accountId: number): Promise<FineractSavingsAccount> {
    return this.request("GET", `/savingsaccounts/${accountId}`);
  }

  // ─── Organization ─────────────────────────────────────────────────

  async getOffices(): Promise<FineractOffice[]> {
    return this.request("GET", "/offices");
  }

  async getStaff(officeId?: number): Promise<FineractStaff[]> {
    const params: Record<string, string> = {};
    if (officeId) params.officeId = String(officeId);
    return this.request("GET", "/staff", params);
  }

  // ─── Hooks (Webhooks) ─────────────────────────────────────────────

  async getHooks(): Promise<unknown[]> {
    return this.request("GET", "/hooks");
  }

  async createHook(data: {
    name: string;
    displayName: string;
    isActive: boolean;
    events: { actionName: string; entityName: string }[];
    config: { fieldName: string; fieldValue: string }[];
  }): Promise<{ resourceId: number }> {
    return this.request("POST", "/hooks", {}, data);
  }

  // ─── Pagination Helpers ───────────────────────────────────────────

  async fetchAllClients(): Promise<FineractClient[]> {
    return this.fetchAllPaginated<FineractClient>((offset, limit) => this.getClients(offset, limit));
  }

  async fetchAllLoans(): Promise<FineractLoan[]> {
    return this.fetchAllPaginated<FineractLoan>((offset, limit) => this.getLoans(offset, limit));
  }

  async fetchAllSavingsAccounts(): Promise<FineractSavingsAccount[]> {
    return this.fetchAllPaginated<FineractSavingsAccount>((offset, limit) => this.getSavingsAccounts(offset, limit));
  }

  private async fetchAllPaginated<T>(
    fetcher: (offset: number, limit: number) => Promise<PaginatedResponse<T>>,
    pageSize = 200,
  ): Promise<T[]> {
    const all: T[] = [];
    let offset = 0;

    while (true) {
      const page = await fetcher(offset, pageSize);
      const items = page.pageItems || [];
      all.push(...items);

      if (items.length < pageSize || all.length >= page.totalFilteredRecords) break;
      offset += pageSize;

      // Safety limit
      if (offset > 100_000) break;
    }

    return all;
  }
}

/**
 * Create a Fineract API client from environment variables.
 *
 * Required env vars:
 *   FINERACT_BASE_URL    - e.g. https://fineract.imfsl.co.tz
 *   FINERACT_USERNAME    - API username
 *   FINERACT_PASSWORD    - API password
 *   FINERACT_TENANT_ID   - Tenant identifier (default: "default")
 */
export function createFineractClient(): FineractApiClient {
  const baseUrl = Deno.env.get("FINERACT_BASE_URL");
  const username = Deno.env.get("FINERACT_USERNAME");
  const password = Deno.env.get("FINERACT_PASSWORD");
  const tenantId = Deno.env.get("FINERACT_TENANT_ID") || "default";

  if (!baseUrl) throw new Error("FINERACT_BASE_URL environment variable is required");
  if (!username) throw new Error("FINERACT_USERNAME environment variable is required");
  if (!password) throw new Error("FINERACT_PASSWORD environment variable is required");

  return new FineractApiClient({ baseUrl, username, password, tenantId });
}
