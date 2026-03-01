// IMFSL Customer App Logic
// =========================
// Stateful wrapper that connects CustomerAppHomeScreen to the
// imfsl-customer-gateway edge function via CustomerGatewayService.
//
// Handles:
//   - Initial parallel data loading (profile, loans, savings, etc.)
//   - All callback implementations for the 8 customer widgets
//   - State management and refresh
//   - Navigation to TransactionHistory and LoanApplicationForm
//   - Loading screen, error screen, retry
//
// Usage:
//   CustomerAppLogic(supabaseClient: Supabase.instance.client)
//
// Dependencies (add to pubspec.yaml):
//   supabase_flutter: ^2.0.0
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'customer_gateway_service.dart';
import 'customer_app_home_screen.dart';
import 'transaction_history.dart';
import 'loan_application_form.dart';
import 'instant_loan_widget.dart';
import 'instant_loan_status_tracker.dart';
import 'otp_verification_dialog.dart';

class CustomerAppLogic extends StatefulWidget {
  const CustomerAppLogic({
    super.key,
    required this.supabaseClient,
    this.onLogout,
  });

  /// The Supabase client instance (must be authenticated).
  final SupabaseClient supabaseClient;

  /// Called when the user taps "Log Out". Parent should navigate to login.
  final VoidCallback? onLogout;

  @override
  State<CustomerAppLogic> createState() => _CustomerAppLogicState();
}

class _CustomerAppLogicState extends State<CustomerAppLogic> {
  static const _primaryColor = Color(0xFF1565C0);

  late final CustomerGatewayService _service;

  // ── Loading state ──────────────────────────────────────────────────
  bool _initialLoading = true;
  String? _loadError;

  // ── Customer identity ──────────────────────────────────────────────
  Map<String, dynamic> _customerData = {};
  String _customerName = '';
  String _customerId = '';
  String _customerPhone = '';
  String _kycStatus = '';

  // ── Dashboard summary ──────────────────────────────────────────────
  double _accountBalance = 0.0;
  double _loanBalance = 0.0;
  double _savingsBalance = 0.0;

  // ── Lists ──────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _loans = [];
  List<Map<String, dynamic>> _savingsAccounts = [];
  List<Map<String, dynamic>> _loanProducts = [];
  List<Map<String, dynamic>> _scoreHistory = [];
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _recentTransactions = [];
  int _unreadNotificationCount = 0;
  Map<String, dynamic>? _existingKycStatus;

  // ── Upcoming Payments ────────────────────────────────────────────
  Map<String, dynamic> _upcomingPayments = {};
  Map<String, dynamic> _paymentHistoryData = {};
  bool _isUpcomingLoading = false;
  bool _isPaymentHistoryLoading = false;

  // ── Instant Loan (Mkopo Chap Chap) ──────────────────────────────
  Map<String, dynamic>? _prequalification;
  String? _deviceId; // Device fingerprint ID (e.g. from platform_device_id)
  String? _deviceDbId; // UUID from customer_devices table

