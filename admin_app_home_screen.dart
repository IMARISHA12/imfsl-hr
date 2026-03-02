// IMFSL Admin Portal Home Screen
// ================================
// Navigation shell that integrates admin widgets with RBAC-based
// tab visibility. Roles: ADMIN, MANAGER, OFFICER, AUDITOR, TELLER.
// 14 tabs (ADMIN/MANAGER), 11 (OFFICER), 4 (AUDITOR), 1 (TELLER).
//
// Usage:
//   AdminAppHomeScreen(
//     currentUserRole: 'ADMIN',
//     staffName: 'Jane Doe',
//     // ...data params + callbacks
//   )
//
// Dependencies (add to pubspec.yaml):
//   supabase_flutter: ^2.0.0
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Widget imports (all admin widgets) ──────────────────────────────
import 'imfsl_admin_dashboard.dart';
import 'imfsl_staff_management.dart';
import 'imfsl_staff_onboarding_form.dart';
import 'imfsl_kyc_review_queue.dart';
import 'imfsl_loan_approval_queue.dart';
import 'imfsl_audit_log_viewer.dart';
import 'imfsl_collections_dashboard.dart';
import 'imfsl_collections_queue.dart';
import 'imfsl_financial_reports.dart';
import 'imfsl_savings_management.dart';
import 'imfsl_sms_center.dart';
import 'imfsl_loan_restructuring.dart';
import 'imfsl_branch_performance.dart';
import 'imfsl_mpesa_reconciliation.dart';
import 'imfsl_approval_workflow.dart';
import 'imfsl_executive_console.dart';
import 'imfsl_loan_operations_console.dart';
import 'imfsl_payment_mpesa_console.dart';
import 'imfsl_risk_compliance_console.dart';
import 'imfsl_customer_360_console.dart';

/// Overlay screens that sit on top of the tab content.
enum _OverlayScreen { none, staffOnboarding, staffProfile }

/// Sub-console views within the Ops Console tab.
enum _OpsConsoleView { executive, loanOps, payments, risk, customer360 }

