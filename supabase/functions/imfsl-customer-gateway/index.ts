// imfsl-customer-gateway v8 — 53 actions
// ========================================
// Deploy: supabase functions deploy imfsl-customer-gateway --no-verify-jwt

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const authHeader = req.headers.get('Authorization')
    if (!authHeader) return _error('Missing authorization header', 401)

    const supabaseAuth = createClient(supabaseUrl, serviceRoleKey)
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabaseAuth.auth.getUser(token)
    if (authError || !user) return _error('Invalid token', 401)

    const db = createClient(supabaseUrl, serviceRoleKey)

    const body = await req.json()
    const { action, ...params } = body

    // Resolve customer
    const { data: customer } = await db
      .from('customers')
      .select('id, phone_number, national_id, email')
      .or(`auth_user_id.eq.${user.id},email.eq.${user.email}`)
      .maybeSingle()

    const customerId = customer?.id

    // Pre-registration actions (don't require customerId)
    const preRegActions = ['submit_kyc', 'kyc_status', 'onboarding_status', 'link_auth']

    // ── PROFILE ──────────────────────────────────────────────────────

    if (action === 'my_profile') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.from('customers').select('*').eq('id', customerId).single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'update_profile') {
      if (!customerId) return _error('Customer not found', 404)
      const updates: any = {}
      if (params.phone_number !== undefined) updates.phone_number = params.phone_number
      if (params.email !== undefined) updates.email = params.email
      if (params.address !== undefined) updates.address = params.address
      if (params.occupation !== undefined) updates.occupation = params.occupation
      if (params.monthly_income !== undefined) updates.monthly_income = params.monthly_income
      updates.updated_at = new Date().toISOString()
      const { data, error } = await db.from('customers').update(updates).eq('id', customerId).select().single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── LOANS ────────────────────────────────────────────────────────

    if (action === 'my_loans') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('imfsl_loans')
        .select('*, loan_product:imfsl_loan_products(*)')
        .eq('customer_id', customerId)
        .order('created_at', { ascending: false })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'loan_detail') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('imfsl_loans')
        .select('*, loan_product:imfsl_loan_products(*), schedule:imfsl_loan_repayment_schedule(*)')
        .eq('id', params.loan_id)
        .eq('customer_id', customerId)
        .single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'loan_products') {
      const { data, error } = await db.from('imfsl_loan_products').select('*').eq('is_active', true)
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'apply_loan') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('imfsl_loan_applications')
        .insert({ customer_id: customerId, ...params, status: 'SUBMITTED' })
        .select()
        .single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'loan_statement') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('imfsl_loans')
        .select('*, schedule:imfsl_loan_repayment_schedule(*), loan_product:imfsl_loan_products(product_name)')
        .eq('id', params.loan_id)
        .eq('customer_id', customerId)
        .single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'calculate_schedule') {
      const { data, error } = await db.functions.invoke('calculate-loan-schedule', {
        body: { principal: params.principal, rate: params.rate, months: params.months },
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── SAVINGS ──────────────────────────────────────────────────────

    if (action === 'my_savings') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('imfsl_savings_accounts')
        .select('*, product:imfsl_savings_products(*)')
        .eq('customer_id', customerId)
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'savings_detail') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('imfsl_savings_accounts')
        .select('*, product:imfsl_savings_products(*)')
        .eq('id', params.account_id)
        .eq('customer_id', customerId)
        .single()
      if (error) return _error(error.message)
      // Get recent transactions
      const { data: txns } = await db
        .from('imfsl_transactions')
        .select('*')
        .eq('savings_account_id', params.account_id)
        .order('created_at', { ascending: false })
        .limit(20)
      return _ok({ ...data, recent_transactions: txns || [] }, action)
    }

    if (action === 'account_statement') {
      if (!customerId) return _error('Customer not found', 404)
      const { data: account, error } = await db
        .from('imfsl_savings_accounts')
        .select('*, product:imfsl_savings_products(product_name)')
        .eq('id', params.account_id)
        .eq('customer_id', customerId)
        .single()
      if (error) return _error(error.message)
      const { data: txns } = await db
        .from('imfsl_transactions')
        .select('*')
        .eq('savings_account_id', params.account_id)
        .order('created_at', { ascending: false })
      return _ok({ account, transactions: txns || [] }, action)
    }

    // ── CREDIT SCORE ─────────────────────────────────────────────────

    if (action === 'my_credit_score') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('credit_score_history')
        .select('*')
        .eq('customer_id', customerId)
        .order('created_at', { ascending: false })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'request_score_refresh') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.functions.invoke('credit-score-engine', {
        body: { customer_id: customerId },
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── TRANSACTIONS ─────────────────────────────────────────────────

    if (action === 'my_transactions') {
      if (!customerId) return _error('Customer not found', 404)
      let query = db
        .from('imfsl_transactions')
        .select('*')
        .eq('customer_id', customerId)
        .order('created_at', { ascending: false })
      if (params.type) query = query.eq('transaction_type', params.type)
      if (params.from_date) query = query.gte('created_at', params.from_date)
      if (params.to_date) query = query.lte('created_at', params.to_date)
      const { data, error } = await query.range(params.offset || 0, (params.offset || 0) + (params.limit || 20) - 1)
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── NOTIFICATIONS ────────────────────────────────────────────────

    if (action === 'my_notifications') {
      if (!customerId) return _error('Customer not found', 404)
      let query = db
        .from('notifications_log')
        .select('*')
        .eq('customer_id', customerId)
        .order('created_at', { ascending: false })
      if (params.unread_only) query = query.eq('is_read', false)
      const { data, error } = await query.range(params.offset || 0, (params.offset || 0) + (params.limit || 20) - 1)
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'mark_read') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('notifications_log')
        .update({ is_read: true, read_at: new Date().toISOString() })
        .eq('id', params.notification_id)
        .eq('customer_id', customerId)
        .select()
        .single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'mark_all_read') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error, count } = await db
        .from('notifications_log')
        .update({ is_read: true, read_at: new Date().toISOString() })
        .eq('customer_id', customerId)
        .eq('is_read', false)
        .select('id')
      if (error) return _error(error.message)
      return _ok({ count: data?.length || 0 }, action)
    }

    if (action === 'unread_count') {
      if (!customerId) return _error('Customer not found', 404)
      const { count, error } = await db
        .from('notifications_log')
        .select('id', { count: 'exact', head: true })
        .eq('customer_id', customerId)
        .eq('is_read', false)
      if (error) return _error(error.message)
      return _ok({ count: count || 0 }, action)
    }

    // ── M-PESA ───────────────────────────────────────────────────────

    if (action === 'mpesa_pay') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.functions.invoke('mpesa-stk-push', {
        body: { ...params, customer_id: customerId },
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'check_status') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('mpesa_transactions')
        .select('*')
        .eq('id', params.transaction_id)
        .eq('customer_id', customerId)
        .single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── KYC (pre-registration) ───────────────────────────────────────

    if (action === 'submit_kyc') {
      const { data, error } = await db
        .from('kyc_submissions')
        .upsert({ auth_user_id: user.id, ...params, status: 'PENDING', updated_at: new Date().toISOString() }, { onConflict: 'auth_user_id' })
        .select()
        .single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'kyc_status') {
      const { data, error } = await db
        .from('kyc_submissions')
        .select('*')
        .eq('auth_user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── INSTANT LOAN (Mkopo Chap Chap) ───────────────────────────────

    if (action === 'register_device') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('customer_devices')
        .upsert({
          customer_id: customerId,
          device_id: params.device_id,
          device_model: params.device_model || null,
          os_version: params.os_version || null,
          app_version: params.app_version || null,
          is_trusted: false,
          last_seen_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        }, { onConflict: 'customer_id,device_id' })
        .select()
        .single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'instant_loan_prequalify') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_instant_loan_prequalify', {
        p_customer_id: customerId,
        p_device_id: params.device_id || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'instant_loan_apply') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_instant_loan_apply', {
        p_customer_id: customerId,
        p_requested_amount: params.requested_amount,
        p_tenure_months: params.tenure_months,
        p_purpose: params.purpose || null,
        p_phone_number: params.phone_number || null,
        p_device_db_id: params.device_db_id || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'instant_loan_status') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_instant_loan_status', {
        p_application_id: params.application_id,
        p_customer_id: customerId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'instant_loan_request_otp') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_instant_loan_request_otp', {
        p_application_id: params.application_id,
        p_customer_id: customerId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'instant_loan_verify_otp') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_instant_loan_verify_otp', {
        p_application_id: params.application_id,
        p_customer_id: customerId,
        p_otp_code: params.otp_code,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'instant_loan_confirm_disburse') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_instant_loan_confirm_disburse', {
        p_application_id: params.application_id,
        p_customer_id: customerId,
        p_phone_number: params.phone_number || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── PAYMENTS & COLLECTIONS ───────────────────────────────────────

    if (action === 'upcoming_payments') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_upcoming_payments', {
        p_customer_id: customerId,
        p_limit: params.limit || 10,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'payment_history') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_payment_history', {
        p_customer_id: customerId,
        p_loan_id: params.loan_id,
        p_limit: params.limit || 20,
        p_offset: params.offset || 0,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── SAVINGS SUMMARY ──────────────────────────────────────────────

    if (action === 'savings_summary') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_savings_account_summary', {
        p_customer_id: customerId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── SMS ──────────────────────────────────────────────────────────

    if (action === 'send_sms_notification') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_send_templated_sms', {
        p_customer_id: customerId,
        p_template_code: params.template_code,
        p_variables: params.variables || null,
        p_language: params.language || 'sw',
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── ONBOARDING (pre-registration) ────────────────────────────────

    if (action === 'onboarding_status') {
      const { data, error } = await db.rpc('fn_imfsl_get_onboarding_status', {
        p_auth_user_id: user.id,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'link_auth') {
      // Link auth_user_id to existing customer/KYC by phone or email
      const phone = user.phone || null
      const email = user.email || null
      // Link KYC
      if (email) {
        await db.from('kyc_submissions').update({ auth_user_id: user.id }).is('auth_user_id', null).eq('email', email)
      }
      if (phone) {
        await db.from('kyc_submissions').update({ auth_user_id: user.id }).is('auth_user_id', null).eq('phone_number', phone)
      }
      // Link customer
      if (email) {
        await db.from('customers').update({ auth_user_id: user.id }).is('auth_user_id', null).eq('email', email)
      }
      if (phone) {
        await db.from('customers').update({ auth_user_id: user.id }).is('auth_user_id', null).eq('phone_number', phone)
      }
      return _ok({ linked: true }, action)
    }

    if (action === 'mark_welcome_shown') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_mark_welcome_shown', {
        p_customer_id: customerId,
      })
      if (error) return _error(error.message)
      return _ok(data || { success: true }, action)
    }

    // ── PAYMENT RECEIPT ──────────────────────────────────────────────

    if (action === 'payment_receipt') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db
        .from('mpesa_transactions')
        .select('*')
        .eq('id', params.transaction_id)
        .eq('customer_id', customerId)
        .single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── RESTRUCTURE STATUS ───────────────────────────────────────────

    if (action === 'my_restructure_status') {
      if (!customerId) return _error('Customer not found', 404)
      const { data: loans } = await db
        .from('imfsl_loans')
        .select('id')
        .eq('customer_id', customerId)
      const loanIds = (loans || []).map((l: any) => l.id)
      if (loanIds.length === 0) return _ok([], action)
      const { data, error } = await db
        .from('imfsl_loan_restructures')
        .select('*, loan:imfsl_loans(loan_number)')
        .in('loan_id', loanIds)
        .order('created_at', { ascending: false })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── PAYMENT CENTER ───────────────────────────────────────────────

    if (action === 'payment_center_summary') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_payment_center_summary', {
        p_customer_id: customerId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'formatted_receipt') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_formatted_payment_receipt', {
        p_transaction_id: params.transaction_id,
        p_customer_id: customerId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'recent_payments') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_customer_recent_payments', {
        p_customer_id: customerId,
        p_limit: params.limit || 20,
        p_offset: params.offset || 0,
        p_purpose: params.purpose || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── SUPPORT TICKETS (v8) ─────────────────────────────────────────

    if (action === 'create_ticket') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_create_support_ticket', {
        p_customer_id: customerId,
        p_category: params.category,
        p_subject: params.subject,
        p_message: params.message,
        p_related_loan_id: params.loan_id || null,
        p_related_transaction_id: params.transaction_id || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'my_tickets') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_get_customer_tickets', {
        p_customer_id: customerId,
        p_status: params.status || null,
        p_limit: params.limit || 20,
        p_offset: params.offset || 0,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'ticket_detail') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_get_ticket_detail', {
        p_ticket_id: params.ticket_id,
        p_customer_id: customerId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'add_ticket_message') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_add_ticket_message', {
        p_ticket_id: params.ticket_id,
        p_sender_type: 'CUSTOMER',
        p_sender_id: customerId,
        p_message: params.message,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── SAVINGS WITHDRAWALS (v8) ─────────────────────────────────────

    if (action === 'request_withdrawal') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_request_savings_withdrawal', {
        p_customer_id: customerId,
        p_savings_account_id: params.savings_account_id,
        p_amount: params.amount,
        p_channel: params.channel || 'MPESA',
        p_destination_phone: params.destination_phone || customer?.phone_number || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'my_withdrawals') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_get_customer_withdrawals', {
        p_customer_id: customerId,
        p_status: params.status || null,
        p_limit: params.limit || 20,
        p_offset: params.offset || 0,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── GUARANTOR SELF-SERVICE (v8) ──────────────────────────────────

    if (action === 'my_guarantor_commitments') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_get_my_guarantor_commitments', {
        p_customer_id: customerId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'guarantor_invites') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_get_my_guarantor_invites', {
        p_customer_id: customerId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'respond_to_guarantor') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_respond_to_guarantor_request', {
        p_guarantor_id: params.guarantor_id,
        p_customer_id: customerId,
        p_response: params.response,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'link_guarantor') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_link_guarantor_to_customer', {
        p_guarantor_id: params.guarantor_id,
        p_customer_id: customerId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── LOAN RESTRUCTURE — Customer Self-Service (v8) ────────────────

    if (action === 'request_restructure') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_customer_request_restructure', {
        p_customer_id: customerId,
        p_loan_id: params.loan_id,
        p_restructure_type: params.type,
        p_reason: params.reason,
        p_requested_term: params.requested_term || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'my_restructure_requests') {
      if (!customerId) return _error('Customer not found', 404)
      const { data, error } = await db.rpc('fn_imfsl_get_customer_restructure_requests', {
        p_customer_id: customerId,
        p_limit: params.limit || 20,
        p_offset: params.offset || 0,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── FALLBACK ─────────────────────────────────────────────────────

    return _error(`Unknown action: ${action}`, 400)

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})

function _ok(data: any, action: string) {
  return new Response(JSON.stringify({ success: true, action, data }), {
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
