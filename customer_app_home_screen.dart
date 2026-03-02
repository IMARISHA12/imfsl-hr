// IMFSL Customer App Home Screen
// ===============================
// Main navigation shell integrating all 9 customer widgets:
//   KYC Onboarding, Loan Products Catalog, My Loans, Savings Accounts,
//   Credit Score, Notifications Center, Customer Profile, M-Pesa Payment,
//   Payment Center
//
// Structure:
//   - 5-tab bottom navigation (Home, Loans, Pay, Savings, More)
//   - Overlay navigation for sub-screens with back-button support
//   - Home dashboard with balance card, quick actions, and summary cards
//   - Pay tab with payment center (quick-pay, history, receipts)
//   - Cross-widget navigation (Pay Now → M-Pesa, Browse Products, etc.)
//   - Notification badge on app bar bell icon
//   - KYC status banner for unverified customers
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Customer widget imports — adjust paths for your project structure.
// In FlutterFlow: import '/custom_code/widgets/<name>.dart';
import 'kyc_onboarding_widget.dart';
import 'loan_products_catalog.dart';
import 'my_loans_widget.dart';
import 'savings_account_widget.dart';
import 'credit_score_widget.dart';
import 'notifications_center_widget.dart';
import 'customer_profile_widget.dart';
import 'mpesa_payment_widget.dart';
import 'loan_prequalification_card.dart';
import 'payment_reminder_card.dart';
import 'payment_history_widget.dart';
import 'imfsl_payment_center.dart';
import 'imfsl_support_tickets.dart';
import 'imfsl_guarantor_management.dart';
import 'imfsl_savings_withdrawal.dart';
import 'imfsl_loan_restructure_request.dart';

enum _OverlayScreen {
  loanProducts,
  notifications,
  profile,
  creditScore,
  kyc,
  mpesaPayment,
  instantLoan,
  paymentHistory,
  supportTickets,
  guarantorManagement,
  savingsWithdrawal,
  restructureRequest,
}

class CustomerAppHomeScreen extends StatefulWidget {
  const CustomerAppHomeScreen({
    super.key,
    // ── Customer identity ──
    required this.customerName,
    required this.customerId,
    this.customerPhone = '',
    this.kycStatus = '',
    // ── Dashboard summary ──
    this.accountBalance = 0.0,
    this.loanBalance = 0.0,
    this.savingsBalance = 0.0,
    this.loanLimit = 0.0,
    this.loanDueDate,
    this.savingsGoal = 0.0,
    // ── List data ──
    this.recentTransactions = const [],
    this.loans = const [],
    this.savingsAccounts = const [],
    this.loanProducts = const [],
    this.scoreHistory = const [],
    this.notifications = const [],
    this.unreadNotificationCount = 0,
    this.customerData = const {},
    this.existingKycStatus,
    // ── Dashboard ──
    this.onRefreshDashboard,
    // ── Loan callbacks ──
    this.onLoadLoanDetail,
    this.onViewLoanStatement,
    this.onCalculateSchedule,
    this.onApplyLoan,
    // ── Savings callbacks ──
    this.onLoadAccountDetail,
    this.onWithdraw,
    // ── Credit score callbacks ──
    this.onRefreshCreditScore,
    this.onRequestScoreRefresh,
    // ── Notification callbacks ──
    this.onLoadMoreNotifications,
    this.onMarkNotificationRead,
    this.onMarkAllNotificationsRead,
    this.onNotificationTap,
    // ── Profile callbacks ──
    this.onSaveProfile,
    this.onChangePassword,
    this.onToggle2FA,
    this.onToggleNotification,
    // ── KYC callbacks ──
    this.onSubmitKyc,
    this.onCheckKycStatus,
    this.onCaptureSelfie,
    this.onLivenessCheck,
    this.onKycComplete,
    // ── M-Pesa callbacks ──
    this.onInitiatePayment,
    this.onCheckPaymentStatus,
    this.onPaymentComplete,
    // ── Instant Loan callbacks ──
    this.prequalification,
    this.onInstantLoanApplyNow,
    this.onRefreshPrequalification,
    // ── Payments & Collections ────────────────────────────────────
    this.upcomingPayments = const {},
    this.isUpcomingLoading = false,
    this.paymentHistoryData = const {},
    this.isPaymentHistoryLoading = false,
    this.onRefreshUpcomingPayments,
    this.onLoadPaymentHistory,
    this.onLoadMorePaymentHistory,
    // ── Payment Center ────────────────────────────────────────────
    this.paymentCenterSummary = const {},
    this.paymentCenterRecentPayments = const [],
    this.paymentCenterRecentTotal = 0,
    this.isPaymentCenterLoading = false,
    this.paymentCenterFilter = 'ALL',
    this.onPaymentCenterFilterChange,
    this.onPaymentCenterPayLoan,
    this.onPaymentCenterDepositSavings,
    this.onPaymentCenterViewReceipt,
    this.onPaymentCenterRefresh,
    this.onPaymentCenterLoadMore,
    this.onPaymentCenterInitiatePayment,
    // ── Savings Summary ──
    this.savingsSummary = const {},
    // ── Support Tickets ────────────────────────────────────────────────
    this.supportTickets = const [],
    this.isSupportLoading = false,
    this.onCreateTicket,
    this.onAddTicketMessage,
    this.onLoadTicketDetail,
    this.onRefreshTickets,
    this.onLoadMoreTickets,
    this.onFilterTicketStatus,
    // ── Guarantor Management ───────────────────────────────────────────
    this.guarantorCommitments = const [],
    this.guarantorInvites = const [],
    this.isGuarantorLoading = false,
    this.onGuarantorRespond,
    this.onGuarantorLink,
    this.onRefreshGuarantors,
    // ── Savings Withdrawal ─────────────────────────────────────────────
    this.savingsWithdrawals = const [],
    this.isWithdrawalLoading = false,
    this.onRequestWithdrawal,
    this.onRefreshWithdrawals,
    this.onLoadMoreWithdrawals,
    // ── Loan Restructure Request ───────────────────────────────────────
    this.restructureRequests = const [],
    this.isRestructureLoading = false,
    this.onRequestRestructure,
    this.onRefreshRestructures,
    // ── Terminal callbacks ──
    this.onLogout,
    this.onViewAllTransactions,
  });