class AdminAppHomeScreen extends StatefulWidget {
  const AdminAppHomeScreen({
    super.key,
    // ── Identity ──
    this.currentUserRole = 'OFFICER',
    this.staffName = '',
    this.staffEmail = '',
    // ── Dashboard ──
    this.dashboardData = const {},
    this.isDashboardLoading = false,
    this.onRefreshDashboard,
    // ── Staff ──
    this.staffList = const [],
    this.staffTotalCount = 0,
    this.isStaffLoading = false,
    this.branches = const [],
    this.onSearchStaff,
    this.onFilterStaffBranch,
    this.onFilterStaffRole,
    this.onLoadMoreStaff,
    this.onStaffTap,
    this.onUpdateStaffRole,
    this.onToggleStaffActive,
    // ── Staff Onboarding ──
    this.approvedKycSubmissions = const [],
    this.isOnboardingLoading = false,
    this.onSubmitOnboarding,
    // ── KYC Review ──
    this.kycSubmissions = const [],
    this.kycTotalCount = 0,
    this.isKycLoading = false,
    this.kycCurrentFilter = 'PENDING',
    this.onKycFilterChange,
    this.onLoadMoreKyc,
    this.onApproveKyc,
    this.onRejectKyc,
    this.onBulkApproveKyc,
    this.onBulkRejectKyc,
    this.onRefreshKyc,
    // ── Loan Approval ──
    this.loanApplications = const [],
    this.loanTotalCount = 0,
    this.loanPendingValue = 0.0,
    this.isLoanLoading = false,
    this.loanCurrentFilter = 'SUBMITTED',
    this.onLoanFilterChange,
    this.onLoadMoreLoans,
    this.onApproveLoan,
    this.onRejectLoan,
    this.onRefreshLoans,
    // ── Audit Log ──
    this.auditEntries = const [],
    this.auditTotalCount = 0,
    this.isAuditLoading = false,
    this.auditEventTypes = const [
      'STAFF_ROLE_CHANGED',
      'STAFF_ACTIVATED',
      'STAFF_DEACTIVATED',
      'STAFF_ONBOARDED',
      'KYC_APPROVED',
      'KYC_REJECTED',
      'LOAN_APPROVED',
      'LOAN_REJECTED',
    ],
    this.onSearchAudit,
    this.onLoadMoreAudit,
    this.onRefreshAudit,
    // ── Collections ──
    this.collectionsDashboard = const {},
    this.collectionsQueue = const [],
    this.collectionsQueueTotal = 0,
    this.isCollectionsLoading = false,
    this.onRefreshCollections,
    this.onLoadCollectionsQueue,
    this.onFilterCollectionsPar,
    this.onFilterCollectionsStatus,
    this.onLoadMoreCollections,
    this.onLogCollectionAction,
    this.onWaivePenalty,
    // ── Financial Reports ──
    this.reportData = const {},
    this.isReportLoading = false,
    this.currentReportType = 'loan_portfolio_report',
    this.onLoadReport,
    this.onRefreshReport,
    // ── Savings Management ──
    this.savingsData = const {},
    this.isSavingsLoading = false,
    this.onRefreshSavings,
    // ── SMS Center ──
    this.smsData = const {},
    this.smsTemplates = const [],
    this.isSmsLoading = false,
    this.onRefreshSms,
    this.onSendBulkSms,
    // ── Restructuring / Write-Off ──
    this.restructureQueue = const {},
    this.isRestructureLoading = false,
    this.onRefreshRestructure,
    this.onRequestRestructure,
    this.onApproveRestructure,
    this.onRequestWriteoff,
    this.onApproveWriteoff,
    this.onRecordRecovery,
    // ── Branch Performance ──
    this.branchDashboard = const {},
    this.branchDetail = const {},
    this.branchTrend = const {},
    this.selectedBranch,
    this.isBranchLoading = false,
    this.onSelectBranch,
    this.onRefreshBranch,
    this.onLoadBranchDetail,
    this.onLoadBranchTrend,
    // ── M-Pesa Reconciliation ──
    this.onGetMpesaDashboard,
    this.onMpesaManualReconcile,
    this.onMpesaSearch,
    // ── Approval Workflow ──
    this.pendingApprovals = const [],
    this.pendingApprovalsTotal = 0,
    this.approvalRules = const [],
    this.isApprovalsLoading = false,
    this.approvalsFilter = 'ALL',
    this.onApprovalsFilterChange,
    this.onProcessApproval,
    this.onViewApprovalChain,
    this.onRefreshApprovals,
    this.onLoadMoreApprovals,
    this.onManageApprovalRules,
    // ── Ops Console ──
    this.executiveKpis = const {},
    this.topPortfolio = const [],
    this.recentMpesa = const [],
    this.isOpsConsoleLoading = false,
    this.onRefreshOpsConsole,
    // Ops Console — Loan Operations
    this.opsPipelineData = const [],
    this.opsPortfolioData = const [],
    this.opsRepaymentData = const [],
    this.isOpsPipelineLoading = false,
    this.isOpsPortfolioLoading = false,
    this.isOpsRepaymentLoading = false,
    this.onRefreshOpsPipeline,
    this.onRefreshOpsPortfolio,
    this.onRefreshOpsRepayment,
    this.onLoadMoreOpsPipeline,
    this.onLoadMoreOpsPortfolio,
    this.onLoadMoreOpsRepayment,
    this.onOpsPipelineStatusFilter,
    this.onOpsPortfolioStatusFilter,
    this.onOpsPortfolioParFilter,
    this.onOpsRepaymentStatusFilter,
    this.onOpsRepaymentDateRange,
    // Ops Console — Payments & M-Pesa
    this.opsMpesaData = const [],
    this.opsDisbursementData = const [],
    this.opsMpesaKpis = const {},
    this.isOpsMpesaLoading = false,
    this.isOpsDisbursementLoading = false,
    this.onRefreshOpsMpesa,
    this.onRefreshOpsDisbursements,
    this.onLoadMoreOpsMpesa,
    this.onLoadMoreOpsDisbursements,
    this.onOpsMpesaStatusFilter,
    this.onOpsMpesaPurposeFilter,
    this.onOpsMpesaDateRange,
    this.onOpsDisbursementStatusFilter,
    // Ops Console — Risk & Compliance
    this.opsCollectionsData = const [],
    this.opsRestructureData = const [],
    this.opsInstantLoanData = const [],
    this.opsApprovalsData = const [],
    this.isOpsCollectionsLoading = false,
    this.isOpsRestructureLoading = false,
    this.isOpsInstantLoanLoading = false,
    this.isOpsApprovalsLoading = false,
    this.onRefreshOpsCollections,
    this.onRefreshOpsRestructure,
    this.onRefreshOpsInstantLoans,
    this.onRefreshOpsApprovals,
    this.onLoadMoreOpsCollections,
    this.onLoadMoreOpsRestructure,
    this.onLoadMoreOpsInstantLoans,
    this.onLoadMoreOpsApprovals,
    this.onOpsCollectionsParFilter,
    this.onOpsCollectionsPriorityFilter,
    this.onOpsRestructureTypeFilter,
    this.onOpsRestructureStatusFilter,
    this.onOpsInstantLoanDecisionFilter,
    this.onOpsApprovalsStatusFilter,
    this.onOpsApprovalsEntityTypeFilter,
    // Ops Console — Customer 360
    this.opsDirectoryData = const [],
    this.opsKycData = const [],
    this.opsSavingsData = const [],
    this.opsGuarantorData = const [],
    this.isOpsDirectoryLoading = false,
    this.isOpsKycLoading = false,
    this.isOpsSavingsLoading = false,
    this.isOpsGuarantorLoading = false,
    this.onRefreshOpsDirectory,
    this.onRefreshOpsKyc,
    this.onRefreshOpsSavings,
    this.onRefreshOpsGuarantors,
    this.onLoadMoreOpsDirectory,
    this.onLoadMoreOpsKyc,
    this.onLoadMoreOpsSavings,
    this.onLoadMoreOpsGuarantors,
    this.onOpsDirectorySearch,
    this.onOpsKycStatusFilter,
    this.onOpsSavingsStatusFilter,
    this.onOpsGuarantorStatusFilter,
    // ── Global ──
    this.onLogout,
  });

  // ── Identity ──
  final String currentUserRole;
  final String staffName;
  final String staffEmail;

  // ── Dashboard ──
  final Map<String, dynamic> dashboardData;
  final bool isDashboardLoading;
  final VoidCallback? onRefreshDashboard;

  // ── Staff Management ──
  final List<Map<String, dynamic>> staffList;
  final int staffTotalCount;
  final bool isStaffLoading;
  final List<String> branches;
  final Function(String)? onSearchStaff;
  final Function(String?)? onFilterStaffBranch;
  final Function(String?)? onFilterStaffRole;
  final VoidCallback? onLoadMoreStaff;
  final Function(Map<String, dynamic>)? onStaffTap;
  final Function(String staffId, String newRole)? onUpdateStaffRole;
  final Function(String staffId, bool isActive, String reason)?
      onToggleStaffActive;

  // ── Staff Onboarding ──
  final List<Map<String, dynamic>> approvedKycSubmissions;
  final bool isOnboardingLoading;
  final Function(Map<String, dynamic>)? onSubmitOnboarding;

