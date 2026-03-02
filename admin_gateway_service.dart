// IMFSL Admin Gateway Service
// ============================
// Typed wrapper for the `imfsl-admin-gateway` Supabase edge function.
// 41 actions with RBAC (ADMIN, MANAGER, OFFICER, AUDITOR, TELLER).
//
// Usage:
//   final service = AdminGatewayService(client: Supabase.instance.client);
//   final dashboard = await service.getDashboard();
//   final staff = await service.getStaffList();
//
// Dependencies (add to pubspec.yaml):
//   supabase_flutter: ^2.0.0

import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception thrown when the admin gateway returns an error response.
class AdminGatewayException implements Exception {
  final String message;
  final int? statusCode;
  const AdminGatewayException(this.message, {this.statusCode});

  @override
  String toString() => 'AdminGatewayException: $message';
}

class AdminGatewayService {
  AdminGatewayService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  static const _functionName = 'imfsl-admin-gateway';

  // ═══════════════════════════════════════════════════════════════════
  // INTERNAL CALL HELPER
  // ═══════════════════════════════════════════════════════════════════

  Future<dynamic> _call(String action,
      [Map<String, dynamic>? params]) async {
    final body = <String, dynamic>{'action': action};
    if (params != null) body.addAll(params);

    final FunctionResponse response;
    try {
      response = await _client.functions.invoke(
        _functionName,
        body: body,
      );
    } catch (e) {
      throw AdminGatewayException('Network error: $e');
    }

    final data = response.data;

    if (data is Map<String, dynamic> && data.containsKey('error')) {
      throw AdminGatewayException(
        data['error']?.toString() ?? 'Unknown error',
        statusCode: response.status,
      );
    }

    // Unwrap {success, action, data} envelope
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'];
    }

