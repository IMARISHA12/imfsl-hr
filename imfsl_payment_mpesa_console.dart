import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL M-Pesa & Disbursement Console — Executive 2-tab monitor.
/// Tab 1: M-Pesa Monitor (V8 vw_retool_imfsl_mpesa_monitor)
/// Tab 2: Disbursements (V14 vw_retool_imfsl_disbursement_tracker)
/// Shared KPI bar: Net Flow, Collections, Disbursements, Pending, Failed.
class ImfslPaymentMpesaConsole extends StatefulWidget {
  final List<Map<String, dynamic>> mpesaData;
  final List<Map<String, dynamic>> disbursementData;
  final Map<String, dynamic> mpesaKpis;
  final bool isMpesaLoading;
  final bool isDisbursementLoading;
  final String? mpesaStatusFilter;
  final String? mpesaPurposeFilter;
  final String? disbursementStatusFilter;
  final Function(String?)? onMpesaStatusFilter;
  final Function(String?)? onMpesaPurposeFilter;
  final Function(String? from, String? to)? onMpesaDateRange;
  final Function(String?)? onDisbursementStatusFilter;
  final VoidCallback? onLoadMoreMpesa;
  final VoidCallback? onLoadMoreDisbursements;
  final VoidCallback? onRefreshMpesa;
  final VoidCallback? onRefreshDisbursements;
  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onItemTap;

  const ImfslPaymentMpesaConsole({
    super.key,
    this.mpesaData = const [],
    this.disbursementData = const [],
    this.mpesaKpis = const {},
    this.isMpesaLoading = false,
    this.isDisbursementLoading = false,
    this.mpesaStatusFilter,
    this.mpesaPurposeFilter,
    this.disbursementStatusFilter,
    this.onMpesaStatusFilter,
    this.onMpesaPurposeFilter,
    this.onMpesaDateRange,
    this.onDisbursementStatusFilter,
    this.onLoadMoreMpesa,
    this.onLoadMoreDisbursements,
    this.onRefreshMpesa,
    this.onRefreshDisbursements,
    this.onBack,
    this.onItemTap,
  });

  @override
  State<ImfslPaymentMpesaConsole> createState() =>
      _ImfslPaymentMpesaConsoleState();
}

