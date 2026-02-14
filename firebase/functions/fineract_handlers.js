const admin = require("firebase-admin");
const { FineractClient } = require("./fineract_client");

/**
 * Cached Fineract credentials loaded from Firestore.
 * Credentials are stored in the `fineract_config` Firestore document
 * and cached for the lifetime of the Cloud Function instance.
 */
let _cachedClient = null;
let _cacheTimestamp = 0;
const CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

/**
 * Loads Fineract credentials from Firestore and creates an authenticated client.
 * Credentials are cached for 5 minutes to avoid repeated Firestore reads.
 *
 * Firestore document: `config/fineract`
 * Required fields: baseUrl, tenantId, username, password
 */
async function getFineractClient() {
  const now = Date.now();
  if (_cachedClient && now - _cacheTimestamp < CACHE_TTL_MS) {
    return _cachedClient;
  }

  try {
    const doc = await admin
      .firestore()
      .collection("config")
      .doc("fineract")
      .get();

    if (!doc.exists) {
      return null;
    }

    const config = doc.data();
    const { baseUrl, tenantId, username, password } = config;
    if (!baseUrl || !tenantId || !username || !password) {
      return null;
    }

    _cachedClient = new FineractClient({ baseUrl, tenantId, username, password });
    _cacheTimestamp = now;
    return _cachedClient;
  } catch (error) {
    console.error("Failed to load Fineract config from Firestore:", error);
    return null;
  }
}

/** Invalidates the cached client so the next call reloads from Firestore. */
function invalidateCache() {
  _cachedClient = null;
  _cacheTimestamp = 0;
}

const MISSING_CONFIG = {
  statusCode: 500,
  error: "Fineract integration not configured. Set credentials in Firestore config/fineract document.",
};

// ── Handler map: callName → handler function ────────────────────────

async function fineractGetClients(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  return client.getClients(variables.params || {});
}

async function fineractGetClient(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  if (!variables.clientId) return { statusCode: 400, error: "Missing clientId" };
  return client.getClient(variables.clientId);
}

async function fineractCreateClient(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  if (!variables.data) return { statusCode: 400, error: "Missing client data" };
  return client.createClient(variables.data);
}

async function fineractGetLoans(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  return client.getLoans(variables.params || {});
}

async function fineractGetLoan(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  if (!variables.loanId) return { statusCode: 400, error: "Missing loanId" };
  return client.getLoanWithAssociations(
    variables.loanId,
    variables.associations || "all"
  );
}

async function fineractCreateLoan(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  if (!variables.data) return { statusCode: 400, error: "Missing loan data" };
  return client.createLoan(variables.data);
}

async function fineractApproveLoan(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  if (!variables.loanId) return { statusCode: 400, error: "Missing loanId" };
  return client.approveLoan(variables.loanId, variables.data || {});
}

async function fineractDisburseLoan(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  if (!variables.loanId) return { statusCode: 400, error: "Missing loanId" };
  return client.disburseLoan(variables.loanId, variables.data || {});
}

async function fineractMakeRepayment(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  if (!variables.loanId) return { statusCode: 400, error: "Missing loanId" };
  if (!variables.data) return { statusCode: 400, error: "Missing repayment data" };
  return client.makeLoanRepayment(variables.loanId, variables.data);
}

async function fineractGetSavingsAccounts(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  return client.getSavingsAccounts(variables.params || {});
}

async function fineractGetOffices(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  return client.getOffices();
}

async function fineractGetStaff(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  return client.getStaff(variables.params || {});
}

async function fineractGetLoanProducts(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  return client.getLoanProducts();
}

async function fineractGetGLAccounts(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  return client.getGLAccounts(variables.params || {});
}

async function fineractGetJournalEntries(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  return client.getJournalEntries(variables.params || {});
}

async function fineractSearch(context, variables) {
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  if (!variables.query) return { statusCode: 400, error: "Missing search query" };
  return client.search(variables.query, variables.resource || null);
}

async function fineractRefreshConfig(context, variables) {
  invalidateCache();
  const client = await getFineractClient();
  if (!client) return MISSING_CONFIG;
  return { statusCode: 200, body: { message: "Fineract config reloaded successfully" } };
}

/**
 * Map of all Fineract call names to their handler functions.
 * Registered into the api_manager callMap via spread operator.
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
  fineractRefreshConfig,
};

module.exports = { fineractCallMap };
