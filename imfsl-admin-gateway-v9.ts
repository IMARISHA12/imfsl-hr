// imfsl-admin-gateway v9 — Customer Self-Service Portal (Admin Side)
// ===================================================================
// 47 actions total (41 existing + 6 new)
//
// NEW ACTIONS (v9):
//   SUPPORT:       support_queue, manage_ticket, ticket_detail_admin
//   WITHDRAWALS:   withdrawal_queue, process_withdrawal
//   GUARANTORS:    admin_guarantor_search
//
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

    // Verify JWT and resolve staff
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return _error('Missing authorization header', 401)
    }

    const supabaseAuth = createClient(supabaseUrl, serviceRoleKey)
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabaseAuth.auth.getUser(token)
    if (authError || !user) {
      return _error('Invalid token', 401)
    }

    const db = createClient(supabaseUrl, serviceRoleKey)

    // Resolve staff record
    const { data: staff } = await db
      .from('staff')
      .select('id, system_role, branch, is_active')
      .eq('user_id', user.id)
      .maybeSingle()

    if (!staff || !staff.is_active) {
      return _error('Staff account not found or inactive', 403)
    }

    const staffId = staff.id
    const role = staff.system_role

    const body = await req.json()
    const { action, ...params } = body

    // === NEW v9 ACTIONS ===

    // ── SUPPORT QUEUE ──────────────────────────────────────────────

    if (action === 'support_queue') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) {
        return _error('Insufficient permissions', 403)
      }

      let query = db
        .from('imfsl_support_tickets')
        .select('*, customer:customers(full_name, phone_number)')
        .order('created_at', { ascending: false })

      if (params.status) query = query.eq('status', params.status)
      if (params.category) query = query.eq('category', params.category)
      if (params.assigned_to) query = query.eq('assigned_staff_id', params.assigned_to)

      const { data, error, count } = await query
        .range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)

      if (error) return _error(error.message)

      // Get summary stats
      const { data: stats } = await db.rpc('fn_imfsl_get_customer_tickets', {
        p_customer_id: '00000000-0000-0000-0000-000000000000', // unused, stats query
        p_status: null,
        p_limit: 0,
        p_offset: 0,
      }).maybeSingle()

      return _ok({ tickets: data, stats }, action)
    }

    if (action === 'manage_ticket') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) {
        return _error('Insufficient permissions', 403)
      }

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
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) {
        return _error('Insufficient permissions', 403)
      }

      const { data, error } = await db.rpc('fn_imfsl_get_ticket_detail', {
        p_ticket_id: params.ticket_id,
        p_customer_id: null, // no ownership check for admin
      })
      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // ── WITHDRAWAL QUEUE ───────────────────────────────────────────

    if (action === 'withdrawal_queue') {
      if (!['ADMIN', 'MANAGER', 'OFFICER', 'TELLER'].includes(role)) {
        return _error('Insufficient permissions', 403)
      }

      let query = db
        .from('imfsl_savings_withdrawals')
        .select('*, customer:customers(full_name, phone_number), savings_account:imfsl_savings_accounts(account_number)')
        .order('created_at', { ascending: false })

      if (params.status) query = query.eq('status', params.status)

      const { data, error } = await query
        .range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)

      if (error) return _error(error.message)
      return _ok(data, action)
    }

    if (action === 'process_withdrawal') {
      if (!['ADMIN', 'MANAGER'].includes(role)) {
        return _error('Only ADMIN/MANAGER can process withdrawals', 403)
      }

      const { data, error } = await db.rpc('fn_imfsl_process_savings_withdrawal', {
        p_withdrawal_id: params.withdrawal_id,
        p_staff_id: staffId,
        p_action: params.action, // APPROVE or REJECT
        p_reason: params.reason || null,
      })
      if (error) return _error(error.message)

      // If approved and channel is MPESA, trigger B2C disbursement
      if (params.action === 'APPROVE') {
        const { data: withdrawal } = await db
          .from('imfsl_savings_withdrawals')
          .select('*')
          .eq('id', params.withdrawal_id)
          .single()

        if (withdrawal && withdrawal.channel === 'MPESA') {
          // Update status to PROCESSING
          await db
            .from('imfsl_savings_withdrawals')
            .update({ status: 'PROCESSING', updated_at: new Date().toISOString() })
            .eq('id', params.withdrawal_id)

          // Invoke B2C disbursement edge function
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
            // Mark as failed and restore balance
            await db
              .from('imfsl_savings_withdrawals')
              .update({ status: 'FAILED', updated_at: new Date().toISOString() })
              .eq('id', params.withdrawal_id)
            await db.rpc('fn_restore_withdrawal_balance', {
              p_withdrawal_id: params.withdrawal_id,
            }).catch(() => {})
          }
        }
      }

      return _ok(data, action)
    }

    // ── GUARANTOR ADMIN SEARCH ─────────────────────────────────────

    if (action === 'admin_guarantor_search') {
      if (!['ADMIN', 'MANAGER', 'OFFICER'].includes(role)) {
        return _error('Insufficient permissions', 403)
      }

      let query = db
        .from('imfsl_guarantors')
        .select('*, loan:imfsl_loans(loan_number, customer_id, principal_amount), linked_customer:customers!guarantor_customer_id(full_name, phone_number)')
        .order('created_at', { ascending: false })

      if (params.query) {
        query = query.or(
          `guarantor_name.ilike.%${params.query}%,phone_number.ilike.%${params.query}%,national_id.ilike.%${params.query}%`
        )
      }

      if (params.linking_status === 'LINKED') {
        query = query.not('guarantor_customer_id', 'is', null)
      } else if (params.linking_status === 'UNLINKED') {
        query = query.is_('guarantor_customer_id', null)
      }

      const { data, error } = await query
        .range(params.offset || 0, (params.offset || 0) + (params.limit || 25) - 1)

      if (error) return _error(error.message)
      return _ok(data, action)
    }

    // === EXISTING v8 ACTIONS (unchanged) ===
    // ... (all 41 existing actions remain as-is) ...

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