  // ── KYC Review ──
  final List<Map<String, dynamic>> kycSubmissions;
  final int kycTotalCount;
  final bool isKycLoading;
  final String kycCurrentFilter;
  final Function(String)? onKycFilterChange;
  final VoidCallback? onLoadMoreKyc;
  final Function(String kycId)? onApproveKyc;
  final Function(String kycId, String reason)? onRejectKyc;
  final Function(List<String> kycIds)? onBulkApproveKyc;
  final Function(List<String> kycIds, String reason)? onBulkRejectKyc;
  final VoidCallback? onRefreshKyc;

  // ── Loan Approval ──
  final List<Map<String, dynamic>> loanApplications;
  final int loanTotalCount;
  final double loanPendingValue;
  final bool isLoanLoading;
  final String loanCurrentFilter;
  final Function(String)? onLoanFilterChange;
  final VoidCallback? onLoadMoreLoans;
  final Function(String appId, double amount)? onApproveLoan;
  final Function(String appId, String reason)? onRejectLoan;
  final VoidCallback? onRefreshLoans;

  // ── Audit Log ──
  final List<Map<String, dynamic>> auditEntries;
  final int auditTotalCount;
  final bool isAuditLoading;
  final List<String> auditEventTypes;
  final Function(Map<String, dynamic> filters)? onSearchAudit;
  final VoidCallback? onLoadMoreAudit;
  final VoidCallback? onRefreshAudit;

  // ── Collections ──
  final Map<String, dynamic> collectionsDashboard;
  final List<Map<String, dynamic>> collectionsQueue;
  final int collectionsQueueTotal;
  final bool isCollectionsLoading;
  final VoidCallback? onRefreshCollections;
  final VoidCallback? onLoadCollectionsQueue;
  final Function(String?)? onFilterCollectionsPar;
  final Function(String?)? onFilterCollectionsStatus;
  final VoidCallback? onLoadMoreCollections;
  final Function(Map<String, dynamic>)? onLogCollectionAction;
  final Function(Map<String, dynamic>)? onWaivePenalty;

  // ── Financial Reports ──
  final Map<String, dynamic> reportData;
  final bool isReportLoading;
  final String currentReportType;
  final Function(String type, String fromDate, String toDate)? onLoadReport;
  final VoidCallback? onRefreshReport;

  // ── Savings Management ──
  final Map<String, dynamic> savingsData;
  final bool isSavingsLoading;
  final VoidCallback? onRefreshSavings;

  // ── SMS Center ──
  final Map<String, dynamic> smsData;
  final List<Map<String, dynamic>> smsTemplates;
  final bool isSmsLoading;
  final VoidCallback? onRefreshSms;
  final Function(Map<String, dynamic>)? onSendBulkSms;

  // ── Restructuring / Write-Off ──
  final Map<String, dynamic> restructureQueue;
  final bool isRestructureLoading;
  final VoidCallback? onRefreshRestructure;
  final Function(Map<String, dynamic>)? onRequestRestructure;
  final Function(String id, String decision, {String? reason})? onApproveRestructure;
  final Function(Map<String, dynamic>)? onRequestWriteoff;
  final Function(String id, String decision, {String? reason})? onApproveWriteoff;
  final Function(Map<String, dynamic>)? onRecordRecovery;

  // ── Branch Performance ──
  final Map<String, dynamic> branchDashboard;
  final Map<String, dynamic> branchDetail;
  final Map<String, dynamic> branchTrend;
  final String? selectedBranch;
  final bool isBranchLoading;
  final Function(String?)? onSelectBranch;
  final VoidCallback? onRefreshBranch;
  final Function(String)? onLoadBranchDetail;
  final Function(String)? onLoadBranchTrend;

  // ── M-Pesa Reconciliation ──
  final Future<Map<String, dynamic>> Function({
    String? status,
    String? fromDate,
    String? toDate,
    int limit,
    int offset,
  })? onGetMpesaDashboard;
  final Future<Map<String, dynamic>> Function({
    required String transactionId,
    required String appliedToType,
    required String appliedToId,
  })? onMpesaManualReconcile;
  final Future<List<Map<String, dynamic>>> Function(String query)?
      onMpesaSearch;

  // ── Approval Workflow ──
  final List<Map<String, dynamic>> pendingApprovals;
  final int pendingApprovalsTotal;
  final List<Map<String, dynamic>> approvalRules;
  final bool isApprovalsLoading;
  final String approvalsFilter;
  final Function(String)? onApprovalsFilterChange;
  final Function(Map<String, dynamic>)? onProcessApproval;
  final Function(String entityType, String entityId)? onViewApprovalChain;
  final VoidCallback? onRefreshApprovals;
  final VoidCallback? onLoadMoreApprovals;
  final Function({required String operation, Map<String, dynamic> ruleData})?
      onManageApprovalRules;

  // ── Ops Console — Executive ──
  final Map<String, dynamic> executiveKpis;
  final List<Map<String, dynamic>> topPortfolio;
  final List<Map<String, dynamic>> recentMpesa;
  final bool isOpsConsoleLoading;
  final VoidCallback? onRefreshOpsConsole;

  // ── Ops Console — Loan Operations ──
  final List<Map<String, dynamic>> opsPipelineData;
  final List<Map<String, dynamic>> opsPortfolioData;
  final List<Map<String, dynamic>> opsRepaymentData;
  final bool isOpsPipelineLoading;
  final bool isOpsPortfolioLoading;
  final bool isOpsRepaymentLoading;
  final VoidCallback? onRefreshOpsPipeline;
  final VoidCallback? onRefreshOpsPortfolio;
  final VoidCallback? onRefreshOpsRepayment;
  final VoidCallback? onLoadMoreOpsPipeline;
  final VoidCallback? onLoadMoreOpsPortfolio;
  final VoidCallback? onLoadMoreOpsRepayment;
  final Function(String?)? onOpsPipelineStatusFilter;
  final Function(String?)? onOpsPortfolioStatusFilter;
  final Function(String?)? onOpsPortfolioParFilter;
  final Function(String?)? onOpsRepaymentStatusFilter;
  final Function(String? from, String? to)? onOpsRepaymentDateRange;