  // ── Customer identity ──────────────────────────────────────────────
  final String customerName;
  final String customerId;
  final String customerPhone;
  final String kycStatus;

  // ── Dashboard summary ──────────────────────────────────────────────
  final double accountBalance;
  final double loanBalance;
  final double savingsBalance;
  final double loanLimit;
  final DateTime? loanDueDate;
  final double savingsGoal;

  // ── List data ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> recentTransactions;
  final List<Map<String, dynamic>> loans;
  final List<Map<String, dynamic>> savingsAccounts;
  final List<Map<String, dynamic>> loanProducts;
  final List<Map<String, dynamic>> scoreHistory;
  final List<Map<String, dynamic>> notifications;
  final int unreadNotificationCount;
  final Map<String, dynamic> customerData;
  final Map<String, dynamic>? existingKycStatus;

  // ── Dashboard ──────────────────────────────────────────────────────
  final Future<void> Function()? onRefreshDashboard;

  // ── Loan callbacks ─────────────────────────────────────────────────
  final Future<Map<String, dynamic>> Function(String loanId)?
      onLoadLoanDetail;
  final Function(String loanId)? onViewLoanStatement;
  final Future<List<Map<String, dynamic>>> Function(
      double principal, double rate, int months)? onCalculateSchedule;
  final Function(Map<String, dynamic> product)? onApplyLoan;

  // ── Savings callbacks ──────────────────────────────────────────────
  final Future<Map<String, dynamic>> Function(String accountId)?
      onLoadAccountDetail;
  final Function(Map<String, dynamic> account)? onWithdraw;

  // ── Credit score callbacks ─────────────────────────────────────────
  final Future<void> Function()? onRefreshCreditScore;
  final Future<void> Function()? onRequestScoreRefresh;

  // ── Notification callbacks ─────────────────────────────────────────
  final Future<List<Map<String, dynamic>>> Function(
      int offset, bool unreadOnly)? onLoadMoreNotifications;
  final Future<void> Function(String notificationId)? onMarkNotificationRead;
  final Future<void> Function()? onMarkAllNotificationsRead;
  final Function(Map<String, dynamic> notification)? onNotificationTap;

