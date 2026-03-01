import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL Financial Reports — Report selector and viewer.
///
/// Supports Trial Balance, Income Statement, Balance Sheet, Portfolio,
/// Cash Flow, and PAR Aging reports with date-range filtering and
/// export placeholder.
class ImfslFinancialReports extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final bool isLoading;
  final Function(String type, String from, String to)? onLoadReport;
  final String currentReport;

  const ImfslFinancialReports({
    super.key,
    this.reportData = const {},
    this.isLoading = false,
    this.onLoadReport,
    this.currentReport = 'trial_balance',
  });

  @override
  State<ImfslFinancialReports> createState() => _ImfslFinancialReportsState();
}

class _ImfslFinancialReportsState extends State<ImfslFinancialReports> {
  static const Color _primary = Color(0xFF1565C0);

  final NumberFormat _kes =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');

  late String _selectedReport;
  DateTime _fromDate = DateTime.now().copyWith(day: 1);
  DateTime _toDate = DateTime.now();
  String _trialBalanceSortColumn = 'code';
  bool _trialBalanceSortAsc = true;
  String _parBucketFilter = 'ALL';

  static const List<_ReportTab> _reportTabs = [
    _ReportTab('trial_balance', 'Trial Balance', Icons.table_chart),
    _ReportTab('income_statement', 'Income Statement', Icons.trending_up),
    _ReportTab('balance_sheet', 'Balance Sheet', Icons.account_balance),
    _ReportTab('portfolio', 'Portfolio', Icons.pie_chart),
    _ReportTab('cash_flow', 'Cash Flow', Icons.swap_horiz),
    _ReportTab('par_aging', 'PAR Aging', Icons.warning_amber),
  ];

  static const Map<String, Color> _accountTypeColors = {
    'Asset': Color(0xFF1565C0),
    'Liability': Color(0xFFE53935),
    'Equity': Color(0xFF43A047),
    'Revenue': Color(0xFF00897B),
    'Expense': Color(0xFFFF8F00),
  };

  static const Map<String, Color> _parColors = {
    'CURRENT': Color(0xFF4CAF50),
    'PAR1_30': Color(0xFFCDDC39),
    'PAR31_60': Color(0xFFFFC107),
    'PAR61_90': Color(0xFFFF9800),
    'PAR91_180': Color(0xFFFF5722),
    'PAR180_PLUS': Color(0xFFF44336),
  };

  static const Map<String, String> _parLabels = {
    'CURRENT': 'Current',
    'PAR1_30': '1-30 days',
    'PAR31_60': '31-60 days',
    'PAR61_90': '61-90 days',
    'PAR91_180': '91-180 days',
    'PAR180_PLUS': '180+ days',
  };

  static const Map<String, double> _provisionRates = {
    'CURRENT': 0.01,
    'PAR1_30': 0.05,
    'PAR31_60': 0.25,
    'PAR61_90': 0.50,
    'PAR91_180': 0.75,
    'PAR180_PLUS': 1.00,
  };

  @override
  void initState() {
    super.initState();
    _selectedReport = widget.currentReport;
  }

