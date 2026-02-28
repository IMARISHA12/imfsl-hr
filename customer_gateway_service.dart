// IMFSL Customer Gateway Service
// ================================
// Thin service layer that wraps all calls to the `imfsl-customer-gateway`
// Supabase edge function. One method per action (21 actions + helpers).
//
// Usage:
//   final service = CustomerGatewayService(client: Supabase.instance.client);
//   final profile = await service.getProfile();
//   final loans = await service.getMyLoans();
//
// Dependencies (add to pubspec.yaml):
//   supabase_flutter: ^2.0.0

import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception thrown when the edge function returns an error response.
class GatewayException implements Exception {
  final String message;
  final int? statusCode;
  const GatewayException(this.message, {this.statusCode});

  @override
  String toString() => 'GatewayException: $message';
}

class CustomerGatewayService {
  CustomerGatewayService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  static const _functionName = 'imfsl-customer-gateway';

  // ═══════════════════════════════════════════════════════════════════
  // INTERNAL CALL HELPER
  // ═══════════════════════════════════════════════════════════════════

  /// Invokes the customer gateway edge function with the given [action]
  /// and optional [params]. Returns the parsed response data.
  /// Throws [GatewayException] on error.
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
      throw GatewayException('Network error: $e');
    }

    final data = response.data;

    // Edge function returns {error: "..."} on failure
    if (data is Map<String, dynamic> && data.containsKey('error')) {
      throw GatewayException(
        data['error']?.toString() ?? 'Unknown error',
        statusCode: response.status,
      );
    }

    // Unwrap {data: ...} envelope if present
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'];
    }

    return data;
  }

  // ═══════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════

  /// Returns the authenticated customer's full profile row.
  Future<Map<String, dynamic>> getProfile() async {
    final result = await _call('my_profile');
    return _asMap(result);
  }

  /// Updates permitted profile fields. Returns the updated customer row.
  Future<Map<String, dynamic>> updateProfile({
    String? phoneNumber,
    String? email,
    String? address,
    String? occupation,
    double? monthlyIncome,
  }) async {
    final result = await _call('update_profile', {
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (occupation != null) 'occupation': occupation,
      if (monthlyIncome != null) 'monthly_income': monthlyIncome,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOANS
  // ═══════════════════════════════════════════════════════════════════

  /// Returns the customer's loan list with joined loan product info.
  Future<List<Map<String, dynamic>>> getMyLoans() async {
    final result = await _call('my_loans');
    return _asList(result);
  }

  /// Returns full loan detail: loan + loan_product + repayment_schedule[].
  Future<Map<String, dynamic>> getLoanDetail(String loanId) async {
    final result = await _call('loan_detail', {'loan_id': loanId});
    return _asMap(result);
  }

  /// Returns all active loan products (public catalog).
  Future<List<Map<String, dynamic>>> getLoanProducts() async {
    final result = await _call('loan_products');
    return _asList(result);
  }

  /// Submits a new loan application. Returns the created application.
  Future<Map<String, dynamic>> applyLoan(
      Map<String, dynamic> applicationData) async {
    final result = await _call('apply_loan', applicationData);
    return _asMap(result);
  }

  /// Generates a loan statement PDF/data for the given loan.
  Future<Map<String, dynamic>> getLoanStatement(String loanId) async {
    final result = await _call('loan_statement', {'loan_id': loanId});
    return _asMap(result);
  }

  /// Proxies to the calculate-loan-schedule edge function for EMI preview.
  Future<List<Map<String, dynamic>>> calculateSchedule({
    required double principal,
    required double rate,
    required int months,
  }) async {
    final result = await _call('calculate_schedule', {
      'principal': principal,
      'rate': rate,
      'months': months,
    });
    return _asList(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SAVINGS
  // ═══════════════════════════════════════════════════════════════════

  /// Returns the customer's savings accounts with joined product info.
  Future<List<Map<String, dynamic>>> getMySavings() async {
    final result = await _call('my_savings');
    return _asList(result);
  }

  /// Returns savings detail: account + product + 20 recent transactions.
  Future<Map<String, dynamic>> getSavingsDetail(String accountId) async {
    final result =
        await _call('savings_detail', {'account_id': accountId});
    return _asMap(result);
  }

  /// Generates an account statement for the given savings account.
  Future<Map<String, dynamic>> getAccountStatement(String accountId) async {
    final result =
        await _call('account_statement', {'account_id': accountId});
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREDIT SCORE
  // ═══════════════════════════════════════════════════════════════════

  /// Returns the customer's credit score history (all records).
  Future<List<Map<String, dynamic>>> getMyCreditScore() async {
    final result = await _call('my_credit_score');
    return _asList(result);
  }

  /// Triggers a credit score recalculation via the scoring engine.
  Future<Map<String, dynamic>> requestScoreRefresh() async {
    final result = await _call('request_score_refresh');
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Returns paginated transactions with optional filters.
  Future<List<Map<String, dynamic>>> getMyTransactions({
    int limit = 20,
    int offset = 0,
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    final result = await _call('my_transactions', {
      'limit': limit,
      'offset': offset,
      if (type != null) 'type': type,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
    });
    return _asList(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Returns paginated notifications.
  Future<List<Map<String, dynamic>>> getMyNotifications({
    int limit = 20,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    final result = await _call('my_notifications', {
      'limit': limit,
      'offset': offset,
      'unread_only': unreadOnly,
    });
    return _asList(result);
  }

  /// Marks a single notification as read.
  Future<void> markNotificationRead(String notificationId) async {
    await _call('mark_read', {'notification_id': notificationId});
  }

  /// Marks all notifications as read. Returns the count marked.
  Future<int> markAllNotificationsRead() async {
    final result = await _call('mark_all_read');
    if (result is Map && result.containsKey('count')) {
      return (result['count'] as num?)?.toInt() ?? 0;
    }
    if (result is int) return result;
    return 0;
  }

  /// Returns the count of unread notifications.
  Future<int> getUnreadNotificationCount() async {
    final result = await _call('unread_count');
    if (result is Map && result.containsKey('count')) {
      return (result['count'] as num?)?.toInt() ?? 0;
    }
    if (result is int) return result;
    return 0;
  }

  // ═══════════════════════════════════════════════════════════════════
  // M-PESA
  // ═══════════════════════════════════════════════════════════════════

  /// Initiates an M-Pesa STK push for loan repayment or savings deposit.
  Future<Map<String, dynamic>> initiateMpesaPayment(
      Map<String, dynamic> paymentData) async {
    final result = await _call('mpesa_pay', paymentData);
    return _asMap(result);
  }

  /// Checks the status of an M-Pesa STK push transaction.
  /// Used for polling during the payment flow.
  Future<Map<String, dynamic>> checkPaymentStatus(
      String transactionId) async {
    final result = await _call('mpesa_pay', {
      'check_status': true,
      'transaction_id': transactionId,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // KYC
  // ═══════════════════════════════════════════════════════════════════

  /// Submits KYC documents and personal data. Works pre-registration.
  Future<Map<String, dynamic>> submitKyc(
      Map<String, dynamic> kycData) async {
    final result = await _call('submit_kyc', kycData);
    return _asMap(result);
  }

  /// Returns the latest KYC submission status. Works pre-registration.
  Future<Map<String, dynamic>> getKycStatus() async {
    final result = await _call('kyc_status');
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
