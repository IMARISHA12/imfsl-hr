// mpesa-b2c-disburse v2 — B2C Disbursement + Savings Withdrawal Support
// =====================================================================
// Handles: LOAN_DISBURSEMENT, SAVINGS_WITHDRAWAL
// Callback: Safaricom B2C result webhook
// Deploy: supabase functions deploy mpesa-b2c-disburse --no-verify-jwt

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function _ok(data: any) {
  return new Response(JSON.stringify(data), {
    status: 200,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

function _error(message: string, status = 400) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

function env(name: string): string {
  const val = Deno.env.get(name)
  if (!val) throw new Error(`Missing env: ${name}`)
  return val
}

async function getAccessToken(consumerKey: string, consumerSecret: string): Promise<string> {
  const tokenUrl = 'https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'
  const auth = btoa(`${consumerKey}:${consumerSecret}`)
  const res = await fetch(tokenUrl, {
    method: 'GET',
    headers: { Authorization: `Basic ${auth}` },
  })
  if (!res.ok) {
    const text = await res.text()
    throw new Error(`OAuth token error: ${res.status} ${text}`)
  }
  const { access_token } = await res.json()
  return access_token
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = env('SUPABASE_URL')
    const serviceRoleKey = env('SUPABASE_SERVICE_ROLE_KEY')
    const db = createClient(supabaseUrl, serviceRoleKey)

    const body = await req.json()

    // Route: Safaricom callback
    if (body.Result) {
      return await handleCallback(db, body)
    }

    // Route: Initiate B2C
    if (body.purpose) {
      return await handleInitiate(db, body)
    }

    return _error('Invalid request: must include purpose or Result')
  } catch (err) {
    console.error('mpesa-b2c-disburse error:', err)
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})

// ══════════════════════════════════════════════════════════════════════
// PATH 1: Initiate B2C Payment
// ══════════════════════════════════════════════════════════════════════

async function handleInitiate(db: any, body: any) {
  const { purpose, phone_number, amount, customer_id } = body

  if (!phone_number || !amount || !customer_id) {
    return _error('phone_number, amount, and customer_id are required')
  }

  if (!['LOAN_DISBURSEMENT', 'SAVINGS_WITHDRAWAL'].includes(purpose)) {
    return _error('purpose must be LOAN_DISBURSEMENT or SAVINGS_WITHDRAWAL')
  }

  let referenceId: string
  let remarks: string

  if (purpose === 'LOAN_DISBURSEMENT') {
    if (!body.loan_id) return _error('loan_id is required for LOAN_DISBURSEMENT')
    referenceId = body.loan_id
    remarks = `Loan disbursement ${body.loan_id}`
  } else {
    if (!body.withdrawal_id) return _error('withdrawal_id is required for SAVINGS_WITHDRAWAL')
    referenceId = body.withdrawal_id
    remarks = `Savings withdrawal ${body.withdrawal_id}`
  }

  // Get Safaricom credentials
  const consumerKey = env('MPESA_B2C_CONSUMER_KEY')
  const consumerSecret = env('MPESA_B2C_CONSUMER_SECRET')
  const shortcode = env('MPESA_B2C_SHORTCODE')
  const initiatorName = env('MPESA_B2C_INITIATOR_NAME')
  const securityCredential = env('MPESA_B2C_SECURITY_CREDENTIAL')
  const queueTimeoutUrl = env('MPESA_B2C_QUEUE_TIMEOUT_URL')
  const resultUrl = env('MPESA_B2C_RESULT_URL')

  // Get OAuth token
  const accessToken = await getAccessToken(consumerKey, consumerSecret)

  // Call Safaricom B2C API
  const originatorConversationId = crypto.randomUUID()
  const b2cPayload = {
    OriginatorConversationID: originatorConversationId,
    InitiatorName: initiatorName,
    SecurityCredential: securityCredential,
    CommandID: 'BusinessPayment',
    Amount: Number(amount),
    PartyA: shortcode,
    PartyB: phone_number.replace(/^\+/, ''),
    Remarks: remarks,
    QueueTimeOutURL: queueTimeoutUrl,
    ResultURL: resultUrl,
    Occasion: purpose,
  }

  const b2cRes = await fetch('https://api.safaricom.co.ke/mpesa/b2c/v3/paymentrequest', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(b2cPayload),
  })

  const b2cResponse = await b2cRes.json()

  if (!b2cRes.ok || b2cResponse.errorCode) {
    console.error('B2C API error:', b2cResponse)
    return _error(`B2C API error: ${b2cResponse.errorMessage || b2cResponse.ResultDesc || 'Unknown'}`, 502)
  }

  // Store disbursement record
  const { data: disbursement, error: dbErr } = await db
    .from('mpesa_disbursements')
    .insert({
      customer_id,
      phone_number,
      amount: Number(amount),
      purpose,
      reference_id: referenceId,
      status: 'PENDING',
      conversation_id: b2cResponse.ConversationID,
      originator_conversation_id: b2cResponse.OriginatorConversationID || originatorConversationId,
    })
    .select()
    .single()

  if (dbErr) {
    console.error('DB insert error:', dbErr)
    return _error(`DB error: ${dbErr.message}`)
  }

  // Purpose-specific linking
  if (purpose === 'SAVINGS_WITHDRAWAL') {
    await db
      .from('imfsl_savings_withdrawals')
      .update({
        mpesa_disbursement_id: disbursement.id,
        status: 'PROCESSING',
        updated_at: new Date().toISOString(),
      })
      .eq('id', body.withdrawal_id)
  }

  return _ok({
    success: true,
    disbursement_id: disbursement.id,
    conversation_id: b2cResponse.ConversationID,
    originator_conversation_id: b2cResponse.OriginatorConversationID || originatorConversationId,
  })
}

// ══════════════════════════════════════════════════════════════════════
// PATH 2: Safaricom Callback
// ══════════════════════════════════════════════════════════════════════

async function handleCallback(db: any, body: any) {
  const result = body.Result
  const resultCode = result.ResultCode
  const resultDesc = result.ResultDesc
  const originatorConversationId = result.OriginatorConversationID
  const conversationId = result.ConversationID
  const transactionId = result.TransactionID

  console.log(`B2C Callback: code=${resultCode}, desc=${resultDesc}, txn=${transactionId}`)

  // Find the disbursement
  let { data: disbursement } = await db
    .from('mpesa_disbursements')
    .select('*')
    .eq('originator_conversation_id', originatorConversationId)
    .maybeSingle()

  if (!disbursement && conversationId) {
    const res = await db
      .from('mpesa_disbursements')
      .select('*')
      .eq('conversation_id', conversationId)
      .maybeSingle()
    disbursement = res.data
  }

  if (!disbursement) {
    console.error(`No disbursement found for conversation: ${originatorConversationId}`)
    return _ok({ ResultCode: 0, ResultDesc: 'Accepted' })
  }

  // Update disbursement record
  const updateData: any = {
    result_code: resultCode,
    result_desc: resultDesc,
    raw_callback_payload: body,
    updated_at: new Date().toISOString(),
  }

  if (resultCode === 0) {
    updateData.status = 'COMPLETED'
    updateData.mpesa_receipt_number = transactionId
    updateData.completed_at = new Date().toISOString()
  } else {
    updateData.status = 'FAILED'
  }

  await db
    .from('mpesa_disbursements')
    .update(updateData)
    .eq('id', disbursement.id)

  // Purpose-specific post-processing
  if (disbursement.purpose === 'LOAN_DISBURSEMENT') {
    await handleLoanDisbursementCallback(db, disbursement, resultCode, resultDesc)
  } else if (disbursement.purpose === 'SAVINGS_WITHDRAWAL') {
    await handleSavingsWithdrawalCallback(db, disbursement, resultCode)
  }

  // Always acknowledge to Safaricom
  return _ok({ ResultCode: 0, ResultDesc: 'Accepted' })
}

// ── LOAN DISBURSEMENT CALLBACK ──────────────────────────────────────

async function handleLoanDisbursementCallback(
  db: any,
  disbursement: any,
  resultCode: number,
  resultDesc: string,
) {
  const loanId = disbursement.reference_id

  if (resultCode === 0) {
    // Success — mark loan as disbursed
    await db
      .from('imfsl_loans')
      .update({
        status: 'DISBURSED',
        disbursed_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('id', loanId)

    // Update application status
    const { data: loan } = await db
      .from('imfsl_loans')
      .select('application_id')
      .eq('id', loanId)
      .maybeSingle()

    if (loan?.application_id) {
      await db
        .from('imfsl_loan_applications')
        .update({
          status: 'DISBURSED',
          updated_at: new Date().toISOString(),
        })
        .eq('id', loan.application_id)
    }
  } else {
    // Failure
    await db
      .from('imfsl_loans')
      .update({
        status: 'DISBURSEMENT_FAILED',
        disbursement_failure_reason: resultDesc,
        updated_at: new Date().toISOString(),
      })
      .eq('id', loanId)
  }
}

// ── SAVINGS WITHDRAWAL CALLBACK ─────────────────────────────────────

async function handleSavingsWithdrawalCallback(
  db: any,
  disbursement: any,
  resultCode: number,
) {
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
    // Failure — mark as failed and restore balance
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
