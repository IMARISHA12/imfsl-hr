import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL Admin Savings Management Dashboard.
///
/// Displays savings KPIs, product breakdowns, account list with search,
/// interest posting log, and configuration panel.
class ImfslSavingsManagement extends StatefulWidget {
  final Map<String, dynamic> savingsData;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Function(String)? onSearch;

  const ImfslSavingsManagement({
    super.key,
    this.savingsData = const {},
    this.isLoading = false,
    this.onRefresh,
    this.onSearch,
  });

  @override
  State<ImfslSavingsManagement> createState() =>
      _ImfslSavingsManagementState();
}

class _ImfslSavingsManagementState extends State<ImfslSavingsManagement>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF1565C0);
  static const Color _accent = Color(0xFF43A047);

  final NumberFormat _kes =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');
  final DateFormat _dateTimeFmt = DateFormat('dd MMM yyyy HH:mm');

  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _sortColumn = 'name';
  bool _sortAsc = true;
  bool _configEditing = false;

  // Editable config state
  String _accrualMethod = 'DAILY';
  double _minBalance = 500;
  int _postingDay = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initConfig();
  }

  void _initConfig() {
    final config = widget.savingsData['config'] as Map<String, dynamic>?;
    if (config != null) {
      _accrualMethod =
          config['accrual_method']?.toString() ?? 'DAILY';
      _minBalance =
          (config['min_balance'] as num?)?.toDouble() ?? 500;
      _postingDay = (config['posting_day'] as int?) ?? 1;
    }
  }

  @override
  void didUpdateWidget(covariant ImfslSavingsManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.savingsData != oldWidget.savingsData) _initConfig();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> get _kpi =>
      widget.savingsData['kpi'] as Map<String, dynamic>? ?? {};

  List<Map<String, dynamic>> get _products =>
      (widget.savingsData['products'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> get _accounts {
    final raw =
        (widget.savingsData['accounts'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];

    var filtered = raw.toList();

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((a) {
        final name = (a['customer_name']?.toString() ?? '').toLowerCase();
        final acct = (a['account_number']?.toString() ?? '').toLowerCase();
        return name.contains(q) || acct.contains(q);
      }).toList();
    }

    // Status filter
    if (_statusFilter != 'ALL') {
      filtered = filtered
          .where((a) => a['status']?.toString() == _statusFilter)
          .toList();
    }

    // Sort
    filtered.sort((a, b) {
      final aVal = a[_sortColumn]?.toString() ?? '';
      final bVal = b[_sortColumn]?.toString() ?? '';
      if (_sortColumn == 'balance' || _sortColumn == 'accrued_interest') {
        final an = double.tryParse(aVal) ?? 0;
        final bn = double.tryParse(bVal) ?? 0;
        return _sortAsc ? an.compareTo(bn) : bn.compareTo(an);
      }
      return _sortAsc ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    });

    return filtered;
  }

  List<Map<String, dynamic>> get _interestLog =>
      (widget.savingsData['interest_log'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Savings Management'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.isLoading ? null : widget.onRefresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 18)),
            Tab(text: 'Accounts', icon: Icon(Icons.people, size: 18)),
            Tab(text: 'Config', icon: Icon(Icons.settings, size: 18)),
          ],
        ),
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAccountsTab(),
                _buildConfigTab(),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Overview
  // ---------------------------------------------------------------------------

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildKPICards(),
        const SizedBox(height: 16),
        _sectionHeader('Product Breakdown'),
        const SizedBox(height: 8),
        ..._products.map(_buildProductCard),
        const SizedBox(height: 16),
        _sectionHeader('Recent Interest Postings'),
        const SizedBox(height: 8),
        _buildInterestLog(),
      ],
    );
  }

  Widget _buildKPICards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: [
        _kpiCard(
          'Total Accounts',
          '${_kpi['total_accounts'] ?? 0}',
          Icons.account_balance,
          _primary,
        ),
        _kpiCard(
          'Total Deposits',
          _kes.format((_kpi['total_deposits'] as num?)?.toDouble() ?? 0),
          Icons.savings,
          _accent,
        ),
        _kpiCard(
          'Interest Accrued',
          _kes.format(
              (_kpi['interest_accrued'] as num?)?.toDouble() ?? 0),
          Icons.trending_up,
          const Color(0xFFFF8F00),
        ),
        _kpiCard(
          'Dormant Accounts',
          '${_kpi['dormant_accounts'] ?? 0}',
          Icons.snooze,
          const Color(0xFFE53935),
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final name = product['name']?.toString() ?? 'Unknown';
    final count = product['count'] ?? 0;
    final totalBalance =
        (product['total_balance'] as num?)?.toDouble() ?? 0;
    final avgBalance =
        (product['avg_balance'] as num?)?.toDouble() ?? 0;
    final rate =
        (product['interest_rate'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _primary.withOpacity(0.1),
                  child: Icon(Icons.savings, color: _primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('$count accounts  |  ${rate.toStringAsFixed(1)}% p.a.',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _productStat('Total Balance', _kes.format(totalBalance)),
                _productStat('Avg Balance', _kes.format(avgBalance)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _productStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInterestLog() {
    final log = _interestLog;
    if (log.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('No recent interest postings',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: const [
                Expanded(
                    flex: 3,
                    child: Text('Account',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey))),
                Expanded(
                    flex: 2,
                    child: Text('Amount',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey))),
                Expanded(
                    flex: 3,
                    child: Text('Date',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey))),
              ],
            ),
          ),
          ...log.map((entry) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                            entry['account_number']?.toString() ?? '-',
                            style: const TextStyle(fontSize: 12))),
                    Expanded(
                        flex: 2,
                        child: Text(
                          _kes.format(
                              (entry['amount'] as num?)?.toDouble() ?? 0),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF43A047)),
                        )),
                    Expanded(
                        flex: 3,
                        child: Text(
                          _formatDate(entry['posted_at']?.toString()),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Accounts
  // ---------------------------------------------------------------------------

  Widget _buildAccountsTab() {
    final accounts = _accounts;

    return Column(
      children: [
        _buildSearchBar(),
        _buildStatusFilterRow(),
        _buildSortRow(),
        Expanded(
          child: accounts.isEmpty
              ? _emptyState('No accounts found')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: accounts.length,
                  itemBuilder: (ctx, i) => _buildAccountRow(accounts[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Search by name or account number...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                    widget.onSearch?.call('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        onChanged: (v) {
          setState(() => _searchQuery = v);
          widget.onSearch?.call(v);
        },
      ),
    );
  }

  Widget _buildStatusFilterRow() {
    const statuses = ['ALL', 'ACTIVE', 'DORMANT', 'FROZEN', 'CLOSED'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses.map((s) {
            final selected = _statusFilter == s;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(s,
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            selected ? Colors.white : Colors.black87)),
                selected: selected,
                selectedColor: _primary,
                checkmarkColor: Colors.white,
                onSelected: (_) =>
                    setState(() => _statusFilter = s),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: Row(
        children: [
          const Text('Sort: ', style: TextStyle(fontSize: 12)),
          DropdownButton<String>(
            value: _sortColumn,
            isDense: true,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                  value: 'name', child: Text('Customer Name')),
              DropdownMenuItem(
                  value: 'account_number', child: Text('Account #')),
              DropdownMenuItem(
                  value: 'balance', child: Text('Balance')),
              DropdownMenuItem(
                  value: 'accrued_interest',
                  child: Text('Accrued Interest')),
              DropdownMenuItem(
                  value: 'last_activity', child: Text('Last Activity')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _sortColumn = v);
            },
          ),
          IconButton(
            icon: Icon(
                _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 18),
            onPressed: () =>
                setState(() => _sortAsc = !_sortAsc),
          ),
          const Spacer(),
          Text('${_accounts.length} accounts',
              style:
                  const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAccountRow(Map<String, dynamic> acct) {
    final status = acct['status']?.toString() ?? 'ACTIVE';
    final statusColor = _statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: _primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          acct['customer_name']?.toString() ?? 'Unknown',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      Text(
                          acct['account_number']?.toString() ?? '-',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _acctStat(
                    'Product',
                    acct['product']?.toString() ?? '-'),
                _acctStat(
                    'Balance',
                    _kes.format(
                        (acct['balance'] as num?)?.toDouble() ?? 0)),
                _acctStat(
                    'Accrued Int.',
                    _kes.format(
                        (acct['accrued_interest'] as num?)?.toDouble() ??
                            0)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Last Activity: ${_formatDate(acct['last_activity']?.toString())}',
              style:
                  const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _acctStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFF43A047);
      case 'DORMANT':
        return const Color(0xFFFF8F00);
      case 'FROZEN':
        return const Color(0xFF1565C0);
      case 'CLOSED':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Config
  // ---------------------------------------------------------------------------

  Widget _buildConfigTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('Interest Configuration'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.settings, size: 20, color: _primary),
                    const SizedBox(width: 8),
                    const Expanded(
                        child: Text('Savings Settings',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14))),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _configEditing = !_configEditing),
                      icon: Icon(
                          _configEditing ? Icons.close : Icons.edit,
                          size: 16),
                      label:
                          Text(_configEditing ? 'Cancel' : 'Edit'),
                    ),
                  ],
                ),
                const Divider(),
                _configRow(
                  'Accrual Method',
                  _accrualMethod,
                  _configEditing
                      ? DropdownButton<String>(
                          value: _accrualMethod,
                          isDense: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                                value: 'DAILY',
                                child: Text('Daily')),
                            DropdownMenuItem(
                                value: 'MONTHLY',
                                child: Text('Monthly')),
                            DropdownMenuItem(
                                value: 'QUARTERLY',
                                child: Text('Quarterly')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _accrualMethod = v);
                            }
                          },
                        )
                      : null,
                ),
                _configRow(
                  'Minimum Balance',
                  _kes.format(_minBalance),
                  _configEditing
                      ? SizedBox(
                          width: 120,
                          child: TextField(
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                                text: _minBalance.toStringAsFixed(0)),
                            onChanged: (v) {
                              final parsed = double.tryParse(v);
                              if (parsed != null) _minBalance = parsed;
                            },
                          ),
                        )
                      : null,
                ),
                _configRow(
                  'Interest Posting Day',
                  'Day $_postingDay of month',
                  _configEditing
                      ? SizedBox(
                          width: 80,
                          child: TextField(
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                                text: _postingDay.toString()),
                            onChanged: (v) {
                              final parsed = int.tryParse(v);
                              if (parsed != null &&
                                  parsed >= 1 &&
                                  parsed <= 28) {
                                _postingDay = parsed;
                              }
                            },
                          ),
                        )
                      : null,
                ),
                if (_configEditing) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saveConfig,
                      style: FilledButton.styleFrom(
                          backgroundColor: _primary),
                      child: const Text('Save Configuration'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionHeader('Configuration Notes'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _noteRow(Icons.info_outline,
                    'Accrual runs nightly at 2:00 AM EAT'),
                const SizedBox(height: 8),
                _noteRow(Icons.info_outline,
                    'Interest is posted on the configured day each month'),
                const SizedBox(height: 8),
                _noteRow(Icons.info_outline,
                    'Accounts below minimum balance do not earn interest'),
                const SizedBox(height: 8),
                _noteRow(Icons.warning_amber,
                    'Dormant accounts: no activity for 6+ months'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _configRow(String label, String value, Widget? editor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(label,
                  style: const TextStyle(fontSize: 13))),
          Expanded(
            flex: 3,
            child: editor ??
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  Widget _noteRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey))),
      ],
    );
  }

  void _saveConfig() {
    setState(() => _configEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration saved successfully'),
        backgroundColor: Color(0xFF43A047),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Common helpers
  // ---------------------------------------------------------------------------

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121))),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      return _dateTimeFmt.format(dt);
    } catch (_) {
      return iso;
    }
  }
}