  // ═══════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _service = CustomerGatewayService(client: widget.supabaseClient);
    _loadInitialData();
    _registerDeviceOnStartup();
  }

  // ═══════════════════════════════════════════════════════════════════
  // DATA LOADING
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadInitialData() async {
    setState(() {
      _initialLoading = true;
      _loadError = null;
    });

    try {
      // Load all data in parallel for speed
      final results = await Future.wait<dynamic>([
        _service.getProfile(),                                  // 0
        _service.getMyLoans(),                                  // 1
        _service.getMySavings(),                                // 2
        _service.getLoanProducts(),                              // 3
        _service.getMyCreditScore(),                             // 4
        _service.getMyNotifications(limit: 20, offset: 0),      // 5
        _service.getUnreadNotificationCount(),                   // 6
        _service.getKycStatus().catchError((_) => <String, dynamic>{}), // 7
        _service.getMyTransactions(limit: 5),                    // 8
        _service.instantLoanPrequalify(deviceId: _deviceId).catchError((_) => <String, dynamic>{}), // 9
        _service.getUpcomingPayments().catchError((_) => <String, dynamic>{}), // 10
      ]);

      if (!mounted) return;

      final profile = results[0] as Map<String, dynamic>;
      final loans = results[1] as List<Map<String, dynamic>>;
      final savings = results[2] as List<Map<String, dynamic>>;
      final products = results[3] as List<Map<String, dynamic>>;
      final scores = results[4] as List<Map<String, dynamic>>;
      final notifs = results[5] as List<Map<String, dynamic>>;
      final unread = results[6] as int;
      final kyc = results[7] as Map<String, dynamic>;
      final txns = results[8] as List<Map<String, dynamic>>;
      final prequal = results[9] as Map<String, dynamic>;
      final upcoming = results[10] as Map<String, dynamic>;

      setState(() {
        _customerData = profile;
        _customerName = _str(profile['full_name']);
        _customerId = _str(profile['id'] ?? profile['customer_id']);
        _customerPhone = _str(profile['phone_number'] ?? profile['phone']);
        _kycStatus = _str(kyc['status'] ?? profile['kyc_status']);

        _loans = loans;
        _savingsAccounts = savings;
        _loanProducts = products;
        _scoreHistory = scores;
        _notifications = notifs;
        _unreadNotificationCount = unread;
        _existingKycStatus = kyc.isNotEmpty ? kyc : null;
        _recentTransactions = txns;

        _accountBalance = _dbl(profile['account_balance']);
        _loanBalance = _computeTotalOutstanding(loans);
        _savingsBalance = _computeTotalSavings(savings);
        _prequalification = prequal.isNotEmpty ? prequal : null;
        if (prequal['device_id'] != null) {
          _deviceDbId = prequal['device_id'] as String;
        }
        _upcomingPayments = upcoming;

        _initialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e is GatewayException ? e.message : e.toString();
        _initialLoading = false;
      });
    }
  }

  double _computeTotalOutstanding(List<Map<String, dynamic>> loans) {
    double total = 0;
    for (final loan in loans) {
      final status = _str(loan['status']).toUpperCase();
      if (status == 'ACTIVE' || status == 'OVERDUE') {
        total += _dbl(loan['outstanding_balance']);
      }
    }
    return total;
  }

  double _computeTotalSavings(List<Map<String, dynamic>> accounts) {
    double total = 0;
    for (final a in accounts) {
      total += _dbl(a['balance'] ?? a['current_balance']);
    }
    return total;
  }

  // ═══════════════════════════════════════════════════════════════════
  // CALLBACK IMPLEMENTATIONS
  // ═══════════════════════════════════════════════════════════════════

  // ── Loan callbacks ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> _handleLoadLoanDetail(String loanId) async {
    return _service.getLoanDetail(loanId);
  }

  void _handleViewLoanStatement(String loanId) async {
    try {
      await _service.getLoanStatement(loanId);
      // Statement generation handled server-side; could show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan statement generated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${_errorMsg(e)}')),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _handleCalculateSchedule(
      double principal, double rate, int months) async {
    return _service.calculateSchedule(
      principal: principal,
      rate: rate,
      months: months,
    );
  }

  void _handleApplyLoan(Map<String, dynamic> product) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Apply for Loan'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        body: LoanApplicationForm(
          customerId: _customerId,
          loanProducts: _loanProducts,
          onSubmit: (application) async {
            final result = await _service.applyLoan(application);
            // Refresh loans after successful application
            if (mounted) {
              _refreshLoans();
            }
            return result;
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    ));
  }

  // ── Savings callbacks ──────────────────────────────────────────────

  Future<Map<String, dynamic>> _handleLoadAccountDetail(
      String accountId) async {
    return _service.getSavingsDetail(accountId);
  }

  void _handleWithdraw(Map<String, dynamic> account) {
    // Withdrawal requires a separate flow (bank transfer, etc.)
    // Show a placeholder dialog until the withdrawal flow is built
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Funds'),
        content: Text(
            'Withdrawal from ${account['account_number'] ?? 'savings account'} '
            'will be processed. Please visit a branch or use the USSD menu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Credit score callbacks ─────────────────────────────────────────

  Future<void> _handleRefreshCreditScore() async {
    try {
      final scores = await _service.getMyCreditScore();
      if (mounted) {
        setState(() => _scoreHistory = scores);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${_errorMsg(e)}')),
        );
      }
    }
  }

  Future<void> _handleRequestScoreRefresh() async {
    try {
      await _service.requestScoreRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Score refresh requested. Check back shortly.')),
        );
      }
      // Reload scores after a brief delay to allow server processing
      await Future.delayed(const Duration(seconds: 3));
      await _handleRefreshCreditScore();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${_errorMsg(e)}')),
        );
      }
    }
  }

  // ── Notification callbacks ─────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _handleLoadMoreNotifications(
      int offset, bool unreadOnly) async {
    return _service.getMyNotifications(
      limit: 20,
      offset: offset,
      unreadOnly: unreadOnly,
    );
  }

  Future<void> _handleMarkNotificationRead(String notificationId) async {
    await _service.markNotificationRead(notificationId);
    if (mounted) {
      setState(() {
        _unreadNotificationCount =
            (_unreadNotificationCount - 1).clamp(0, 999);
      });
    }
  }

  Future<void> _handleMarkAllNotificationsRead() async {
    final count = await _service.markAllNotificationsRead();
    if (mounted) {
      setState(() => _unreadNotificationCount = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count notifications marked as read')),
      );
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Could deep-link to the relevant loan/transaction based on type
    final type = _str(notification['notification_type']).toUpperCase();
    if (type.contains('LOAN')) {
      // Could navigate to loan detail
    } else if (type.contains('PAYMENT') || type.contains('TRANSACTION')) {
      // Could navigate to transaction detail
    }
  }

  // ── Profile callbacks ──────────────────────────────────────────────

  Future<Map<String, dynamic>> _handleSaveProfile(
      Map<String, dynamic> updates) async {
    final result = await _service.updateProfile(
      phoneNumber: updates['phone_number'] as String?,
      email: updates['email'] as String?,
      address: updates['address'] as String?,
      occupation: updates['occupation'] as String?,
      monthlyIncome: updates['monthly_income'] != null
          ? double.tryParse(updates['monthly_income'].toString())
          : null,
    );

    // Update local state with the saved profile
    if (mounted) {
      setState(() {
        _customerData = {..._customerData, ...result};
        _customerName = _str(result['full_name']);
        _customerPhone =
            _str(result['phone_number'] ?? result['phone']);
      });
    }
    return result;
  }

  Future<bool> _handleChangePassword(
      String oldPassword, String newPassword) async {
    try {
      await widget.supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${_errorMsg(e)}')),
        );
      }
      return false;
    }
  }

  Future<bool> _handleToggle2FA(bool enable) async {
    // 2FA enrollment requires Supabase MFA APIs
    // Placeholder until MFA flow is implemented
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(enable
                ? '2FA enrollment coming soon'
                : '2FA disabled')),
      );
    }
    return false;
  }

  void _handleToggleNotification(String type, bool enabled) {
    // Notification preferences stored locally or server-side
    // Placeholder implementation
  }

  // ── KYC callbacks ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> _handleSubmitKyc(
      Map<String, dynamic> kycData) async {
    final result = await _service.submitKyc(kycData);
    // Refresh KYC status after submission
    _refreshKycStatus();
    return result;
  }

  Future<Map<String, dynamic>> _handleCheckKycStatus() async {
    final status = await _service.getKycStatus();
    if (mounted) {
      setState(() {
        _existingKycStatus = status.isNotEmpty ? status : null;
        _kycStatus = _str(status['status']);
      });
    }
    return status;
  }

  Future<String> _handleCaptureSelfie() async {
    // Image capture handled by the device camera.
    // Return a placeholder — the actual implementation depends on
    // image_picker or camera plugin integration.
    return '';
  }

  Future<Map<String, dynamic>> _handleLivenessCheck() async {
    // Liveness verification handled by a third-party SDK.
    // Return a placeholder result.
    return {'status': 'pending', 'message': 'Liveness check not configured'};
  }

  void _handleKycComplete() {
    _refreshKycStatus();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC submitted successfully!')),
      );
    }
  }

  // ── M-Pesa callbacks ───────────────────────────────────────────────

  Future<Map<String, dynamic>> _handleInitiatePayment(
      Map<String, dynamic> paymentData) async {
    return _service.initiateMpesaPayment(paymentData);
  }

  Future<Map<String, dynamic>> _handleCheckPaymentStatus(
      String transactionId) async {
    return _service.checkPaymentStatus(transactionId);
  }

  void _handlePaymentComplete(Map<String, dynamic> result) {
    // Refresh relevant data after successful payment
    _refreshLoans();
    _refreshSavings();
    _refreshTransactions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed successfully!')),
      );
    }
  }

  // ── Instant Loan (Mkopo Chap Chap) callbacks ─────────────────────

  Future<void> _registerDeviceOnStartup() async {
    // Generate a simple device ID from platform info
    // In production, use platform_device_id or device_info_plus package
    _deviceId = 'flutter_device_${DateTime.now().millisecondsSinceEpoch}';
    try {
      final result = await _service.registerDevice({
        'device_id': _deviceId,
        'platform': 'android', // Detect from Platform.isAndroid/isIOS
        'device_name': 'Flutter App',
        'app_version': '1.0.0',
      });
      if (mounted && result['id'] != null) {
        setState(() => _deviceDbId = result['id'] as String);
      }
    } catch (_) {
      // Non-critical — app works without device registration
    }
  }

  void _handleInstantLoanApplyNow() {
    if (_prequalification == null) return;

    final product = _prequalification!['product'] as Map<String, dynamic>?;
    if (product == null) return;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        body: InstantLoanWidget(
          prequalifiedAmount: _dbl(_prequalification!['max_amount']),
          product: product,
          creditScore: _dbl(_prequalification!['credit_score']),
          customerPhone: _customerPhone,
          deviceDbId: _deviceDbId,
          onApply: (applicationData) async {
            try {
              final result = await _service.instantLoanApply(
                requestedAmount: _dbl(applicationData['requested_amount']),
                tenureMonths: (applicationData['tenure_months'] as num).toInt(),
                purpose: applicationData['purpose'] as String?,
                phoneNumber: _customerPhone,
                deviceDbId: _deviceDbId,
              );
              if (mounted) {
                Navigator.of(context).pop();
                _showInstantLoanStatusTracker(result);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${_errorMsg(e)}')),
                );
              }
            }
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    ));
  }

  void _showInstantLoanStatusTracker(Map<String, dynamic> applyResult) {
    final applicationId = applyResult['application_id'] as String? ?? '';
    final decision = applyResult['decision'] as Map<String, dynamic>?;
    final amount = _dbl(decision?['requested_amount'] ?? applyResult['requested_amount']);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => InstantLoanStatusTracker(
        applicationId: applicationId,
        requestedAmount: amount,
        phoneNumber: _customerPhone,
        initialDecision: decision,
        onCheckStatus: (appId) => _service.instantLoanStatus(appId),
        onRequestOtp: (appId) => _service.instantLoanRequestOtp(appId),
        onVerifyOtp: (appId, code) => _service.instantLoanVerifyOtp(appId, code),
        onComplete: (result) {
          _refreshLoans();
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hongera! Mkopo wako umetumwa!')),
            );
          }
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    ));
  }

  Future<void> _handleRefreshPrequalification() async {
    try {
      final prequal = await _service.instantLoanPrequalify(deviceId: _deviceId);
      if (mounted) {
        setState(() {
          _prequalification = prequal.isNotEmpty ? prequal : null;
          if (prequal['device_id'] != null) {
            _deviceDbId = prequal['device_id'] as String;
          }
        });
      }
    } catch (_) {}
  }

  // ── Upcoming Payments & Payment History callbacks ────────────────

  Future<void> _refreshUpcomingPayments() async {
    setState(() => _isUpcomingLoading = true);
    try {
      final data = await _service.getUpcomingPayments();
      if (mounted) {
        setState(() {
          _upcomingPayments = data;
          _isUpcomingLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isUpcomingLoading = false);
    }
  }

  Future<void> _handleLoadPaymentHistory(String loanId,
      {int limit = 20, int offset = 0}) async {
    setState(() => _isPaymentHistoryLoading = true);
    try {
      final data = await _service.getPaymentHistory(
        loanId: loanId,
        limit: limit,
        offset: offset,
      );
      if (mounted) {
        setState(() {
          _paymentHistoryData = data;
          _isPaymentHistoryLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPaymentHistoryLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${_errorMsg(e)}')),
        );
      }
    }
  }

  void _handlePayNowFromReminder() {
    // Navigate to M-Pesa payment — delegate to home screen overlay
  }

  // ── Navigation callbacks ───────────────────────────────────────────

  void _handleViewAllTransactions() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        body: TransactionHistory(
          customerId: _customerId,
          initialTransactions: _recentTransactions,
          onLoadMore: (page, type, search, from, to) async {
            return _service.getMyTransactions(
              limit: 20,
              offset: page * 20,
              type: type,
              fromDate: from?.toIso8601String(),
              toDate: to?.toIso8601String(),
            );
          },
          onRefresh: _refreshTransactions,
        ),
      ),
    ));
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.supabaseClient.auth.signOut();
              widget.onLogout?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PARTIAL REFRESH HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _refreshLoans() async {
    try {
      final loans = await _service.getMyLoans();
      if (mounted) {
        setState(() {
          _loans = loans;
          _loanBalance = _computeTotalOutstanding(loans);
        });
      }
    } catch (_) {}
  }

  Future<void> _refreshSavings() async {
    try {
      final savings = await _service.getMySavings();
      if (mounted) {
        setState(() {
          _savingsAccounts = savings;
          _savingsBalance = _computeTotalSavings(savings);
        });
      }
    } catch (_) {}
  }

  Future<void> _refreshTransactions() async {
    try {
      final txns = await _service.getMyTransactions(limit: 5);
      if (mounted) setState(() => _recentTransactions = txns);
    } catch (_) {}
  }

  Future<void> _refreshKycStatus() async {
    try {
      final kyc = await _service.getKycStatus();
      if (mounted) {
        setState(() {
          _existingKycStatus = kyc.isNotEmpty ? kyc : null;
          _kycStatus = _str(kyc['status']);
        });
      }
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) return _buildLoadingScreen();
    if (_loadError != null) return _buildErrorScreen();

    return CustomerAppHomeScreen(
      // ── Identity ──
      customerName: _customerName,
      customerId: _customerId,
      customerPhone: _customerPhone,
      kycStatus: _kycStatus,
      // ── Dashboard summary ──
      accountBalance: _accountBalance,
      loanBalance: _loanBalance,
      savingsBalance: _savingsBalance,
      // ── List data ──
      recentTransactions: _recentTransactions,
      loans: _loans,
      savingsAccounts: _savingsAccounts,
      loanProducts: _loanProducts,
      scoreHistory: _scoreHistory,
      notifications: _notifications,
      unreadNotificationCount: _unreadNotificationCount,
      customerData: _customerData,
      existingKycStatus: _existingKycStatus,
      // ── Dashboard ──
      onRefreshDashboard: _loadInitialData,
      // ── Loan callbacks ──
      onLoadLoanDetail: _handleLoadLoanDetail,
      onViewLoanStatement: _handleViewLoanStatement,
      onCalculateSchedule: _handleCalculateSchedule,
      onApplyLoan: _handleApplyLoan,
      // ── Savings callbacks ──
      onLoadAccountDetail: _handleLoadAccountDetail,
      onWithdraw: _handleWithdraw,
      // ── Credit score callbacks ──
      onRefreshCreditScore: _handleRefreshCreditScore,
      onRequestScoreRefresh: _handleRequestScoreRefresh,
      // ── Notification callbacks ──
      onLoadMoreNotifications: _handleLoadMoreNotifications,
      onMarkNotificationRead: _handleMarkNotificationRead,
      onMarkAllNotificationsRead: _handleMarkAllNotificationsRead,
      onNotificationTap: _handleNotificationTap,
      // ── Profile callbacks ──
      onSaveProfile: _handleSaveProfile,
      onChangePassword: _handleChangePassword,
      onToggle2FA: _handleToggle2FA,
      onToggleNotification: _handleToggleNotification,
      // ── KYC callbacks ──
      onSubmitKyc: _handleSubmitKyc,
      onCheckKycStatus: _handleCheckKycStatus,
      onCaptureSelfie: _handleCaptureSelfie,
      onLivenessCheck: _handleLivenessCheck,
      onKycComplete: _handleKycComplete,
      // ── M-Pesa callbacks ──
      onInitiatePayment: _handleInitiatePayment,
      onCheckPaymentStatus: _handleCheckPaymentStatus,
      onPaymentComplete: _handlePaymentComplete,
      // ── Instant Loan callbacks ──
      prequalification: _prequalification,
      onInstantLoanApplyNow: _handleInstantLoanApplyNow,
      onRefreshPrequalification: _handleRefreshPrequalification,
      // ── Upcoming Payments callbacks ──
      upcomingPayments: _upcomingPayments,
      isUpcomingLoading: _isUpcomingLoading,
      paymentHistoryData: _paymentHistoryData,
      isPaymentHistoryLoading: _isPaymentHistoryLoading,
      onRefreshUpcomingPayments: _refreshUpcomingPayments,
      onLoadPaymentHistory: _handleLoadPaymentHistory,
      // ── Terminal callbacks ──
      onLogout: _handleLogout,
      onViewAllTransactions: _handleViewAllTransactions,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOADING & ERROR SCREENS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.account_balance,
                  color: _primaryColor, size: 32),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            Text('Loading your account...',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    Icon(Icons.error_outline, color: Colors.red[400], size: 32),
              ),
              const SizedBox(height: 20),
              const Text('Something went wrong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                _loadError ?? 'Unable to load your account data.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadInitialData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TYPE HELPERS
  // ═══════════════════════════════════════════════════════════════════

  static String _str(dynamic v) => v?.toString() ?? '';

  static double _dbl(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static String _errorMsg(dynamic e) {
    if (e is GatewayException) return e.message;
    return e.toString();
  }
}