  // ── Profile callbacks ──────────────────────────────────────────────
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> updates)?
      onSaveProfile;
  final Future<bool> Function(String oldPassword, String newPassword)?
      onChangePassword;
  final Future<bool> Function(bool enable)? onToggle2FA;
  final Function(String type, bool enabled)? onToggleNotification;

  // ── KYC callbacks ──────────────────────────────────────────────────
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> kycData)?
      onSubmitKyc;
  final Future<Map<String, dynamic>> Function()? onCheckKycStatus;
  final Future<String> Function()? onCaptureSelfie;
  final Future<Map<String, dynamic>> Function()? onLivenessCheck;
  final VoidCallback? onKycComplete;

  // ── M-Pesa callbacks ───────────────────────────────────────────────
  final Future<Map<String, dynamic>> Function(
      Map<String, dynamic> paymentData)? onInitiatePayment;
  final Future<Map<String, dynamic>> Function(String transactionId)?
      onCheckPaymentStatus;
  final Function(Map<String, dynamic> result)? onPaymentComplete;

  // ── Instant Loan (Mkopo Chap Chap) ────────────────────────────────
  final Map<String, dynamic>? prequalification;
  final VoidCallback? onInstantLoanApplyNow;
  final VoidCallback? onRefreshPrequalification;

  // ── Payments & Collections ──────────────────────────────────────
  final Map<String, dynamic> upcomingPayments;
  final bool isUpcomingLoading;
  final Map<String, dynamic> paymentHistoryData;
  final bool isPaymentHistoryLoading;
  final VoidCallback? onRefreshUpcomingPayments;
  final Function(String loanId, {int limit, int offset})? onLoadPaymentHistory;
  final VoidCallback? onLoadMorePaymentHistory;

  // ── Payment Center ─────────────────────────────────────────────────
  final Map<String, dynamic> paymentCenterSummary;
  final List<Map<String, dynamic>> paymentCenterRecentPayments;
  final int paymentCenterRecentTotal;
  final bool isPaymentCenterLoading;
  final String paymentCenterFilter;
  final Function(String filter)? onPaymentCenterFilterChange;
  final Function(Map<String, dynamic> loan)? onPaymentCenterPayLoan;
  final Function(Map<String, dynamic> account)? onPaymentCenterDepositSavings;
  final Function(String transactionId)? onPaymentCenterViewReceipt;
  final VoidCallback? onPaymentCenterRefresh;
  final VoidCallback? onPaymentCenterLoadMore;
  final VoidCallback? onPaymentCenterInitiatePayment;

  // ── Savings Summary ────────────────────────────────────────────────
  final Map<String, dynamic> savingsSummary;

  // ── Support Tickets ─────────────────────────────────────────────────
  final List<Map<String, dynamic>> supportTickets;
  final bool isSupportLoading;
  final Function(String category, String subject, String message,
      String? loanId, String? txnId)? onCreateTicket;
  final Function(String ticketId, String message)? onAddTicketMessage;
  final Future<Map<String, dynamic>> Function(String ticketId)?
      onLoadTicketDetail;
  final VoidCallback? onRefreshTickets;
  final VoidCallback? onLoadMoreTickets;
  final Function(String? status)? onFilterTicketStatus;

  // ── Guarantor Management ────────────────────────────────────────────
  final List<Map<String, dynamic>> guarantorCommitments;
  final List<Map<String, dynamic>> guarantorInvites;
  final bool isGuarantorLoading;
  final Function(String guarantorId, String response)? onGuarantorRespond;
  final Function(String guarantorId)? onGuarantorLink;
  final VoidCallback? onRefreshGuarantors;

  // ── Savings Withdrawal ──────────────────────────────────────────────
  final List<Map<String, dynamic>> savingsWithdrawals;
  final bool isWithdrawalLoading;
  final Function(String accountId, double amount, String channel,
      String? phone)? onRequestWithdrawal;
  final VoidCallback? onRefreshWithdrawals;
  final VoidCallback? onLoadMoreWithdrawals;

  // ── Loan Restructure Request ────────────────────────────────────────
  final List<Map<String, dynamic>> restructureRequests;
  final bool isRestructureLoading;
  final Function(String loanId, String type, String reason, int? term)?
      onRequestRestructure;
  final VoidCallback? onRefreshRestructures;

  // ── Terminal callbacks ─────────────────────────────────────────────
  final VoidCallback? onLogout;
  final VoidCallback? onViewAllTransactions;

  @override
  State<CustomerAppHomeScreen> createState() => _CustomerAppHomeScreenState();
}

// ═══════════════════════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════════════════════

