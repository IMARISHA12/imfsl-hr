import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL Branch Performance Analytics Dashboard.
///
/// Provides overview comparison of all branches and drill-down detail
/// for individual branches including KPIs, staff leaderboard, trends,
/// and top overdue loans.
class ImfslBranchPerformance extends StatefulWidget {
  final Map<String, dynamic> dashboardData;
  final Map<String, dynamic> branchDetail;
  final Map<String, dynamic> trendData;
  final bool isLoading;
  final String? selectedBranch;
  final Function(String?)? onSelectBranch;
  final VoidCallback? onRefresh;
  final Function(String)? onLoadDetail;
  final Function(String)? onLoadTrend;

  const ImfslBranchPerformance({
    super.key,
    this.dashboardData = const {},
    this.branchDetail = const {},
    this.trendData = const {},
    this.isLoading = false,
    this.selectedBranch,
    this.onSelectBranch,
    this.onRefresh,
    this.onLoadDetail,
    this.onLoadTrend,
  });

  @override
  State<ImfslBranchPerformance> createState() =>
      _ImfslBranchPerformanceState();
}

class _ImfslBranchPerformanceState extends State<ImfslBranchPerformance>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF1565C0);

  final NumberFormat _kes =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final NumberFormat _numFmt = NumberFormat('#,##0');
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');

  String? _selectedBranch;
  late TabController _detailTabController;
  String _sortColumn = 'name';
  bool _sortAsc = true;

  static const List<Color> _branchColors = [
    Color(0xFF1565C0),
    Color(0xFF43A047),
    Color(0xFFFF8F00),
    Color(0xFFE53935),
    Color(0xFF7B1FA2),
    Color(0xFF00897B),
    Color(0xFF5D4037),
    Color(0xFFC62828),
  ];

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.selectedBranch;
    _detailTabController = TabController(length: 4, vsync: this);
  }

  @override
  void didUpdateWidget(covariant ImfslBranchPerformance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedBranch != oldWidget.selectedBranch) {
      setState(() => _selectedBranch = widget.selectedBranch);
    }
  }

  @override
  void dispose() {
    _detailTabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data helpers
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> get _branches {
    final raw =
        (widget.dashboardData['branches'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];

    final sorted = raw.toList();
    sorted.sort((a, b) {
      final aVal = a[_sortColumn]?.toString() ?? '';
      final bVal = b[_sortColumn]?.toString() ?? '';

      if ({'total_loans', 'outstanding', 'par_ratio',
            'collection_rate', 'customers'}
          .contains(_sortColumn)) {
        final an = double.tryParse(aVal) ?? 0;
        final bn = double.tryParse(bVal) ?? 0;
        return _sortAsc ? an.compareTo(bn) : bn.compareTo(an);
      }
      return _sortAsc ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    });
    return sorted;
  }

  List<String> get _branchNames =>
      _branches.map((b) => b['name']?.toString() ?? '').toList();

  Map<String, dynamic> get _detail => widget.branchDetail;

  List<Map<String, dynamic>> get _detailProducts =>
      (_detail['products'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> get _staffLeaderboard =>
      (_detail['staff_leaderboard'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> get _topOverdue =>
      (_detail['top_overdue'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> _trendSeries(String key) =>
      (widget.trendData[key] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  void _selectBranch(String? branch) {
    setState(() => _selectedBranch = branch);
    widget.onSelectBranch?.call(branch);
    if (branch != null) {
      widget.onLoadDetail?.call(branch);
      widget.onLoadTrend?.call(branch);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(_selectedBranch != null
            ? '$_selectedBranch Branch'
            : 'Branch Performance'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 1,
        leading: _selectedBranch != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _selectBranch(null),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.isLoading ? null : widget.onRefresh,
          ),
        ],
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedBranch == null
              ? _buildOverview()
              : _buildBranchDetail(),
    );
  }

  // ---------------------------------------------------------------------------
  // Overview mode
  // ---------------------------------------------------------------------------

  Widget _buildOverview() {
    final branches = _branches;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildBranchSelector(),
        const SizedBox(height: 12),
        _sectionHeader('Branch Comparison'),
        const SizedBox(height: 8),
        _buildSortRow(),
        _buildComparisonTable(branches),
        const SizedBox(height: 16),
        _sectionHeader('Disbursement Volume by Branch'),
        const SizedBox(height: 8),
        _buildDisbursementChart(branches),
        const SizedBox(height: 16),
        _sectionHeader('Performance Summary'),
        const SizedBox(height: 8),
        _buildOverviewKPIs(branches),
      ],
    );
  }

  Widget _buildBranchSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.store, color: _primary, size: 20),
            const SizedBox(width: 8),
            const Text('Select Branch:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String?>(
                value: _selectedBranch,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('All Branches'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Branches'),
                  ),
                  ..._branchNames.map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      )),
                ],
                onChanged: _selectBranch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text('Sort: ', style: TextStyle(fontSize: 12)),
          DropdownButton<String>(
            value: _sortColumn,
            isDense: true,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(
                  value: 'total_loans', child: Text('Total Loans')),
              DropdownMenuItem(
                  value: 'outstanding', child: Text('Outstanding')),
              DropdownMenuItem(
                  value: 'par_ratio', child: Text('PAR Ratio')),
              DropdownMenuItem(
                  value: 'collection_rate',
                  child: Text('Collection Rate')),
              DropdownMenuItem(
                  value: 'customers', child: Text('Customers')),
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
        ],
      ),
    );
  }

  Widget _buildComparisonTable(List<Map<String, dynamic>> branches) {
    if (branches.isEmpty) return _emptyState('No branch data');

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(_primary.withOpacity(0.05)),
          columnSpacing: 16,
          horizontalMargin: 12,
          headingTextStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey),
          dataTextStyle: const TextStyle(fontSize: 12),
          columns: const [
            DataColumn(label: Text('Branch')),
            DataColumn(label: Text('Loans'), numeric: true),
            DataColumn(label: Text('Outstanding'), numeric: true),
            DataColumn(label: Text('PAR %'), numeric: true),
            DataColumn(label: Text('Collection %'), numeric: true),
            DataColumn(label: Text('Customers'), numeric: true),
            DataColumn(label: Text('Trend')),
          ],
          rows: branches.asMap().entries.map((entry) {
            final i = entry.key;
            final b = entry.value;
            final color = _branchColors[i % _branchColors.length];
            final parRatio =
                (b['par_ratio'] as num?)?.toDouble() ?? 0;
            final collRate =
                (b['collection_rate'] as num?)?.toDouble() ?? 0;

            return DataRow(
              onSelectChanged: (_) =>
                  _selectBranch(b['name']?.toString()),
              cells: [
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(b['name']?.toString() ?? '',
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )),
                DataCell(Text('${b['total_loans'] ?? 0}')),
                DataCell(Text(_kes.format(
                    (b['outstanding'] as num?)?.toDouble() ?? 0))),
                DataCell(Text(
                  '${parRatio.toStringAsFixed(1)}%',
                  style: TextStyle(
                      color: parRatio > 10
                          ? const Color(0xFFE53935)
                          : const Color(0xFF43A047),
                      fontWeight: FontWeight.w600),
                )),
                DataCell(Text(
                  '${collRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                      color: collRate >= 90
                          ? const Color(0xFF43A047)
                          : const Color(0xFFFF8F00),
                      fontWeight: FontWeight.w600),
                )),
                DataCell(Text('${b['customers'] ?? 0}')),
                DataCell(_buildSparkline(
                    b['trend'] as List<dynamic>? ?? [], color)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSparkline(List<dynamic> data, Color color) {
    if (data.isEmpty) return const SizedBox(width: 50);
    final values = data.map((v) => (v as num).toDouble()).toList();
    final maxVal =
        values.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);

    return SizedBox(
      width: 50,
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              height: (v / maxVal * 18).clamp(2, 18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(1)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisbursementChart(List<Map<String, dynamic>> branches) {
    if (branches.isEmpty) return const SizedBox();

    final maxDisbursed = branches.fold<double>(0, (m, b) {
      final v = (b['disbursed'] as num?)?.toDouble() ?? 0;
      return v > m ? v : m;
    }).clamp(1, double.infinity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: branches.asMap().entries.map((entry) {
            final i = entry.key;
            final b = entry.value;
            final disbursed =
                (b['disbursed'] as num?)?.toDouble() ?? 0;
            final fraction = disbursed / maxDisbursed;
            final color = _branchColors[i % _branchColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      b['name']?.toString() ?? '',
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: fraction.clamp(0.02, 1.0),
                          child: Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.only(right: 6),
                            child: Text(
                              _kes.format(disbursed),
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOverviewKPIs(List<Map<String, dynamic>> branches) {
    double totalOutstanding = 0;
    int totalLoans = 0;
    int totalCustomers = 0;
    double sumPar = 0;

    for (final b in branches) {
      totalOutstanding +=
          (b['outstanding'] as num?)?.toDouble() ?? 0;
      totalLoans += (b['total_loans'] as int?) ?? 0;
      totalCustomers += (b['customers'] as int?) ?? 0;
      sumPar += (b['par_ratio'] as num?)?.toDouble() ?? 0;
    }
    final avgPar =
        branches.isNotEmpty ? sumPar / branches.length : 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _kpiCard('Total Branches', '${branches.length}',
            Icons.store, _primary),
        _kpiCard('Total Loans', _numFmt.format(totalLoans),
            Icons.receipt_long, const Color(0xFF00897B)),
        _kpiCard('Total Outstanding', _kes.format(totalOutstanding),
            Icons.account_balance_wallet, const Color(0xFFE53935)),
        _kpiCard(
            'Avg PAR',
            '${avgPar.toStringAsFixed(1)}%',
            Icons.warning_amber,
            avgPar > 10
                ? const Color(0xFFE53935)
                : const Color(0xFF43A047)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Branch detail mode
  // ---------------------------------------------------------------------------

  Widget _buildBranchDetail() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _detailTabController,
            labelColor: _primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: _primary,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Products'),
              Tab(text: 'Staff'),
              Tab(text: 'Trends'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _detailTabController,
            children: [
              _buildDetailOverview(),
              _buildDetailProducts(),
              _buildDetailStaff(),
              _buildDetailTrends(),
            ],
          ),
        ),
      ],
    );
  }

  // --- Detail Overview ---

  Widget _buildDetailOverview() {
    final kpi = _detail['kpi'] as Map<String, dynamic>? ?? {};

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildDetailKPIs(kpi),
        const SizedBox(height: 16),
        _sectionHeader('Collection Efficiency'),
        const SizedBox(height: 8),
        _buildCollectionEfficiency(kpi),
        const SizedBox(height: 16),
        _sectionHeader('Top Overdue Loans'),
        const SizedBox(height: 8),
        ..._topOverdue.map(_buildOverdueLoanCard),
        if (_topOverdue.isEmpty)
          _emptyState('No overdue loans'),
      ],
    );
  }

  Widget _buildDetailKPIs(Map<String, dynamic> kpi) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: [
        _kpiCard('Active Loans', '${kpi['active_loans'] ?? 0}',
            Icons.receipt_long, _primary),
        _kpiCard(
            'Outstanding',
            _kes.format(
                (kpi['outstanding'] as num?)?.toDouble() ?? 0),
            Icons.account_balance_wallet,
            const Color(0xFFE53935)),
        _kpiCard(
            'PAR > 30',
            '${((kpi['par_gt_30'] as num?)?.toDouble() ?? 0).toStringAsFixed(1)}%',
            Icons.warning_amber,
            const Color(0xFFFF8F00)),
        _kpiCard(
            'Customers',
            '${kpi['total_customers'] ?? 0}',
            Icons.people,
            const Color(0xFF00897B)),
        _kpiCard(
            'Disbursed (Month)',
            _kes.format(
                (kpi['disbursed_month'] as num?)?.toDouble() ?? 0),
            Icons.send,
            const Color(0xFF43A047)),
        _kpiCard(
            'Collected (Month)',
            _kes.format(
                (kpi['collected_month'] as num?)?.toDouble() ?? 0),
            Icons.payments,
            const Color(0xFF7B1FA2)),
      ],
    );
  }

  Widget _buildCollectionEfficiency(Map<String, dynamic> kpi) {
    final target =
        (kpi['collection_target'] as num?)?.toDouble() ?? 100;
    final actual =
        (kpi['collection_actual'] as num?)?.toDouble() ?? 0;
    final rate = target > 0 ? (actual / target * 100) : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Collection Rate',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text(
                          '${rate.toStringAsFixed(1)}% of target',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Text(
                  '${rate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: rate >= 90
                        ? const Color(0xFF43A047)
                        : rate >= 70
                            ? const Color(0xFFFF8F00)
                            : const Color(0xFFE53935),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (rate / 100).clamp(0, 1),
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  rate >= 90
                      ? const Color(0xFF43A047)
                      : rate >= 70
                          ? const Color(0xFFFF8F00)
                          : const Color(0xFFE53935),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Target: ${_kes.format(target)}',
                    style: const TextStyle(fontSize: 11)),
                Text('Actual: ${_kes.format(actual)}',
                    style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueLoanCard(Map<String, dynamic> loan) {
    final daysOverdue = loan['days_overdue'] ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFFE53935).withOpacity(0.1),
          child: const Icon(Icons.person,
              color: Color(0xFFE53935), size: 18),
        ),
        title: Text(loan['customer_name']?.toString() ?? 'Unknown',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(
          'Loan# ${loan['loan_number'] ?? '-'}  |  $daysOverdue days overdue',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Text(
          _kes.format(
              (loan['outstanding'] as num?)?.toDouble() ?? 0),
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFFE53935)),
        ),
      ),
    );
  }

  // --- Detail Products ---

  Widget _buildDetailProducts() {
    final products = _detailProducts;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('Loan Products'),
        const SizedBox(height: 8),
        if (products.isEmpty)
          _emptyState('No product data')
        else
          ...products.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final color = _branchColors[i % _branchColors.length];
            return _buildProductCard(p, color);
          }),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      product['name']?.toString() ?? 'Unknown',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCol('Active Loans',
                    '${product['active_loans'] ?? 0}'),
                _statCol(
                    'Outstanding',
                    _kes.format(
                        (product['outstanding'] as num?)?.toDouble() ??
                            0)),
                _statCol(
                    'PAR',
                    '${((product['par_ratio'] as num?)?.toDouble() ?? 0).toStringAsFixed(1)}%'),
                _statCol(
                    'Disbursed',
                    _kes.format(
                        (product['disbursed'] as num?)?.toDouble() ??
                            0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600)),
        Text(label,
            style:
                const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  // --- Detail Staff ---

  Widget _buildDetailStaff() {
    final staff = _staffLeaderboard;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('Staff Leaderboard'),
        const SizedBox(height: 8),
        if (staff.isEmpty)
          _emptyState('No staff data')
        else
          ...staff.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final s = entry.value;
            return _buildStaffCard(rank, s);
          }),
      ],
    );
  }

  Widget _buildStaffCard(int rank, Map<String, dynamic> staff) {
    final medalColors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };
    final medalColor = medalColors[rank];

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (medalColor != null)
              CircleAvatar(
                radius: 16,
                backgroundColor: medalColor.withOpacity(0.2),
                child: Text('#$rank',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: medalColor)),
              )
            else
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade100,
                child: Text('#$rank',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      staff['name']?.toString() ?? 'Unknown',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  Text(
                      staff['role']?.toString() ?? 'OFFICER',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${staff['loans_managed'] ?? 0} loans',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Coll: ${((staff['collection_rate'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  Text(
                    _kes.format(
                        (staff['collected'] as num?)?.toDouble() ?? 0),
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                  const Text('collected',
                      style:
                          TextStyle(fontSize: 8, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Detail Trends ---

  Widget _buildDetailTrends() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('6-Month Trends'),
        const SizedBox(height: 8),
        _buildTrendChart(
            'Disbursements', _trendSeries('disbursements'), _primary),
        const SizedBox(height: 12),
        _buildTrendChart('Repayments', _trendSeries('repayments'),
            const Color(0xFF43A047)),
        const SizedBox(height: 12),
        _buildTrendChart('PAR Ratio (%)', _trendSeries('par_ratio'),
            const Color(0xFFE53935)),
        const SizedBox(height: 12),
        _buildTrendChart('Customer Growth',
            _trendSeries('customer_growth'), const Color(0xFF7B1FA2)),
      ],
    );
  }

  Widget _buildTrendChart(
      String title, List<Map<String, dynamic>> series, Color color) {
    if (series.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 12),
              Center(
                child: Text('No trend data',
                    style: TextStyle(color: Colors.grey.shade500)),
              ),
            ],
          ),
        ),
      );
    }

    final values =
        series.map((s) => (s['value'] as num?)?.toDouble() ?? 0).toList();
    final maxVal =
        values.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: series.asMap().entries.map((entry) {
                  final s = entry.value;
                  final value =
                      (s['value'] as num?)?.toDouble() ?? 0;
                  final fraction = value / maxVal;
                  final label =
                      s['label']?.toString() ?? 'M${entry.key + 1}';

                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            title.contains('%')
                                ? '${value.toStringAsFixed(1)}%'
                                : _numFmt.format(value),
                            style: const TextStyle(fontSize: 8),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            height: (fraction * 70).clamp(4, 70),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.8),
                              borderRadius:
                                  const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(label,
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Common helpers
  // ---------------------------------------------------------------------------

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
            ]),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message,
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
