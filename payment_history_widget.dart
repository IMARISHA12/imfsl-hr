// IMFSL Payment History Timeline - FlutterFlow Custom Widget
// ===========================================================
// Customer-facing payment history with loan summary header and
// chronological timeline of repayment transactions.
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentHistoryWidget extends StatefulWidget {
  const PaymentHistoryWidget({
    super.key,
    this.historyData = const {},
    this.isLoading = false,
    this.onLoadMore,
    this.onBack,
  });

  final Map<String, dynamic> historyData;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final VoidCallback? onBack;

  @override
  State<PaymentHistoryWidget> createState() => _PaymentHistoryWidgetState();
}

class _PaymentHistoryWidgetState extends State<PaymentHistoryWidget> {
  static const _primary = Color(0xFF1565C0);
  static const _primaryDark = Color(0xFF0D47A1);
  static const _green = Color(0xFF2E7D32);
  static const _red = Color(0xFFC62828);
  static const _darkRed = Color(0xFF8B0000);
  static const _grey = Color(0xFF757575);
  static const _lightGrey = Color(0xFFE0E0E0);
  static const _brown = Color(0xFF795548);

  final _fmt = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final _dateFmt = DateFormat('dd MMM yyyy, HH:mm');

  // ── Data accessors ────────────────────────────────────────

  Map<String, dynamic> get _loan {
    final raw = widget.historyData['loan'];
    return raw is Map<String, dynamic> ? raw : {};
  }

  List<Map<String, dynamic>> get _payments {
    final raw = widget.historyData['payments'];
    if (raw is List) return raw.whereType<Map<String, dynamic>>().toList(growable: false);
    return [];
  }

  bool get _hasData => widget.historyData['success'] == true && _loan.isNotEmpty;

  // ── Helpers ───────────────────────────────────────────────

