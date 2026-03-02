// IMFSL Customer Gateway Service
// ================================
// Thin service layer that wraps all calls to the `imfsl-customer-gateway`
// Supabase edge function. One method per action (53 actions + helpers).
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
    final result = await _call('check_status', {
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
  // INSTANT LOAN (Mkopo Chap Chap)
  // ═══════════════════════════════════════════════════════════════════

  /// Registers or updates a device fingerprint. Returns the device record.
  Future<Map<String, dynamic>> registerDevice(
      Map<String, dynamic> deviceData) async {
    final result = await _call('register_device', deviceData);
    return _asMap(result);
  }

  /// Pre-qualifies the customer for an instant loan.
  /// Returns: qualified, max_amount, credit_score, device_trusted, checks, product.
  Future<Map<String, dynamic>> instantLoanPrequalify({
    String? deviceId,
  }) async {
    final result = await _call('instant_loan_prequalify', {
      if (deviceId != null) 'device_id': deviceId,
    });
    return _asMap(result);
  }

  /// Submits an instant loan application and runs the auto-decision engine.
  /// Returns: application_id, decision, disbursement (if auto-approved).
  Future<Map<String, dynamic>> instantLoanApply({
    required double requestedAmount,
    required int tenureMonths,
    String? purpose,
    String? phoneNumber,
    String? deviceDbId,
  }) async {
    final result = await _call('instant_loan_apply', {
      'requested_amount': requestedAmount,
      'tenure_months': tenureMonths,
      if (purpose != null) 'purpose': purpose,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (deviceDbId != null) 'device_db_id': deviceDbId,
    });
    return _asMap(result);
  }

  /// Polls the status of an instant loan application.
  /// Returns: application, decision, disbursement.
  Future<Map<String, dynamic>> instantLoanStatus(
      String applicationId) async {
    final result = await _call('instant_loan_status', {
      'application_id': applicationId,
    });
    return _asMap(result);
  }

  /// Requests an OTP for high-value instant loan disbursement.
  /// Returns: otp_sent, phone_number, expires_in_seconds.
  Future<Map<String, dynamic>> instantLoanRequestOtp(
      String applicationId) async {
    final result = await _call('instant_loan_request_otp', {
      'application_id': applicationId,
    });
    return _asMap(result);
  }

  /// Verifies OTP and triggers disbursement if valid.
  /// Returns: verified, disbursement (if verified).
  Future<Map<String, dynamic>> instantLoanVerifyOtp(
      String applicationId, String otpCode) async {
    final result = await _call('instant_loan_verify_otp', {
      'application_id': applicationId,
      'otp_code': otpCode,
    });
    return _asMap(result);
  }

  /// Confirms disbursement for loans below OTP threshold.
  /// Returns: loan_id, disbursement_id, amount, phone, status.
  Future<Map<String, dynamic>> instantLoanConfirmDisburse(
      String applicationId, {String? phoneNumber}) async {
    final result = await _call('instant_loan_confirm_disburse', {
      'application_id': applicationId,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAYMENTS & COLLECTIONS (Customer View)
  // ═══════════════════════════════════════════════════════════════════

  /// Returns upcoming payment installments across all active loans,
  /// plus a summary of total due this month and total overdue.
  Future<Map<String, dynamic>> getUpcomingPayments({int limit = 10}) async {
    final result = await _call('upcoming_payments', {'limit': limit});
    return _asMap(result);
  }

  /// Returns payment history for a specific loan, including loan summary
  /// and paginated list of completed repayment transactions.
  Future<Map<String, dynamic>> getPaymentHistory({
    required String loanId,
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await _call('payment_history', {
      'loan_id': loanId,
      'limit': limit,
      'offset': offset,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SAVINGS SUMMARY
  // ═══════════════════════════════════════════════════════════════════

  /// Returns savings account summary with balances and accrued interest.
  Future<Map<String, dynamic>> getSavingsSummary() async {
    final result = await _call('savings_summary');
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SMS NOTIFICATION
  // ═══════════════════════════════════════════════════════════════════

  /// Sends a templated SMS notification (self-service).
  Future<Map<String, dynamic>> sendSmsNotification({
    required String templateCode,
    Map<String, dynamic>? variables,
    String language = 'sw',
  }) async {
    final result = await _call('send_sms_notification', {
      'template_code': templateCode,
      if (variables != null) 'variables': variables,
      'language': language,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ONBOARDING
  // ═══════════════════════════════════════════════════════════════════

  /// Returns the onboarding status for the authenticated user.
  /// Possible statuses: NEEDS_KYC, KYC_PENDING, KYC_UNDER_REVIEW,
  /// KYC_REJECTED, KYC_APPROVED_NO_CUSTOMER, WELCOME, COMPLETE.
  Future<Map<String, dynamic>> getOnboardingStatus() async {
    final result = await _call('onboarding_status');
    return _asMap(result);
  }

  /// Opportunistically links auth_user_id to existing customer/KYC records
  /// matched by phone or email. Safe to call on every app startup.
  Future<Map<String, dynamic>> linkAuth() async {
    final result = await _call('link_auth');
    return _asMap(result);
  }

  /// Marks the welcome screen as shown for the current customer.
  Future<void> markWelcomeShown() async {
    await _call('mark_welcome_shown');
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAYMENT RECEIPT
  // ═══════════════════════════════════════════════════════════════════

  /// Returns full M-Pesa transaction details including reconciliation status.
  /// Used for real-time payment polling after STK push initiation.
  Future<Map<String, dynamic>> getPaymentReceipt(
      String transactionId) async {
    final result = await _call('payment_receipt', {
      'transaction_id': transactionId,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // RESTRUCTURE STATUS
  // ═══════════════════════════════════════════════════════════════════

  /// Returns the customer's loan restructure status/history.
  Future<List<Map<String, dynamic>>> getMyRestructureStatus() async {
    final result = await _call('my_restructure_status');
    return _asList(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAYMENT CENTER
  // ═══════════════════════════════════════════════════════════════════

  /// Returns aggregated payment dashboard data: monthly totals, active
  /// loans/savings quick-pay info, and pending payments.
  Future<Map<String, dynamic>> getPaymentCenterSummary() async {
    final result = await _call('payment_center_summary');
    return _asMap(result);
  }

  /// Returns a formatted receipt for a completed M-Pesa transaction,
  /// including applied-to info (loan/savings) and customer details.
  Future<Map<String, dynamic>> getFormattedReceipt({
    required String transactionId,
  }) async {
    final result = await _call('formatted_receipt', {
      'transaction_id': transactionId,
    });
    return _asMap(result);
  }

  /// Returns paginated M-Pesa payment history, optionally filtered by purpose.
  Future<Map<String, dynamic>> getRecentPayments({
    int limit = 20,
    int offset = 0,
    String? purpose,
  }) async {
    final result = await _call('recent_payments', {
      'limit': limit,
      'offset': offset,
      if (purpose != null) 'purpose': purpose,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SUPPORT TICKETS
  // ═══════════════════════════════════════════════════════════════════

  /// Creates a new support ticket with an initial message.
  Future<Map<String, dynamic>> createSupportTicket({
    required String category,
    required String subject,
    required String message,
    String? loanId,
    String? transactionId,
  }) async {
    final result = await _call('create_ticket', {
      'category': category,
      'subject': subject,
      'message': message,
      if (loanId != null) 'loan_id': loanId,
      if (transactionId != null) 'transaction_id': transactionId,
    });
    return _asMap(result);
  }

  /// Returns the customer's tickets with optional status filter.
  Future<List<Map<String, dynamic>>> getMyTickets({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await _call('my_tickets', {
      if (status != null) 'status': status,
      'limit': limit,
      'offset': offset,
    });
    return _asList(result);
  }

  /// Returns ticket detail with full conversation thread.
  Future<Map<String, dynamic>> getTicketDetail(String ticketId) async {
    final result = await _call('ticket_detail', {'ticket_id': ticketId});
    return _asMap(result);
  }

  /// Adds a message to an existing ticket.
  Future<Map<String, dynamic>> addTicketMessage({
    required String ticketId,
    required String message,
  }) async {
    final result = await _call('add_ticket_message', {
      'ticket_id': ticketId,
      'message': message,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SAVINGS WITHDRAWALS
  // ═══════════════════════════════════════════════════════════════════

  /// Requests a savings withdrawal. Balance is held atomically.
  Future<Map<String, dynamic>> requestSavingsWithdrawal({
    required String savingsAccountId,
    required double amount,
    String channel = 'MPESA',
    String? destinationPhone,
  }) async {
    final result = await _call('request_withdrawal', {
      'savings_account_id': savingsAccountId,
      'amount': amount,
      'channel': channel,
      if (destinationPhone != null) 'destination_phone': destinationPhone,
    });
    return _asMap(result);
  }

  /// Returns the customer's withdrawal history.
  Future<List<Map<String, dynamic>>> getMyWithdrawals({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await _call('my_withdrawals', {
      if (status != null) 'status': status,
      'limit': limit,
      'offset': offset,
    });
    return _asList(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GUARANTOR SELF-SERVICE
  // ═══════════════════════════════════════════════════════════════════

  /// Returns guarantor commitments where the customer is the guarantor.
  Future<List<Map<String, dynamic>>> getMyGuarantorCommitments() async {
    final result = await _call('my_guarantor_commitments');
    return _asList(result);
  }

  /// Returns unlinked guarantor invites matching the customer's phone/ID.
  Future<List<Map<String, dynamic>>> getGuarantorInvites() async {
    final result = await _call('guarantor_invites');
    return _asList(result);
  }

  /// Accepts or declines a guarantor request.
  Future<Map<String, dynamic>> respondToGuarantor({
    required String guarantorId,
    required String response,
  }) async {
    final result = await _call('respond_to_guarantor', {
      'guarantor_id': guarantorId,
      'response': response,
    });
    return _asMap(result);
  }

  /// Links an unlinked guarantor record to the customer's account.
  Future<Map<String, dynamic>> linkGuarantor(String guarantorId) async {
    final result = await _call('link_guarantor', {
      'guarantor_id': guarantorId,
    });
    return _asMap(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAN RESTRUCTURE (Customer Self-Service)
  // ═══════════════════════════════════════════════════════════════════

  /// Submits a customer-initiated loan restructure request.
  Future<Map<String, dynamic>> requestRestructure({
    required String loanId,
    required String type,
    required String reason,
    int? requestedTerm,
  }) async {
    final result = await _call('request_restructure', {
      'loan_id': loanId,
      'type': type,
      'reason': reason,
      if (requestedTerm != null) 'requested_term': requestedTerm,
    });
    return _asMap(result);
  }

  /// Returns the customer's restructure requests with approval progress.
  Future<List<Map<String, dynamic>>> getMyRestructureRequests({
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await _call('my_restructure_requests', {
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