  // ── Ops Console — Payments & M-Pesa ──
  final List<Map<String, dynamic>> opsMpesaData;
  final List<Map<String, dynamic>> opsDisbursementData;
  final Map<String, dynamic> opsMpesaKpis;
  final bool isOpsMpesaLoading;
  final bool isOpsDisbursementLoading;
  final VoidCallback? onRefreshOpsMpesa;
  final VoidCallback? onRefreshOpsDisbursements;
  final VoidCallback? onLoadMoreOpsMpesa;
  final VoidCallback? onLoadMoreOpsDisbursements;
  final Function(String?)? onOpsMpesaStatusFilter;
  final Function(String?)? onOpsMpesaPurposeFilter;
  final Function(String? from, String? to)? onOpsMpesaDateRange;
  final Function(String?)? onOpsDisbursementStatusFilter;

  // ── Ops Console — Risk & Compliance ──
  final List<Map<String, dynamic>> opsCollectionsData;
  final List<Map<String, dynamic>> opsRestructureData;
  final List<Map<String, dynamic>> opsInstantLoanData;
  final List<Map<String, dynamic>> opsApprovalsData;
  final bool isOpsCollectionsLoading;
  final bool isOpsRestructureLoading;
  final bool isOpsInstantLoanLoading;
  final bool isOpsApprovalsLoading;
  final VoidCallback? onRefreshOpsCollections;
  final VoidCallback? onRefreshOpsRestructure;
  final VoidCallback? onRefreshOpsInstantLoans;
  final VoidCallback? onRefreshOpsApprovals;
  final VoidCallback? onLoadMoreOpsCollections;
  final VoidCallback? onLoadMoreOpsRestructure;
  final VoidCallback? onLoadMoreOpsInstantLoans;
  final VoidCallback? onLoadMoreOpsApprovals;
  final Function(String?)? onOpsCollectionsParFilter;
  final Function(String?)? onOpsCollectionsPriorityFilter;
  final Function(String?)? onOpsRestructureTypeFilter;
  final Function(String?)? onOpsRestructureStatusFilter;
  final Function(String?)? onOpsInstantLoanDecisionFilter;
  final Function(String?)? onOpsApprovalsStatusFilter;
  final Function(String?)? onOpsApprovalsEntityTypeFilter;

  // ── Ops Console — Customer 360 ──
  final List<Map<String, dynamic>> opsDirectoryData;
  final List<Map<String, dynamic>> opsKycData;
  final List<Map<String, dynamic>> opsSavingsData;
  final List<Map<String, dynamic>> opsGuarantorData;
  final bool isOpsDirectoryLoading;
  final bool isOpsKycLoading;
  final bool isOpsSavingsLoading;
  final bool isOpsGuarantorLoading;
  final VoidCallback? onRefreshOpsDirectory;
  final VoidCallback? onRefreshOpsKyc;
  final VoidCallback? onRefreshOpsSavings;
  final VoidCallback? onRefreshOpsGuarantors;
  final VoidCallback? onLoadMoreOpsDirectory;
  final VoidCallback? onLoadMoreOpsKyc;
  final VoidCallback? onLoadMoreOpsSavings;
  final VoidCallback? onLoadMoreOpsGuarantors;
  final Function(String)? onOpsDirectorySearch;
  final Function(String?)? onOpsKycStatusFilter;
  final Function(String?)? onOpsSavingsStatusFilter;
  final Function(String?)? onOpsGuarantorStatusFilter;

  // ── Global ──
  final VoidCallback? onLogout;

  @override
  State<AdminAppHomeScreen> createState() => _AdminAppHomeScreenState();
}

class _AdminAppHomeScreenState extends State<AdminAppHomeScreen> {
  static const _primaryColor = Color(0xFF1565C0);

  int _currentTabIndex = 0;
  _OverlayScreen _overlay = _OverlayScreen.none;
  _OpsConsoleView _opsConsoleView = _OpsConsoleView.executive;

  // ═══════════════════════════════════════════════════════════════════
  // RBAC TAB CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════

  /// Returns the list of tabs visible to the current user role.
  List<_AdminTab> get _visibleTabs {
    final role = widget.currentUserRole.toUpperCase();
    switch (role) {
      case 'ADMIN':
      case 'MANAGER':
        return _AdminTab.values; // All 14 tabs
      case 'OFFICER':
        return [
          _AdminTab.dashboard,
          _AdminTab.kyc,
          _AdminTab.loans,
          _AdminTab.approvals,
          _AdminTab.collections,
          _AdminTab.reports,
          _AdminTab.restructure,
          _AdminTab.branches,
          _AdminTab.mpesa,
          _AdminTab.audit,
          _AdminTab.opsConsole,
        ];
      case 'AUDITOR':
        return [
          _AdminTab.dashboard,
          _AdminTab.reports,
          _AdminTab.branches,
          _AdminTab.audit,
        ];
      case 'TELLER':
        return [_AdminTab.dashboard];
      default:
        return [_AdminTab.dashboard];
    }
  }

  /// Use NavigationDrawer when >5 tabs, BottomNav otherwise.
  bool get _useDrawer => _visibleTabs.length > 5;

  bool get _canManageStaff {
    final role = widget.currentUserRole.toUpperCase();
    return role == 'ADMIN' || role == 'MANAGER';
  }

  // ═══════════════════════════════════════════════════════════════════
  // NAVIGATION HELPERS
  // ═══════════════════════════════════════════════════════════════════