class _CustomerAppHomeScreenState extends State<CustomerAppHomeScreen>
    with SingleTickerProviderStateMixin {
  // ── Constants ──────────────────────────────────────────────────────
  static const _primaryColor = Color(0xFF1565C0);
  static const _darkBlue = Color(0xFF0D47A1);
  static const _successColor = Color(0xFF2E7D32);
  static const _warningColor = Color(0xFFEF6C00);

  // ── State ──────────────────────────────────────────────────────────
  int _currentTab = 0;
  _OverlayScreen? _overlayScreen;
  bool _balanceVisible = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final NumberFormat _currencyFmt =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  // ── Computed helpers ───────────────────────────────────────────────

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _firstName {
    final name = widget.customerName;
    final idx = name.indexOf(' ');
    return idx > 0 ? name.substring(0, idx) : name;
  }

  String get _initials {
    final parts = widget.customerName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get _kycVerified => widget.kycStatus.toUpperCase() == 'VERIFIED';

  Map<String, dynamic>? get _firstActiveLoan {
    for (final loan in widget.loans) {
      final status = (loan['status'] as String? ?? '').toUpperCase();
      if (status == 'ACTIVE') return loan;
    }
    return null;
  }

  Map<String, dynamic>? get _latestCreditScore {
    if (widget.scoreHistory.isEmpty) return null;
    final sorted = List<Map<String, dynamic>>.from(widget.scoreHistory);
    sorted.sort((a, b) {
      final dA =
          DateTime.tryParse(a['scored_at']?.toString() ?? '') ?? DateTime(2000);
      final dB =
          DateTime.tryParse(b['scored_at']?.toString() ?? '') ?? DateTime(2000);
      return dB.compareTo(dA);
    });
    return sorted.first;
  }

  String _maskedBalance(double amount) =>
      _balanceVisible ? _currencyFmt.format(amount) : 'KES ****.**';

  double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ─────────────────────────────────────────────

  void _openOverlay(_OverlayScreen screen) {
    setState(() => _overlayScreen = screen);
  }

  void _closeOverlay() {
    setState(() => _overlayScreen = null);
  }

  void _switchTab(int index) {
    setState(() {
      _currentTab = index;
      _overlayScreen = null;
    });
  }

  // ═════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _overlayScreen == null && _currentTab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_overlayScreen != null) {
          _closeOverlay();
        } else if (_currentTab != 0) {
          _switchTab(0);
        }
      },
      child: _overlayScreen != null
          ? _buildOverlayScreen()
          : Scaffold(
              body: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: IndexedStack(
                    index: _currentTab,
                    children: [
                      _buildHomeTab(),
                      _buildLoansTab(),
                      _buildPayTab(),
                      _buildSavingsTab(),
                      _buildMoreTab(),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: _buildBottomNav(),
            ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // OVERLAY SCREENS
  // ═════════════════════════════════════════════════════════════════════

  Widget _buildOverlayScreen() {
    late final String title;
    late final Widget child;

    switch (_overlayScreen!) {
      case _OverlayScreen.loanProducts:
        title = 'Loan Products';
        child = LoanProductsCatalog(
          loanProducts: widget.loanProducts,
          onCalculateSchedule: widget.onCalculateSchedule,
          onApplyNow: (product) {
            _closeOverlay();
            widget.onApplyLoan?.call(product);
          },
        );
      case _OverlayScreen.notifications:
        title = 'Notifications';
        child = NotificationsCenterWidget(
          notifications: widget.notifications,
          unreadCount: widget.unreadNotificationCount,
          onLoadMore: widget.onLoadMoreNotifications,
          onMarkRead: widget.onMarkNotificationRead,
          onMarkAllRead: widget.onMarkAllNotificationsRead,
          onNotificationTap: widget.onNotificationTap,
        );
      case _OverlayScreen.profile:
        title = 'My Profile';
        child = CustomerProfileWidget(
          customerData: widget.customerData,
          onSaveProfile: widget.onSaveProfile,
          onChangePassword: widget.onChangePassword,
          onToggle2FA: widget.onToggle2FA,
          onToggleNotification: widget.onToggleNotification,
          onLogout: () {
            _closeOverlay();
            widget.onLogout?.call();
          },
        );
      case _OverlayScreen.creditScore:
        title = 'Credit Score';
        child = CreditScoreWidget(
          scoreHistory: widget.scoreHistory,
          onRefresh: widget.onRefreshCreditScore,
          onRequestScoreRefresh: widget.onRequestScoreRefresh,
        );
      case _OverlayScreen.kyc:
        title = 'KYC Verification';
        child = KycOnboardingWidget(
          existingKycStatus: widget.existingKycStatus,
          onSubmitKyc: widget.onSubmitKyc,
          onCheckStatus: widget.onCheckKycStatus,
          onCaptureSelfie: widget.onCaptureSelfie,
          onLivenessCheck: widget.onLivenessCheck,
          onComplete: () {
            _closeOverlay();
            widget.onKycComplete?.call();
          },
        );
      case _OverlayScreen.mpesaPayment:
        title = 'M-Pesa Payment';
        child = MpesaPaymentWidget(
          loans: widget.loans,
          savingsAccounts: widget.savingsAccounts,
          defaultPhoneNumber: widget.customerPhone,
          onInitiatePayment: widget.onInitiatePayment,
          onCheckPaymentStatus: widget.onCheckPaymentStatus,
          onSuccess: (result) {
            _closeOverlay();
            widget.onPaymentComplete?.call(result);
          },
          onCancel: _closeOverlay,
        );
      case _OverlayScreen.instantLoan:
        title = 'Instant Loan';
        child = const SizedBox.shrink();
      case _OverlayScreen.paymentHistory:
        title = 'Payment History';
        child = PaymentHistoryWidget(
          historyData: widget.paymentHistoryData,
          isLoading: widget.isPaymentHistoryLoading,
          onLoadMore: widget.onLoadMorePaymentHistory,
          onBack: _closeOverlay,
        );
      case _OverlayScreen.supportTickets:
        title = 'Support & Disputes';
        child = ImfslSupportTickets(
          tickets: widget.supportTickets,
          isLoading: widget.isSupportLoading,
          onCreateTicket: widget.onCreateTicket,
          onAddMessage: widget.onAddTicketMessage,
          onLoadTicketDetail: widget.onLoadTicketDetail,
          onRefresh: widget.onRefreshTickets,
          onLoadMore: widget.onLoadMoreTickets,
          onFilterStatus: widget.onFilterTicketStatus,
          loanOptions: widget.loans,
        );
      case _OverlayScreen.guarantorManagement:
        title = 'My Guarantors';
        child = ImfslGuarantorManagement(
          commitments: widget.guarantorCommitments,
          invites: widget.guarantorInvites,
          isLoading: widget.isGuarantorLoading,
          onRespond: widget.onGuarantorRespond,
          onLink: widget.onGuarantorLink,
          onRefresh: widget.onRefreshGuarantors,
        );
      case _OverlayScreen.savingsWithdrawal:
        title = 'Withdraw Savings';
        child = ImfslSavingsWithdrawal(
          savingsAccounts: widget.savingsAccounts,
          withdrawals: widget.savingsWithdrawals,
          isLoading: widget.isWithdrawalLoading,
          onRequestWithdrawal: widget.onRequestWithdrawal,
          onRefresh: widget.onRefreshWithdrawals,
          onLoadMore: widget.onLoadMoreWithdrawals,
          profilePhone: widget.customerPhone,
        );
      case _OverlayScreen.restructureRequest:
        title = 'Loan Restructure';
        child = ImfslLoanRestructureRequest(
          eligibleLoans: widget.loans
              .where((l) {
                final s = (l['status'] as String? ?? '').toUpperCase();
                return s == 'ACTIVE' || s == 'OVERDUE';
              })
              .toList(),
          myRequests: widget.restructureRequests,
          isLoading: widget.isRestructureLoading,
          onRequestRestructure: widget.onRequestRestructure,
          onRefresh: widget.onRefreshRestructures,
        );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _closeOverlay,
        ),
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: child,
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // TAB 0 — HOME DASHBOARD
  // ═════════════════════════════════════════════════════════════════════

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async => widget.onRefreshDashboard?.call(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingHeader(),
            const SizedBox(height: 16),
            if (!_kycVerified && widget.kycStatus.isNotEmpty) ...[
              _buildKycBanner(),
              const SizedBox(height: 16),
            ],
            _buildBalanceCard(),
            const SizedBox(height: 16),
            PaymentReminderCard(
              upcomingData: widget.upcomingPayments,
              isLoading: widget.isUpcomingLoading,
              onPayNow: () => _openOverlay(_OverlayScreen.mpesaPayment),
              onViewAll: () {
                // Load history for the first loan in upcoming installments
                final installments = widget.upcomingPayments['installments'];
                if (installments is List && installments.isNotEmpty) {
                  final loanId = installments[0]['loan_id']?.toString() ?? '';
                  if (loanId.isNotEmpty) {
                    widget.onLoadPaymentHistory?.call(loanId, limit: 20, offset: 0);
                  }
                }
                _openOverlay(_OverlayScreen.paymentHistory);
              },
              onRefresh: widget.onRefreshUpcomingPayments,
            ),
            const SizedBox(height: 16),
            if (widget.prequalification != null) ...[
              LoanPrequalificationCard(
                qualified: widget.prequalification!['qualified'] == true,
                maxAmount: _toDouble(widget.prequalification!['max_amount']),
                creditScore: _toDouble(widget.prequalification!['credit_score']),
                kycApproved: widget.prequalification!['kyc_approved'] == true,
                deviceTrusted: widget.prequalification!['device_trusted'] == true,
                noArrears: widget.prequalification!['no_arrears'] == true,
                onApplyNow: () => widget.onInstantLoanApplyNow?.call(),
                onRefresh: () => widget.onRefreshPrequalification?.call(),
              ),
              const SizedBox(height: 16),
            ],
            _buildQuickActionsGrid(),
            const SizedBox(height: 16),
            _buildNeedHelpCard(),
            const SizedBox(height: 20),
            if (_firstActiveLoan != null) ...[
              _buildActiveLoanSummary(),
              const SizedBox(height: 16),
            ],
            if (_latestCreditScore != null) ...[
              _buildCreditScoreMini(),
              const SizedBox(height: 16),
            ],
            _buildRecentTransactionsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Greeting header ────────────────────────────────────────────────

  Widget _buildGreetingHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: _primaryColor,
          child: Text(
            _initials,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              Text(_firstName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        _buildNotificationBell(),
      ],
    );
  }

  Widget _buildNotificationBell() {
    return GestureDetector(
      onTap: () => _openOverlay(_OverlayScreen.notifications),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.notifications_outlined, size: 26),
            ),
            if (widget.unreadNotificationCount > 0)
              Positioned(
                right: 2,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 14),
                  child: Text(
                    widget.unreadNotificationCount > 99
                        ? '99+'
                        : '${widget.unreadNotificationCount}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── KYC banner ─────────────────────────────────────────────────────

  Widget _buildKycBanner() {
    final status = widget.kycStatus.toUpperCase();
    final isRejected = status == 'REJECTED';
    final color = isRejected ? Colors.red : Colors.amber.shade800;
    final bgColor = isRejected ? Colors.red.shade50 : Colors.amber.shade50;
    final message = isRejected
        ? 'Your KYC was rejected. Please re-submit.'
        : status == 'RECEIVED' || status == 'PROCESSING'
            ? 'Your KYC is being reviewed.'
            : 'Complete KYC to unlock all features.';

    return GestureDetector(
      onTap: () => _openOverlay(_OverlayScreen.kyc),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              isRejected ? Icons.error_outline : Icons.info_outline,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Balance card ───────────────────────────────────────────────────

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryColor, _darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              GestureDetector(
                onTap: () =>
                    setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _maskedBalance(widget.accountBalance),
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBalancePill('Savings', widget.savingsBalance),
              const SizedBox(width: 12),
              _buildBalancePill('Loan Due', widget.loanBalance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalancePill(String label, double amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 11)),
            const SizedBox(height: 2),
            Text(_maskedBalance(amount),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Quick actions grid ─────────────────────────────────────────────

  Widget _buildQuickActionsGrid() {
    final actions = [
      if (widget.prequalification?['qualified'] == true)
        _QuickAction(Icons.bolt, 'Get Money', const Color(0xFFE65100), () {
          widget.onInstantLoanApplyNow?.call();
        }),
      _QuickAction(Icons.payment, 'Pay Loan', const Color(0xFF2E7D32), () {
        _openOverlay(_OverlayScreen.mpesaPayment);
      }),
      _QuickAction(Icons.savings, 'Deposit', _primaryColor, () {
        _openOverlay(_OverlayScreen.mpesaPayment);
      }),
      _QuickAction(
          Icons.account_balance_wallet, 'Withdraw', _warningColor, () {
        if (widget.savingsAccounts.isNotEmpty) {
          widget.onWithdraw?.call(widget.savingsAccounts.first);
        }
      }),
      _QuickAction(Icons.description_outlined, 'Apply Loan',
          const Color(0xFF6A1B9A), () {
        _openOverlay(_OverlayScreen.loanProducts);
      }),
      _QuickAction(Icons.speed, 'Credit Score', const Color(0xFF00695C), () {
        _openOverlay(_OverlayScreen.creditScore);
      }),
      _QuickAction(
          Icons.verified_user_outlined, 'KYC', const Color(0xFF37474F), () {
        _openOverlay(_OverlayScreen.kyc);
      }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.sublist(0, 3).map(_buildActionButton).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.sublist(3, 6).map(_buildActionButton).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton(_QuickAction action) {
    return Expanded(
      child: GestureDetector(
        onTap: action.onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: action.color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(action.label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Need Help card ───────────────────────────────────────────────

  Widget _buildNeedHelpCard() {
    return GestureDetector(
      onTap: () => _openOverlay(_OverlayScreen.supportTickets),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF5C6BC0).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF5C6BC0).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5C6BC0).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.support_agent,
                  color: Color(0xFF5C6BC0), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Need Help?',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('Create a support ticket',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Active loan summary ────────────────────────────────────────────

  Widget _buildActiveLoanSummary() {
    final loan = _firstActiveLoan!;
    final outstanding = _toDouble(loan['outstanding_balance']);
    final principal = _toDouble(loan['principal_amount']);
    final progress =
        principal > 0 ? ((principal - outstanding) / principal).clamp(0.0, 1.0) : 0.0;
    final dueDateStr = loan['next_due_date']?.toString() ?? '';
    final dueDate = DateTime.tryParse(dueDateStr);
    final daysLeft =
        dueDate != null ? dueDate.difference(DateTime.now()).inDays : 0;
    final isOverdue = daysLeft < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Loan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () => _switchTab(1),
                child: const Text('View All',
                    style: TextStyle(
                        fontSize: 12,
                        color: _primaryColor,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Outstanding: ${_currencyFmt.format(outstanding)}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (dueDate != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOverdue
                        ? '${daysLeft.abs()}d overdue'
                        : '${daysLeft}d left',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            isOverdue ? Colors.red : Colors.orange.shade800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                  isOverdue ? Colors.red : _successColor),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(progress * 100).toStringAsFixed(0)}% repaid',
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ── Credit score mini card ─────────────────────────────────────────

  Widget _buildCreditScoreMini() {
    final data = _latestCreditScore!;
    final score = _toInt(data['credit_score']);
    final category = (data['risk_category'] as String? ?? 'Unknown').toUpperCase();
    final maxAmount = _toDouble(data['max_recommended_amount']);

    Color categoryColor;
    switch (category) {
      case 'LOW':
        categoryColor = _successColor;
      case 'MEDIUM':
        categoryColor = _warningColor;
      case 'HIGH':
      case 'VERY HIGH':
        categoryColor = Colors.red;
      default:
        categoryColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _openOverlay(_OverlayScreen.creditScore),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CustomPaint(
                painter: _CreditScoreMiniPainter(
                  score: score,
                  minScore: 300,
                  maxScore: 850,
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Credit Score',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${category[0]}${category.substring(1).toLowerCase()} Risk',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: categoryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Max loan: ${_currencyFmt.format(maxAmount)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Recent transactions ────────────────────────────────────────────

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: widget.onViewAllTransactions,
              child: const Text('View All',
                  style: TextStyle(
                      fontSize: 12,
                      color: _primaryColor,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.recentTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text('No recent transactions',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          )
        else
          ...widget.recentTransactions
              .take(5)
              .map((tx) => _buildTransactionTile(tx)),
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final type = (tx['type'] as String? ?? 'UNKNOWN').toUpperCase();
    final amount = _toDouble(tx['amount']);
    final description = tx['description'] as String? ?? type;
    final dateStr = tx['date'] as String? ?? tx['created_at'] as String? ?? '';
    final isCredit =
        type == 'DEPOSIT' || type == 'LOAN_DISBURSEMENT' || type == 'CREDIT';

    IconData icon;
    Color iconColor;
    switch (type) {
      case 'DEPOSIT':
        icon = Icons.arrow_downward;
        iconColor = _successColor;
      case 'WITHDRAWAL':
        icon = Icons.arrow_upward;
        iconColor = _warningColor;
      case 'LOAN_REPAYMENT':
        icon = Icons.payment;
        iconColor = _primaryColor;
      case 'LOAN_DISBURSEMENT':
        icon = Icons.account_balance;
        iconColor = const Color(0xFF6A1B9A);
      default:
        icon = Icons.swap_horiz;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (dateStr.isNotEmpty)
                  Text(_formatTransactionDate(dateStr),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'} ${_currencyFmt.format(amount)}',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCredit ? _successColor : Colors.red.shade700),
          ),
        ],
      ),
    );
  }

  String _formatTransactionDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  // ═════════════════════════════════════════════════════════════════════
  // TAB 1 — LOANS
  // ═════════════════════════════════════════════════════════════════════

  Widget _buildLoansTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Loans',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _openOverlay(_OverlayScreen.loanProducts),
                icon: const Icon(Icons.storefront, size: 18),
                label: const Text('Browse Products'),
                style: TextButton.styleFrom(foregroundColor: _primaryColor),
              ),
            ],
          ),
        ),
        Expanded(
          child: MyLoansWidget(
            loans: widget.loans,
            onLoadLoanDetail: widget.onLoadLoanDetail,
            onPayNow: (loan) => _openOverlay(_OverlayScreen.mpesaPayment),
            onViewStatement: widget.onViewLoanStatement,
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // TAB 2 — PAY (Payment Center)
  // ═════════════════════════════════════════════════════════════════════

  Widget _buildPayTab() {
    return ImfslPaymentCenter(
      summary: widget.paymentCenterSummary,
      recentPayments: widget.paymentCenterRecentPayments,
      recentPaymentsTotalCount: widget.paymentCenterRecentTotal,
      isLoading: widget.isPaymentCenterLoading,
      currentFilter: widget.paymentCenterFilter,
      onFilterChange: widget.onPaymentCenterFilterChange,
      onPayLoan: widget.onPaymentCenterPayLoan,
      onDepositSavings: widget.onPaymentCenterDepositSavings,
      onViewReceipt: widget.onPaymentCenterViewReceipt,
      onRefresh: widget.onPaymentCenterRefresh,
      onLoadMore: widget.onPaymentCenterLoadMore,
      onInitiatePayment: widget.onPaymentCenterInitiatePayment ??
          () => _openOverlay(_OverlayScreen.mpesaPayment),
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // TAB 3 — SAVINGS
  // ═════════════════════════════════════════════════════════════════════

  Widget _buildSavingsTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Savings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: SavingsAccountWidget(
            savingsAccounts: widget.savingsAccounts,
            onLoadAccountDetail: widget.onLoadAccountDetail,
            onDepositMpesa: (account) =>
                _openOverlay(_OverlayScreen.mpesaPayment),
            onWithdraw: widget.onWithdraw,
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // TAB 4 — MORE MENU
  // ═════════════════════════════════════════════════════════════════════

  Widget _buildMoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _buildMoreProfileCard(),
          const SizedBox(height: 20),
          _buildMoreMenuItem(
            icon: Icons.speed,
            label: 'Credit Score',
            color: const Color(0xFF00695C),
            onTap: () => _openOverlay(_OverlayScreen.creditScore),
          ),
          _buildMoreMenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            color: _primaryColor,
            badge: widget.unreadNotificationCount,
            onTap: () => _openOverlay(_OverlayScreen.notifications),
          ),
          _buildMoreMenuItem(
            icon: Icons.verified_user_outlined,
            label: 'KYC Verification',
            color: const Color(0xFF37474F),
            trailing: _kycVerified
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Verified',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _successColor)),
                  )
                : null,
            onTap: () => _openOverlay(_OverlayScreen.kyc),
          ),
          _buildMoreMenuItem(
            icon: Icons.phone_android,
            label: 'M-Pesa Payment',
            color: const Color(0xFF4CAF50),
            onTap: () => _openOverlay(_OverlayScreen.mpesaPayment),
          ),
          _buildMoreMenuItem(
            icon: Icons.receipt_long,
            label: 'Transaction History',
            color: _warningColor,
            onTap: widget.onViewAllTransactions,
          ),
          const SizedBox(height: 8),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 8, bottom: 4),
            child: Text('Self-Service',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
          ),
          _buildMoreMenuItem(
            icon: Icons.support_agent,
            label: 'Support & Disputes',
            color: const Color(0xFF5C6BC0),
            onTap: () => _openOverlay(_OverlayScreen.supportTickets),
          ),
          _buildMoreMenuItem(
            icon: Icons.handshake_outlined,
            label: 'My Guarantors',
            color: const Color(0xFF00838F),
            onTap: () => _openOverlay(_OverlayScreen.guarantorManagement),
          ),
          _buildMoreMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Withdraw Savings',
            color: const Color(0xFFAD1457),
            onTap: () => _openOverlay(_OverlayScreen.savingsWithdrawal),
          ),
          _buildMoreMenuItem(
            icon: Icons.tune,
            label: 'Loan Restructure',
            color: const Color(0xFF6A1B9A),
            onTap: () => _openOverlay(_OverlayScreen.restructureRequest),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMoreProfileCard() {
    final name = widget.customerName;
    final phone = widget.customerPhone;
    final kycLabel = _kycVerified ? 'KYC Verified' : 'KYC Pending';
    final kycColor = _kycVerified ? _successColor : _warningColor;

    return GestureDetector(
      onTap: () => _openOverlay(_OverlayScreen.profile),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryColor, _darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                _initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(phone.isNotEmpty ? phone : 'No phone',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: kycColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(kycLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    int badge = 0,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: badge > 0
                  ? Stack(
                      children: [
                        Center(child: Icon(icon, color: color, size: 22)),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              badge > 99 ? '99+' : '$badge',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            if (trailing != null) trailing,
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // BOTTOM NAVIGATION
  // ═════════════════════════════════════════════════════════════════════

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: _switchTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        backgroundColor: Colors.white,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            activeIcon: Icon(Icons.account_balance),
            label: 'Loans',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Pay',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            activeIcon: Icon(Icons.savings),
            label: 'Savings',
          ),
          BottomNavigationBarItem(
            icon: widget.unreadNotificationCount > 0
                ? Badge(
                    label: Text(
                      widget.unreadNotificationCount > 9
                          ? '9+'
                          : '${widget.unreadNotificationCount}',
                      style: const TextStyle(fontSize: 9),
                    ),
                    child: const Icon(Icons.grid_view_outlined),
                  )
                : const Icon(Icons.grid_view_outlined),
            activeIcon: const Icon(Icons.grid_view),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// HELPER CLASSES
// ═════════════════════════════════════════════════════════════════════════

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _QuickAction(this.icon, this.label, this.color, this.onTap);
}

// ═════════════════════════════════════════════════════════════════════════
// CREDIT SCORE MINI GAUGE PAINTER
// ═════════════════════════════════════════════════════════════════════════

class _CreditScoreMiniPainter extends CustomPainter {
  final int score;
  final int minScore;
  final int maxScore;

  _CreditScoreMiniPainter({
    required this.score,
    this.minScore = 300,
    this.maxScore = 850,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    final radius = size.width / 2 - 5;
    const startAngle = pi * 0.8;
    const sweepAngle = pi * 1.4;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Score arc
    final fraction =
        ((score - minScore) / (maxScore - minScore)).clamp(0.0, 1.0);
    Color arcColor;
    if (fraction < 0.35) {
      arcColor = Colors.red;
    } else if (fraction < 0.65) {
      arcColor = Colors.orange;
    } else {
      arcColor = const Color(0xFF2E7D32);
    }

    final fgPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * fraction,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CreditScoreMiniPainter old) =>
      old.score != score;
}
