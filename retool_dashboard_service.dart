// IMFSL Retool Dashboard Service
// ================================
// Service layer wrapping all 19 vw_retool_imfsl_* views via PostgREST.
// Uses SupabaseClient.from() to query views directly (not edge functions).
//
// Usage:
//   final service = RetoolDashboardService(client: Supabase.instance.client);
//   final kpis = await service.getExecutiveKpis();
//
// Dependencies (add to pubspec.yaml):
//   supabase_flutter: ^2.0.0

import 'package:supabase_flutter/supabase_flutter.dart';

class RetoolDashboardService {
  RetoolDashboardService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  // ═══════════════════════════════════════════════════════════════════
  // V19 — EXECUTIVE DASHBOARD (single-row KPIs)
  // ═══════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getExecutiveKpis() async {
    final res = await _client
        .from('vw_retool_imfsl_executive_dashboard')
        .select()
        .limit(1)
        .maybeSingle();
    return res ?? {};
  }

  // ═══════════════════════════════════════════════════════════════════
  // V1 — CUSTOMER DIRECTORY
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getCustomerDirectory({
    String? search,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_customer_directory').select();
    if (search != null && search.isNotEmpty) {
      query = query.or('full_name.ilike.%$search%,phone_number.ilike.%$search%,national_id.ilike.%$search%,account_number.ilike.%$search%');
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V2 — KYC QUEUE
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getKycQueue({
    String? status,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_kyc_queue').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V3 — LOAN PIPELINE
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getLoanPipeline({
    String? status,
    String? riskCategory,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_loan_pipeline').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    if (riskCategory != null && riskCategory.isNotEmpty) {
      query = query.eq('risk_category', riskCategory);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V4 — LOAN PORTFOLIO
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getLoanPortfolio({
    String? status,
    String? parBucket,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_loan_portfolio').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    if (parBucket != null && parBucket.isNotEmpty) {
      query = query.eq('par_bucket', parBucket);
    }
    return await query
        .order('disbursed_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V5 — REPAYMENT MONITOR
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getRepaymentMonitor({
    String? status,
    String? dateFrom,
    String? dateTo,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_repayment_monitor').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    if (dateFrom != null) {
      query = query.gte('due_date', dateFrom);
    }
    if (dateTo != null) {
      query = query.lte('due_date', dateTo);
    }
    return await query
        .order('due_date', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V6 — SAVINGS OVERVIEW
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getSavingsOverview({
    String? status,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_savings_overview').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    return await query
        .order('opened_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V7 — GUARANTOR REGISTRY
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getGuarantorRegistry({
    String? status,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_guarantor_registry').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V8 — M-PESA MONITOR
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getMpesaMonitor({
    String? status,
    String? purpose,
    String? dateFrom,
    String? dateTo,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_mpesa_monitor').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    if (purpose != null && purpose.isNotEmpty) {
      query = query.eq('purpose', purpose);
    }
    if (dateFrom != null) {
      query = query.gte('created_at', dateFrom);
    }
    if (dateTo != null) {
      query = query.lte('created_at', dateTo);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V9 — COLLECTIONS QUEUE
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getCollectionsQueue({
    String? parBucket,
    String? priority,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_collections_queue').select();
    if (parBucket != null && parBucket.isNotEmpty) {
      query = query.eq('par_bucket', parBucket);
    }
    if (priority != null && priority.isNotEmpty) {
      query = query.eq('collection_priority', priority);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V10 — FINANCIAL LEDGER
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getFinancialLedger({
    String? accountType,
    String? dateFrom,
    String? dateTo,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_financial_ledger').select();
    if (accountType != null && accountType.isNotEmpty) {
      query = query.eq('account_type', accountType);
    }
    if (dateFrom != null) {
      query = query.gte('transaction_date', dateFrom);
    }
    if (dateTo != null) {
      query = query.lte('transaction_date', dateTo);
    }
    return await query
        .order('transaction_date', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V11 — APPROVAL QUEUE
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getApprovalQueue({
    String? status,
    String? entityType,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_approval_queue').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    if (entityType != null && entityType.isNotEmpty) {
      query = query.eq('entity_type', entityType);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V12 — RESTRUCTURE / WRITEOFF QUEUE
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getRestructureWriteoffQueue({
    String? queueType,
    String? status,
    int limit = 25,
    int offset = 0,
  }) async {
    var query =
        _client.from('vw_retool_imfsl_restructure_writeoff_queue').select();
    if (queueType != null && queueType.isNotEmpty) {
      query = query.eq('queue_type', queueType);
    }
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V13 — INSTANT LOAN MONITOR
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getInstantLoanMonitor({
    String? decision,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_instant_loan_monitor').select();
    if (decision != null && decision.isNotEmpty) {
      query = query.eq('decision', decision);
    }
    return await query
        .order('decided_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V14 — DISBURSEMENT TRACKER
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getDisbursementTracker({
    String? status,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_disbursement_tracker').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V15 — STAFF DIRECTORY
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getStaffDirectory({
    String? role,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_staff_directory').select();
    if (role != null && role.isNotEmpty) {
      query = query.eq('system_role', role);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V16 — SMS CENTER
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getSmsCenter({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _client
        .from('vw_retool_imfsl_sms_center')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V17 — AUDIT TRAIL
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getAuditTrail({
    String? eventType,
    String? dateFrom,
    String? dateTo,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('vw_retool_imfsl_audit_trail').select();
    if (eventType != null && eventType.isNotEmpty) {
      query = query.eq('event_type', eventType);
    }
    if (dateFrom != null) {
      query = query.gte('occurred_at', dateFrom);
    }
    if (dateTo != null) {
      query = query.lte('occurred_at', dateTo);
    }
    return await query
        .order('occurred_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // V18 — SYSTEM CONFIG
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getSystemConfig() async {
    return await _client
        .from('vw_retool_imfsl_system_config')
        .select()
        .order('config_section')
        .order('item_key');
  }

  // ═══════════════════════════════════════════════════════════════════
  // SUPPORT TICKET QUEUE (direct table query)
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getSupportTicketQueue({
    String? status,
    String? category,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('imfsl_support_tickets').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SAVINGS WITHDRAWAL QUEUE (direct table query)
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getSavingsWithdrawalQueue({
    String? status,
    int limit = 25,
    int offset = 0,
  }) async {
    var query = _client.from('imfsl_savings_withdrawals').select();
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    return await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }
}
