import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Admin M-Pesa Reconciliation Dashboard
///
/// 3-tab layout: All Transactions | Unreconciled | Failed
/// Summary cards, search, date filtering, manual reconcile action.
///
/// Usage:
///   ImfslMpesaReconciliation(
///     onGetDashboard: service.getMpesaDashboard,
///     onManualReconcile: service.mpesaManualReconcile,
///     onSearch: service.mpesaSearchTransactions,
///   )
class ImfslMpesaReconciliation extends StatefulWidget {
  final Future<Map<String, dynamic>> Function({
    String? status,
    String? fromDate,
    String? toDate,
    int limit,
    int offset,
  })? onGetDashboard;

  final Future<Map<String, dynamic>> Function({
    required String transactionId,
    required String appliedToType,
    required String appliedToId,
  })? onManualReconcile;

  final Future<List<Map<String, dynamic>>> Function(String query)? onSearch;
  final VoidCallback? onBack;

  const ImfslMpesaReconciliation({
    super.key,
    this.onGetDashboard,
    this.onManualReconcile,
    this.onSearch,
    this.onBack,
  });

  @override
  State<ImfslMpesaReconciliation> createState() =>
      _ImfslMpesaReconciliationState();
}

class _ImfslMpesaReconciliationState extends State<ImfslMpesaReconciliation>
    with SingleTickerProviderStateMixin {
  static const Color _primaryColor = Color(0xFF1565C0);
  static const Color _successGreen = Color(0xFF4CAF50);
  static const Color _warningOrange = Color(0xFFFF9800);
  static const Color _errorRed = Color(0xFFF44336);

  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _searchResults = [];

  // Filters
  DateTimeRange? _dateRange;
  int _offset = 0;
  static const int _pageSize = 50;

  // Auto-refresh
  bool _autoRefresh = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadDashboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _offset = 0;
      _loadDashboard();
    }
  }

  String? get _currentStatusFilter {
    switch (_tabController.index) {
      case 1:
        return 'COMPLETED'; // Unreconciled tab filters for COMPLETED + NONE applied_to
      case 2:
        return 'FAILED';
      default:
        return null;
    }
  }

  // ─── DATA LOADING ───

  Future<void> _loadDashboard() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.onGetDashboard != null) {
        final result = await widget.onGetDashboard!(
          status: _currentStatusFilter,
          fromDate: _dateRange?.start.toIso8601String().substring(0, 10),
          toDate: _dateRange?.end.toIso8601String().substring(0, 10),
          limit: _pageSize,
          offset: _offset,
        );
        if (!mounted) return;
        setState(() {
          _stats = (result['stats'] as Map<String, dynamic>?) ?? {};
          _allTransactions = _parseList(result['transactions']);
          _isLoading = false;
        });
      } else {
        // Demo data
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        setState(() {
          _stats = {
            'total_count': 156,
            'completed_count': 120,
            'failed_count': 18,
            'pending_count': 8,
            'expired_count': 10,
            'total_amount': 2450000,
            'unreconciled_count': 5,
          };
          _allTransactions = List.generate(
            10,
            (i) => {
              final statuses = ['COMPLETED', 'FAILED', 'INITIATED', 'EXPIRED'];
              return {
                'id': 'txn-${1000 + i}',
                'phone_number': '2547${10000000 + i}',
                'amount': (1000 + i * 500).toDouble(),
                'purpose': i % 2 == 0 ? 'LOAN_REPAYMENT' : 'DEPOSIT',
                'mpesa_receipt_number': i < 7 ? 'REC${100 + i}ABC' : null,
                'status': statuses[i % statuses.length],
                'applied_to_type': i < 5 ? 'LOAN_REPAYMENT' : (i < 7 ? 'NONE' : null),
                'reconciled_at': i < 5 ? '2026-03-01T10:00:00Z' : null,
                'reconciliation_type': i < 5 ? 'AUTO' : null,
                'created_at': '2026-03-01T${(8 + i).toString().padLeft(2, '0')}:00:00Z',
                'customer_name': 'Customer ${i + 1}',
                'customer_phone': '2547${10000000 + i}',
              };
            },
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _searchTransactions(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      if (widget.onSearch != null) {
        final results = await widget.onSearch!(query.trim());
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        setState(() {
          _searchResults = _allTransactions
              .where((t) =>
                  (t['mpesa_receipt_number'] ?? '').toString().contains(query) ||
                  (t['phone_number'] ?? '').toString().contains(query))
              .toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  Future<void> _performManualReconcile(
    String transactionId,
    String appliedToType,
    String appliedToId,
  ) async {
    try {
      if (widget.onManualReconcile != null) {
        await widget.onManualReconcile!(
          transactionId: transactionId,
          appliedToType: appliedToType,
          appliedToId: appliedToId,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction reconciled successfully'),
          backgroundColor: _successGreen,
        ),
      );
      _loadDashboard();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reconciliation failed: $e'),
          backgroundColor: _errorRed,
        ),
      );
    }
  }

  void _toggleAutoRefresh() {
    setState(() => _autoRefresh = !_autoRefresh);
    if (_autoRefresh) {
      _refreshTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _loadDashboard(),
      );
    } else {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _offset = 0;
      });
      _loadDashboard();
    }
  }

  // ─── HELPERS ───

  String _formatCurrency(dynamic value) {
    if (value == null) return _currencyFormat.format(0);
    final num parsed =
        value is num ? value : num.tryParse(value.toString()) ?? 0;
    return _currencyFormat.format(parsed);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt.toLocal());
    } catch (_) {
      return dateStr;
    }
  }

  String _shortDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      return DateFormat('dd MMM HH:mm').format(DateTime.parse(dateStr).toLocal());
    } catch (_) {
      return dateStr;
    }
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) {
      return data
          .map((e) =>
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return _successGreen;
      case 'FAILED':
      case 'CANCELLED':
        return _errorRed;
      case 'INITIATED':
      case 'PROCESSING':
        return _warningOrange;
      case 'EXPIRED':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'FAILED':
        return Icons.cancel;
      case 'INITIATED':
      case 'PROCESSING':
        return Icons.hourglass_top;
      case 'EXPIRED':
        return Icons.timer_off;
      default:
        return Icons.help_outline;
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_searchController.text.isNotEmpty && _searchResults.isNotEmpty) {
      return _searchResults;
    }
    if (_tabController.index == 1) {
      return _allTransactions
          .where((t) =>
              t['status'] == 'COMPLETED' &&
              (t['applied_to_type'] == null || t['applied_to_type'] == 'NONE'))
          .toList();
    }
    return _allTransactions;
  }

  // ─── BUILD ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'M-Pesa Reconciliation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_autoRefresh ? Icons.sync : Icons.sync_disabled),
            tooltip: _autoRefresh ? 'Auto-refresh ON' : 'Auto-refresh OFF',
            onPressed: _toggleAutoRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadDashboard,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unreconciled'),
            Tab(text: 'Failed'),
          ],
        ),
      ),
      body: _isLoading && _allTransactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _allTransactions.isEmpty
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildSummaryCards()),
                      SliverToBoxAdapter(child: _buildSearchAndFilterBar()),
                      if (_isLoading)
                        const SliverToBoxAdapter(
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                      _buildTransactionList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: _errorRed),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SUMMARY CARDS ───

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Volume',
                  value: _formatCurrency(_stats['total_amount']),
                  icon: Icons.account_balance_wallet,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Success Rate',
                  value: _successRate,
                  icon: Icons.trending_up,
                  color: _successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Unreconciled',
                  value: '${_stats['unreconciled_count'] ?? 0}',
                  icon: Icons.warning_amber,
                  color: _warningOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Failed',
                  value: '${_stats['failed_count'] ?? 0}',
                  icon: Icons.cancel_outlined,
                  color: _errorRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _successRate {
    final total = (_stats['total_count'] as num?)?.toInt() ?? 0;
    final completed = (_stats['completed_count'] as num?)?.toInt() ?? 0;
    if (total == 0) return '—';
    return '${((completed / total) * 100).toStringAsFixed(1)}%';
  }

  // ─── SEARCH & FILTER BAR ───

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search receipt, phone, amount...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: _searchTransactions,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.date_range, size: 16),
            label: Text(
              _dateRange != null
                  ? '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}'
                  : 'Dates',
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: _pickDateRange,
          ),
          if (_dateRange != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                setState(() => _dateRange = null);
                _loadDashboard();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  // ─── TRANSACTION LIST ───

  Widget _buildTransactionList() {
    final transactions = _filteredTransactions;
    if (transactions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                _tabController.index == 1
                    ? 'No unreconciled transactions'
                    : _tabController.index == 2
                        ? 'No failed transactions'
                        : 'No transactions found',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= transactions.length) return null;
          return _buildTransactionTile(transactions[index]);
        },
        childCount: transactions.length,
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> txn) {
    final status = txn['status']?.toString() ?? 'UNKNOWN';
    final isUnreconciled = status == 'COMPLETED' &&
        (txn['applied_to_type'] == null || txn['applied_to_type'] == 'NONE');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showTransactionDetail(txn),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_statusIcon(status),
                    color: _statusColor(status), size: 22),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            txn['mpesa_receipt_number']?.toString() ??
                                txn['checkout_request_id']?.toString() ??
                                'Pending...',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatCurrency(txn['amount']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          txn['customer_name']?.toString() ??
                              txn['phone_number']?.toString() ??
                              '—',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _shortDate(txn['created_at']?.toString()),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildChip(status, _statusColor(status)),
                        const SizedBox(width: 6),
                        _buildChip(
                          txn['purpose']?.toString() ?? '—',
                          Colors.blueGrey,
                        ),
                        if (isUnreconciled) ...[
                          const SizedBox(width: 6),
                          _buildChip('NEEDS ACTION', _warningOrange),
                        ],
                        if (txn['reconciliation_type'] != null) ...[
                          const SizedBox(width: 6),
                          _buildChip(
                            txn['reconciliation_type'].toString(),
                            _primaryColor,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ─── TRANSACTION DETAIL SHEET ───

  void _showTransactionDetail(Map<String, dynamic> txn) {
    final status = txn['status']?.toString() ?? 'UNKNOWN';
    final isUnreconciled = status == 'COMPLETED' &&
        (txn['applied_to_type'] == null || txn['applied_to_type'] == 'NONE');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  Icon(_statusIcon(status),
                      color: _statusColor(status), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: _statusColor(status),
                          ),
                        ),
                        if (txn['mpesa_receipt_number'] != null)
                          Text(
                            'Receipt: ${txn['mpesa_receipt_number']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(txn['amount']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              // Detail rows
              _detailRow('Transaction ID', txn['id']?.toString()),
              _detailRow('Phone Number', txn['phone_number']?.toString()),
              _detailRow(
                  'Customer', txn['customer_name']?.toString()),
              _detailRow('Purpose', txn['purpose']?.toString()),
              _detailRow('Created', _formatDate(txn['created_at']?.toString())),
              _detailRow('Callback Received',
                  _formatDate(txn['callback_received_at']?.toString())),
              _detailRow('Result', txn['result_desc']?.toString()),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Reconciliation',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              _detailRow('Type', txn['reconciliation_type']?.toString()),
              _detailRow(
                  'Applied To', txn['applied_to_type']?.toString()),
              _detailRow('Applied ID', txn['applied_to_id']?.toString()),
              _detailRow(
                  'Reconciled At',
                  _formatDate(txn['reconciled_at']?.toString())),

              // Manual reconcile button
              if (isUnreconciled) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _showManualReconcileDialog(txn);
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('Manual Reconcile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─── MANUAL RECONCILE DIALOG ───

  void _showManualReconcileDialog(Map<String, dynamic> txn) {
    String? appliedToType;
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Manual Reconcile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apply ${_formatCurrency(txn['amount'])} to:',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: appliedToType,
                decoration: const InputDecoration(
                  labelText: 'Payment Type',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'LOAN_REPAYMENT',
                    child: Text('Loan Repayment'),
                  ),
                  DropdownMenuItem(
                    value: 'SAVINGS_DEPOSIT',
                    child: Text('Savings Deposit'),
                  ),
                ],
                onChanged: (v) => setDialogState(() => appliedToType = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: appliedToType == 'LOAN_REPAYMENT'
                      ? 'Loan ID'
                      : 'Savings Account ID',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  hintText: 'Enter UUID',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: appliedToType != null && idController.text.isNotEmpty
                  ? () {
                      Navigator.of(ctx).pop();
                      _performManualReconcile(
                        txn['id'].toString(),
                        appliedToType!,
                        idController.text.trim(),
                      );
                    }
                  : null,
              style:
                  ElevatedButton.styleFrom(backgroundColor: _primaryColor),
              child: const Text('Reconcile'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STAT CARD WIDGET ───

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
