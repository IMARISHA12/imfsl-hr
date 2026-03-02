// IMFSL Loan Restructure Request Widget
// =======================================
// Customer-facing widget: eligible loans list, restructure request form
// (DraggableScrollableSheet), and request history with approval progress.
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslLoanRestructureRequest extends StatefulWidget {
  const ImfslLoanRestructureRequest({
    super.key,
    this.eligibleLoans = const [],
    this.myRequests = const [],
    this.isLoading = false,
    this.onRequestRestructure,
    this.onRefresh,
  });

  final List<Map<String, dynamic>> eligibleLoans;
  final List<Map<String, dynamic>> myRequests;
  final bool isLoading;
  final Function(String loanId, String type, String reason, int? requestedTerm)?
      onRequestRestructure;
  final VoidCallback? onRefresh;

  @override
  State<ImfslLoanRestructureRequest> createState() =>
      _ImfslLoanRestructureRequestState();
}

class _ImfslLoanRestructureRequestState
    extends State<ImfslLoanRestructureRequest> {
  static const Color _primary = Color(0xFF1565C0);
  static const _typeLabels = {
    'EXTENSION': 'Extend repayment period',
    'REFINANCE': 'New terms on remaining balance',
    'RESCHEDULING': 'Modify payment schedule',
  };
  static const _typeIcons = {
    'EXTENSION': Icons.schedule,
    'REFINANCE': Icons.autorenew,
    'RESCHEDULING': Icons.event_note,
  };
  static const _typeColors = {
    'EXTENSION': Color(0xFF1565C0),
    'REFINANCE': Color(0xFF6A1B9A),
    'RESCHEDULING': Color(0xFFEF6C00),
  };

  final _kes = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final _dtFmt = DateFormat('dd MMM yyyy HH:mm');
  String _selectedType = 'EXTENSION';
  final _reasonCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  bool _isSubmitting = false;
  final Set<String> _expanded = {};

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _termCtrl.dispose();
    super.dispose();
  }

  double _d(dynamic v) =>
      v is double ? v : double.tryParse('$v') ?? 0.0;
  int _i(dynamic v) =>
      v is int ? v : int.tryParse('$v') ?? 0;

  void _resetForm() {
    _selectedType = 'EXTENSION';
    _reasonCtrl.clear();
    _termCtrl.clear();
    _isSubmitting = false;
  }

  // ─── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading &&
        widget.eligibleLoans.isEmpty &&
        widget.myRequests.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primary)));
    }
    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh?.call(),
      color: _primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _section('Eligible Loans')),
          if (widget.eligibleLoans.isEmpty)
            SliverToBoxAdapter(
                child: _empty(Icons.check_circle_outline,
                    'No loans eligible for restructuring',
                    sub: 'All your loans are in good standing'))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (_, i) =>
                          _buildEligibleLoanCard(widget.eligibleLoans[i]),
                      childCount: widget.eligibleLoans.length)),
            ),
          SliverToBoxAdapter(
              child: _section('My Restructure Requests')),
          if (widget.myRequests.isEmpty)
            SliverToBoxAdapter(
                child: _empty(Icons.inbox_outlined,
                    'No restructure requests yet',
                    sub: 'Select an eligible loan above to request'))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildRequestCard(widget.myRequests[i]),
                      childCount: widget.myRequests.length)),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final pending =
        widget.myRequests.where((r) => r['status'] == 'PENDING').length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_primary, Color(0xFF0D47A1)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: _primary.withValues(alpha: 0.3),
                blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.build_circle,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loan Restructuring',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Request changes to your loan terms',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _pill('${widget.eligibleLoans.length}', 'Eligible'),
            const SizedBox(width: 8),
            _pill('$pending', 'Pending'),
            const SizedBox(width: 8),
            _pill('${widget.myRequests.length}', 'Total'),
          ]),
        ]),
      ),
    );
  }

  Widget _pill(String val, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Text(val,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style:
                    const TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        ),
      );

  Widget _section(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(t,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121))));

  Widget _empty(IconData ic, String msg, {String? sub}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(ic, color: Colors.grey[400], size: 48),
          const SizedBox(height: 12),
          Text(msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600])),
          if (sub != null) ...[
            const SizedBox(height: 6),
            Text(sub,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ],
        ]),
      ));

  // ─── Eligible Loan Card ────────────────────────────────────────────
  Widget _buildEligibleLoanCard(Map<String, dynamic> loan) {
    final loanNum = loan['loan_number']?.toString() ?? '--';
    final product = loan['product_name']?.toString() ?? 'Loan';
    final balance = _d(loan['outstanding_balance']);
    final arrears = _i(loan['days_in_arrears']);
    final par = loan['par_bucket']?.toString() ?? 'CURRENT';
    final overdue = (loan['loan_status'] == 'OVERDUE') || arrears > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: overdue
                ? const Color(0xFFE57373).withValues(alpha: 0.5)
                : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.account_balance, color: _primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loanNum,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(product,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600])),
                ]),
          ),
          _buildParBucketBadge(par),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outstanding Balance',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(height: 2),
                  Text(_kes.format(balance),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
          ),
          if (overdue)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFD32F2F), size: 16),
                const SizedBox(width: 4),
                Text('$arrears days overdue',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD32F2F))),
              ]),
            ),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openSheet(loan),
            icon: const Icon(Icons.build, size: 18),
            label: const Text('Request Restructure'),
            style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0),
          ),
        ),
      ]),
    );
  }

  // ─── PAR Bucket Badge ──────────────────────────────────────────────
  Widget _buildParBucketBadge(String bucket) {
    final b = bucket.toUpperCase();
    Color bg, fg;
    String label;
    if (b == 'CURRENT') {
      bg = const Color(0xFF4CAF50); fg = const Color(0xFF2E7D32);
      label = 'Current';
    } else if (b == '1-30' || b == 'PAR_1_30') {
      bg = const Color(0xFFFFC107); fg = const Color(0xFFF9A825);
      label = '1-30 days';
    } else if (b == '31-60' || b == 'PAR_31_60') {
      bg = const Color(0xFFFF9800); fg = const Color(0xFFEF6C00);
      label = '31-60 days';
    } else if (b == '61-90' || b == 'PAR_61_90') {
      bg = const Color(0xFFF44336); fg = const Color(0xFFD32F2F);
      label = '61-90 days';
    } else {
      bg = const Color(0xFFB71C1C); fg = const Color(0xFFB71C1C);
      label = '90+ days';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  // ─── Request Form Sheet ────────────────────────────────────────────
  void _openSheet(Map<String, dynamic> loan) {
    _resetForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildRequestFormSheet(loan),
    );
  }

  Widget _buildRequestFormSheet(Map<String, dynamic> loan) {
    return StatefulBuilder(builder: (ctx, setS) {
      final loanNum = loan['loan_number']?.toString() ?? '--';
      final loanId = loan['loan_id']?.toString() ?? '';
      final term = int.tryParse(_termCtrl.text);
      final canSubmit = _reasonCtrl.text.trim().isNotEmpty && !_isSubmitting;

      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24))),
          child: ListView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Center(
                child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
              ),
              Text('Request Restructure',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Loan $loanNum',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 20),
              _label('Restructure Type'),
              const SizedBox(height: 10),
              _buildTypeSelector(setS),
              const SizedBox(height: 20),
              _label('Reason for Request *'),
              const SizedBox(height: 8),
              _field(_reasonCtrl, 'Explain why you need this restructure...',
                  lines: 4, onChanged: () => setS(() {})),
              const SizedBox(height: 20),
              if (_selectedType != 'REFINANCE') ...[
                _label('Requested New Term (months)'),
                const SizedBox(height: 4),
                Text('Optional - leave blank if unsure',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 8),
                _field(_termCtrl, 'e.g. 12',
                    number: true,
                    suffix: 'months',
                    onChanged: () => setS(() {})),
                const SizedBox(height: 20),
              ],
              _buildReviewSummary(loan, term),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: canSubmit
                      ? () {
                          setS(() => _isSubmitting = true);
                          widget.onRequestRestructure?.call(
                              loanId, _selectedType,
                              _reasonCtrl.text.trim(), term);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white)))
                      : const Text('Submit Request',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF424242)));

  Widget _field(TextEditingController c, String hint,
      {int lines = 1,
      bool number = false,
      String? suffix,
      VoidCallback? onChanged}) {
    return TextField(
      controller: c,
      maxLines: lines,
      keyboardType: number ? TextInputType.number : TextInputType.multiline,
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixText: suffix,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 1.5)),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  // ─── Type Selector ─────────────────────────────────────────────────
  Widget _buildTypeSelector(void Function(void Function()) setS) {
    return Wrap(spacing: 8, runSpacing: 8, children: _typeLabels.entries.map((e) {
      final sel = _selectedType == e.key;
      final c = _typeColors[e.key] ?? _primary;
      return ChoiceChip(
        label: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_typeIcons[e.key], size: 16,
              color: sel ? Colors.white : c),
          const SizedBox(width: 6),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.key,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: sel ? Colors.white : c)),
                Text(e.value,
                    style: TextStyle(
                        fontSize: 10,
                        color: sel
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.grey[600])),
              ]),
        ]),
        selected: sel,
        selectedColor: c,
        backgroundColor: c.withValues(alpha: 0.08),
        side: BorderSide(
            color: sel ? c : c.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        onSelected: (_) => setS(() {
          _selectedType = e.key;
          if (e.key == 'REFINANCE') _termCtrl.clear();
        }),
      );
    }).toList());
  }

  // ─── Review Summary ────────────────────────────────────────────────
  Widget _buildReviewSummary(Map<String, dynamic> loan, int? newTerm) {
    final c = _typeColors[_selectedType] ?? _primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.summarize, color: Colors.grey[600], size: 18),
          const SizedBox(width: 8),
          const Text('Review Summary',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF424242))),
        ]),
        const SizedBox(height: 14),
        _row('Loan Number', loan['loan_number']?.toString() ?? '--'),
        const SizedBox(height: 8),
        _row('Outstanding Balance',
            _kes.format(_d(loan['outstanding_balance']))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Restructure Type',
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: c.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(_selectedType,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: c)),
          ),
        ]),
        if (newTerm != null) ...[
          const SizedBox(height: 8),
          _row('Requested New Term', '$newTerm months'),
        ],
      ]),
    );
  }

  Widget _row(String l, String v) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Text(v,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121))),
      ]);

  // ─── Request Card ──────────────────────────────────────────────────
  Widget _buildRequestCard(Map<String, dynamic> req) {
    final id = req['id']?.toString() ?? '';
    final loanNum = req['loan_number']?.toString() ?? '--';
    final type = req['restructure_type']?.toString() ?? 'EXTENSION';
    final status = req['status']?.toString() ?? 'PENDING';
    final reason = req['reason']?.toString() ?? '';
    final rTerm = _i(req['requested_term']);
    final newTerms = req['new_terms'] as Map<String, dynamic>? ?? {};
    final progress =
        req['approval_progress'] as Map<String, dynamic>? ?? {};
    final created = req['created_at']?.toString() ?? '';
    final open = _expanded.contains(id);
    DateTime? dt;
    try { dt = DateTime.parse(created); } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() =>
              open ? _expanded.remove(id) : _expanded.add(id)),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loanNum,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                            if (dt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(_dtFmt.format(dt),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500])),
                              ),
                          ]),
                    ),
                    _typeBadge(type),
                    const SizedBox(width: 6),
                    _buildStatusBadge(status),
                  ]),
                  if (progress.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildApprovalProgressBar(progress),
                  ],
                  const SizedBox(height: 8),
                  Center(
                      child: Icon(
                          open
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
                          size: 20)),
                ]),
          ),
        ),
        if (open)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14))),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  if (reason.isNotEmpty) ...[
                    Text('Reason',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(reason,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF424242))),
                    const SizedBox(height: 12),
                  ],
                  if (rTerm > 0) ...[
                    _row('Requested Term', '$rTerm months'),
                    const SizedBox(height: 8),
                  ],
                  if (newTerms.isNotEmpty) ...[
                    Text('Approved New Terms',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600])),
                    const SizedBox(height: 6),
                    ...newTerms.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _row(_fmtKey(e.key),
                            e.value?.toString() ?? '--'))),
                  ],
                ]),
          ),
      ]),
    );
  }

  String _fmtKey(String k) => k
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) =>
          w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  Widget _typeBadge(String type) {
    final c = _typeColors[type] ?? _primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(type,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: c)),
    );
  }

  // ─── Status Badge ──────────────────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    final Color bg, fg;
    final IconData ic;
    switch (status.toUpperCase()) {
      case 'APPROVED':
        bg = const Color(0xFF4CAF50); fg = const Color(0xFF2E7D32);
        ic = Icons.check_circle;
        break;
      case 'REJECTED':
        bg = const Color(0xFFF44336); fg = const Color(0xFFD32F2F);
        ic = Icons.cancel;
        break;
      default:
        bg = const Color(0xFFFF9800); fg = const Color(0xFFEF6C00);
        ic = Icons.hourglass_bottom;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ic, size: 12, color: fg),
        const SizedBox(width: 4),
        Text(status,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
      ]),
    );
  }

  // ─── Approval Progress Bar ─────────────────────────────────────────
  Widget _buildApprovalProgressBar(Map<String, dynamic> progress) {
    final step = _i(progress['step_number']);
    final total = _i(progress['total_steps']);
    final role = progress['current_step_role']?.toString() ?? '';
    if (total == 0) return const SizedBox.shrink();
    final pct = (step / total).clamp(0.0, 1.0);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Approval Progress',
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Text('Step $step of $total',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242))),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
              pct >= 1.0 ? const Color(0xFF4CAF50) : _primary),
        ),
      ),
      if (role.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Awaiting: $role',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500])),
        ),
    ]);
  }
}