  @override
  void didUpdateWidget(covariant ImfslFinancialReports oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentReport != oldWidget.currentReport) {
      setState(() => _selectedReport = widget.currentReport);
    }
  }

  // ---------------------------------------------------------------------------
  // Date helpers
  // ---------------------------------------------------------------------------

  void _setPresetRange(String preset) {
    final now = DateTime.now();
    DateTime from;
    DateTime to = now;
    switch (preset) {
      case 'this_month':
        from = DateTime(now.year, now.month, 1);
        break;
      case 'last_month':
        final prev = DateTime(now.year, now.month - 1, 1);
        from = prev;
        to = DateTime(now.year, now.month, 0);
        break;
      case 'this_quarter':
        final q = ((now.month - 1) ~/ 3) * 3 + 1;
        from = DateTime(now.year, q, 1);
        break;
      case 'this_year':
        from = DateTime(now.year, 1, 1);
        break;
      default:
        from = DateTime(now.year, now.month, 1);
    }
    setState(() {
      _fromDate = from;
      _toDate = to;
    });
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _loadReport() {
    final from = _fromDate.toIso8601String().substring(0, 10);
    final to = _toDate.toIso8601String().substring(0, 10);
    widget.onLoadReport?.call(_selectedReport, from, to);
  }

  // ---------------------------------------------------------------------------
  // Data helpers
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> _trialBalanceEntries() {
    final raw =
        widget.reportData['trial_balance'] as List<dynamic>? ?? <dynamic>[];
    final entries = raw.cast<Map<String, dynamic>>().toList();

    entries.sort((a, b) {
      final aVal = a[_trialBalanceSortColumn]?.toString() ?? '';
      final bVal = b[_trialBalanceSortColumn]?.toString() ?? '';
      if (_trialBalanceSortColumn == 'debit' ||
          _trialBalanceSortColumn == 'credit') {
        final aNum = double.tryParse(aVal) ?? 0;
        final bNum = double.tryParse(bVal) ?? 0;
        return _trialBalanceSortAsc
            ? aNum.compareTo(bNum)
            : bNum.compareTo(aNum);
      }
      return _trialBalanceSortAsc
          ? aVal.compareTo(bVal)
          : bVal.compareTo(aVal);
    });
    return entries;
  }

  Map<String, List<Map<String, dynamic>>> _groupedTrialBalance() {
    final entries = _trialBalanceEntries();
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final e in entries) {
      final type = (e['account_type'] as String?) ?? 'Other';
      grouped.putIfAbsent(type, () => []).add(e);
    }
    return grouped;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () => _showExportPlaceholder(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: widget.isLoading ? null : _loadReport,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildReportSelector(),
          _buildDateRangeBar(),
          const SizedBox(height: 4),
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildReportBody(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Report selector
  // ---------------------------------------------------------------------------

  Widget _buildReportSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _reportTabs.map((tab) {
            final selected = _selectedReport == tab.key;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                avatar: Icon(tab.icon,
                    size: 18, color: selected ? Colors.white : _primary),
                label: Text(tab.label),
                selected: selected,
                selectedColor: _primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) {
                  setState(() => _selectedReport = tab.key);
                  _loadReport();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Date range bar
  // ---------------------------------------------------------------------------

  Widget _buildDateRangeBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _dateButton('From', _fromDate, () => _pickDate(true)),
              const SizedBox(width: 12),
              _dateButton('To', _toDate, () => _pickDate(false)),
              const Spacer(),
              FilledButton.icon(
                onPressed: widget.isLoading ? null : _loadReport,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Load'),
                style: FilledButton.styleFrom(backgroundColor: _primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _presetChip('This Month', 'this_month'),
                const SizedBox(width: 6),
                _presetChip('Last Month', 'last_month'),
                const SizedBox(width: 6),
                _presetChip('This Quarter', 'this_quarter'),
                const SizedBox(width: 6),
                _presetChip('This Year', 'this_year'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateButton(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$label: ',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(_dateFmt.format(date),
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _presetChip(String label, String key) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () => _setPresetRange(key),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
    );
  }

  // ---------------------------------------------------------------------------
  // Report body dispatcher
  // ---------------------------------------------------------------------------

  Widget _buildReportBody() {
    switch (_selectedReport) {
      case 'trial_balance':
        return _buildTrialBalance();
      case 'income_statement':
        return _buildIncomeStatement();
      case 'balance_sheet':
        return _buildBalanceSheet();
      case 'portfolio':
        return _buildPortfolio();
      case 'cash_flow':
        return _buildCashFlow();
      case 'par_aging':
        return _buildParAging();
      default:
        return const Center(child: Text('Select a report'));
    }
  }

  // ---------------------------------------------------------------------------
  // 1. Trial Balance
  // ---------------------------------------------------------------------------

  Widget _buildTrialBalance() {
    final grouped = _groupedTrialBalance();
    if (grouped.isEmpty) return _emptyState('No trial balance data');

    double totalDebit = 0;
    double totalCredit = 0;
    for (final entries in grouped.values) {
      for (final e in entries) {
        totalDebit += (e['debit'] as num?)?.toDouble() ?? 0;
        totalCredit += (e['credit'] as num?)?.toDouble() ?? 0;
      }
    }

    final typeOrder = ['Asset', 'Liability', 'Equity', 'Revenue', 'Expense'];
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final ia = typeOrder.indexOf(a);
        final ib = typeOrder.indexOf(b);
        return (ia < 0 ? 99 : ia).compareTo(ib < 0 ? 99 : ib);
      });

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('Trial Balance'),
        _buildSortControls(),
        const SizedBox(height: 8),
        ...sortedKeys.map((type) => _buildTBGroup(type, grouped[type]!)),
        const SizedBox(height: 8),
        _buildTBTotalsRow(totalDebit, totalCredit),
      ],
    );
  }

  Widget _buildSortControls() {
    return Row(
      children: [
        const Text('Sort by: ', style: TextStyle(fontSize: 12)),
        DropdownButton<String>(
          value: _trialBalanceSortColumn,
          isDense: true,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'code', child: Text('Account Code')),
            DropdownMenuItem(value: 'name', child: Text('Name')),
            DropdownMenuItem(value: 'debit', child: Text('Debit')),
            DropdownMenuItem(value: 'credit', child: Text('Credit')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _trialBalanceSortColumn = v);
          },
        ),
        IconButton(
          icon: Icon(
              _trialBalanceSortAsc ? Icons.arrow_upward : Icons.arrow_downward,
              size: 18),
          onPressed: () =>
              setState(() => _trialBalanceSortAsc = !_trialBalanceSortAsc),
        ),
      ],
    );
  }

  Widget _buildTBGroup(String type, List<Map<String, dynamic>> entries) {
    final color = _accountTypeColors[type] ?? Colors.grey;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(type,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          ),
          _buildTBTableHeader(),
          ...entries.map(_buildTBRow),
          _buildTBSubtotal(entries),
        ],
      ),
    );
  }

  Widget _buildTBTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.grey.shade100,
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Code', style: _headerStyle)),
          Expanded(flex: 4, child: Text('Account Name', style: _headerStyle)),
          Expanded(
              flex: 3,
              child:
                  Text('Debit', style: _headerStyle, textAlign: TextAlign.end)),
          Expanded(
              flex: 3,
              child: Text('Credit',
                  style: _headerStyle, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildTBRow(Map<String, dynamic> entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(entry['code']?.toString() ?? '',
                  style: const TextStyle(fontSize: 12))),
          Expanded(
              flex: 4,
              child: Text(entry['name']?.toString() ?? '',
                  style: const TextStyle(fontSize: 12))),
          Expanded(
              flex: 3,
              child: Text(
                _kes.format((entry['debit'] as num?)?.toDouble() ?? 0),
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 12),
              )),
          Expanded(
              flex: 3,
              child: Text(
                _kes.format((entry['credit'] as num?)?.toDouble() ?? 0),
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 12),
              )),
        ],
      ),
    );
  }

  Widget _buildTBSubtotal(List<Map<String, dynamic>> entries) {
    double d = 0, c = 0;
    for (final e in entries) {
      d += (e['debit'] as num?)?.toDouble() ?? 0;
      c += (e['credit'] as num?)?.toDouble() ?? 0;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          const Expanded(flex: 6, child: Text('Subtotal', style: _boldStyle)),
          Expanded(
              flex: 3,
              child: Text(_kes.format(d),
                  textAlign: TextAlign.end, style: _boldStyle)),
          Expanded(
              flex: 3,
              child: Text(_kes.format(c),
                  textAlign: TextAlign.end, style: _boldStyle)),
        ],
      ),
    );
  }

  Widget _buildTBTotalsRow(double totalDebit, double totalCredit) {
    final balanced = (totalDebit - totalCredit).abs() < 0.01;
    return Card(
      color: balanced ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(balanced ? Icons.check_circle : Icons.error,
                color: balanced ? Colors.green : Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
                child: Text(balanced ? 'Balanced' : 'Imbalanced',
                    style: _boldStyle)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Total Debit: ${_kes.format(totalDebit)}',
                    style: _boldStyle),
                Text('Total Credit: ${_kes.format(totalCredit)}',
                    style: _boldStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Income Statement
  // ---------------------------------------------------------------------------

  Widget _buildIncomeStatement() {
    final data = widget.reportData['income_statement'] as Map<String, dynamic>?;
    if (data == null) return _emptyState('No income statement data');

    final revenue =
        (data['revenue'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];
    final expenses =
        (data['expenses'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];
    final totalRevenue = (data['total_revenue'] as num?)?.toDouble() ?? 0;
    final totalExpenses = (data['total_expenses'] as num?)?.toDouble() ?? 0;
    final netIncome = totalRevenue - totalExpenses;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('Income Statement'),
        const SizedBox(height: 8),
        _buildISSection('Revenue', revenue, const Color(0xFF00897B)),
        _buildISTotalRow('Total Revenue', totalRevenue, const Color(0xFF00897B)),
        const SizedBox(height: 12),
        _buildISSection('Expenses', expenses, const Color(0xFFE53935)),
        _buildISTotalRow('Total Expenses', totalExpenses, const Color(0xFFE53935)),
        const SizedBox(height: 16),
        _buildNetIncomeCard(netIncome),
      ],
    );
  }

  Widget _buildISSection(
      String title, List<Map<String, dynamic>> items, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          ),
          ...items.map((item) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(item['name']?.toString() ?? '',
                            style: const TextStyle(fontSize: 13))),
                    Text(
                      _kes.format((item['amount'] as num?)?.toDouble() ?? 0),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildISTotalRow(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14))),
          Text(_kes.format(amount),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNetIncomeCard(double netIncome) {
    final positive = netIncome >= 0;
    return Card(
      color: positive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(positive ? Icons.trending_up : Icons.trending_down,
                color: positive ? Colors.green.shade700 : Colors.red.shade700,
                size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Net Income',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(_kes.format(netIncome),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: positive
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Balance Sheet
  // ---------------------------------------------------------------------------

  Widget _buildBalanceSheet() {
    final data = widget.reportData['balance_sheet'] as Map<String, dynamic>?;
    if (data == null) return _emptyState('No balance sheet data');

    final assets =
        (data['assets'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];
    final liabilities =
        (data['liabilities'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];
    final equity =
        (data['equity'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];

    final totalAssets = (data['total_assets'] as num?)?.toDouble() ?? 0;
    final totalLiabilities =
        (data['total_liabilities'] as num?)?.toDouble() ?? 0;
    final totalEquity = (data['total_equity'] as num?)?.toDouble() ?? 0;
    final totalLE = totalLiabilities + totalEquity;
    final balanced = (totalAssets - totalLE).abs() < 0.01;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('Balance Sheet'),
        const SizedBox(height: 8),
        _buildBSSection(
            'Assets', assets, totalAssets, const Color(0xFF1565C0)),
        const SizedBox(height: 8),
        _buildBSSection('Liabilities', liabilities, totalLiabilities,
            const Color(0xFFE53935)),
        const SizedBox(height: 8),
        _buildBSSection(
            'Equity', equity, totalEquity, const Color(0xFF43A047)),
        const SizedBox(height: 12),
        _buildBSCheckCard(totalAssets, totalLE, balanced),
      ],
    );
  }

  Widget _buildBSSection(String title, List<Map<String, dynamic>> items,
      double total, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          ),
          ...items.map((item) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(item['name']?.toString() ?? '',
                            style: const TextStyle(fontSize: 13))),
                    Text(
                        _kes.format(
                            (item['amount'] as num?)?.toDouble() ?? 0),
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              )),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: color.withOpacity(0.05),
            child: Row(
              children: [
                Expanded(
                    child: Text('Total $title',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: color))),
                Text(_kes.format(total),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBSCheckCard(double assets, double le, bool balanced) {
    return Card(
      color: balanced ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(balanced ? Icons.check_circle : Icons.error,
                    color: balanced ? Colors.green : Colors.red),
                const SizedBox(width: 8),
                Text(
                    balanced
                        ? 'Assets = Liabilities + Equity'
                        : 'Balance sheet is imbalanced!',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bsCheckColumn('Total Assets', assets),
                const Text('=',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _bsCheckColumn('Total L + E', le),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bsCheckColumn(String label, double amount) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(_kes.format(amount),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Portfolio
  // ---------------------------------------------------------------------------

  Widget _buildPortfolio() {
    final data = widget.reportData['portfolio'] as Map<String, dynamic>?;
    if (data == null) return _emptyState('No portfolio data');

    final summary = data['summary'] as Map<String, dynamic>? ?? {};
    final products =
        (data['products'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];
    final parData = data['par'] as Map<String, dynamic>? ?? {};

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('Portfolio Overview'),
        const SizedBox(height: 8),
        _buildPortfolioKPIs(summary),
        const SizedBox(height: 12),
        _sectionHeader('Product Breakdown'),
        const SizedBox(height: 8),
        ...products.map(_buildProductRow),
        const SizedBox(height: 12),
        _sectionHeader('PAR Distribution'),
        const SizedBox(height: 8),
        _buildParStackedBar(parData),
        const SizedBox(height: 8),
        _buildParLegend(parData),
      ],
    );
  }

  Widget _buildPortfolioKPIs(Map<String, dynamic> summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _kpiCard('Active Loans', '${summary['active_loans'] ?? 0}',
            Icons.receipt_long, _primary),
        _kpiCard(
            'Outstanding',
            _kes.format((summary['outstanding'] as num?)?.toDouble() ?? 0),
            Icons.account_balance_wallet,
            const Color(0xFFE53935)),
        _kpiCard(
            'Disbursed (Period)',
            _kes.format(
                (summary['disbursed_period'] as num?)?.toDouble() ?? 0),
            Icons.send,
            const Color(0xFF00897B)),
        _kpiCard(
            'PAR > 30',
            '${((summary['par_gt_30'] as num?)?.toDouble() ?? 0).toStringAsFixed(1)}%',
            Icons.warning_amber,
            const Color(0xFFFF8F00)),
      ],
    );
  }

  Widget _buildProductRow(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _primary.withOpacity(0.1),
          child: Icon(Icons.inventory_2, color: _primary, size: 20),
        ),
        title: Text(product['name']?.toString() ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(
          'Loans: ${product['count'] ?? 0}  |  PAR: ${((product['par_ratio'] as num?)?.toDouble() ?? 0).toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Text(
          _kes.format((product['outstanding'] as num?)?.toDouble() ?? 0),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildParStackedBar(Map<String, dynamic> parData) {
    final total = parData.values.fold<double>(
        0, (sum, v) => sum + ((v as num?)?.toDouble() ?? 0));
    if (total <= 0) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 28,
                child: Row(
                  children: _parColors.entries.map((e) {
                    final amount =
                        (parData[e.key] as num?)?.toDouble() ?? 0;
                    final fraction = amount / total;
                    if (fraction <= 0) return const SizedBox();
                    return Expanded(
                      flex: (fraction * 1000).toInt().clamp(1, 1000),
                      child: Container(color: e.value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParLegend(Map<String, dynamic> parData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: _parColors.entries.map((e) {
            final amount = (parData[e.key] as num?)?.toDouble() ?? 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: e.value,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Text(
                  '${_parLabels[e.key]}: ${_kes.format(amount)}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Cash Flow
  // ---------------------------------------------------------------------------

  Widget _buildCashFlow() {
    final data = widget.reportData['cash_flow'] as Map<String, dynamic>?;
    if (data == null) return _emptyState('No cash flow data');

    final inflows =
        (data['inflows'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];
    final outflows =
        (data['outflows'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];
    final totalIn = (data['total_inflows'] as num?)?.toDouble() ?? 0;
    final totalOut = (data['total_outflows'] as num?)?.toDouble() ?? 0;
    final netCash = totalIn - totalOut;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('Cash Flow Statement'),
        const SizedBox(height: 8),
        _buildNetCashCard(netCash, totalIn, totalOut),
        const SizedBox(height: 12),
        _buildCFSection('Inflows', inflows, totalIn, const Color(0xFF43A047)),
        const SizedBox(height: 8),
        _buildCFSection('Outflows', outflows, totalOut, const Color(0xFFE53935)),
      ],
    );
  }

  Widget _buildNetCashCard(double net, double inflow, double outflow) {
    final positive = net >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  positive
                      ? Icons.arrow_circle_up
                      : Icons.arrow_circle_down,
                  color: positive ? Colors.green : Colors.red,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Net Cash Flow',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text(
                      _kes.format(net),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: positive ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _cfMiniStat('Total Inflows', inflow, Colors.green),
                _cfMiniStat('Total Outflows', outflow, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cfMiniStat(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(_kes.format(amount),
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildCFSection(String title, List<Map<String, dynamic>> items,
      double total, Color color) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14)),
                const Spacer(),
                Text(_kes.format(total),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14)),
              ],
            ),
          ),
          ...items.map((item) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(item['category']?.toString() ?? '',
                            style: const TextStyle(fontSize: 13))),
                    Text(
                      _kes.format(
                          (item['amount'] as num?)?.toDouble() ?? 0),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. PAR Aging
  // ---------------------------------------------------------------------------

  Widget _buildParAging() {
    final data = widget.reportData['par_aging'] as Map<String, dynamic>?;
    if (data == null) return _emptyState('No PAR aging data');

    final buckets =
        (data['buckets'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];
    final loans =
        (data['loans'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];

    final filteredLoans = _parBucketFilter == 'ALL'
        ? loans
        : loans
            .where((l) => l['par_bucket'] == _parBucketFilter)
            .toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('PAR Aging Report'),
        const SizedBox(height: 8),
        _buildParBucketCards(buckets),
        const SizedBox(height: 12),
        _buildParBucketFilter(),
        const SizedBox(height: 8),
        _sectionHeader(
            'Loans (${filteredLoans.length}${_parBucketFilter != 'ALL' ? ' - ${_parLabels[_parBucketFilter] ?? _parBucketFilter}' : ''})'),
        const SizedBox(height: 8),
        ...filteredLoans.map(_buildParLoanCard),
        if (filteredLoans.isEmpty)
          _emptyState('No loans in selected bucket'),
      ],
    );
  }

  Widget _buildParBucketCards(List<Map<String, dynamic>> buckets) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: buckets.map((bucket) {
        final key = bucket['bucket']?.toString() ?? 'CURRENT';
        final color = _parColors[key] ?? Colors.grey;
        final rate = _provisionRates[key] ?? 0;
        final amount = (bucket['amount'] as num?)?.toDouble() ?? 0;
        final count = bucket['count'] ?? 0;

        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () => setState(() => _parBucketFilter = key),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _parLabels[key] ?? key,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(_kes.format(amount),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    '$count loans  |  Prov: ${(rate * 100).toStringAsFixed(0)}%',
                    style:
                        const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParBucketFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _parFilterChip('ALL', 'All Buckets', Colors.grey),
          ..._parColors.entries.map((e) => _parFilterChip(
                e.key,
                _parLabels[e.key] ?? e.key,
                e.value,
              )),
        ],
      ),
    );
  }

  Widget _parFilterChip(String key, String label, Color color) {
    final selected = _parBucketFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11,
            color: selected ? Colors.white : Colors.black87)),
        selected: selected,
        selectedColor: color,
        checkmarkColor: Colors.white,
        onSelected: (_) => setState(() => _parBucketFilter = key),
      ),
    );
  }

  Widget _buildParLoanCard(Map<String, dynamic> loan) {
    final bucket = loan['par_bucket']?.toString() ?? 'CURRENT';
    final color = _parColors[bucket] ?? Colors.grey;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.person, color: color, size: 20),
        ),
        title: Text(loan['customer_name']?.toString() ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(
          'Loan# ${loan['loan_number'] ?? '-'}  |  ${loan['days_in_arrears'] ?? 0} days overdue',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Text(
          _kes.format(
              (loan['outstanding'] as num?)?.toDouble() ?? 0),
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13, color: color),
        ),
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
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _showExportPlaceholder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export PDF'),
        content: const Text(
            'PDF export functionality will be available in a future update. '
            'The report will be generated and downloaded as a PDF document.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.grey,
  );

  static const TextStyle _boldStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
}

// ---------------------------------------------------------------------------
// Internal helper class
// ---------------------------------------------------------------------------

class _ReportTab {
  final String key;
  final String label;
  final IconData icon;
  const _ReportTab(this.key, this.label, this.icon);
}