  double _dbl(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  String _str(dynamic v) => v?.toString() ?? '';

  Color _statusColor(String s) {
    switch (s) {
      case 'ACTIVE': return _green;
      case 'OVERDUE': return _red;
      case 'DEFAULTED': return _darkRed;
      default: return _grey; // CLOSED and unknown
    }
  }

  Color _channelColor(String ch) {
    switch (ch.toUpperCase()) {
      case 'M-PESA': case 'MPESA': return _green;
      case 'BANK': return _primary;
      case 'CASH': return _brown;
      default: return _grey;
    }
  }

  String _channelLabel(String ch) {
    switch (ch.toUpperCase()) {
      case 'M-PESA': case 'MPESA': return 'M-PESA';
      case 'BANK': return 'BANK';
      case 'CASH': return 'CASH';
      default: return 'OTHER';
    }
  }

  String _fmtDate(String iso) {
    try { return _dateFmt.format(DateTime.parse(iso)); }
    catch (_) { return iso; }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (widget.onBack != null) _buildBackBar(),
      if (widget.isLoading && !_hasData)
        const Expanded(child: Center(child: CircularProgressIndicator(color: _primary)))
      else if (_hasData) ...[
        _buildLoanSummaryHeader(),
        const SizedBox(height: 4),
        Expanded(child: _buildPaymentList()),
      ] else
        Expanded(child: _buildEmpty('No payments recorded yet', null)),
    ]);
  }

  // ── Back bar ──────────────────────────────────────────────

  Widget _buildBackBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: widget.onBack,
          tooltip: 'Back',
        ),
        const Text('Payment History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _primary)),
      ]),
    );
  }

  // ── Loan Summary Header ───────────────────────────────────

  Widget _buildLoanSummaryHeader() {
    final loanNumber = _str(_loan['loan_number']);
    final productName = _str(_loan['product_name']);
    final principal = _dbl(_loan['principal_amount']);
    final outstanding = _dbl(_loan['outstanding_balance']);
    final totalPaid = _dbl(_loan['total_paid']);
    final progressPct = _dbl(_loan['progress_pct']);
    final status = _str(_loan['status']).toUpperCase();
    final progress = (progressPct / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _primaryDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Loan number + status badge
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(loanNumber, style: const TextStyle(
              color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(productName, style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ])),
          _buildStatusBadge(status),
        ]),
        const SizedBox(height: 16),

        // Principal
        _headerLabel('Principal'),
        Text(_fmt.format(principal), style: const TextStyle(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 14),

        // Outstanding balance (hero)
        _headerLabel('Outstanding Balance'),
        Text(_fmt.format(outstanding), style: const TextStyle(
          color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),

        // Total paid
        _headerLabel('Total Paid'),
        Text(_fmt.format(totalPaid), style: const TextStyle(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress, minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF81C784)),
          ),
        ),
        const SizedBox(height: 6),
        Text('${progressPct.toStringAsFixed(1)}% repaid',
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _headerLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12)),
  );

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85), borderRadius: BorderRadius.circular(12)),
      child: Text(status.isNotEmpty ? status : 'UNKNOWN', style: const TextStyle(
        color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  // ── Payment List ──────────────────────────────────────────

  Widget _buildPaymentList() {
    if (_payments.isEmpty) {
      return _buildEmpty('No payments recorded yet', 'Your repayment history will appear here');
    }
    final itemCount = _payments.length + (widget.onLoadMore != null ? 1 : 0);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: itemCount,
      itemBuilder: (context, i) => i == _payments.length ? _buildLoadMore() : _buildTimelineItem(i),
    );
  }

  // ── Timeline Item ─────────────────────────────────────────

  Widget _buildTimelineItem(int index) {
    final p = _payments[index];
    final isFirst = index == 0;
    final isLast = index == _payments.length - 1 && widget.onLoadMore == null;
    final date = _str(p['date']);
    final amount = _dbl(p['amount']);
    final channel = _str(p['channel']);
    final ref = _str(p['reference']);
    final desc = _str(p['description']);
    final txnRef = _str(p['transaction_ref']);

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Timeline decoration
        SizedBox(width: 32, child: Column(children: [
          isFirst
              ? const Expanded(child: SizedBox())
              : Expanded(child: Container(width: 2, color: _lightGrey)),
          Container(width: 12, height: 12, decoration: BoxDecoration(
            color: _primary, shape: BoxShape.circle,
            border: Border.all(color: _primary.withOpacity(0.3), width: 3),
          )),
          isLast
              ? const Expanded(child: SizedBox())
              : Expanded(child: Container(width: 2, color: _lightGrey)),
        ])),
        const SizedBox(width: 12),

        // Content card
        Expanded(child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 6,
              offset: const Offset(0, 2))],
            border: Border.all(color: Colors.grey.shade200, width: 0.5),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Date
            Text(_fmtDate(date), style: TextStyle(
              fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            // Amount + channel
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_fmt.format(amount), style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
              _buildChannelChip(channel),
            ]),
            const SizedBox(height: 8),
            // Reference
            if (ref.isNotEmpty)
              _monoText('Ref: $ref', Colors.grey.shade500, 12),
            // Transaction ref (if different from reference)
            if (txnRef.isNotEmpty && txnRef != ref)
              _monoText('Txn: $txnRef', Colors.grey.shade400, 11),
            // Description
            if (desc.isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 4),
                child: Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  maxLines: 2, overflow: TextOverflow.ellipsis)),
          ]),
        )),
      ]),
    );
  }

  Widget _monoText(String text, Color color, double size) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: TextStyle(
      fontSize: size, color: color, fontFamily: 'monospace', letterSpacing: 0.3)),
  );

  // ── Channel Chip ──────────────────────────────────────────

  Widget _buildChannelChip(String channel) {
    final color = _channelColor(channel);
    final label = _channelLabel(channel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(
        color: color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
    );
  }

  // ── Load More ─────────────────────────────────────────────

  Widget _buildLoadMore() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Center(
        child: widget.isLoading
            ? const SizedBox(width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: _primary))
            : OutlinedButton.icon(
                onPressed: widget.onLoadMore,
                icon: const Icon(Icons.expand_more, size: 20),
                label: const Text('Load More Payments'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────

  Widget _buildEmpty(String title, String? subtitle) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(
          fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ]),
    ));
  }
}
