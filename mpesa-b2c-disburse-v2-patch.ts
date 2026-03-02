// mpesa-b2c-disburse v2 — Savings Withdrawal Support
// ====================================================
// PATCH: Add these blocks to the existing mpesa-b2c-disburse edge function.
//
// Changes:
// 1. Accept purpose: 'SAVINGS_WITHDRAWAL' alongside 'LOAN_DISBURSEMENT'
// 2. On B2C callback success for withdrawals: update withdrawal status + completed_at
// 3. On B2C callback failure for withdrawals: update status to FAILED + restore balance

// ══════════════════════════════════════════════════════════════════════
// ADD to the request handler (alongside existing LOAN_DISBURSEMENT logic):
// ══════════════════════════════════════════════════════════════════════

/*
  // In the main serve() handler, after parsing the body:

  if (purpose === 'SAVINGS_WITHDRAWAL') {
    const { withdrawal_id, phone_number, amount, customer_id } = body

    if (!withdrawal_id || !phone_number || !amount) {
      return _error('withdrawal_id, phone_number, and amount are required')
    }

    // Initiate B2C payment via Safaricom API
    // ... (same Safaricom B2C API call as LOAN_DISBURSEMENT) ...

    // Store the disbursement record
    const { data: disbursement, error: dbErr } = await db
      .from('mpesa_disbursements')
      .insert({
        customer_id,
        phone_number,
        amount,
        purpose: 'SAVINGS_WITHDRAWAL',
        reference_id: withdrawal_id,
        status: 'PENDING',
        conversation_id: b2cResponse.ConversationID,
        originator_conversation_id: b2cResponse.OriginatorConversationID,
      })
      .select()
      .single()

    if (dbErr) return _error(`DB error: ${dbErr.message}`)

    // Link disbursement to withdrawal
    await db
      .from('imfsl_savings_withdrawals')
      .update({
        mpesa_disbursement_id: disbursement.id,
        status: 'PROCESSING',
        updated_at: new Date().toISOString(),
      })
      .eq('id', withdrawal_id)

    return _ok({ disbursement_id: disbursement.id, status: 'PROCESSING' })
  }
*/

// ══════════════════════════════════════════════════════════════════════
// ADD to the callback handler (alongside existing callback logic):
// ══════════════════════════════════════════════════════════════════════

/*
  // In the callback handler, after updating mpesa_disbursements:

  if (disbursement.purpose === 'SAVINGS_WITHDRAWAL') {
    const withdrawalId = disbursement.reference_id

    if (resultCode === 0) {
      // Success — mark withdrawal as completed
      await db
        .from('imfsl_savings_withdrawals')
        .update({
          status: 'COMPLETED',
          completed_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq('id', withdrawalId)

    } else {
      // Failure — mark as failed and restore available_balance
      const { data: withdrawal } = await db
        .from('imfsl_savings_withdrawals')
        .select('savings_account_id, amount')
        .eq('id', withdrawalId)
        .single()

      if (withdrawal) {
        // Restore the held balance
        await db.rpc('fn_restore_withdrawal_balance_raw', {
          p_account_id: withdrawal.savings_account_id,
          p_amount: withdrawal.amount,
        })
        // Or directly:
        // await db
        //   .from('imfsl_savings_accounts')
        //   .update({
        //     available_balance: db.raw(`available_balance + ${withdrawal.amount}`),
        //   })
        //   .eq('id', withdrawal.savings_account_id)
      }

      await db
        .from('imfsl_savings_withdrawals')
        .update({
          status: 'FAILED',
          updated_at: new Date().toISOString(),
        })
        .eq('id', withdrawalId)
    }
  }
*/

// ══════════════════════════════════════════════════════════════════════
// HELPER: fn_restore_withdrawal_balance (add to M166 or as separate migration)
// ══════════════════════════════════════════════════════════════════════

/*
CREATE OR REPLACE FUNCTION fn_restore_withdrawal_balance_raw(
  p_account_id UUID,
  p_amount NUMERIC
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  UPDATE imfsl_savings_accounts
  SET available_balance = available_balance + p_amount,
      updated_at = NOW()
  WHERE id = p_account_id;
END;
$$;

GRANT EXECUTE ON FUNCTION fn_restore_withdrawal_balance_raw(UUID, NUMERIC) TO service_role;
*/