  void _switchToTab(_AdminTab tab) {
    final tabs = _visibleTabs;
    final index = tabs.indexOf(tab);
    if (index >= 0) {
      setState(() {
        _currentTabIndex = index;
        _overlay = _OverlayScreen.none;
      });
    }
  }

  void _openOverlay(_OverlayScreen overlay) {
    setState(() => _overlay = overlay);
  }

  void _closeOverlay() {
    setState(() => _overlay = _OverlayScreen.none);
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final tabs = _visibleTabs;

    // Clamp current index to visible tabs
    if (_currentTabIndex >= tabs.length) {
      _currentTabIndex = 0;
    }

    return PopScope(
      canPop: _overlay == _OverlayScreen.none &&
          !(_visibleTabs[_currentTabIndex] == _AdminTab.opsConsole &&
              _opsConsoleView != _OpsConsoleView.executive),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_overlay != _OverlayScreen.none) {
            _closeOverlay();
          } else if (_visibleTabs[_currentTabIndex] == _AdminTab.opsConsole &&
              _opsConsoleView != _OpsConsoleView.executive) {
            setState(() => _opsConsoleView = _OpsConsoleView.executive);
          }
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(tabs),
        drawer: _useDrawer ? _buildDrawer(tabs) : null,
        body: Stack(
          children: [
            // ── Tab content ──
            IndexedStack(
              index: _currentTabIndex,
              children: tabs.map((tab) => _buildTabContent(tab)).toList(),
            ),
            // ── Overlay ──
            if (_overlay != _OverlayScreen.none) _buildOverlay(),
          ],
        ),
        bottomNavigationBar: !_useDrawer && tabs.length > 1
            ? _buildBottomNav(tabs)
            : null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar(List<_AdminTab> tabs) {
    final currentTab = tabs[_currentTabIndex];
    final isOverlay = _overlay != _OverlayScreen.none;

    String title;
    if (isOverlay) {
      switch (_overlay) {
        case _OverlayScreen.staffOnboarding:
          title = 'Staff Onboarding';
          break;
        case _OverlayScreen.staffProfile:
          title = 'Staff Profile';
          break;
        default:
          title = 'Admin Portal';
      }
    } else {
      title = currentTab.label;
    }

    return AppBar(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      leading: isOverlay
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _closeOverlay,
            )
          : _useDrawer
              ? null // Scaffold auto-shows hamburger icon for drawer
              : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (!isOverlay)
            Text(
              '${widget.staffName} \u2022 ${widget.currentUserRole}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
            ),
        ],
      ),
      actions: [
        if (!isOverlay) ...[
          // Role badge chip
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Chip(
              label: Text(
                widget.currentUserRole,
                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: _roleColor(widget.currentUserRole),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                widget.onLogout?.call();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.staffName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                    Text(widget.staffEmail, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _roleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return Colors.red.shade700;
      case 'MANAGER':
        return Colors.orange.shade700;
      case 'OFFICER':
        return Colors.blue.shade700;
      case 'AUDITOR':
        return Colors.purple.shade700;
      case 'TELLER':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // NAVIGATION DRAWER (for roles with >5 tabs)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildDrawer(List<_AdminTab> tabs) {
    return NavigationDrawer(
      selectedIndex: _currentTabIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentTabIndex = index;
          _overlay = _OverlayScreen.none;
        });
        Navigator.of(context).pop(); // close drawer
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.staffName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.staffEmail} \u2022 ${widget.currentUserRole}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const Divider(indent: 16, endIndent: 16),
        ...tabs.map((tab) {
          return NavigationDrawerDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.activeIcon),
            label: Text(tab.label),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // BOTTOM NAV (for roles with <=5 tabs)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildBottomNav(List<_AdminTab> tabs) {
    return BottomNavigationBar(
      currentIndex: _currentTabIndex,
      onTap: (index) {
        setState(() {
          _currentTabIndex = index;
          _overlay = _OverlayScreen.none;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: tabs.map((tab) {
        return BottomNavigationBarItem(
          icon: Icon(tab.icon),
          activeIcon: Icon(tab.activeIcon),
          label: tab.label,
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TAB CONTENT
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTabContent(_AdminTab tab) {
    switch (tab) {
      case _AdminTab.dashboard:
        return _buildDashboardTab();
      case _AdminTab.staff:
        return _buildStaffTab();
      case _AdminTab.kyc:
        return _buildKycTab();
      case _AdminTab.loans:
        return _buildLoanTab();
      case _AdminTab.approvals:
        return _buildApprovalsTab();
      case _AdminTab.collections:
        return _buildCollectionsTab();
      case _AdminTab.reports:
        return _buildReportsTab();
      case _AdminTab.savings:
        return _buildSavingsTab();
      case _AdminTab.sms:
        return _buildSmsTab();
      case _AdminTab.restructure:
        return _buildRestructureTab();
      case _AdminTab.branches:
        return _buildBranchesTab();
      case _AdminTab.mpesa:
        return _buildMpesaTab();
      case _AdminTab.audit:
        return _buildAuditTab();
      case _AdminTab.opsConsole:
        return _buildOpsConsoleTab();
    }
  }

  // ── Dashboard Tab ──

  Widget _buildDashboardTab() {
    return ImfslAdminDashboard(
      dashboardData: widget.dashboardData,
      isLoading: widget.isDashboardLoading,
      onRefresh: widget.onRefreshDashboard,
      onNavigateStaff: () => _switchToTab(_AdminTab.staff),
      onNavigateKyc: () => _switchToTab(_AdminTab.kyc),
      onNavigateLoans: () => _switchToTab(_AdminTab.loans),
      onNavigateCollections: () => _switchToTab(_AdminTab.collections),
      onNavigateAudit: () => _switchToTab(_AdminTab.audit),
      onNavigateReports: () => _switchToTab(_AdminTab.reports),
    );
  }

  // ── Staff Tab ──

  Widget _buildStaffTab() {
    return ImfslStaffManagement(
      staffList: widget.staffList,
      totalCount: widget.staffTotalCount,
      isLoading: widget.isStaffLoading,
      currentUserRole: widget.currentUserRole,
      branches: widget.branches,
      onSearch: widget.onSearchStaff,
      onFilterBranch: widget.onFilterStaffBranch,
      onFilterRole: widget.onFilterStaffRole,
      onLoadMore: widget.onLoadMoreStaff,
      onStaffTap: widget.onStaffTap,
      onAddStaff: _canManageStaff
          ? () => _openOverlay(_OverlayScreen.staffOnboarding)
          : null,
      onUpdateRole: widget.onUpdateStaffRole,
      onToggleActive: widget.onToggleStaffActive,
    );
  }

  // ── KYC Tab ──

  Widget _buildKycTab() {
    return ImfslKycReviewQueue(
      submissions: widget.kycSubmissions,
      totalCount: widget.kycTotalCount,
      isLoading: widget.isKycLoading,
      currentFilter: widget.kycCurrentFilter,
      onFilterChange: widget.onKycFilterChange,
      onLoadMore: widget.onLoadMoreKyc,
      onApprove: widget.onApproveKyc,
      onReject: widget.onRejectKyc,
      onBulkApprove: widget.onBulkApproveKyc,
      onBulkReject: widget.onBulkRejectKyc,
      onRefresh: widget.onRefreshKyc,
    );
  }

  // ── Loan Tab ──

  Widget _buildLoanTab() {
    return ImfslLoanApprovalQueue(
      applications: widget.loanApplications,
      totalCount: widget.loanTotalCount,
      pendingValue: widget.loanPendingValue,
      isLoading: widget.isLoanLoading,
      currentFilter: widget.loanCurrentFilter,
      onFilterChange: widget.onLoanFilterChange,
      onLoadMore: widget.onLoadMoreLoans,
      onApprove: widget.onApproveLoan,
      onReject: widget.onRejectLoan,
      onRefresh: widget.onRefreshLoans,
    );
  }

  // ── Collections Tab ──

  int _collectionsViewIndex = 0; // 0=Overview, 1=Queue

  Widget _buildCollectionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Overview'), icon: Icon(Icons.dashboard_outlined, size: 18)),
                    ButtonSegment(value: 1, label: Text('Queue'), icon: Icon(Icons.list_alt, size: 18)),
                  ],
                  selected: {_collectionsViewIndex},
                  onSelectionChanged: (set) {
                    setState(() => _collectionsViewIndex = set.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _collectionsViewIndex == 0
              ? ImfslCollectionsDashboard(
                  dashboardData: widget.collectionsDashboard,
                  isLoading: widget.isCollectionsLoading,
                  onRefresh: widget.onRefreshCollections,
                  onLoanTap: (loanId) {
                    // Switch to queue view filtered
                    setState(() => _collectionsViewIndex = 1);
                  },
                  onLogAction: widget.onLogCollectionAction,
                )
              : ImfslCollectionsQueue(
                  items: widget.collectionsQueue,
                  totalCount: widget.collectionsQueueTotal,
                  isLoading: widget.isCollectionsLoading,
                  currentParFilter: null,
                  currentStatusFilter: null,
                  onFilterPar: widget.onFilterCollectionsPar,
                  onFilterStatus: widget.onFilterCollectionsStatus,
                  onLoadMore: widget.onLoadMoreCollections,
                  onLogAction: widget.onLogCollectionAction,
                  onWaivePenalty: widget.onWaivePenalty,
                  onRefresh: widget.onRefreshCollections,
                  currentUserRole: widget.currentUserRole,
                ),
        ),
      ],
    );
  }

  // ── Reports Tab ──

  Widget _buildReportsTab() {
    return ImfslFinancialReports(
      reportData: widget.reportData,
      isLoading: widget.isReportLoading,
      currentReport: widget.currentReportType,
      onLoadReport: widget.onLoadReport,
    );
  }

  // ── Savings Tab ──

  Widget _buildSavingsTab() {
    return ImfslSavingsManagement(
      savingsData: widget.savingsData,
      isLoading: widget.isSavingsLoading,
      onRefresh: widget.onRefreshSavings,
    );
  }

  // ── SMS Tab ──

  Widget _buildSmsTab() {
    return ImfslSmsCenter(
      smsData: widget.smsData,
      templates: widget.smsTemplates,
      isLoading: widget.isSmsLoading,
      onRefresh: widget.onRefreshSms,
      onSendBulk: widget.onSendBulkSms,
    );
  }

  // ── Restructure Tab ──

  Widget _buildRestructureTab() {
    return ImfslLoanRestructuring(
      queueData: widget.restructureQueue,
      isLoading: widget.isRestructureLoading,
      onRefresh: widget.onRefreshRestructure,
      onRequestRestructure: widget.onRequestRestructure,
      onApproveRestructure: widget.onApproveRestructure,
      onRejectRestructure: (id, {String? reason}) =>
          widget.onApproveRestructure?.call(id, 'REJECTED', reason: reason),
      onRequestWriteoff: widget.onRequestWriteoff,
      onApproveWriteoff: widget.onApproveWriteoff,
      onRejectWriteoff: (id, {String? reason}) =>
          widget.onApproveWriteoff?.call(id, 'REJECTED', reason: reason),
      onRecordRecovery: widget.onRecordRecovery,
    );
  }

  // ── Branches Tab ──

  Widget _buildBranchesTab() {
    return ImfslBranchPerformance(
      dashboardData: widget.branchDashboard,
      branchDetail: widget.branchDetail,
      trendData: widget.branchTrend,
      isLoading: widget.isBranchLoading,
      selectedBranch: widget.selectedBranch,
      onSelectBranch: widget.onSelectBranch,
      onRefresh: widget.onRefreshBranch,
      onLoadDetail: widget.onLoadBranchDetail,
      onLoadTrend: widget.onLoadBranchTrend,
    );
  }

  // ── Approvals Tab ──

  Widget _buildApprovalsTab() {
    return ImfslApprovalWorkflow(
      pendingApprovals: widget.pendingApprovals,
      pendingTotalCount: widget.pendingApprovalsTotal,
      approvalRules: widget.approvalRules,
      isLoading: widget.isApprovalsLoading,
      currentUserRole: widget.currentUserRole,
      currentFilter: widget.approvalsFilter,
      onFilterChange: widget.onApprovalsFilterChange,
      onProcessApproval: widget.onProcessApproval,
      onViewChain: widget.onViewApprovalChain,
      onRefresh: widget.onRefreshApprovals,
      onLoadMore: widget.onLoadMoreApprovals,
      onManageRules: widget.onManageApprovalRules,
    );
  }

  // ── M-Pesa Tab ──

  Widget _buildMpesaTab() {
    return ImfslMpesaReconciliation(
      onGetDashboard: widget.onGetMpesaDashboard,
      onManualReconcile: widget.onMpesaManualReconcile,
      onSearch: widget.onMpesaSearch,
    );
  }

  // ── Audit Tab ──

  Widget _buildAuditTab() {
    return ImfslAuditLogViewer(
      entries: widget.auditEntries,
      totalCount: widget.auditTotalCount,
      isLoading: widget.isAuditLoading,
      eventTypes: widget.auditEventTypes,
      onSearch: widget.onSearchAudit,
      onLoadMore: widget.onLoadMoreAudit,
      onRefresh: widget.onRefreshAudit,
    );
  }

  // ── Ops Console Tab ──

  void _navigateOpsConsole(String consoleName) {
    setState(() {
      switch (consoleName) {
        case 'loanOps':
          _opsConsoleView = _OpsConsoleView.loanOps;
          break;
        case 'payments':
          _opsConsoleView = _OpsConsoleView.payments;
          break;
        case 'risk':
          _opsConsoleView = _OpsConsoleView.risk;
          break;
        case 'customer360':
          _opsConsoleView = _OpsConsoleView.customer360;
          break;
        default:
          _opsConsoleView = _OpsConsoleView.executive;
      }
    });
  }

  Widget _buildOpsConsoleTab() {
    switch (_opsConsoleView) {
      case _OpsConsoleView.executive:
        return ImfslExecutiveConsole(
          executiveKpis: widget.executiveKpis,
          topPortfolio: widget.topPortfolio,
          recentMpesa: widget.recentMpesa,
          isLoading: widget.isOpsConsoleLoading,
          onRefresh: widget.onRefreshOpsConsole,
          onNavigate: _navigateOpsConsole,
        );
      case _OpsConsoleView.loanOps:
        return ImfslLoanOperationsConsole(
          pipelineData: widget.opsPipelineData,
          portfolioData: widget.opsPortfolioData,
          repaymentData: widget.opsRepaymentData,
          isPipelineLoading: widget.isOpsPipelineLoading,
          isPortfolioLoading: widget.isOpsPortfolioLoading,
          isRepaymentLoading: widget.isOpsRepaymentLoading,
          onPipelineStatusFilter: widget.onOpsPipelineStatusFilter,
          onPortfolioStatusFilter: widget.onOpsPortfolioStatusFilter,
          onPortfolioParFilter: widget.onOpsPortfolioParFilter,
          onRepaymentStatusFilter: widget.onOpsRepaymentStatusFilter,
          onRepaymentDateRange: widget.onOpsRepaymentDateRange,
          onLoadMorePipeline: widget.onLoadMoreOpsPipeline,
          onLoadMorePortfolio: widget.onLoadMoreOpsPortfolio,
          onLoadMoreRepayment: widget.onLoadMoreOpsRepayment,
          onRefreshPipeline: widget.onRefreshOpsPipeline,
          onRefreshPortfolio: widget.onRefreshOpsPortfolio,
          onRefreshRepayment: widget.onRefreshOpsRepayment,
          onBack: () => setState(() => _opsConsoleView = _OpsConsoleView.executive),
        );
      case _OpsConsoleView.payments:
        return ImfslPaymentMpesaConsole(
          mpesaData: widget.opsMpesaData,
          disbursementData: widget.opsDisbursementData,
          mpesaKpis: widget.opsMpesaKpis,
          isMpesaLoading: widget.isOpsMpesaLoading,
          isDisbursementLoading: widget.isOpsDisbursementLoading,
          onMpesaStatusFilter: widget.onOpsMpesaStatusFilter,
          onMpesaPurposeFilter: widget.onOpsMpesaPurposeFilter,
          onMpesaDateRange: widget.onOpsMpesaDateRange,
          onDisbursementStatusFilter: widget.onOpsDisbursementStatusFilter,
          onLoadMoreMpesa: widget.onLoadMoreOpsMpesa,
          onLoadMoreDisbursements: widget.onLoadMoreOpsDisbursements,
          onRefreshMpesa: widget.onRefreshOpsMpesa,
          onRefreshDisbursements: widget.onRefreshOpsDisbursements,
          onBack: () => setState(() => _opsConsoleView = _OpsConsoleView.executive),
        );
      case _OpsConsoleView.risk:
        return ImfslRiskComplianceConsole(
          collectionsData: widget.opsCollectionsData,
          restructureData: widget.opsRestructureData,
          instantLoanData: widget.opsInstantLoanData,
          approvalsData: widget.opsApprovalsData,
          isCollectionsLoading: widget.isOpsCollectionsLoading,
          isRestructureLoading: widget.isOpsRestructureLoading,
          isInstantLoanLoading: widget.isOpsInstantLoanLoading,
          isApprovalsLoading: widget.isOpsApprovalsLoading,
          onCollectionsParFilter: widget.onOpsCollectionsParFilter,
          onCollectionsPriorityFilter: widget.onOpsCollectionsPriorityFilter,
          onRestructureTypeFilter: widget.onOpsRestructureTypeFilter,
          onRestructureStatusFilter: widget.onOpsRestructureStatusFilter,
          onInstantLoanDecisionFilter: widget.onOpsInstantLoanDecisionFilter,
          onApprovalsStatusFilter: widget.onOpsApprovalsStatusFilter,
          onApprovalsEntityTypeFilter: widget.onOpsApprovalsEntityTypeFilter,
          onLoadMoreCollections: widget.onLoadMoreOpsCollections,
          onLoadMoreRestructure: widget.onLoadMoreOpsRestructure,
          onLoadMoreInstantLoans: widget.onLoadMoreOpsInstantLoans,
          onLoadMoreApprovals: widget.onLoadMoreOpsApprovals,
          onRefreshCollections: widget.onRefreshOpsCollections,
          onRefreshRestructure: widget.onRefreshOpsRestructure,
          onRefreshInstantLoans: widget.onRefreshOpsInstantLoans,
          onRefreshApprovals: widget.onRefreshOpsApprovals,
          onBack: () => setState(() => _opsConsoleView = _OpsConsoleView.executive),
        );
      case _OpsConsoleView.customer360:
        return ImfslCustomer360Console(
          directoryData: widget.opsDirectoryData,
          kycData: widget.opsKycData,
          savingsData: widget.opsSavingsData,
          guarantorData: widget.opsGuarantorData,
          isDirectoryLoading: widget.isOpsDirectoryLoading,
          isKycLoading: widget.isOpsKycLoading,
          isSavingsLoading: widget.isOpsSavingsLoading,
          isGuarantorLoading: widget.isOpsGuarantorLoading,
          onDirectorySearch: widget.onOpsDirectorySearch,
          onKycStatusFilter: widget.onOpsKycStatusFilter,
          onSavingsStatusFilter: widget.onOpsSavingsStatusFilter,
          onGuarantorStatusFilter: widget.onOpsGuarantorStatusFilter,
          onLoadMoreDirectory: widget.onLoadMoreOpsDirectory,
          onLoadMoreKyc: widget.onLoadMoreOpsKyc,
          onLoadMoreSavings: widget.onLoadMoreOpsSavings,
          onLoadMoreGuarantors: widget.onLoadMoreOpsGuarantors,
          onRefreshDirectory: widget.onRefreshOpsDirectory,
          onRefreshKyc: widget.onRefreshOpsKyc,
          onRefreshSavings: widget.onRefreshOpsSavings,
          onRefreshGuarantors: widget.onRefreshOpsGuarantors,
          onBack: () => setState(() => _opsConsoleView = _OpsConsoleView.executive),
        );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // OVERLAY SCREENS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildOverlay() {
    return Container(
      color: Colors.white,
      child: _buildOverlayContent(),
    );
  }

  Widget _buildOverlayContent() {
    switch (_overlay) {
      case _OverlayScreen.staffOnboarding:
        return ImfslStaffOnboardingForm(
          approvedKycSubmissions: widget.approvedKycSubmissions,
          isLoading: widget.isOnboardingLoading,
          onSubmit: (data) {
            widget.onSubmitOnboarding?.call(data);
            _closeOverlay();
          },
          onCancel: _closeOverlay,
        );
      case _OverlayScreen.staffProfile:
        // Placeholder — staff profile detail could be added later
        return const Center(child: Text('Staff Profile'));
      case _OverlayScreen.none:
        return const SizedBox.shrink();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TAB ENUM
// ═══════════════════════════════════════════════════════════════════════

enum _AdminTab {
  dashboard(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
  ),
  staff(
    label: 'Staff',
    icon: Icons.people_outline,
    activeIcon: Icons.people,
  ),
  kyc(
    label: 'KYC',
    icon: Icons.verified_user_outlined,
    activeIcon: Icons.verified_user,
  ),
  loans(
    label: 'Loans',
    icon: Icons.account_balance_outlined,
    activeIcon: Icons.account_balance,
  ),
  approvals(
    label: 'Approvals',
    icon: Icons.approval_outlined,
    activeIcon: Icons.approval,
  ),
  collections(
    label: 'Collections',
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet,
  ),
  reports(
    label: 'Reports',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart,
  ),
  savings(
    label: 'Savings',
    icon: Icons.savings_outlined,
    activeIcon: Icons.savings,
  ),
  sms(
    label: 'SMS',
    icon: Icons.sms_outlined,
    activeIcon: Icons.sms,
  ),
  restructure(
    label: 'Restructure',
    icon: Icons.build_circle_outlined,
    activeIcon: Icons.build_circle,
  ),
  branches(
    label: 'Branches',
    icon: Icons.account_tree_outlined,
    activeIcon: Icons.account_tree,
  ),
  mpesa(
    label: 'M-Pesa',
    icon: Icons.phone_android_outlined,
    activeIcon: Icons.phone_android,
  ),
  audit(
    label: 'Audit',
    icon: Icons.history_outlined,
    activeIcon: Icons.history,
  ),
  opsConsole(
    label: 'Ops Console',
    icon: Icons.dashboard_customize_outlined,
    activeIcon: Icons.dashboard_customize,
  );

  const _AdminTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
