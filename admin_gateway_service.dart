// IMFSL Admin Gateway Service
// ============================
// Typed wrapper for the `imfsl-admin-gateway` Supabase edge function.
// 13 actions with RBAC (ADMIN, MANAGER, OFFICER, AUDITOR, TELLER).
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
