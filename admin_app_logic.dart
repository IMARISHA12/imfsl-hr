// IMFSL Admin App Logic
// ======================
// Entry-point widget that wires AdminAppHomeScreen to AdminGatewayService.
// Manages state, loads initial data, and implements all callbacks.
//
// Usage:
//   AdminAppLogic(
//     supabaseClient: Supabase.instance.client,
//     currentUserRole: 'ADMIN',
//     staffName: 'Jane Doe',
//     staffEmail: 'jane@imfsl.co.ke',
//     onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
//   )
//
// Dependencies (add to pubspec.yaml):
//   supabase_flutter: ^2.0.0
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_gateway_service.dart';
import 'admin_app_home_screen.dart';

class AdminAppLogic extends StatefulWidget {
  const AdminAppLogic({
    super.key,
    required this.supabaseClient,
    required this.currentUserRole,
    this.staffName = '',
    this.staffEmail = '',
    this.onLogout,
  });

  final SupabaseClient supabaseClient;
  final String currentUserRole;
  final String staffName;
  final String staffEmail;
  final VoidCallback? onLogout;

  @override
  State<AdminAppLogic> createState() => _AdminAppLogicState();
}

class _AdminAppLogicState extends State<AdminAppLogic> {
  late final AdminGatewayService _service;
  static const _primaryColor = Color(0xFF1565C0);

  // ═══════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════

  bool _initialLoading = true;
  String? _initialError;

  // Dashboard
  Map<String, dynamic> _dashboardData = {};
  bool _isDashboardLoading = false;

  // Staff
  List<Map<String, dynamic>> _staffList = [];
  int _staffTotalCount = 0;
  bool _isStaffLoading = false;
  String _staffSearch = '';
  String? _staffBranchFilter;
  String? _staffRoleFilter;
  int _staffOffset = 0;
  List<String> _branches = [];

  // Staff Onboarding
  List<Map<String, dynamic>> _approvedKycSubmissions = [];
  bool _isOnboardingLoading = false;

  // KYC Review
  List<Map<String, dynamic>> _kycSubmissions = [];
  int _kycTotalCount = 0;
  bool _isKycLoading = false;
  String _kycFilter = 'PENDING';

  // Loan Approval
  List<Map<String, dynamic>> _loanApplications = [];
  int _loanTotalCount = 0;
  double _loanPendingValue = 0.0;
  bool _isLoanLoading = false;
  String _loanFilter = 'SUBMITTED';

  // Audit Log
  List<Map<String, dynamic>> _auditEntries = [];
  int _auditTotalCount = 0;
  bool _isAuditLoading = false;

  // Collections
  Map<String, dynamic> _collectionsDashboard = {};
  List<Map<String, dynamic>> _collectionsQueue = [];
  int _collectionsQueueTotal = 0;
  bool _isCollectionsLoading = false;
  String? _collectionsParFilter;
  String? _collectionsStatusFilter;