class _ImfslPaymentMpesaConsoleState extends State<ImfslPaymentMpesaConsole>
    with SingleTickerProviderStateMixin {
  // ── Theme constants ────────────────────────────────────────────────────────

  static const Color _primary = Color(0xFF1565C0);
  static const Color _green = Color(0xFF4CAF50);
  static const Color _yellow = Color(0xFFFFC107);
  static const Color _red = Color(0xFFF44336);
  static const Color _orange = Color(0xFFFF9800);
  static const Color _depositGreen = Color(0xFF2E7D32);
  static const Color _feeOrange = Color(0xFFEF6C00);

  // ── Formatters ─────────────────────────────────────────────────────────────

  final NumberFormat _kes =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dtFmt = DateFormat('dd MMM yyyy, HH:mm');
  final DateFormat _dFmt = DateFormat('dd MMM yyyy');

  // ── State ──────────────────────────────────────────────────────────────────

  late TabController _tabController;
  final TextEditingController _searchCtl = TextEditingController();
  String _searchQuery = '';
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtl.dispose();
    super.dispose();
  }

  // ── Conversion helpers ─────────────────────────────────────────────────────

  double _dbl(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse('$v') ?? 0;
  }

  String _fmtDt(dynamic v) {
    if (v == null) return '\u2014';
    try {
      return _dtFmt.format(DateTime.parse('$v'));
    } catch (_) {
      return '$v';
    }
  }

  String _p2(int n) => n.toString().padLeft(2, '0');

  // ── Colour helpers ─────────────────────────────────────────────────────────

  Color _statusClr(String? s) {
    switch (s?.toUpperCase()) {
      case 'COMPLETED': return _green;
      case 'PENDING': return _yellow;
      case 'FAILED': return _red;
      case 'EXPIRED': return Colors.grey;
      default: return Colors.grey;
    }
  }

  Color _purposeClr(String? p) {
    switch (p?.toUpperCase()) {
      case 'LOAN_REPAYMENT': return _primary;
      case 'DEPOSIT': return _depositGreen;
      case 'FEE_PAYMENT': return _feeOrange;
      default: return Colors.grey;
    }
  }

  String _purposeLbl(String? p) {
    switch (p?.toUpperCase()) {
      case 'LOAN_REPAYMENT': return 'Loan Repayment';
      case 'DEPOSIT': return 'Deposit';
      case 'FEE_PAYMENT': return 'Fee Payment';
      default: return p ?? '\u2014';
    }
  }

  // ── Client-side search filter ──────────────────────────────────────────────

  List<Map<String, dynamic>> get _filteredMpesa {
    if (_searchQuery.isEmpty) return widget.mpesaData;
    final q = _searchQuery.toLowerCase();
    return widget.mpesaData.where((item) {
      final name = (item['full_name'] ?? '').toString().toLowerCase();
      final receipt =
          (item['mpesa_receipt_number'] ?? '').toString().toLowerCase();
      return name.contains(q) || receipt.contains(q);
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Root build
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildKpiBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMpesaTab(),
                _buildDisbursementsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 2,
      leading: widget.onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            )
          : null,
      title: const Text('M-Pesa Console',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
        tabs: const [
          Tab(icon: Icon(Icons.receipt_long, size: 20),
              text: 'M-Pesa Monitor'),
          Tab(icon: Icon(Icons.send, size: 20),
              text: 'Disbursements'),
        ],
      ),
    );
  }

  // ── Shared KPI Bar ─────────────────────────────────────────────────────────

  Widget _buildKpiBar() {
    final netFlow = _dbl(widget.mpesaKpis['net_flow']);
    final collectionsTotal = _dbl(widget.mpesaKpis['collections_total']);
    final disbursementsTotal = _dbl(widget.mpesaKpis['disbursements_total']);
    final pendingCount = _int(widget.mpesaKpis['pending_count']);
    final failedCount = _int(widget.mpesaKpis['failed_count']);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          _kpi('Net Flow', _kes.format(netFlow), Icons.swap_vert,
              netFlow >= 0 ? _green : _red),
          const SizedBox(width: 10),
          _kpi('Collections', _kes.format(collectionsTotal),
              Icons.arrow_downward, _green),
          const SizedBox(width: 10),
          _kpi('Disbursements', _kes.format(disbursementsTotal),
              Icons.arrow_upward, _primary),
          const SizedBox(width: 10),
          _kpi('Pending', '$pendingCount',
              Icons.hourglass_empty, _orange),
          const SizedBox(width: 10),
          _kpi('Failed', '$failedCount',
              Icons.error_outline, _red),
        ]),
      ),
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(child: Text(label,
                style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w600, color: color),
                overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700, color: color),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1 — M-Pesa Monitor
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMpesaTab() {
    final data = _filteredMpesa;
    return RefreshIndicator(
      onRefresh: () async => widget.onRefreshMpesa?.call(),
      child: Column(children: [
        _buildSearchBar(),
        _buildMpesaFilters(),
        _buildDateRangeRow(),
        Expanded(
          child: widget.isMpesaLoading && data.isEmpty
              ? const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_primary)))
              : data.isEmpty
                  ? _empty('No M-Pesa transactions found',
                      Icons.receipt_long)
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: data.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == data.length) {
                          return _loadMore(widget.isMpesaLoading,
                              widget.onLoadMoreMpesa, data.length);
                        }
                        return _mpesaCard(data[i]);
                      },
                    ),
        ),
      ]),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchCtl,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search by name or receipt number...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: _primary, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchCtl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primary, width: 1.5)),
        ),
      ),
    );
  }

  // ── M-Pesa filter chips ────────────────────────────────────────────────────

  Widget _buildMpesaFilters() {
    const statuses = ['ALL', 'PENDING', 'COMPLETED', 'FAILED', 'EXPIRED'];
    const purposes = ['ALL', 'LOAN_REPAYMENT', 'DEPOSIT', 'FEE_PAYMENT'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterLabel('Status'),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statuses.map((s) => _chip(
                s,
                _isActive(widget.mpesaStatusFilter, s),
                _statusClr(s == 'ALL' ? 'COMPLETED' : s),
                () => widget.onMpesaStatusFilter
                    ?.call(s == 'ALL' ? null : s),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          _filterLabel('Purpose'),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: purposes.map((p) => _chip(
                p == 'ALL' ? 'ALL' : _purposeLbl(p),
                _isActive(widget.mpesaPurposeFilter, p),
                p == 'ALL' ? _primary : _purposeClr(p),
                () => widget.onMpesaPurposeFilter
                    ?.call(p == 'ALL' ? null : p),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date range row ─────────────────────────────────────────────────────────

  Widget _buildDateRangeRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(children: [
        const Icon(Icons.date_range, size: 16, color: _primary),
        const SizedBox(width: 6),
        Text(
          _dateFrom != null && _dateTo != null
              ? '${_dFmt.format(_dateFrom!)} \u2014 ${_dFmt.format(_dateTo!)}'
              : 'All dates',
          style: TextStyle(fontSize: 12, color: Colors.grey[700],
              fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        SizedBox(
          height: 30,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 14),
            label: Text(
                _dateFrom != null ? 'Change' : 'Pick Range',
                style: const TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: const BorderSide(color: _primary),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _pickDateRange,
          ),
        ),
        if (_dateFrom != null) ...[
          const SizedBox(width: 6),
          SizedBox(
            height: 30,
            width: 30,
            child: IconButton(
              icon: const Icon(Icons.clear, size: 16),
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _dateFrom = null;
                  _dateTo = null;
                });
                widget.onMpesaDateRange?.call(null, null);
              },
            ),
          ),
        ],
      ]),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)), end: now),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: _primary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dateFrom = picked.start;
        _dateTo = picked.end;
      });
      final from = '${picked.start.year}-${_p2(picked.start.month)}'
          '-${_p2(picked.start.day)}';
      final to = '${picked.end.year}-${_p2(picked.end.month)}'
          '-${_p2(picked.end.day)}';
      widget.onMpesaDateRange?.call(from, to);
    }
  }

  // ── M-Pesa transaction card ────────────────────────────────────────────────

  Widget _mpesaCard(Map<String, dynamic> item) {
    final receipt = item['mpesa_receipt_number']?.toString();
    final name = item['full_name']?.toString() ?? '\u2014';
    final phone = item['txn_phone']?.toString() ?? '\u2014';
    final amt = _dbl(item['amount']);
    final purpose = item['purpose']?.toString();
    final status = item['status']?.toString()?.toUpperCase();
    final reconType = item['reconciliation_type']?.toString();
    final created = _fmtDt(item['created_at']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            widget.onItemTap?.call(item);
            _showMpesaDetail(item);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Receipt number + status badge
                Row(children: [
                  Icon(
                    receipt != null
                        ? Icons.receipt_long : Icons.hourglass_empty,
                    size: 16,
                    color: receipt != null ? _primary : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    receipt ?? 'Pending',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: receipt != null
                          ? Colors.grey[900] : Colors.grey[500],
                      fontStyle: receipt != null
                          ? FontStyle.normal : FontStyle.italic,
                    ),
                  )),
                  _statusBadge(status),
                ]),
                const SizedBox(height: 8),
                // Row 2: Customer name + phone
                Row(children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(name,
                      style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800]),
                      overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Icon(Icons.phone, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 3),
                  Text(phone,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600])),
                ]),
                const SizedBox(height: 8),
                // Row 3: Amount + purpose badge + reconciliation chip
                Row(children: [
                  Text(_kes.format(amt),
                      style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w700, color: _primary)),
                  const SizedBox(width: 10),
                  if (purpose != null) _purposeBadge(purpose),
                  const Spacer(),
                  if (reconType != null) _reconChip(reconType),
                ]),
                const SizedBox(height: 6),
                // Row 4: Created timestamp
                Row(children: [
                  Icon(Icons.access_time,
                      size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(created, style: TextStyle(
                      fontSize: 11, color: Colors.grey[500])),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── M-Pesa detail bottom sheet ─────────────────────────────────────────────

  void _showMpesaDetail(Map<String, dynamic> item) {
    _showDetailSheet(
      title: 'M-Pesa Transaction Detail',
      icon: Icons.receipt_long,
      status: item['status']?.toString()?.toUpperCase(),
      rows: [
        _dr('Receipt Number',
            item['mpesa_receipt_number']?.toString() ?? 'Pending'),
        _dr('Customer',
            item['full_name']?.toString() ?? '\u2014'),
        _dr('Customer Phone',
            item['customer_phone']?.toString() ?? '\u2014'),
        _dr('Transaction Phone',
            item['txn_phone']?.toString() ?? '\u2014'),
        _dr('Amount', _kes.format(_dbl(item['amount']))),
        _dr('Purpose',
            _purposeLbl(item['purpose']?.toString())),
        _dr('Status',
            item['status']?.toString() ?? '\u2014'),
        null, // divider
        _dr('Checkout Request ID',
            item['checkout_request_id']?.toString() ?? '\u2014'),
        _dr('Reference ID',
            item['reference_id']?.toString() ?? '\u2014'),
        _dr('Result Code',
            item['result_code']?.toString() ?? '\u2014'),
        _dr('Result Description',
            item['result_desc']?.toString() ?? '\u2014'),
        null, // divider
        _dr('Reconciliation Type',
            item['reconciliation_type']?.toString() ?? '\u2014'),
        _dr('Applied To Type',
            item['applied_to_type']?.toString() ?? '\u2014'),
        _dr('Applied To ID',
            item['applied_to_id']?.toString() ?? '\u2014'),
        _dr('Reconciled At',
            _fmtDt(item['reconciled_at'])),
        null, // divider
        _dr('Callback Received',
            _fmtDt(item['callback_received_at'])),
        _dr('Created At',
            _fmtDt(item['created_at'])),
        _dr('Transaction ID',
            item['id']?.toString() ?? '\u2014'),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2 — Disbursements
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDisbursementsTab() {
    final data = widget.disbursementData;
    return RefreshIndicator(
      onRefresh: () async => widget.onRefreshDisbursements?.call(),
      child: Column(children: [
        _buildDisbursementFilters(),
        Expanded(
          child: widget.isDisbursementLoading && data.isEmpty
              ? const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_primary)))
              : data.isEmpty
                  ? _empty('No disbursements found', Icons.send)
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: data.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == data.length) {
                          return _loadMore(widget.isDisbursementLoading,
                              widget.onLoadMoreDisbursements, data.length);
                        }
                        return _disbursementCard(data[i]);
                      },
                    ),
        ),
      ]),
    );
  }

  // ── Disbursement filter chips ──────────────────────────────────────────────

  Widget _buildDisbursementFilters() {
    const statuses = ['ALL', 'PENDING', 'COMPLETED', 'FAILED'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterLabel('Disbursement Status'),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statuses.map((s) => _chip(
                s,
                _isActive(widget.disbursementStatusFilter, s),
                _statusClr(s == 'ALL' ? 'COMPLETED' : s),
                () => widget.onDisbursementStatusFilter
                    ?.call(s == 'ALL' ? null : s),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Disbursement card ──────────────────────────────────────────────────────

  Widget _disbursementCard(Map<String, dynamic> item) {
    final loan = item['loan_number']?.toString() ?? '\u2014';
    final name = item['full_name']?.toString() ?? '\u2014';
    final phone = item['phone_number']?.toString() ?? '\u2014';
    final amt = _dbl(item['amount']);
    final status = item['status']?.toString()?.toUpperCase();
    final receipt = item['mpesa_receipt']?.toString();
    final completedAt = item['completed_at'];
    final createdAt = item['created_at'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            widget.onItemTap?.call(item);
            _showDisbursementDetail(item);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Loan number + status badge
                Row(children: [
                  const Icon(Icons.description,
                      size: 16, color: _primary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(loan,
                      style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900]))),
                  _statusBadge(status),
                ]),
                const SizedBox(height: 8),
                // Row 2: Customer name + phone
                Row(children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(name,
                      style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800]),
                      overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Icon(Icons.phone, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 3),
                  Text(phone,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600])),
                ]),
                const SizedBox(height: 8),
                // Row 3: Amount + M-Pesa receipt
                Row(children: [
                  Text(_kes.format(amt),
                      style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w700, color: _primary)),
                  const Spacer(),
                  Icon(
                    receipt != null
                        ? Icons.check_circle : Icons.hourglass_bottom,
                    size: 14,
                    color: receipt != null ? _green : Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(receipt ?? 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: receipt != null
                            ? Colors.grey[700] : Colors.grey[500],
                        fontStyle: receipt != null
                            ? FontStyle.normal : FontStyle.italic,
                      )),
                ]),
                const SizedBox(height: 6),
                // Row 4: Completed / created timestamp
                Row(children: [
                  Icon(Icons.access_time,
                      size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    completedAt != null
                        ? 'Completed: ${_fmtDt(completedAt)}'
                        : 'Created: ${_fmtDt(createdAt)}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Disbursement detail bottom sheet ───────────────────────────────────────

  void _showDisbursementDetail(Map<String, dynamic> item) {
    final s = (String k) => item[k]?.toString() ?? '\u2014';
    _showDetailSheet(title: 'Disbursement Detail', icon: Icons.send,
      status: item['status']?.toString()?.toUpperCase(), rows: [
        _dr('Loan Number', s('loan_number')),
        _dr('Application Number', s('application_number')),
        _dr('Customer', s('full_name')),
        _dr('Phone Number', s('phone_number')),
        _dr('Amount', _kes.format(_dbl(item['amount']))),
        _dr('Status', s('status')), _dr('M-Pesa Receipt', s('mpesa_receipt')),
        null,
        _dr('Conversation ID', s('conversation_id')),
        _dr('Originator Conversation ID', s('originator_conversation_id')),
        _dr('Result Code', s('result_code')),
        _dr('Result Description', s('result_desc')),
        null,
        _dr('Completed At', _fmtDt(item['completed_at'])),
        _dr('Created At', _fmtDt(item['created_at'])),
        _dr('Disbursement ID', s('id')),
      ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Shared UI Components
  // ═══════════════════════════════════════════════════════════════════════════

  bool _isActive(String? current, String option) =>
      (current == null && option == 'ALL') || current == option;

  Widget _filterLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey));

  Widget _chip(String label, bool selected, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : Colors.grey[700])),
        selected: selected, selectedColor: color,
        backgroundColor: Colors.grey[100], checkmarkColor: Colors.white,
        onSelected: (_) => onTap(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _statusBadge(String? status) {
    final c = _statusClr(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.4))),
      child: Text(status ?? '\u2014',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
    );
  }

  Widget _purposeBadge(String purpose) {
    final c = _purposeClr(purpose);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: c.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10)),
      child: Text(_purposeLbl(purpose),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
    );
  }

  Widget _reconChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: Colors.teal.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.link, size: 11, color: Colors.teal),
        const SizedBox(width: 3),
        Text(type, style: const TextStyle(fontSize: 10,
            fontWeight: FontWeight.w600, color: Colors.teal)),
      ]),
    );
  }

  List<String> _dr(String label, String value) => [label, value];

  void _showDetailSheet({required String title, required IconData icon,
      String? status, required List<List<String>?> rows}) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7, maxChildSize: 0.92, minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollCtl) => SingleChildScrollView(
          controller: scrollCtl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)))),
            Row(children: [
              Icon(icon, color: _primary, size: 24), const SizedBox(width: 10),
              Expanded(child: Text(title, style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w700, color: Colors.grey[900]))),
              _statusBadge(status),
            ]),
            const Divider(height: 28),
            ...rows.map((r) {
              if (r == null) return const Divider(height: 24);
              return Padding(padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 140, child: Text(r[0], style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600]))),
                  Expanded(child: Text(r[1], style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[900]))),
                ]));
            }),
          ]),
        ),
      ),
    );
  }

  Widget _loadMore(bool loading, VoidCallback? onTap, int count) {
    if (onTap == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Center(child: loading
          ? const SizedBox(height: 24, width: 24,
              child: CircularProgressIndicator(strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_primary)))
          : OutlinedButton.icon(
              icon: const Icon(Icons.expand_more, size: 18),
              label: Text('Load More ($count loaded)', style: const TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: onTap)),
    );
  }

  Widget _empty(String msg, IconData icon) {
    return Center(child: Padding(padding: const EdgeInsets.all(48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 56, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(msg, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
            color: Colors.grey[500]), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Try adjusting your filters or date range.',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            textAlign: TextAlign.center),
      ]),
    ));
  }
}
