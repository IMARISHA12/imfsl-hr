// IMFSL Transaction History - FlutterFlow Custom Widget
// ======================================================
// Filterable, searchable transaction list with:
// - Date range picker
// - Type filter chips (All, Deposits, Withdrawals, Loans, Fees)
// - Search by reference/description
// - Date-grouped transaction tiles with expand/collapse
// - Infinite scroll pagination
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({
    super.key,
    required this.customerId,
    this.initialTransactions = const [],
    this.onLoadMore,
    this.onRefresh,
  });

  final String customerId;
  final List<Map<String, dynamic>> initialTransactions;
  final Future<List<Map<String, dynamic>>> Function(int page, String? type,
      String? search, DateTime? from, DateTime? to)? onLoadMore;
  final Future<void> Function()? onRefresh;

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final NumberFormat _currencyFmt =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');
  final DateFormat _timeFmt = DateFormat('hh:mm a');
  final DateFormat _groupFmt = DateFormat('EEEE, dd MMMM yyyy');
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _transactions = [];
  String _selectedType = 'ALL';
  String _searchQuery = '';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _expandedTxId;

  final List<_FilterChip> _typeFilters = [
    _FilterChip('ALL', 'All', Icons.list),
    _FilterChip('DEPOSIT', 'Deposits', Icons.arrow_downward),
    _FilterChip('WITHDRAWAL', 'Withdrawals', Icons.arrow_upward),
    _FilterChip('LOAN_REPAYMENT', 'Loan', Icons.payment),
    _FilterChip('FEE', 'Fees', Icons.receipt),
  ];

  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.initialTransactions);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (widget.onLoadMore == null || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final type = _selectedType == 'ALL' ? null : _selectedType;
      final search = _searchQuery.isEmpty ? null : _searchQuery;
      final newTxns = await widget.onLoadMore!(
          _currentPage + 1, type, search, _dateFrom, _dateTo);

      setState(() {
        _currentPage++;
        _transactions.addAll(newTxns);
        _hasMore = newTxns.length >= 20;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    if (widget.onRefresh != null) await widget.onRefresh!();
    setState(() {
      _currentPage = 0;
      _hasMore = true;
    });

    if (widget.onLoadMore != null) {
      setState(() => _isLoading = true);
      try {
        final type = _selectedType == 'ALL' ? null : _selectedType;
        final search = _searchQuery.isEmpty ? null : _searchQuery;
        final txns =
            await widget.onLoadMore!(0, type, search, _dateFrom, _dateTo);
        setState(() {
          _transactions = txns;
          _hasMore = txns.length >= 20;
          _isLoading = false;
        });
      } catch (_) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onFilterChanged(String type) {
    setState(() {
      _selectedType = type;
      _currentPage = 0;
      _hasMore = true;
    });
    _refresh();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_searchQuery == query) _refresh();
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : null,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _dateFrom = picked.start;
        _dateTo = picked.end;
      });
      _refresh();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
    });
    _refresh();
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    var list = _transactions;

    if (_selectedType != 'ALL') {
      list = list.where((tx) => tx['type'] == _selectedType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((tx) {
        final desc = (tx['description'] ?? '').toString().toLowerCase();
        final ref = (tx['reference'] ?? '').toString().toLowerCase();
        return desc.contains(q) || ref.contains(q);
      }).toList();
    }

    return list;
  }

  Map<String, List<Map<String, dynamic>>> get _groupedTransactions {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final tx in _filteredTransactions) {
      final dateStr = tx['date'] as String? ?? tx['created_at'] as String? ?? '';
      DateTime? dt;
      try {
        dt = DateTime.tryParse(dateStr);
      } catch (_) {}
      final groupKey = dt != null ? _groupFmt.format(dt) : 'Unknown Date';
      map.putIfAbsent(groupKey, () => []).add(tx);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        if (_dateFrom != null) _buildDateRangeBadge(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: _filteredTransactions.isEmpty && !_isLoading
                ? _buildEmptyState()
                : _buildTransactionList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey[500], size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _dateFrom != null
                    ? const Color(0xFF1565C0).withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.date_range,
                  color: _dateFrom != null
                      ? const Color(0xFF1565C0)
                      : Colors.grey[600],
                  size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _typeFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filter = _typeFilters[i];
          final isActive = _selectedType == filter.value;
          return GestureDetector(
            onTap: () => _onFilterChanged(filter.value),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF1565C0)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(filter.icon,
                      size: 16,
                      color: isActive ? Colors.white : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(filter.label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              isActive ? Colors.white : Colors.grey[700])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangeBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_dateFmt.format(_dateFrom!)} - ${_dateFmt.format(_dateTo!)}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _clearDateFilter,
                  child: const Icon(Icons.close,
                      size: 14, color: Color(0xFF1565C0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 56, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text('No transactions found',
                  style:
                      TextStyle(fontSize: 15, color: Colors.grey[500])),
              const SizedBox(height: 4),
              Text(
                _searchQuery.isNotEmpty || _dateFrom != null
                    ? 'Try adjusting your filters'
                    : 'Transactions will appear here',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final grouped = _groupedTransactions;
    final groups = grouped.entries.toList();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groups.length + (_isLoading ? 1 : 0),
      itemBuilder: (ctx, index) {
        if (index >= groups.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 12),
            Text(group.key,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500])),
            const SizedBox(height: 6),
            ...group.value.map((tx) => _buildTransactionTile(tx)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final id = tx['id']?.toString() ?? '';
    final type = tx['type'] as String? ?? 'UNKNOWN';
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final description = tx['description'] as String? ?? type;
    final reference = tx['reference'] as String? ?? '';
    final dateStr = tx['date'] as String? ?? tx['created_at'] as String? ?? '';
    final channel = tx['channel'] as String? ?? '';
    final status = tx['status'] as String? ?? 'COMPLETED';
    final isExpanded = _expandedTxId == id;
    final isCredit = type == 'DEPOSIT' ||
        type == 'LOAN_DISBURSEMENT' ||
        type == 'CREDIT' ||
        type == 'INTEREST_EARNED';

    DateTime? dt;
    try {
      dt = DateTime.tryParse(dateStr);
    } catch (_) {}

    IconData icon;
    Color iconColor;
    switch (type) {
      case 'DEPOSIT':
        icon = Icons.arrow_downward;
        iconColor = const Color(0xFF2E7D32);
        break;
      case 'WITHDRAWAL':
        icon = Icons.arrow_upward;
        iconColor = const Color(0xFFEF6C00);
        break;
      case 'LOAN_REPAYMENT':
        icon = Icons.payment;
        iconColor = const Color(0xFF1565C0);
        break;
      case 'LOAN_DISBURSEMENT':
        icon = Icons.account_balance;
        iconColor = const Color(0xFF6A1B9A);
        break;
      case 'FEE':
        icon = Icons.receipt;
        iconColor = Colors.red.shade700;
        break;
      default:
        icon = Icons.swap_horiz;
        iconColor = Colors.grey;
    }

    return GestureDetector(
      onTap: id.isNotEmpty
          ? () => setState(
              () => _expandedTxId = isExpanded ? null : id)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isExpanded
                  ? const Color(0xFF1565C0).withValues(alpha: 0.3)
                  : Colors.grey.shade100),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6)
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
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
                      if (dt != null)
                        Text(_timeFmt.format(dt),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isCredit ? '+' : '-'} ${_currencyFmt.format(amount)}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isCredit
                              ? const Color(0xFF2E7D32)
                              : Colors.red.shade700),
                    ),
                    if (status != 'COMPLETED')
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: status == 'PENDING'
                              ? Colors.orange.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(status,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: status == 'PENDING'
                                    ? Colors.orange[800]
                                    : Colors.red[800])),
                      ),
                  ],
                ),
              ],
            ),
            if (isExpanded) ...[
              const Divider(height: 16),
              _detailRow('Reference', reference),
              if (channel.isNotEmpty) _detailRow('Channel', channel),
              _detailRow('Status', status),
              _detailRow('Type', type.replaceAll('_', ' ')),
              if (dateStr.isNotEmpty)
                _detailRow(
                    'Date/Time', dt != null ? dt.toString() : dateStr),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _FilterChip {
  final String value;
  final String label;
  final IconData icon;
  const _FilterChip(this.value, this.label, this.icon);
}
