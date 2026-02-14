const axios = require("axios").default;

/**
 * Apache Fineract API Client for Firebase Cloud Functions.
 *
 * Provides authenticated HTTP methods against a Fineract instance.
 * All requests include the required Fineract-Platform-TenantId header
 * and Basic Auth credentials.
 *
 * Fineract API docs: https://fineract.apache.org/docs/current
 */

class FineractClient {
  /**
   * @param {Object} config
   * @param {string} config.baseUrl   - Fineract API base URL (e.g. https://fineract.example.com/fineract-provider/api/v1)
   * @param {string} config.tenantId  - Fineract tenant identifier
   * @param {string} config.username  - Basic auth username
   * @param {string} config.password  - Basic auth password
   */
  constructor({ baseUrl, tenantId, username, password }) {
    this.baseUrl = baseUrl.replace(/\/+$/, "");
    this.tenantId = tenantId;
    this.auth = { username, password };
  }

  _headers() {
    return {
      "Content-Type": "application/json",
      "Fineract-Platform-TenantId": this.tenantId,
    };
  }

  async _request(method, path, data = null, params = null) {
    const url = `${this.baseUrl}${path}`;
    try {
      const response = await axios.request({
        method,
        url,
        headers: this._headers(),
        auth: this.auth,
        ...(params && { params }),
        ...(data && { data }),
      });
      return { statusCode: response.status, body: response.data };
    } catch (error) {
      const status = error.response ? error.response.status : 500;
      const body = error.response ? error.response.data : null;
      return {
        statusCode: status,
        body,
        error: error.message,
      };
    }
  }

  // ── Authentication ──────────────────────────────────────────────────
  async authenticate() {
    return this._request("POST", "/authentication", {
      username: this.auth.username,
      password: this.auth.password,
    });
  }

  // ── Clients ─────────────────────────────────────────────────────────
  async getClients(params = {}) {
    return this._request("GET", "/clients", null, params);
  }

  async getClient(clientId) {
    return this._request("GET", `/clients/${clientId}`);
  }

  async createClient(data) {
    return this._request("POST", "/clients", data);
  }

  async updateClient(clientId, data) {
    return this._request("PUT", `/clients/${clientId}`, data);
  }

  // ── Loans ───────────────────────────────────────────────────────────
  async getLoans(params = {}) {
    return this._request("GET", "/loans", null, params);
  }

  async getLoan(loanId) {
    return this._request("GET", `/loans/${loanId}`);
  }

  async getLoanWithAssociations(loanId, associations = "all") {
    return this._request("GET", `/loans/${loanId}`, null, { associations });
  }

  async createLoan(data) {
    return this._request("POST", "/loans", data);
  }

  async approveLoan(loanId, data) {
    return this._request(
      "POST",
      `/loans/${loanId}?command=approve`,
      data
    );
  }

  async disburseLoan(loanId, data) {
    return this._request(
      "POST",
      `/loans/${loanId}?command=disburse`,
      data
    );
  }

  // ── Loan Repayments ─────────────────────────────────────────────────
  async getLoanRepaymentSchedule(loanId) {
    return this._request("GET", `/loans/${loanId}`, null, {
      associations: "repaymentSchedule",
    });
  }

  async makeLoanRepayment(loanId, data) {
    return this._request(
      "POST",
      `/loans/${loanId}/transactions?command=repayment`,
      data
    );
  }

  // ── Loan Products ───────────────────────────────────────────────────
  async getLoanProducts() {
    return this._request("GET", "/loanproducts");
  }

  async getLoanProduct(productId) {
    return this._request("GET", `/loanproducts/${productId}`);
  }

  // ── Savings Accounts ────────────────────────────────────────────────
  async getSavingsAccounts(params = {}) {
    return this._request("GET", "/savingsaccounts", null, params);
  }

  async getSavingsAccount(accountId) {
    return this._request("GET", `/savingsaccounts/${accountId}`);
  }

  async createSavingsAccount(data) {
    return this._request("POST", "/savingsaccounts", data);
  }

  async savingsDeposit(accountId, data) {
    return this._request(
      "POST",
      `/savingsaccounts/${accountId}/transactions?command=deposit`,
      data
    );
  }

  async savingsWithdrawal(accountId, data) {
    return this._request(
      "POST",
      `/savingsaccounts/${accountId}/transactions?command=withdrawal`,
      data
    );
  }

  // ── Savings Products ────────────────────────────────────────────────
  async getSavingsProducts() {
    return this._request("GET", "/savingsproducts");
  }

  // ── Offices (Branches) ─────────────────────────────────────────────
  async getOffices() {
    return this._request("GET", "/offices");
  }

  async getOffice(officeId) {
    return this._request("GET", `/offices/${officeId}`);
  }

  // ── Staff ───────────────────────────────────────────────────────────
  async getStaff(params = {}) {
    return this._request("GET", "/staff", null, params);
  }

  async getStaffMember(staffId) {
    return this._request("GET", `/staff/${staffId}`);
  }

  // ── Charges ─────────────────────────────────────────────────────────
  async getCharges() {
    return this._request("GET", "/charges");
  }

  // ── Journal Entries (Accounting) ────────────────────────────────────
  async getJournalEntries(params = {}) {
    return this._request("GET", "/journalentries", null, params);
  }

  async createJournalEntry(data) {
    return this._request("POST", "/journalentries", data);
  }

  // ── GL Accounts ─────────────────────────────────────────────────────
  async getGLAccounts(params = {}) {
    return this._request("GET", "/glaccounts", null, params);
  }

  // ── Reports ─────────────────────────────────────────────────────────
  async runReport(reportName, params = {}) {
    return this._request("GET", `/runreports/${reportName}`, null, params);
  }

  // ── Search ──────────────────────────────────────────────────────────
  async search(query, resource = null) {
    const params = { query };
    if (resource) params.resource = resource;
    return this._request("GET", "/search", null, params);
  }
}

module.exports = { FineractClient };