  // ═══════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _service = AdminGatewayService(client: widget.supabaseClient);
    _loadInitialData();
  }

  // ═══════════════════════════════════════════════════════════════════
  // INITIAL DATA LOAD
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadInitialData() async {
    setState(() {
      _initialLoading = true;
      _initialError = null;
    });

    try {
      final role = widget.currentUserRole.toUpperCase();

      // All roles get the dashboard
      final futures = <Future>[_loadDashboard()];

      // Role-based parallel loading
      if (role == 'ADMIN' || role == 'MANAGER' || role == 'OFFICER') {
        futures.add(_loadStaffList());
        futures.add(_loadKycQueue());
        futures.add(_loadLoanQueue());
        futures.add(_loadAuditLog());
        futures.add(_loadApprovedKycForOnboarding());
        futures.add(_loadCollectionsDashboard());
        futures.add(_loadCollectionsQueue());
      } else if (role == 'AUDITOR') {
        futures.add(_loadAuditLog());
      }
      // TELLER gets dashboard only

      await Future.wait(futures);

      // Extract unique branches from staff list for filter dropdown
      _extractBranches();

      if (mounted) {
        setState(() => _initialLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialLoading = false;
          _initialError = e.toString();
        });
      }
    }
  }

  void _extractBranches() {
    final branchSet = <String>{};
    for (final staff in _staffList) {
      final branch = staff['branch']?.toString();
      if (branch != null && branch.isNotEmpty) {
        branchSet.add(branch);
      }
    }
    _branches = branchSet.toList()..sort();
  }

  // ═══════════════════════════════════════════════════════════════════
  // DATA LOADERS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadDashboard() async {
    if (mounted) setState(() => _isDashboardLoading = true);
    try {
      final data = await _service.getDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isDashboardLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDashboardLoading = false);
        _showError('Failed to load dashboard: $e');
      }
    }
  }

  Future<void> _loadStaffList({bool append = false}) async {
    if (mounted) setState(() => _isStaffLoading = true);
    try {
      final data = await _service.getStaffList(
        search: _staffSearch.isNotEmpty ? _staffSearch : null,
        branch: _staffBranchFilter,
        role: _staffRoleFilter,
        limit: 25,
        offset: append ? _staffOffset : 0,
      );
      if (mounted) {
        setState(() {
          if (append) {
            _staffList.addAll(data);
          } else {
            _staffList = data;
            _staffOffset = 0;
          }
          // Use totalCount from the first item's metadata if available,
          // otherwise estimate from the returned data length
          if (data.isNotEmpty && data.first.containsKey('total_count')) {
            _staffTotalCount =
                (data.first['total_count'] as num?)?.toInt() ?? data.length;
          } else if (!append) {
            _staffTotalCount = data.length;
          }
          _staffOffset = _staffList.length;
          _isStaffLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isStaffLoading = false);
        _showError('Failed to load staff: $e');
      }
    }
  }

  Future<void> _loadApprovedKycForOnboarding() async {
    try {
      final data = await _service.getKycQueue(status: 'APPROVED', limit: 100);
      if (mounted) {
        setState(() => _approvedKycSubmissions = data);
      }
    } catch (_) {
      // Non-critical, ignore
    }
  }

  Future<void> _loadKycQueue({bool append = false}) async {
    if (mounted) setState(() => _isKycLoading = true);
    try {
      final data = await _service.getKycQueue(
        status: _kycFilter,
        limit: 25,
        offset: append ? _kycSubmissions.length : 0,
      );
      if (mounted) {
        setState(() {
          if (append) {
            _kycSubmissions.addAll(data);
          } else {
            _kycSubmissions = data;
          }
          if (data.isNotEmpty && data.first.containsKey('total_count')) {
            _kycTotalCount =
                (data.first['total_count'] as num?)?.toInt() ?? data.length;
          } else if (!append) {
            _kycTotalCount = data.length;
          }
          _isKycLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isKycLoading = false);
        _showError('Failed to load KYC queue: $e');
      }
    }
  }

  Future<void> _loadLoanQueue({bool append = false}) async {
    if (mounted) setState(() => _isLoanLoading = true);
    try {
      final data = await _service.getLoanQueue(
        status: _loanFilter,
        limit: 25,
        offset: append ? _loanApplications.length : 0,
      );
      if (mounted) {
        setState(() {
          if (append) {
            _loanApplications.addAll(data);
          } else {
            _loanApplications = data;
          }
          if (data.isNotEmpty && data.first.containsKey('total_count')) {
            _loanTotalCount =
                (data.first['total_count'] as num?)?.toInt() ?? data.length;
          } else if (!append) {
            _loanTotalCount = data.length;
          }
          // Calculate pending value from current items
          _loanPendingValue = _loanApplications.fold<double>(0.0, (sum, app) {
            final amount = app['amount'] ?? app['requested_amount'] ?? 0;
            return sum + (amount is num ? amount.toDouble() : 0.0);
          });
          _isLoanLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoanLoading = false);
        _showError('Failed to load loan queue: $e');
      }
    }
  }

  Future<void> _loadAuditLog(
      {bool append = false, Map<String, dynamic>? filters}) async {
    if (mounted) setState(() => _isAuditLoading = true);
    try {
      final data = await _service.searchAuditLog(
        eventType: filters?['event_type'],
        entityType: filters?['entity_type'],
        actorId: filters?['actor_id'],
        dateFrom: filters?['date_from'],
        dateTo: filters?['date_to'],
        severity: filters?['severity'],
        search: filters?['search'],
        limit: 25,
        offset: append ? _auditEntries.length : 0,
      );
      if (mounted) {
        setState(() {
          if (append) {
            _auditEntries.addAll(data);
          } else {
            _auditEntries = data;
          }
          if (data.isNotEmpty && data.first.containsKey('total_count')) {
            _auditTotalCount =
                (data.first['total_count'] as num?)?.toInt() ?? data.length;
          } else if (!append) {
            _auditTotalCount = data.length;
          }
          _isAuditLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuditLoading = false);
        _showError('Failed to load audit log: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // COLLECTIONS DATA LOADERS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadCollectionsDashboard() async {
    if (mounted) setState(() => _isCollectionsLoading = true);
    try {
      final data = await _service.getCollectionsDashboard();
      if (mounted) {
        setState(() {
          _collectionsDashboard = data;
          _isCollectionsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCollectionsLoading = false);
        _showError('Failed to load collections dashboard: $e');
      }
    }
  }

  Future<void> _loadCollectionsQueue({bool append = false}) async {
    if (mounted) setState(() => _isCollectionsLoading = true);
    try {
      final data = await _service.getCollectionsQueue(
        status: _collectionsStatusFilter,
        parBucket: _collectionsParFilter,
        limit: 20,
        offset: append ? _collectionsQueue.length : 0,
      );
      if (mounted) {
        setState(() {
          final loans = (data['loans'] as List?)
                  ?.map((e) => e is Map<String, dynamic>
                      ? e
                      : Map<String, dynamic>.from(e as Map))
                  .toList() ??
              [];
          if (append) {
            _collectionsQueue.addAll(loans);
          } else {
            _collectionsQueue = loans;
          }
          _collectionsQueueTotal =
              (data['total_count'] as num?)?.toInt() ?? loans.length;
          _isCollectionsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCollectionsLoading = false);
        _showError('Failed to load collections queue: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CALLBACK IMPLEMENTATIONS
  // ═══════════════════════════════════════════════════════════════════

  // ── Staff ──

  void _handleSearchStaff(String query) {
    _staffSearch = query;
    _loadStaffList();
  }

  void _handleFilterStaffBranch(String? branch) {
    _staffBranchFilter = branch;
    _loadStaffList();
  }

  void _handleFilterStaffRole(String? role) {
    _staffRoleFilter = role;
    _loadStaffList();
  }

  void _handleLoadMoreStaff() {
    _loadStaffList(append: true);
  }

  void _handleStaffTap(Map<String, dynamic> staff) {
    // Could navigate to a staff detail screen in the future
    // For now, this is a no-op or can show a dialog
  }

  Future<void> _handleUpdateStaffRole(String staffId, String newRole) async {
    try {
      await _service.updateStaffRole(staffId: staffId, newRole: newRole);
      _showSuccess('Staff role updated to $newRole');
      _loadStaffList();
      _loadDashboard();
    } catch (e) {
      _showError('Failed to update role: $e');
    }
  }

  Future<void> _handleToggleStaffActive(
      String staffId, bool isActive, String reason) async {
    try {
      await _service.toggleStaffActive(
        staffId: staffId,
        isActive: isActive,
        reason: reason,
      );
      _showSuccess(isActive ? 'Staff activated' : 'Staff deactivated');
      _loadStaffList();
      _loadDashboard();
    } catch (e) {
      _showError('Failed to toggle staff status: $e');
    }
  }

  // ── Onboarding ──

  Future<void> _handleSubmitOnboarding(Map<String, dynamic> data) async {
    setState(() => _isOnboardingLoading = true);
    try {
      await _service.onboardStaff(
        kycId: data['kyc_id'] ?? '',
        employeeId: data['employee_id'] ?? '',
        systemRole: data['system_role'] ?? 'OFFICER',
        branchCode: data['branch_code'] ?? '',
        passwordHash: data['password_hash'] ?? '',
      );
      _showSuccess('Staff member onboarded successfully');
      setState(() => _isOnboardingLoading = false);
      // Refresh staff list and approved KYC
      _loadStaffList();
      _loadApprovedKycForOnboarding();
      _loadDashboard();
    } catch (e) {
      if (mounted) setState(() => _isOnboardingLoading = false);
      _showError('Onboarding failed: $e');
    }
  }

  // ── KYC ──

  void _handleKycFilterChange(String filter) {
    _kycFilter = filter;
    _loadKycQueue();
  }

  void _handleLoadMoreKyc() {
    _loadKycQueue(append: true);
  }

  Future<void> _handleApproveKyc(String kycId) async {
    try {
      await _service.reviewKyc(kycId: kycId, decision: 'APPROVE');
      _showSuccess('KYC submission approved');
      _loadKycQueue();
      _loadApprovedKycForOnboarding();
      _loadDashboard();
    } catch (e) {
      _showError('Failed to approve KYC: $e');
    }
  }

  Future<void> _handleRejectKyc(String kycId, String reason) async {
    try {
      await _service.reviewKyc(
          kycId: kycId, decision: 'REJECT', reason: reason);
      _showSuccess('KYC submission rejected');
      _loadKycQueue();
      _loadDashboard();
    } catch (e) {
      _showError('Failed to reject KYC: $e');
    }
  }

  Future<void> _handleBulkApproveKyc(List<String> kycIds) async {
    try {
      await _service.bulkKycAction(kycIds: kycIds, decision: 'APPROVE');
      _showSuccess('${kycIds.length} KYC submissions approved');
      _loadKycQueue();
      _loadApprovedKycForOnboarding();
      _loadDashboard();
    } catch (e) {
      _showError('Bulk approve failed: $e');
    }
  }

  Future<void> _handleBulkRejectKyc(
      List<String> kycIds, String reason) async {
    try {
      await _service.bulkKycAction(
          kycIds: kycIds, decision: 'REJECT', reason: reason);
      _showSuccess('${kycIds.length} KYC submissions rejected');
      _loadKycQueue();
      _loadDashboard();
    } catch (e) {
      _showError('Bulk reject failed: $e');
    }
  }

  // ── Loans ──

  void _handleLoanFilterChange(String filter) {
    _loanFilter = filter;
    _loadLoanQueue();
  }

  void _handleLoadMoreLoans() {
    _loadLoanQueue(append: true);
  }

  Future<void> _handleApproveLoan(String appId, double amount) async {
    try {
      await _service.reviewLoan(
          appId: appId, decision: 'APPROVE', amount: amount);
      _showSuccess('Loan application approved');
      _loadLoanQueue();
      _loadDashboard();
    } catch (e) {
      _showError('Failed to approve loan: $e');
    }
  }

  Future<void> _handleRejectLoan(String appId, String reason) async {
    try {
      await _service.reviewLoan(
          appId: appId, decision: 'REJECT', reason: reason);
      _showSuccess('Loan application rejected');
      _loadLoanQueue();
      _loadDashboard();
    } catch (e) {
      _showError('Failed to reject loan: $e');
    }
  }

  // ── Collections ──

  void _handleFilterCollectionsPar(String? parBucket) {
    _collectionsParFilter = parBucket;
    _loadCollectionsQueue();
  }

  void _handleFilterCollectionsStatus(String? status) {
    _collectionsStatusFilter = status;
    _loadCollectionsQueue();
  }

  void _handleLoadMoreCollections() {
    _loadCollectionsQueue(append: true);
  }

  Future<void> _handleLogCollectionAction(Map<String, dynamic> data) async {
    try {
      await _service.logCollectionAction(
        loanId: data['loan_id'] ?? '',
        actionType: data['action_type'] ?? '',
        notes: data['notes'],
        outcome: data['outcome'] ?? 'N/A',
        promiseDate: data['promise_date'],
        promiseAmount: data['promise_amount'] != null
            ? (data['promise_amount'] as num).toDouble()
            : null,
        nextActionDate: data['next_action_date'],
        nextActionType: data['next_action_type'],
      );
      _showSuccess('Collection action logged');
      _loadCollectionsDashboard();
      _loadCollectionsQueue();
    } catch (e) {
      _showError('Failed to log collection action: $e');
    }
  }

  Future<void> _handleWaivePenalty(Map<String, dynamic> data) async {
    try {
      await _service.waivePenalty(
        loanId: data['loan_id'] ?? '',
        amount: (data['amount'] as num).toDouble(),
        reason: data['reason'] ?? '',
      );
      _showSuccess('Penalty waived successfully');
      _loadCollectionsDashboard();
      _loadCollectionsQueue();
    } catch (e) {
      _showError('Failed to waive penalty: $e');
    }
  }

  // ── Audit ──

  Map<String, dynamic>? _lastAuditFilters;

  void _handleSearchAudit(Map<String, dynamic> filters) {
    _lastAuditFilters = filters;
    _loadAuditLog(filters: filters);
  }

  void _handleLoadMoreAudit() {
    _loadAuditLog(append: true, filters: _lastAuditFilters);
  }

  // ── Logout ──

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.supabaseClient.auth.signOut();
              widget.onLogout?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // UI HELPERS
  // ═══════════════════════════════════════════════════════════════════

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // Loading screen
    if (_initialLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings,
                    size: 40, color: _primaryColor),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: _primaryColor),
              const SizedBox(height: 16),
              Text(
                'Loading admin portal...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error screen
    if (_initialError != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Failed to load admin portal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _initialError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadInitialData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Main content
    return AdminAppHomeScreen(
      // Identity
      currentUserRole: widget.currentUserRole,
      staffName: widget.staffName,
      staffEmail: widget.staffEmail,
      // Dashboard
      dashboardData: _dashboardData,
      isDashboardLoading: _isDashboardLoading,
      onRefreshDashboard: _loadDashboard,
      // Staff
      staffList: _staffList,
      staffTotalCount: _staffTotalCount,
      isStaffLoading: _isStaffLoading,
      branches: _branches,
      onSearchStaff: _handleSearchStaff,
      onFilterStaffBranch: _handleFilterStaffBranch,
      onFilterStaffRole: _handleFilterStaffRole,
      onLoadMoreStaff: _handleLoadMoreStaff,
      onStaffTap: _handleStaffTap,
      onUpdateStaffRole: _handleUpdateStaffRole,
      onToggleStaffActive: _handleToggleStaffActive,
      // Staff Onboarding
      approvedKycSubmissions: _approvedKycSubmissions,
      isOnboardingLoading: _isOnboardingLoading,
      onSubmitOnboarding: _handleSubmitOnboarding,
      // KYC Review
      kycSubmissions: _kycSubmissions,
      kycTotalCount: _kycTotalCount,
      isKycLoading: _isKycLoading,
      kycCurrentFilter: _kycFilter,
      onKycFilterChange: _handleKycFilterChange,
      onLoadMoreKyc: _handleLoadMoreKyc,
      onApproveKyc: _handleApproveKyc,
      onRejectKyc: _handleRejectKyc,
      onBulkApproveKyc: _handleBulkApproveKyc,
      onBulkRejectKyc: _handleBulkRejectKyc,
      onRefreshKyc: () {
        _loadKycQueue();
      },
      // Loan Approval
      loanApplications: _loanApplications,
      loanTotalCount: _loanTotalCount,
      loanPendingValue: _loanPendingValue,
      isLoanLoading: _isLoanLoading,
      loanCurrentFilter: _loanFilter,
      onLoanFilterChange: _handleLoanFilterChange,
      onLoadMoreLoans: _handleLoadMoreLoans,
      onApproveLoan: _handleApproveLoan,
      onRejectLoan: _handleRejectLoan,
      onRefreshLoans: () {
        _loadLoanQueue();
      },
      // Audit Log
      auditEntries: _auditEntries,
      auditTotalCount: _auditTotalCount,
      isAuditLoading: _isAuditLoading,
      onSearchAudit: _handleSearchAudit,
      onLoadMoreAudit: _handleLoadMoreAudit,
      onRefreshAudit: () {
        _loadAuditLog(filters: _lastAuditFilters);
      },
      // Collections
      collectionsDashboard: _collectionsDashboard,
      collectionsQueue: _collectionsQueue,
      collectionsQueueTotal: _collectionsQueueTotal,
      isCollectionsLoading: _isCollectionsLoading,
      onRefreshCollections: () {
        _loadCollectionsDashboard();
        _loadCollectionsQueue();
      },
      onLoadCollectionsQueue: () => _loadCollectionsQueue(),
      onFilterCollectionsPar: _handleFilterCollectionsPar,
      onFilterCollectionsStatus: _handleFilterCollectionsStatus,
      onLoadMoreCollections: _handleLoadMoreCollections,
      onLogCollectionAction: _handleLogCollectionAction,
      onWaivePenalty: _handleWaivePenalty,
      // Global
      onLogout: _handleLogout,
    );
  }
}
