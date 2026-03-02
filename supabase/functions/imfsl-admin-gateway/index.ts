// imfsl-admin-gateway v9 — 47 actions
// =====================================
// Deploy: supabase functions deploy imfsl-admin-gateway --no-verify-jwt

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

    const { data: staff } = await db
      .from('staff')
      .select('id, system_role, branch, is_active')
      .eq('user_id', user.id)
      .maybeSingle()

    if (!staff || !staff.is_active) return _error('Staff account not found or inactive', 403)

    const staffId = staff.id
    const role = staff.system_role

    const body = await req.json()
    const { action, ...params } = body

    // ── DASHBOARD ────────────────────────────────────────────────────

    if (action === 'dashboard') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const [customers, activeLoans, pendingKyc, savingsAccounts, overdueLoans] = await Promise.all([
        db.from('customers').select('id', { count: 'exact', head: true }),
        db.from('imfsl_loans').select('id', { count: 'exact', head: true }).eq('status', 'ACTIVE'),
        db.from('kyc_submissions').select('id', { count: 'exact', head: true }).eq('status', 'PENDING'),
        db.from('imfsl_savings_accounts').select('id', { count: 'exact', head: true }).eq('status', 'ACTIVE'),
        db.from('imfsl_loans').select('id', { count: 'exact', head: true }).eq('status', 'OVERDUE'),
      ])
      const { data: loanAgg } = await db.from('imfsl_loans').select('principal_amount').in('status', ['ACTIVE', 'OVERDUE', 'DISBURSED'])
      const totalDisbursed = (loanAgg || []).reduce((s: number, l: any) => s + Number(l.principal_amount || 0), 0)
      return _ok({
        total_customers: customers.count || 0,
        active_loans: activeLoans.count || 0,
        pending_kyc: pendingKyc.count || 0,
        active_savings: savingsAccounts.count || 0,
        overdue_loans: overdueLoans.count || 0,
        total_disbursed: totalDisbursed,
      }, action)
    }

    // ── STAFF MANAGEMENT ─────────────────────────────────────────────

    if (action === 'staff_list') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      let query = db.from('staff').select('*').order('created_at', { ascending: false })
      if (params.search) query = query.or(`full_name.ilike.%${params.search}%,employee_id.ilike.%${params.search}%`)
      if (params.branch) query = query.eq('branch', params.branch)
      if (params.role) query = query.eq('system_role', params.role)
      const { data, error } = await query.range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'staff_profile') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.from('staff').select('*').eq('id', params.id).single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'staff_update_role') {
      if (role !== 'ADMIN') return _error('ADMIN only', 403)
      const { data, error } = await db.from('staff').update({ system_role: params.new_role, updated_at: new Date().toISOString() }).eq('id', params.staff_id).select().single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'staff_toggle_active') {
      if (role !== 'ADMIN') return _error('ADMIN only', 403)
      const { data, error } = await db.from('staff').update({ is_active: params.is_active, updated_at: new Date().toISOString() }).eq('id', params.staff_id).select().single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'staff_onboard') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      // Create auth user and staff record from approved KYC
      const { data: kyc } = await db.from('kyc_submissions').select('*').eq('id', params.kyc_id).single()
      if (!kyc) return _error('KYC submission not found')
      const { data: authUser, error: authErr } = await supabaseAuth.auth.admin.createUser({
        email: kyc.email,
        phone: kyc.phone_number,
        password: params.password_hash,
        email_confirm: true,
      })
      if (authErr) return _error(`Auth error: ${authErr.message}`)
      const { data, error } = await db.from('staff').insert({
        user_id: authUser.user.id,
        full_name: kyc.full_name,
        employee_id: params.employee_id,
        system_role: params.system_role,
        branch: params.branch_code,
        is_active: true,
        email: kyc.email,
        phone_number: kyc.phone_number,
      }).select().single()
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'staff_activity') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db
        .from('enterprise_audit_log')
        .select('*')
        .eq('actor_id', params.staff_id)
        .order('created_at', { ascending: false })
        .range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── KYC REVIEW ───────────────────────────────────────────────────

    if (action === 'kyc_queue') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      let query = db.from('kyc_submissions').select('*').order('created_at', { ascending: false })
      if (params.status) query = query.eq('status', params.status)
      const { data, error } = await query.range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'kyc_review') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      if (params.decision === 'APPROVE') {
        const { data, error } = await db.rpc('fn_imfsl_complete_kyc_approval', { p_kyc_id: params.kyc_id, p_reviewed_by: staffId })
        if (error) return _error(error.message)
        return _ok(data, action)
      } else if (params.decision === 'REJECT') {
        const { data, error } = await db.rpc('fn_imfsl_complete_kyc_rejection', { p_kyc_id: params.kyc_id, p_reviewed_by: staffId, p_reason: params.reason || 'Rejected' })
        if (error) return _error(error.message)
        return _ok(data, action)
      }
      return _error('decision must be APPROVE or REJECT')
    }

    if (action === 'kyc_bulk') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const results: any[] = []
      for (const kycId of (params.kyc_ids || [])) {
        if (params.decision === 'APPROVE') {
          const { data, error } = await db.rpc('fn_imfsl_complete_kyc_approval', { p_kyc_id: kycId, p_reviewed_by: staffId })
          results.push({ kyc_id: kycId, success: !error, error: error?.message })
        } else {
          const { data, error } = await db.rpc('fn_imfsl_complete_kyc_rejection', { p_kyc_id: kycId, p_reviewed_by: staffId, p_reason: params.reason || 'Rejected' })
          results.push({ kyc_id: kycId, success: !error, error: error?.message })
        }
      }
      return _ok({ results, processed: results.length }, action)
    }

    // ── LOAN APPROVAL ────────────────────────────────────────────────

    if (action === 'loan_queue') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      let query = db.from('imfsl_loan_applications').select('*, customer:customers(full_name, phone_number)').order('created_at', { ascending: false })
      if (params.status) query = query.eq('status', params.status)
      const { data, error } = await query.range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'loan_review') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_process_approval_step', {
        p_entity_type: 'LOAN_APPLICATION',
        p_entity_id: params.app_id,
        p_staff_id: staffId,
        p_decision: params.decision,
        p_comments: params.reason || null,
        p_approved_amount: params.amount || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── AUDIT LOG ────────────────────────────────────────────────────

    if (action === 'audit_search') {
      if (!['ADMIN', 'MANAGER', 'AUDITOR'].includes(role)) return _error('Insufficient permissions', 403)
      let query = db.from('enterprise_audit_log').select('*').order('created_at', { ascending: false })
      if (params.event_type) query = query.eq('event_type', params.event_type)
      if (params.entity_type) query = query.eq('entity_type', params.entity_type)
      if (params.actor_id) query = query.eq('actor_id', params.actor_id)
      if (params.date_from) query = query.gte('created_at', params.date_from)
      if (params.date_to) query = query.lte('created_at', params.date_to)
      if (params.search) query = query.ilike('details', `%${params.search}%`)
      const { data, error } = await query.range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── COLLECTIONS ──────────────────────────────────────────────────

    if (action === 'collections_dashboard') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_collections_dashboard')
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'collections_queue') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_collections_queue', {
        p_status: params.status || null,
        p_par_bucket: params.par_bucket || null,
        p_assigned_to: params.assigned_to || null,
        p_limit: params.limit || 20,
        p_offset: params.offset || 0,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'log_collection_action') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_log_collection_action', {
        p_loan_id: params.loan_id,
        p_staff_id: staffId,
        p_action_type: params.action_type,
        p_notes: params.notes || null,
        p_outcome: params.outcome || 'N/A',
        p_promise_date: params.promise_date || null,
        p_promise_amount: params.promise_amount || null,
        p_next_action_date: params.next_action_date || null,
        p_next_action_type: params.next_action_type || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'waive_penalty') {
      if (role !== 'ADMIN') return _error('ADMIN only', 403)
      const { data, error } = await db.rpc('fn_imfsl_waive_penalty', {
        p_loan_id: params.loan_id,
        p_amount: params.amount,
        p_reason: params.reason,
        p_staff_id: staffId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── FINANCIAL REPORTING ──────────────────────────────────────────

    if (action === 'trial_balance') {
      if (!['ADMIN', 'MANAGER', 'AUDITOR'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_trial_balance', { p_as_of_date: params.as_of_date })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'income_statement') {
      if (!['ADMIN', 'MANAGER', 'AUDITOR'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_income_statement', { p_from_date: params.from_date, p_to_date: params.to_date })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'balance_sheet') {
      if (!['ADMIN', 'MANAGER', 'AUDITOR'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_balance_sheet', { p_as_of_date: params.as_of_date })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'loan_portfolio_report') {
      if (!['ADMIN', 'MANAGER', 'AUDITOR'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_loan_portfolio_report', { p_as_of_date: params.as_of_date })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'cashflow_report') {
      if (!['ADMIN', 'MANAGER', 'AUDITOR'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_cashflow_report', { p_from_date: params.from_date, p_to_date: params.to_date })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'par_aging_report') {
      if (!['ADMIN', 'MANAGER', 'AUDITOR'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_par_aging_report', { p_as_of_date: params.as_of_date })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── SMS ──────────────────────────────────────────────────────────

    if (action === 'sms_dashboard') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_sms_dashboard')
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'sms_template_list') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_sms_template_list')
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'send_bulk_sms') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_bulk_send_sms', {
        p_template_code: params.template_code,
        p_customer_ids: params.customer_ids,
        p_variables: params.variables || null,
        p_language: params.language || 'sw',
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── RESTRUCTURING & WRITE-OFF ────────────────────────────────────

    if (action === 'restructure_writeoff_queue') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_restructure_writeoff_queue', {
        p_type: params.type || 'ALL',
        p_status: params.status || 'ALL',
        p_limit: params.limit || 20,
        p_offset: params.offset || 0,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'request_restructure') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_request_restructure', {
        p_loan_id: params.loan_id,
        p_requested_by: staffId,
        p_type: params.type,
        p_new_terms: params.new_terms,
        p_reason: params.reason,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'approve_restructure') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_process_approval_step', {
        p_entity_type: 'LOAN_RESTRUCTURE',
        p_entity_id: params.restructure_id,
        p_staff_id: staffId,
        p_decision: params.decision,
        p_comments: params.reason || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'request_writeoff') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_request_writeoff', {
        p_loan_id: params.loan_id,
        p_requested_by: staffId,
        p_reason: params.reason,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'approve_writeoff') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_process_approval_step', {
        p_entity_type: 'LOAN_WRITEOFF',
        p_entity_id: params.writeoff_id,
        p_staff_id: staffId,
        p_decision: params.decision,
        p_comments: params.reason || null,
      })
      if (error) return _error(error.message)
      // If approved, also execute the writeoff GL entries
      if (params.decision === 'APPROVE') {
        await db.rpc('fn_imfsl_approve_writeoff', { p_writeoff_id: params.writeoff_id, p_approved_by: staffId })
      }
      return _ok(data, action)
    }

    if (action === 'record_recovery') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_record_recovery', {
        p_writeoff_id: params.writeoff_id,
        p_amount: params.amount,
        p_reference: params.reference,
        p_recorded_by: staffId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── BRANCH PERFORMANCE ───────────────────────────────────────────

    if (action === 'branch_dashboard') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_branch_dashboard')
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'branch_comparison') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_branch_comparison', { p_from_date: params.from_date, p_to_date: params.to_date })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'branch_detail') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_branch_detail', { p_branch_id: params.branch_id, p_from_date: params.from_date, p_to_date: params.to_date })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'branch_trend') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_branch_trend', { p_branch_id: params.branch_id, p_months: params.months || 6 })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── M-PESA RECONCILIATION ────────────────────────────────────────

    if (action === 'mpesa_dashboard') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_mpesa_reconciliation_dashboard', {
        p_status: params.status || null,
        p_from_date: params.from_date || null,
        p_to_date: params.to_date || null,
        p_limit: params.limit || 50,
        p_offset: params.offset || 0,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'mpesa_manual_reconcile') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_mpesa_manual_reconcile', {
        p_transaction_id: params.transaction_id,
        p_applied_to_type: params.applied_to_type,
        p_applied_to_id: params.applied_to_id,
        p_staff_id: staffId,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'mpesa_search') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_mpesa_search_transactions', {
        p_query: params.query,
        p_limit: params.limit || 20,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── APPROVAL WORKFLOW ────────────────────────────────────────────

    if (action === 'my_approvals') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_get_my_pending_approvals', {
        p_staff_id: staffId,
        p_staff_role: role,
        p_limit: params.limit || 50,
        p_offset: params.offset || 0,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'process_approval') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_process_approval_step', {
        p_entity_type: params.entity_type,
        p_entity_id: params.entity_id,
        p_staff_id: staffId,
        p_decision: params.decision,
        p_comments: params.comments || null,
        p_approved_amount: params.approved_amount || null,
      })
      if (error) return _error(error.message)
      // If writeoff was approved, execute GL entries
      if (params.entity_type === 'LOAN_WRITEOFF' && params.decision === 'APPROVE') {
        await db.rpc('fn_imfsl_approve_writeoff', { p_writeoff_id: params.entity_id, p_approved_by: staffId }).catch(() => {})
      }
      return _ok(data, action)
    }

    if (action === 'approval_chain') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_get_approval_chain', {
        p_entity_type: params.entity_type,
        p_entity_id: params.entity_id,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'approval_rules') {
      if (role !== 'ADMIN') return _error('ADMIN only', 403)
      const { data, error } = await db.rpc('fn_imfsl_manage_approval_rules', { p_operation: 'LIST' })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'update_approval_rule') {
      if (role !== 'ADMIN') return _error('ADMIN only', 403)
      const { data, error } = await db.rpc('fn_imfsl_manage_approval_rules', {
        p_operation: params.operation,
        p_rule_id: params.rule_id || null,
        p_entity_type: params.entity_type || null,
        p_min_amount: params.min_amount || null,
        p_max_amount: params.max_amount || null,
        p_risk_category: params.risk_category || null,
        p_required_levels: params.required_levels || null,
        p_level_1_min_role: params.level_1_min_role || null,
        p_level_2_min_role: params.level_2_min_role || null,
        p_level_3_min_role: params.level_3_min_role || null,
        p_description: params.description || null,
        p_priority: params.priority || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── SUPPORT QUEUE (v9) ───────────────────────────────────────────

    if (action === 'support_queue') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      let query = db
        .from('imfsl_support_tickets')
        .select('*, customer:customers(full_name, phone_number)')
        .order('created_at', { ascending: false })
      if (params.status) query = query.eq('status', params.status)
      if (params.category) query = query.eq('category', params.category)
      if (params.assigned_to) query = query.eq('assigned_staff_id', params.assigned_to)
      const { data, error } = await query.range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)
      if (error) return _error(error.message)
      // Summary stats
      const [open, inProgress, resolved, closed] = await Promise.all([
        db.from('imfsl_support_tickets').select('id', { count: 'exact', head: true }).eq('status', 'OPEN'),
        db.from('imfsl_support_tickets').select('id', { count: 'exact', head: true }).eq('status', 'IN_PROGRESS'),
        db.from('imfsl_support_tickets').select('id', { count: 'exact', head: true }).eq('status', 'RESOLVED'),
        db.from('imfsl_support_tickets').select('id', { count: 'exact', head: true }).eq('status', 'CLOSED'),
      ])
      return _ok({ tickets: data, stats: { open: open.count || 0, in_progress: inProgress.count || 0, resolved: resolved.count || 0, closed: closed.count || 0 } }, action)
    }

    if (action === 'manage_ticket') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_admin_manage_ticket', {
        p_ticket_id: params.ticket_id,
        p_action: params.action,
        p_staff_id: staffId,
        p_notes: params.notes || null,
        p_priority: params.priority || null,
        p_assigned_to: params.assigned_to || null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'ticket_detail_admin') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      const { data, error } = await db.rpc('fn_imfsl_get_ticket_detail', {
        p_ticket_id: params.ticket_id,
        p_customer_id: null,
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── WITHDRAWAL QUEUE (v9) ────────────────────────────────────────

    if (action === 'withdrawal_queue') {
      if (!['ADMIN', 'MANAGER', 'OFFICER', 'TELLER'].includes(role)) return _error('Insufficient permissions', 403)
      let query = db
        .from('imfsl_savings_withdrawals')
        .select('*, customer:customers(full_name, phone_number), savings_account:imfsl_savings_accounts(account_number)')
        .order('created_at', { ascending: false })
      if (params.status) query = query.eq('status', params.status)
      const { data, error } = await query.range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'process_withdrawal') {
      if (!['ADMIN', 'MANAGER'].includes(role)) return _error('Only ADMIN/MANAGER can process withdrawals', 403)
      const { data, error } = await db.rpc('fn_imfsl_process_savings_withdrawal', {
        p_withdrawal_id: params.withdrawal_id,
        p_staff_id: staffId,
        p_action: params.action,
        p_reason: params.reason || null,
      })
      if (error) return _error(error.message)
      // If approved and M-Pesa channel, trigger B2C
      if (params.action === 'APPROVE') {
        const { data: withdrawal } = await db
          .from('imfsl_savings_withdrawals')
          .select('*')
          .eq('id', params.withdrawal_id)
          .single()
        if (withdrawal && withdrawal.channel === 'MPESA') {
          await db.from('imfsl_savings_withdrawals').update({ status: 'PROCESSING', updated_at: new Date().toISOString() }).eq('id', params.withdrawal_id)
          try {
            await db.functions.invoke('mpesa-b2c-disburse', {
              body: {
                purpose: 'SAVINGS_WITHDRAWAL',
                withdrawal_id: params.withdrawal_id,
                phone_number: withdrawal.destination_phone,
                amount: withdrawal.amount,
                customer_id: withdrawal.customer_id,
              },
            })
          } catch (b2cErr) {
            console.error('B2C disbursement failed:', b2cErr)
            await db.from('imfsl_savings_withdrawals').update({ status: 'FAILED', updated_at: new Date().toISOString() }).eq('id', params.withdrawal_id)
            await db.rpc('fn_restore_withdrawal_balance_raw', { p_account_id: withdrawal.savings_account_id, p_amount: withdrawal.amount }).catch(() => {})
          }
        }
      }
      return _ok(data, action)
    }

    // ── GUARANTOR ADMIN SEARCH (v9) ──────────────────────────────────

    if (action === 'admin_guarantor_search') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) return _error('Insufficient permissions', 403)
      let query = db
        .from('imfsl_guarantors')
        .select('*, loan:imfsl_loans(loan_number, customer_id, principal_amount), linked_customer:customers!guarantor_customer_id(full_name, phone_number)')
        .order('created_at', { ascending: false })
      if (params.query) {
        query = query.or(`guarantor_name.ilike.%${params.query}%,phone_number.ilike.%${params.query}%,national_id.ilike.%${params.query}%`)
      }
      if (params.linking_status === 'LINKED') {
        query = query.not('guarantor_customer_id', 'is', null)
      } else if (params.linking_status === 'UNLINKED') {
        query = query.is('guarantor_customer_id', null)
      }
      const { data, error } = await query.range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)
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
