// IMFSL Admin Portal Home Screen
// ================================
// Navigation shell that integrates all 6 admin widgets with RBAC-based
// tab visibility. Roles: ADMIN, MANAGER, OFFICER, AUDITOR, TELLER.
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

/// Overlay screens that sit on top of the tab content.
enum _OverlayScreen { none, staffOnboarding, staffProfile }

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

  // ── Global ──
  final VoidCallback? onLogout;

  @override
  State<AdminAppHomeScreen> createState() => _AdminAppHomeScreenState();
}

class _AdminAppHomeScreenState extends State<AdminAppHomeScreen> {
  static const _primaryColor = Color(0xFF1565C0);

  int _currentTabIndex = 0;
  _OverlayScreen _overlay = _OverlayScreen.none;

  // ═══════════════════════════════════════════════════════════════════
  // RBAC TAB CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════

  /// Returns the list of tabs visible to the current user role.
  List<_AdminTab> get _visibleTabs {
    final role = widget.currentUserRole.toUpperCase();
    switch (role) {
      case 'ADMIN':
      case 'MANAGER':
        return _AdminTab.values; // All 6 tabs
      case 'OFFICER':
        return [
          _AdminTab.dashboard,
          _AdminTab.staff,
          _AdminTab.kyc,
          _AdminTab.loans,
          _AdminTab.collections,
          _AdminTab.audit,
        ];
      case 'AUDITOR':
        return [
          _AdminTab.dashboard,
          _AdminTab.audit,
        ];
      case 'TELLER':
        return [_AdminTab.dashboard];
      default:
        return [_AdminTab.dashboard];
    }
  }

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
      canPop: _overlay == _OverlayScreen.none,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _overlay != _OverlayScreen.none) {
          _closeOverlay();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(tabs),
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
        bottomNavigationBar: tabs.length > 1
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
  // BOTTOM NAV
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
      case _AdminTab.collections:
        return _buildCollectionsTab();
      case _AdminTab.audit:
        return _buildAuditTab();
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
      onNavigateReports: null, // No reports tab yet
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
  collections(
    label: 'Collections',
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet,
  ),
  audit(
    label: 'Audit',
    icon: Icons.history_outlined,
    activeIcon: Icons.history,
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
