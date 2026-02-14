const admin = require("firebase-admin");
const { FineractClient } = require("./fineract_client");

/**
 * Creates a FineractClient from an integration record stored in Firestore
 * or from the provided credentials in the request variables.
 */
function createClientFromVariables(variables) {
  const { baseUrl, tenantId, username, password } = variables;
  if (!baseUrl || !tenantId || !username || !password) {
    return null;
  }
  return new FineractClient({ baseUrl, tenantId, username, password });
}

// ── Handler map: callName → handler function ────────────────────────

async function fineractGetClients(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  return client.getClients(variables.params || {});
}

async function fineractGetClient(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  if (!variables.clientId) return { statusCode: 400, error: "Missing clientId" };
  return client.getClient(variables.clientId);
}

async function fineractCreateClient(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  if (!variables.data) return { statusCode: 400, error: "Missing client data" };
  return client.createClient(variables.data);
}

async function fineractGetLoans(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  return client.getLoans(variables.params || {});
}

async function fineractGetLoan(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  if (!variables.loanId) return { statusCode: 400, error: "Missing loanId" };
  return client.getLoanWithAssociations(
    variables.loanId,
    variables.associations || "all"
  );
}

async function fineractCreateLoan(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  if (!variables.data) return { statusCode: 400, error: "Missing loan data" };
  return client.createLoan(variables.data);
}

async function fineractApproveLoan(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  if (!variables.loanId) return { statusCode: 400, error: "Missing loanId" };
  return client.approveLoan(variables.loanId, variables.data || {});
}

async function fineractDisburseLoan(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  if (!variables.loanId) return { statusCode: 400, error: "Missing loanId" };
  return client.disburseLoan(variables.loanId, variables.data || {});
}

async function fineractMakeRepayment(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  if (!variables.loanId) return { statusCode: 400, error: "Missing loanId" };
  if (!variables.data) return { statusCode: 400, error: "Missing repayment data" };
  return client.makeLoanRepayment(variables.loanId, variables.data);
}

async function fineractGetSavingsAccounts(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  return client.getSavingsAccounts(variables.params || {});
}

async function fineractGetOffices(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  return client.getOffices();
}

async function fineractGetStaff(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  return client.getStaff(variables.params || {});
}

async function fineractGetLoanProducts(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  return client.getLoanProducts();
}

async function fineractGetGLAccounts(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  return client.getGLAccounts(variables.params || {});
}

async function fineractGetJournalEntries(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  return client.getJournalEntries(variables.params || {});
}

async function fineractSearch(context, variables) {
  const client = createClientFromVariables(variables);
  if (!client) return { statusCode: 400, error: "Missing Fineract credentials" };
  if (!variables.query) return { statusCode: 400, error: "Missing search query" };
  return client.search(variables.query, variables.resource || null);
}

/**
 * Map of all Fineract call names to their handler functions.
 * Register these into the api_manager callMap.
 */
const fineractCallMap = {
  fineractGetClients,
  fineractGetClient,
  fineractCreateClient,
  fineractGetLoans,
  fineractGetLoan,
  fineractCreateLoan,
  fineractApproveLoan,
  fineractDisburseLoan,
  fineractMakeRepayment,
  fineractGetSavingsAccounts,
  fineractGetOffices,
  fineractGetStaff,
  fineractGetLoanProducts,
  fineractGetGLAccounts,
  fineractGetJournalEntries,
  fineractSearch,
};

module.exports = { fineractCallMap };
