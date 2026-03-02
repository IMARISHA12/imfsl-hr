import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Loan Operations Console — 3-tab view (Pipeline, Portfolio, Repayments).
/// Data sources: V3 loan_pipeline, V4 loan_portfolio, V5 repayment_monitor.
class ImfslLoanOperationsConsole extends StatefulWidget {
  final List<Map<String, dynamic>> pipelineData;
  final List<Map<String, dynamic>> portfolioData;
  final List<Map<String, dynamic>> repaymentData;
  final bool isPipelineLoading;
  final bool isPortfolioLoading;
  final bool isRepaymentLoading;
  final String? pipelineStatusFilter;
  final String? portfolioStatusFilter;
  final String? portfolioParFilter;
  final String? repaymentStatusFilter;
  final Function(String?)? onPipelineStatusFilter;
  final Function(String?)? onPortfolioStatusFilter;
  final Function(String?)? onPortfolioParFilter;
  final Function(String?)? onRepaymentStatusFilter;
  final Function(String? from, String? to)? onRepaymentDateRange;
  final VoidCallback? onLoadMorePipeline;
  final VoidCallback? onLoadMorePortfolio;
  final VoidCallback? onLoadMoreRepayment;
  final VoidCallback? onRefreshPipeline;
  final VoidCallback? onRefreshPortfolio;
  final VoidCallback? onRefreshRepayment;
  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onItemTap;

  const ImfslLoanOperationsConsole({
    super.key,
    this.pipelineData = const [],
    this.portfolioData = const [],
    this.repaymentData = const [],
    this.isPipelineLoading = false,
    this.isPortfolioLoading = false,
    this.isRepaymentLoading = false,
    this.pipelineStatusFilter,
    this.portfolioStatusFilter,
    this.portfolioParFilter,
    this.repaymentStatusFilter,
    this.onPipelineStatusFilter,
    this.onPortfolioStatusFilter,
    this.onPortfolioParFilter,
    this.onRepaymentStatusFilter,
    this.onRepaymentDateRange,
    this.onLoadMorePipeline,
    this.onLoadMorePortfolio,
    this.onLoadMoreRepayment,
    this.onRefreshPipeline,
    this.onRefreshPortfolio,
    this.onRefreshRepayment,
    this.onBack,
    this.onItemTap,
  });

  @override
  State<ImfslLoanOperationsConsole> createState() =>
      _ImfslLoanOperationsConsoleState();
}