    return data;
  }

  // ═══════════════════════════════════════════════════════════════════
  // DASHBOARD
  // ═══════════════════════════════════════════════════════════════════

  /// Returns executive dashboard KPIs.
  Future<Map<String, dynamic>> getDashboard() async {
    final result = await _call('dashboard');
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // STAFF MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════

  /// Returns paginated staff list with optional filters.
  Future<List<Map<String, dynamic>>> getStaffList({
    String? search,
    String? branch,
    String? role,
    int limit = 25,
    int offset = 0,
  }) async {
    final result = await _call('staff_list', {
      if (search != null && search.isNotEmpty) 'search': search,
      if (branch != null) 'branch': branch,
      if (role != null) 'role': role,
      'limit': limit,
      'offset': offset,
    });
    return _asList(result);
  }

  /// Returns comprehensive staff profile (60+ column view).
  Future<Map<String, dynamic>> getStaffProfile(String staffId) async {
    final result = await _call('staff_profile', {'id': staffId});
    return _asMap(result);
  }

  /// Updates a staff member's system_role. ADMIN only.
  Future<Map<String, dynamic>> updateStaffRole({
    required String staffId,
    required String newRole,
  }) async {
    final result = await _call('staff_update_role', {
      'staff_id': staffId,
      'new_role': newRole,
    });
    return _asMap(result);
  }

  /// Activates or deactivates a staff member. ADMIN only.
  Future<Map<String, dynamic>> toggleStaffActive({
    required String staffId,
    required bool isActive,
    String? reason,
  }) async {
    final result = await _call('staff_toggle_active', {
      'staff_id': staffId,
      'is_active': isActive,
      if (reason != null) 'reason': reason,
    });
    return _asMap(result);
  }

  /// Onboards a new staff member from an approved KYC submission.
  Future<Map<String, dynamic>> onboardStaff({
    required String kycId,
    required String employeeId,
    required String systemRole,
    required String branchCode,
    required String passwordHash,
  }) async {
    final result = await _call('staff_onboard', {
      'kyc_id': kycId,
      'employee_id': employeeId,
      'system_role': systemRole,
      'branch_code': branchCode,
      'password_hash': passwordHash,
    });
    return _asMap(result);
  }

  /// Returns activity log for a specific staff member.
  Future<List<Map<String, dynamic>>> getStaffActivity({
    required String staffId,
    int limit = 25,
    int offset = 0,
  }) async {
    final result = await _call('staff_activity', {
      'staff_id': staffId,
      'limit': limit,
      'offset': offset,
    });
    return _asList(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // KYC REVIEW
  // ═══════════════════════════════════════════════════════════════════

  /// Returns paginated KYC review queue with optional status filter.
  Future<List<Map<String, dynamic>>> getKycQueue({
    String? status,
    int limit = 25,
    int offset = 0,
  }) async {
    final result = await _call('kyc_queue', {
      if (status != null) 'status': status,
      'limit': limit,
      'offset': offset,
    });
    return _asList(result);
  }

  /// Approves or rejects a single KYC submission.
  /// [decision]: 'APPROVE' or 'REJECT'
  Future<Map<String, dynamic>> reviewKyc({
    required String kycId,
    required String decision,
    String? reason,
  }) async {
    final result = await _call('kyc_review', {
      'kyc_id': kycId,
      'decision': decision,
      if (reason != null) 'reason': reason,
    });
    return _asMap(result);
  }

  /// Bulk approve or reject multiple KYC submissions.
  Future<Map<String, dynamic>> bulkKycAction({
    required List<String> kycIds,
    required String decision,
    String? reason,
  }) async {
    final result = await _call('kyc_bulk', {
      'kyc_ids': kycIds,
      'decision': decision,
      if (reason != null) 'reason': reason,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAN APPROVAL
  // ═══════════════════════════════════════════════════════════════════

  /// Returns paginated loan approval queue with optional status filter.
  Future<List<Map<String, dynamic>>> getLoanQueue({
    String? status,
    int limit = 25,
    int offset = 0,
  }) async {
    final result = await _call('loan_queue', {
      if (status != null) 'status': status,
      'limit': limit,
      'offset': offset,
    });
    return _asList(result);
  }

  /// Approves or rejects a loan application.
  /// [decision]: 'APPROVE' or 'REJECT'
  Future<Map<String, dynamic>> reviewLoan({
    required String appId,
    required String decision,
    double? amount,
    String? reason,
  }) async {
    final result = await _call('loan_review', {
      'app_id': appId,
      'decision': decision,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // AUDIT LOG
  // ═══════════════════════════════════════════════════════════════════

  /// Searches the audit log with comprehensive filters.
  Future<List<Map<String, dynamic>>> searchAuditLog({
    String? eventType,
    String? entityType,
    String? actorId,
    String? dateFrom,
    String? dateTo,
    String? severity,
    String? search,
    int limit = 25,
    int offset = 0,
  }) async {
    final result = await _call('audit_search', {
      if (eventType != null) 'event_type': eventType,
      if (entityType != null) 'entity_type': entityType,
      if (actorId != null) 'actor_id': actorId,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (severity != null) 'severity': severity,
      if (search != null && search.isNotEmpty) 'search': search,
      'limit': limit,
      'offset': offset,
    });
    return _asList(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // COLLECTIONS MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════

  /// Returns collections dashboard: summary, PAR distribution, recent actions, top overdue.
  Future<Map<String, dynamic>> getCollectionsDashboard() async {
    final result = await _call('collections_dashboard');
    return _asMap(result);
  }

  /// Returns filterable/paginated overdue loan queue for collections.
  Future<Map<String, dynamic>> getCollectionsQueue({
    String? status,
    String? parBucket,
    String? assignedTo,
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await _call('collections_queue', {
      if (status != null) 'status': status,
      if (parBucket != null) 'par_bucket': parBucket,
      if (assignedTo != null) 'assigned_to': assignedTo,
      'limit': limit,
      'offset': offset,
    });
    return _asMap(result);
  }

  /// Logs a collection action against a loan. Returns the created action.
  Future<Map<String, dynamic>> logCollectionAction({
    required String loanId,
    required String actionType,
    String? notes,
    String outcome = 'N/A',
    String? promiseDate,
    double? promiseAmount,
    String? nextActionDate,
    String? nextActionType,
  }) async {
    final result = await _call('log_collection_action', {
      'loan_id': loanId,
      'action_type': actionType,
      if (notes != null) 'notes': notes,
      'outcome': outcome,
      if (promiseDate != null) 'promise_date': promiseDate,
      if (promiseAmount != null) 'promise_amount': promiseAmount,
      if (nextActionDate != null) 'next_action_date': nextActionDate,
      if (nextActionType != null) 'next_action_type': nextActionType,
    });
    return _asMap(result);
  }

  /// Waives penalty on a loan. ADMIN only. Creates reversal journal entry.
  Future<Map<String, dynamic>> waivePenalty({
    required String loanId,
    required double amount,
    required String reason,
  }) async {
    final result = await _call('waive_penalty', {
      'loan_id': loanId,
      'amount': amount,
      'reason': reason,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // FINANCIAL REPORTING
  // ═══════════════════════════════════════════════════════════════════

  /// Returns trial balance as of the given date.
  Future<Map<String, dynamic>> getTrialBalance(String asOfDate) async {
    final result = await _call('trial_balance', {'as_of_date': asOfDate});
    return _asMap(result);
  }

  /// Returns income statement for a date range.
  Future<Map<String, dynamic>> getIncomeStatement({
    required String fromDate,
    required String toDate,
  }) async {
    final result = await _call('income_statement', {
      'from_date': fromDate,
      'to_date': toDate,
    });
    return _asMap(result);
  }

  /// Returns balance sheet as of the given date.
  Future<Map<String, dynamic>> getBalanceSheet(String asOfDate) async {
    final result = await _call('balance_sheet', {'as_of_date': asOfDate});
    return _asMap(result);
  }

  /// Returns loan portfolio report with PAR aging and product breakdown.
  Future<Map<String, dynamic>> getLoanPortfolioReport(String asOfDate) async {
    final result =
        await _call('loan_portfolio_report', {'as_of_date': asOfDate});
    return _asMap(result);
  }

  /// Returns cash flow report for a date range.
  Future<Map<String, dynamic>> getCashflowReport({
    required String fromDate,
    required String toDate,
  }) async {
    final result = await _call('cashflow_report', {
      'from_date': fromDate,
      'to_date': toDate,
    });
    return _asMap(result);
  }

  /// Returns detailed PAR aging report as of the given date.
  Future<Map<String, dynamic>> getParAgingReport(String asOfDate) async {
    final result = await _call('par_aging_report', {'as_of_date': asOfDate});
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SMS / COMMUNICATION
  // ═══════════════════════════════════════════════════════════════════

  /// Returns SMS dashboard: summary, by category, queue status, recent.
  Future<Map<String, dynamic>> getSmsDashboard() async {
    final result = await _call('sms_dashboard');
    return _asMap(result);
  }

  /// Returns all active SMS templates.
  Future<List<Map<String, dynamic>>> getSmsTemplateList() async {
    final result = await _call('sms_template_list');
    return _asList(result);
  }

  /// Sends bulk SMS to multiple customers using a template.
  Future<Map<String, dynamic>> sendBulkSms({
    required String templateCode,
    required List<String> customerIds,
    List<Map<String, dynamic>>? variables,
    String language = 'sw',
  }) async {
    final result = await _call('send_bulk_sms', {
      'template_code': templateCode,
      'customer_ids': customerIds,
      if (variables != null) 'variables': variables,
      'language': language,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAN RESTRUCTURING & WRITE-OFF
  // ═══════════════════════════════════════════════════════════════════

  /// Returns combined restructure/write-off queue.
  Future<Map<String, dynamic>> getRestructureWriteoffQueue({
    String type = 'ALL',
    String status = 'ALL',
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await _call('restructure_writeoff_queue', {
      'type': type,
      'status': status,
      'limit': limit,
      'offset': offset,
    });
    return _asMap(result);
  }

  /// Requests a loan restructure. Returns the created request.
  Future<Map<String, dynamic>> requestRestructure({
    required String loanId,
    required String type,
    required Map<String, dynamic> newTerms,
    required String reason,
  }) async {
    final result = await _call('request_restructure', {
      'loan_id': loanId,
      'type': type,
      'new_terms': newTerms,
      'reason': reason,
    });
    return _asMap(result);
  }

  /// Approves or rejects a restructure request.
  Future<Map<String, dynamic>> approveRestructure({
    required String restructureId,
    required String decision,
    String? reason,
  }) async {
    final result = await _call('approve_restructure', {
      'restructure_id': restructureId,
      'decision': decision,
      if (reason != null) 'reason': reason,
    });
    return _asMap(result);
  }

  /// Requests a loan write-off. Returns the created request.
  Future<Map<String, dynamic>> requestWriteoff({
    required String loanId,
    required String reason,
  }) async {
    final result = await _call('request_writeoff', {
      'loan_id': loanId,
      'reason': reason,
    });
    return _asMap(result);
  }

  /// Approves or rejects a write-off request. ADMIN only.
  Future<Map<String, dynamic>> approveWriteoff({
    required String writeoffId,
    required String decision,
    String? reason,
  }) async {
    final result = await _call('approve_writeoff', {
      'writeoff_id': writeoffId,
      'decision': decision,
      if (reason != null) 'reason': reason,
    });
    return _asMap(result);
  }

  /// Records a recovery payment against a written-off loan.
  Future<Map<String, dynamic>> recordRecovery({
    required String writeoffId,
    required double amount,
    required String reference,
  }) async {
    final result = await _call('record_recovery', {
      'writeoff_id': writeoffId,
      'amount': amount,
      'reference': reference,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // BRANCH PERFORMANCE
  // ═══════════════════════════════════════════════════════════════════

  /// Returns per-branch KPIs and aggregate totals.
  Future<Map<String, dynamic>> getBranchDashboard() async {
    final result = await _call('branch_dashboard');
    return _asMap(result);
  }

  /// Returns side-by-side branch comparison for a date range.
  Future<Map<String, dynamic>> getBranchComparison({
    required String fromDate,
    required String toDate,
  }) async {
    final result = await _call('branch_comparison', {
      'from_date': fromDate,
      'to_date': toDate,
    });
    return _asMap(result);
  }

  /// Returns deep-dive detail for a single branch.
  Future<Map<String, dynamic>> getBranchDetail({
    required String branchId,
    required String fromDate,
    required String toDate,
  }) async {
    final result = await _call('branch_detail', {
      'branch_id': branchId,
      'from_date': fromDate,
      'to_date': toDate,
    });
    return _asMap(result);
  }

  /// Returns monthly trend data for a branch.
  Future<Map<String, dynamic>> getBranchTrend({
    required String branchId,
    int months = 6,
  }) async {
    final result = await _call('branch_trend', {
      'branch_id': branchId,
      'months': months,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // M-PESA RECONCILIATION
  // ═══════════════════════════════════════════════════════════════════

  /// Returns M-Pesa reconciliation dashboard with stats and transactions.
  Future<Map<String, dynamic>> getMpesaDashboard({
    String? status,
    String? fromDate,
    String? toDate,
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await _call('mpesa_dashboard', {
      if (status != null) 'status': status,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      'limit': limit,
      'offset': offset,
    });
    return _asMap(result);
  }

  /// Manually reconciles a completed but unreconciled M-Pesa transaction.
  Future<Map<String, dynamic>> mpesaManualReconcile({
    required String transactionId,
    required String appliedToType,
    required String appliedToId,
  }) async {
    final result = await _call('mpesa_manual_reconcile', {
      'transaction_id': transactionId,
      'applied_to_type': appliedToType,
      'applied_to_id': appliedToId,
    });
    return _asMap(result);
  }

  /// Searches M-Pesa transactions by receipt, phone, checkout ID, or amount.
  Future<List<Map<String, dynamic>>> mpesaSearchTransactions(
      String query, {int limit = 20}) async {
    final result = await _call('mpesa_search', {
      'query': query,
      'limit': limit,
    });
    if (result is Map<String, dynamic> && result.containsKey('results')) {
      return _asList(result['results']);
    }
    return _asList(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // APPROVAL WORKFLOW
  // ═══════════════════════════════════════════════════════════════════

  /// Returns pending approvals for the current staff member's role.
  Future<Map<String, dynamic>> getMyApprovals({
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await _call('my_approvals', {
      'limit': limit,
      'offset': offset,
    });
    return _asMap(result);
  }

  /// Processes an approval step (APPROVE or REJECT).
  Future<Map<String, dynamic>> processApproval({
    required String entityType,
    required String entityId,
    required String decision,
    String? comments,
    double? approvedAmount,
  }) async {
    final result = await _call('process_approval', {
      'entity_type': entityType,
      'entity_id': entityId,
      'decision': decision,
      if (comments != null) 'comments': comments,
      if (approvedAmount != null) 'approved_amount': approvedAmount,
    });
    return _asMap(result);
  }

  /// Returns the full approval chain for an entity.
  Future<Map<String, dynamic>> getApprovalChain({
    required String entityType,
    required String entityId,
  }) async {
    final result = await _call('approval_chain', {
      'entity_type': entityType,
      'entity_id': entityId,
    });
    return _asMap(result);
  }

  /// Returns all approval rules. ADMIN only.
  Future<Map<String, dynamic>> getApprovalRules() async {
    final result = await _call('approval_rules');
    return _asMap(result);
  }

  /// Creates, updates, or deactivates an approval rule. ADMIN only.
  Future<Map<String, dynamic>> updateApprovalRule({
    required String operation,
    String? ruleId,
    String? entityType,
    double? minAmount,
    double? maxAmount,
    String? riskCategory,
    int? requiredLevels,
    String? level1MinRole,
    String? level2MinRole,
    String? level3MinRole,
    String? description,
    int? priority,
  }) async {
    final result = await _call('update_approval_rule', {
      'operation': operation,
      if (ruleId != null) 'rule_id': ruleId,
      if (entityType != null) 'entity_type': entityType,
      if (minAmount != null) 'min_amount': minAmount,
      if (maxAmount != null) 'max_amount': maxAmount,
      if (riskCategory != null) 'risk_category': riskCategory,
      if (requiredLevels != null) 'required_levels': requiredLevels,
      if (level1MinRole != null) 'level_1_min_role': level1MinRole,
      if (level2MinRole != null) 'level_2_min_role': level2MinRole,
      if (level3MinRole != null) 'level_3_min_role': level3MinRole,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // TYPE HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) {
      return data
          .map((e) =>
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }
}
