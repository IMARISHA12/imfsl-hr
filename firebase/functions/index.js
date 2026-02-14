const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const { makeApiCall } = require("./api_manager");

/**
 * Callable Cloud Function for Fineract API operations.
 *
 * Clients send { callName: "fineractGetLoans", variables: { ... } }
 * and receive the Fineract API response.
 */
exports.fineractApi = functions.https.onCall(async (data, context) => {
  // Require authentication
  if (!context.auth) {
    return {
      statusCode: 401,
      error: "Authentication required for Fineract API access.",
    };
  }
  return makeApiCall(context, data);
});