class _ImfslLoanOperationsConsoleState
    extends State<ImfslLoanOperationsConsole> {
  // Design tokens
  static const _pri = Color(0xFF1565C0);
  static const _grn = Color(0xFF2E7D32);
  static const _ylw = Color(0xFFF9A825);
  static const _org = Color(0xFFEF6C00);
  static const _red = Color(0xFFC62828);

  // Filter option lists
  static const _pipSt = ['ALL', 'SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'DISBURSED'];
  static const _porSt = ['ALL', 'ACTIVE', 'CLOSED', 'WRITTEN_OFF', 'RESTRUCTURED', 'DISBURSED'];
  static const _parBk = ['ALL', 'CURRENT', 'PAR_1_30', 'PAR_31_60', 'PAR_61_90', 'PAR_90_PLUS'];
  static const _repSt = ['ALL', 'PENDING', 'PAID', 'OVERDUE', 'PARTIALLY_PAID'];

  // Formatters
  final _cFmt = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final _dFmt = DateFormat('dd MMM yyyy');
  final _dtFmt = DateFormat('dd MMM yyyy HH:mm');

  // Local state
  String _searchQ = '';
  final _searchCtrl = TextEditingController();
  String? _dateFrom;
  String? _dateTo;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // -- Conversion helpers -----------------------------------------------------

  double _dbl(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String _s(dynamic v) => v?.toString() ?? '';
  String _fc(dynamic v) => _cFmt.format(_dbl(v));

  String _fd(dynamic v) {
    if (v == null) return '-';
    try { return _dFmt.format(DateTime.parse(v.toString())); }
    catch (_) { return v.toString(); }
  }

  String _fdt(dynamic v) {
    if (v == null) return '-';
    try { return _dtFmt.format(DateTime.parse(v.toString())); }
    catch (_) { return v.toString(); }
  }

  // -- Colour helpers ---------------------------------------------------------

  Color _stClr(String s) {
    switch (s.toUpperCase()) {
      case 'SUBMITTED': return Colors.blue;
      case 'UNDER_REVIEW': return _org;
      case 'APPROVED': return _grn;
      case 'REJECTED': return _red;
      case 'DISBURSED': return Colors.teal;
      case 'ACTIVE': return _grn;
      case 'CLOSED': return Colors.grey;
      case 'WRITTEN_OFF': return _red;
      case 'RESTRUCTURED': return _org;
      case 'PAID': return _grn;
      case 'OVERDUE': return _red;
      case 'PENDING': return Colors.blueGrey;
      case 'PARTIALLY_PAID': return _ylw;
      default: return Colors.grey;
    }
  }

  /// 0=green, 1-30=yellow, 31-90=orange, >90=red
  Color _arrClr(int d) {
    if (d <= 0) return _grn;
    if (d <= 30) return _ylw;
    if (d <= 90) return _org;
    return _red;
  }

  Color _riskClr(String r) {
    switch (r.toUpperCase()) {
      case 'LOW': return _grn;
      case 'MEDIUM': return _ylw;
      case 'HIGH': return _org;
      case 'VERY_HIGH': return _red;
      default: return Colors.grey;
    }
  }

  // -- Detail bottom sheet ----------------------------------------------------

  void _showDetail(BuildContext ctx, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => DraggableScrollableSheet(
        initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.95,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                const Icon(Icons.info_outline, color: _pri, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  _s(item['loan_number'] ?? item['application_number'] ?? 'Detail'),
                  style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: _pri),
                )),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(c)),
              ]),
            ),
            const Divider(height: 1),
            Expanded(child: ListView(
              controller: sc,
              padding: const EdgeInsets.all(16),
              children: item.entries.map((e) {
                final lbl = e.key.replaceAll('_', ' ').split(' ')
                    .map((w) => w.isNotEmpty
                        ? '${w[0].toUpperCase()}${w.substring(1)}'
                        : '')
                    .join(' ');
                final k = e.key;
                String val;
                if (k.contains('amount') || k.contains('balance') ||
                    k.contains('installment') || k.contains('principal') ||
                    k.contains('interest') || k.contains('fees') ||
                    k.contains('penalty') || k.contains('repayable') ||
                    k.contains('outstanding') ||
                    (k.contains('due') && !k.contains('date'))) {
                  val = _fc(e.value);
                } else if (k.contains('_at') || k.contains('date')) {
                  val = _fdt(e.value);
                } else {
                  val = _s(e.value);
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(lbl, style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        val.isEmpty ? '-' : val,
                        style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                );
              }).toList(),
            )),
          ]),
        ),
      ),
    );
  }

  // -- Reusable widgets -------------------------------------------------------

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: TextStyle(
          fontSize: 12,
          color: sel ? Colors.white : Colors.grey.shade700,
          fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
        selected: sel,
        onSelected: (_) => onTap(),
        selectedColor: _pri,
        backgroundColor: Colors.grey.shade100,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: c),
            const SizedBox(height: 6),
            Text(value,
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: c),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label,
              style: TextStyle(fontSize: 11, color: c.withOpacity(0.8)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _badge(String status) {
    final c = _stClr(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(status.replaceAll('_', ' '),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
    );
  }

  Widget _loadMore(VoidCallback? cb) {
    if (cb == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(child: OutlinedButton.icon(
        onPressed: cb,
        icon: const Icon(Icons.expand_more, size: 18),
        label: const Text('Load More'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _pri,
          side: const BorderSide(color: _pri),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20))),
      )),
    );
  }

  Widget _loading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(color: _pri)));
  }

  Widget _empty(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(msg,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1 — Pipeline
  // ===========================================================================

  List<Map<String, dynamic>> get _filteredPipeline {
    var data = widget.pipelineData;
    final sf = widget.pipelineStatusFilter;
    if (sf != null && sf.isNotEmpty && sf.toUpperCase() != 'ALL') {
      data = data.where(
        (r) => _s(r['status']).toUpperCase() == sf.toUpperCase()).toList();
    }
    if (_searchQ.isNotEmpty) {
      final q = _searchQ.toLowerCase();
      data = data.where((r) =>
        _s(r['full_name']).toLowerCase().contains(q) ||
        _s(r['application_number']).toLowerCase().contains(q)).toList();
    }
    return data;
  }

  Widget _buildPipelineTab() {
    final all = widget.pipelineData;
    final filtered = _filteredPipeline;

    // KPIs from unfiltered data
    final totalApps = all.length;
    final pendingReview = all.where((r) {
      final s = _s(r['status']).toUpperCase();
      return s == 'SUBMITTED' || s == 'UNDER_REVIEW';
    }).length;
    double approvedValue = 0;
    for (final r in all) {
      final s = _s(r['status']).toUpperCase();
      if (s == 'APPROVED' || s == 'DISBURSED') {
        approvedValue += _dbl(r['approved_amount']);
      }
    }

    return Column(children: [
      // KPI row
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Row(children: [
          _kpi('Total Apps', totalApps.toString(),
            Icons.description_outlined, _pri),
          const SizedBox(width: 8),
          _kpi('Pending Review', pendingReview.toString(),
            Icons.hourglass_top, _org),
          const SizedBox(width: 8),
          _kpi('Approved Value', _fc(approvedValue),
            Icons.check_circle_outline, _grn),
        ]),
      ),
      // Status filter chips
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _pipSt.map((s) => _chip(
              s.replaceAll('_', ' '),
              (widget.pipelineStatusFilter ?? 'ALL').toUpperCase() == s,
              () => widget.onPipelineStatusFilter?.call(
                s == 'ALL' ? null : s),
            )).toList(),
          ),
        ),
      ),
      // Search bar
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Search by name or application number...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search,
              size: 20, color: Colors.grey.shade400),
            suffixIcon: _searchQ.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQ = '');
                  })
              : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _pri)),
          ),
          style: const TextStyle(fontSize: 14),
          onChanged: (v) => setState(() => _searchQ = v),
        ),
      ),
      // Card list
      Expanded(
        child: widget.isPipelineLoading
          ? _loading()
          : filtered.isEmpty
            ? _empty('No pipeline applications found.')
            : RefreshIndicator(
                color: _pri,
                onRefresh: () async => widget.onRefreshPipeline?.call(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: filtered.length + 1,
                  itemBuilder: (_, i) => i == filtered.length
                    ? _loadMore(widget.onLoadMorePipeline)
                    : _buildPipelineCard(filtered[i]),
                ),
              ),
      ),
    ]);
  }

  Widget _buildPipelineCard(Map<String, dynamic> row) {
    final appNo = _s(row['application_number']);
    final fullName = _s(row['full_name']);
    final productName = _s(row['product_name']);
    final requestedAmt = _dbl(row['requested_amount']);
    final status = _s(row['status']).toUpperCase();
    final riskCat = _s(row['risk_category']);
    final stepNum = _int(row['step_number']);
    final totalSteps = _int(row['total_steps']);
    final submittedAt = _fdt(row['submitted_at']);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          widget.onItemTap?.call(row);
          _showDetail(context, row);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Application number + status badge
              Row(children: [
                Expanded(child: Text(
                  appNo.isNotEmpty ? appNo : 'N/A',
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold,
                    color: _pri),
                )),
                _badge(status),
              ]),
              const SizedBox(height: 8),
              // Full name
              Text(fullName,
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              // Product name
              Text(productName,
                style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              // Requested amount + risk category chip
              Row(children: [
                Text(_fc(requestedAmt),
                  style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (riskCat.isNotEmpty) Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _riskClr(riskCat).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(riskCat.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: _riskClr(riskCat))),
                ),
              ]),
              const SizedBox(height: 8),
              // Step progress + submitted timestamp
              Row(children: [
                if (totalSteps > 0) ...[
                  SizedBox(
                    width: 80,
                    child: LinearProgressIndicator(
                      value: stepNum / totalSteps,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(_pri),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(width: 6),
                  Text('$stepNum/$totalSteps',
                    style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600)),
                ],
                const Spacer(),
                Icon(Icons.access_time,
                  size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text(submittedAt,
                  style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade500)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 2 — Portfolio
  // ===========================================================================

  List<Map<String, dynamic>> get _filteredPortfolio {
    var data = widget.portfolioData;
    final sf = widget.portfolioStatusFilter;
    if (sf != null && sf.isNotEmpty && sf.toUpperCase() != 'ALL') {
      data = data.where(
        (r) => _s(r['status']).toUpperCase() == sf.toUpperCase()).toList();
    }
    final pf = widget.portfolioParFilter;
    if (pf != null && pf.isNotEmpty && pf.toUpperCase() != 'ALL') {
      data = data.where(
        (r) => _s(r['par_bucket']).toUpperCase() == pf.toUpperCase()).toList();
    }
    return data;
  }

  Widget _buildPortfolioTab() {
    final all = widget.portfolioData;
    final filtered = _filteredPortfolio;

    // KPIs from unfiltered data
    final activeCount = all
      .where((r) => _s(r['status']).toUpperCase() == 'ACTIVE').length;
    double totalOutstanding = 0;
    int overdueCount = 0;
    for (final r in all) {
      totalOutstanding += _dbl(r['outstanding_balance']);
      if (_int(r['days_in_arrears']) > 0) overdueCount++;
    }

    return Column(children: [
      // KPI row
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Row(children: [
          _kpi('Active Loans', activeCount.toString(),
            Icons.account_balance_wallet_outlined, _pri),
          const SizedBox(width: 8),
          _kpi('Total Outstanding', _fc(totalOutstanding),
            Icons.monetization_on_outlined, _org),
          const SizedBox(width: 8),
          _kpi('Overdue', overdueCount.toString(),
            Icons.warning_amber_outlined, _red),
        ]),
      ),
      // Status filter chips
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _porSt.map((s) => _chip(
              s.replaceAll('_', ' '),
              (widget.portfolioStatusFilter ?? 'ALL').toUpperCase() == s,
              () => widget.onPortfolioStatusFilter?.call(
                s == 'ALL' ? null : s),
            )).toList(),
          ),
        ),
      ),
      // PAR bucket filter chips
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6, top: 4),
                child: Text('PAR:',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
              ),
              ..._parBk.map((p) {
                final label = p == 'ALL' ? 'ALL'
                  : p.replaceAll('PAR_', '')
                     .replaceAll('_PLUS', '+')
                     .replaceAll('_', '-');
                final isSel = (widget.portfolioParFilter ?? 'ALL')
                  .toUpperCase() == p;
                return _chip(label, isSel,
                  () => widget.onPortfolioParFilter?.call(
                    p == 'ALL' ? null : p));
              }),
            ],
          ),
        ),
      ),
      // Card list
      Expanded(
        child: widget.isPortfolioLoading
          ? _loading()
          : filtered.isEmpty
            ? _empty('No portfolio loans found.')
            : RefreshIndicator(
                color: _pri,
                onRefresh: () async => widget.onRefreshPortfolio?.call(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: filtered.length + 1,
                  itemBuilder: (_, i) => i == filtered.length
                    ? _loadMore(widget.onLoadMorePortfolio)
                    : _buildPortfolioCard(filtered[i]),
                ),
              ),
      ),
    ]);
  }

  Widget _buildPortfolioCard(Map<String, dynamic> row) {
    final loanNo = _s(row['loan_number']);
    final fullName = _s(row['full_name']);
    final productName = _s(row['product_name']);
    final principal = _dbl(row['principal_amount']);
    final outBal = _dbl(row['outstanding_balance']);
    final installment = _dbl(row['monthly_installment']);
    final daysArr = _int(row['days_in_arrears']);
    final parBucket = _s(row['par_bucket']);
    final status = _s(row['status']).toUpperCase();
    final paidCnt = _int(row['paid_count']);
    final totalCnt = _int(row['total_count']);
    final nextDue = _fd(row['next_due_date']);
    final ac = _arrClr(daysArr);
    final progress = totalCnt > 0 ? paidCnt / totalCnt : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          widget.onItemTap?.call(row);
          _showDetail(context, row);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan number + status badge
              Row(children: [
                Expanded(child: Text(
                  loanNo.isNotEmpty ? loanNo : 'N/A',
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold,
                    color: _pri),
                )),
                _badge(status),
              ]),
              const SizedBox(height: 8),
              // Name + product
              Text(fullName,
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(productName,
                style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 10),
              // Three-column financial summary
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Principal', style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
                    Text(_fc(principal), style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                )),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Outstanding', style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
                    Text(_fc(outBal), style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: outBal > 0 ? _org : _grn)),
                  ],
                )),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Installment', style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
                    Text(_fc(installment), style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                )),
              ]),
              const SizedBox(height: 10),
              // Arrears badge + PAR chip + next due date
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ac.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ac.withOpacity(0.4))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(daysArr > 0
                        ? Icons.warning_amber : Icons.check_circle,
                        size: 14, color: ac),
                      const SizedBox(width: 4),
                      Text('$daysArr days', style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: ac)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (parBucket.isNotEmpty) Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(parBucket.replaceAll('_', ' '),
                    style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500,
                      color: Colors.blueGrey)),
                ),
                const Spacer(),
                Text('Next: $nextDue', style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade500)),
              ]),
              const SizedBox(height: 10),
              // Repayment progress bar
              Row(children: [
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? _grn : _pri),
                    minHeight: 8),
                )),
                const SizedBox(width: 8),
                Text('$paidCnt / $totalCnt paid',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 3 — Repayments
  // ===========================================================================

  List<Map<String, dynamic>> get _filteredRepayments {
    var data = widget.repaymentData;
    final sf = widget.repaymentStatusFilter;
    if (sf != null && sf.isNotEmpty && sf.toUpperCase() != 'ALL') {
      data = data.where(
        (r) => _s(r['status']).toUpperCase() == sf.toUpperCase()).toList();
    }
    // From-date filter
    if (_dateFrom != null) {
      try {
        final fromDt = DateTime.parse(_dateFrom!);
        data = data.where((r) {
          final d = r['due_date'];
          if (d == null) return false;
          try {
            return DateTime.parse(d.toString())
              .isAfter(fromDt.subtract(const Duration(days: 1)));
          } catch (_) { return true; }
        }).toList();
      } catch (_) {}
    }
    // To-date filter
    if (_dateTo != null) {
      try {
        final toDt = DateTime.parse(_dateTo!);
        data = data.where((r) {
          final d = r['due_date'];
          if (d == null) return false;
          try {
            return DateTime.parse(d.toString())
              .isBefore(toDt.add(const Duration(days: 1)));
          } catch (_) { return true; }
        }).toList();
      } catch (_) {}
    }
    return data;
  }

  Widget _buildRepaymentTab() {
    final all = widget.repaymentData;
    final filtered = _filteredRepayments;

    // KPI date calculations
    final now = DateTime.now();
    final todayStr = '${now.year}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    int dueToday = 0;
    int overdueCount = 0;
    int paidThisWeek = 0;
    for (final r in all) {
      if (_s(r['due_date']).startsWith(todayStr)) dueToday++;
      if (_s(r['status']).toUpperCase() == 'OVERDUE') overdueCount++;
      if (_s(r['status']).toUpperCase() == 'PAID' && r['paid_at'] != null) {
        try {
          if (DateTime.parse(_s(r['paid_at'])).isAfter(weekStart)) {
            paidThisWeek++;
          }
        } catch (_) {}
      }
    }

    return Column(children: [
      // KPI row
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Row(children: [
          _kpi('Due Today', dueToday.toString(),
            Icons.today_outlined, _pri),
          const SizedBox(width: 8),
          _kpi('Overdue', overdueCount.toString(),
            Icons.error_outline, _red),
          const SizedBox(width: 8),
          _kpi('Paid This Week', paidThisWeek.toString(),
            Icons.payments_outlined, _grn),
        ]),
      ),
      // Status filter chips
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _repSt.map((s) => _chip(
              s.replaceAll('_', ' '),
              (widget.repaymentStatusFilter ?? 'ALL').toUpperCase() == s,
              () => widget.onRepaymentStatusFilter?.call(
                s == 'ALL' ? null : s),
            )).toList(),
          ),
        ),
      ),
      // Date range picker row
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(children: [
          Icon(Icons.date_range,
            size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          TextButton(
            onPressed: () => _pickRepaymentDate(isFrom: true),
            style: TextButton.styleFrom(
              foregroundColor: _pri,
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(
              _dateFrom != null ? _fd(_dateFrom) : 'From Date',
              style: const TextStyle(fontSize: 13)),
          ),
          Text(' - ',
            style: TextStyle(
              fontSize: 13, color: Colors.grey.shade500)),
          TextButton(
            onPressed: () => _pickRepaymentDate(isFrom: false),
            style: TextButton.styleFrom(
              foregroundColor: _pri,
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(
              _dateTo != null ? _fd(_dateTo) : 'To Date',
              style: const TextStyle(fontSize: 13)),
          ),
          if (_dateFrom != null || _dateTo != null)
            IconButton(
              icon: Icon(Icons.clear,
                size: 16, color: Colors.grey.shade500),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _dateFrom = null;
                  _dateTo = null;
                });
                widget.onRepaymentDateRange?.call(null, null);
              },
            ),
        ]),
      ),
      // DataTable in horizontal scroll
      Expanded(
        child: widget.isRepaymentLoading
          ? _loading()
          : filtered.isEmpty
            ? _empty('No repayment records found.')
            : RefreshIndicator(
                color: _pri,
                onRefresh: () async => widget.onRefreshRepayment?.call(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildRepaymentDataTable(filtered),
                    ),
                    _loadMore(widget.onLoadMoreRepayment),
                  ],
                ),
              ),
      ),
    ]);
  }

  /// Opens the platform date picker for the repayment date range.
  Future<void> _pickRepaymentDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _pri,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black)),
        child: child!,
      ),
    );
    if (picked != null) {
      final dateStr = '${picked.year}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        if (isFrom) {
          _dateFrom = dateStr;
        } else {
          _dateTo = dateStr;
        }
      });
      widget.onRepaymentDateRange?.call(_dateFrom, _dateTo);
    }
  }

  /// Builds the repayment DataTable with colour-coded rows:
  /// green tint for PAID, red tint for OVERDUE, white for PENDING.
  Widget _buildRepaymentDataTable(List<Map<String, dynamic>> data) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        _pri.withOpacity(0.06)),
      headingTextStyle: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700, color: _pri),
      dataTextStyle: const TextStyle(
        fontSize: 12, color: Colors.black87),
      columnSpacing: 16,
      horizontalMargin: 12,
      dataRowMinHeight: 40,
      dataRowMaxHeight: 52,
      columns: const [
        DataColumn(label: Text('Due Date')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Loan #')),
        DataColumn(label: Text('Inst #')),
        DataColumn(label: Text('Total Due'), numeric: true),
        DataColumn(label: Text('Total Paid'), numeric: true),
        DataColumn(label: Text('Status')),
      ],
      rows: data.map((row) {
        final status = _s(row['status']).toUpperCase();
        Color? rowColor;
        if (status == 'PAID') {
          rowColor = _grn.withOpacity(0.06);
        } else if (status == 'OVERDUE') {
          rowColor = _red.withOpacity(0.06);
        }
        return DataRow(
          color: rowColor != null
            ? WidgetStateProperty.all(rowColor) : null,
          onSelectChanged: (_) {
            widget.onItemTap?.call(row);
            _showDetail(context, row);
          },
          cells: [
            DataCell(Text(_fd(row['due_date']))),
            DataCell(ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(_s(row['full_name']),
                overflow: TextOverflow.ellipsis),
            )),
            DataCell(Text(_s(row['loan_number']))),
            DataCell(Text(_s(row['installment_number']))),
            DataCell(Text(_fc(row['total_due']))),
            DataCell(Text(_fc(row['total_paid']))),
            DataCell(_badge(status)),
          ],
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // Root build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: _pri,
          foregroundColor: Colors.white,
          elevation: 2,
          leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack)
            : null,
          title: const Text(
            'Loan Operations Console',
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 22),
              tooltip: 'Refresh current tab',
              onPressed: () {
                final tabIndex =
                  DefaultTabController.of(context).index;
                switch (tabIndex) {
                  case 0:
                    widget.onRefreshPipeline?.call();
                    break;
                  case 1:
                    widget.onRefreshPortfolio?.call();
                    break;
                  case 2:
                    widget.onRefreshRepayment?.call();
                    break;
                }
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 13),
            tabs: [
              Tab(
                icon: Icon(Icons.account_tree_outlined, size: 20),
                text: 'Pipeline'),
              Tab(
                icon: Icon(Icons.pie_chart_outline, size: 20),
                text: 'Portfolio'),
              Tab(
                icon: Icon(Icons.receipt_long_outlined, size: 20),
                text: 'Repayments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPipelineTab(),
            _buildPortfolioTab(),
            _buildRepaymentTab(),
          ],
        ),
      ),
    );
  }
}
