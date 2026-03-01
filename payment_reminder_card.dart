// IMFSL Payment Reminder Card - Customer Home Screen
// States: Empty (checkmark), Active (overdue banner + next payment + actions), Loading (shimmer).
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentReminderCard extends StatelessWidget {
  const PaymentReminderCard({
    super.key,
    this.upcomingData = const {},
    this.isLoading = false,
    this.onPayNow,
    this.onViewAll,
    this.onRefresh,
  });

  final Map<String, dynamic> upcomingData;
  final bool isLoading;
  final VoidCallback? onPayNow;
  final VoidCallback? onViewAll;
  final VoidCallback? onRefresh;

  static const _blue = Color(0xFF1565C0);
  static const _red = Color(0xFFC62828);
  static const _green = Color(0xFF2E7D32);
  static const _grey = Color(0xFF757575);
  static final _kes = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  static final _dateFmt = DateFormat('dd MMM yyyy');

  List<Map<String, dynamic>> get _inst {
    final r = upcomingData['installments'];
    return r is List ? r.cast<Map<String, dynamic>>() : [];
  }

  Map<String, dynamic> get _sum =>
      upcomingData['summary'] is Map<String, dynamic>
          ? upcomingData['summary'] as Map<String, dynamic>
          : {};

  double _d(dynamic v) => v is double ? v : (v is int ? v.toDouble() : (v is String ? double.tryParse(v) ?? 0 : 0));
  int _i(dynamic v) => v is int ? v : (v is double ? v.round() : (v is String ? int.tryParse(v) ?? 0 : 0));

  String _fmtDate(String? s) {
    if (s == null || s.isEmpty) return '--';
    final dt = DateTime.tryParse(s);
    return dt != null ? _dateFmt.format(dt) : s;
  }

  bool get _hasData => _inst.isNotEmpty || _d(_sum['total_overdue']) > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: isLoading ? _loading() : (_hasData ? _active() : _empty()),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────
  Widget _loading() {
    Widget bar({double? w, double h = 16}) => Container(
        width: w, height: h,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        bar(w: 160, h: 16), const SizedBox(height: 12),
        bar(h: 48), const SizedBox(height: 12),
        bar(w: 200, h: 14), const SizedBox(height: 12),
        Row(children: [Expanded(child: bar(h: 14)), const SizedBox(width: 16), Expanded(child: bar(h: 14))]),
        const SizedBox(height: 16), bar(h: 40),
      ]),
    );
  }

  // ── Empty ──────────────────────────────────────────────────────────────
  Widget _empty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: _green.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.check_circle, color: _green, size: 24),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('No Upcoming Payments',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
        const SizedBox(height: 2),
        const Text('You are all caught up!', style: TextStyle(fontSize: 13, color: _grey)),
      ])),
      if (onRefresh != null)
        IconButton(icon: const Icon(Icons.refresh, size: 20, color: _grey), onPressed: onRefresh, splashRadius: 20),
    ]),
  );

  // ── Active ─────────────────────────────────────────────────────────────
  Widget _active() {
    final overdue = _d(_sum['total_overdue']);
    final dueMonth = _d(_sum['total_due_this_month']);
    final nextDate = _sum['next_due_date']?.toString();

    Map<String, dynamic>? next, worst;
    for (final i in _inst) {
      final d = _i(i['days_until_due']);
      if (d < 0) { if (worst == null || d < _i(worst['days_until_due'])) worst = i; }
      else { next ??= i; }
    }
    next ??= _inst.isNotEmpty ? _inst.first : null;

    final amt = next != null ? _d(next['amount_due']) : dueMonth;
    final loan = next?['loan_number']?.toString();

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Overdue banner
      if (overdue > 0) _overdueBanner(overdue, worst),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Next payment info (only when not overdue)
        if (nextDate != null && overdue <= 0) ...[
          _nextPayment(nextDate, next),
          const SizedBox(height: 12),
        ],
        // Amount
        Text(_kes.format(amt),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
        if (loan != null && loan.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text('Loan $loan', style: const TextStyle(fontSize: 13, color: _grey)),
        ],
        const SizedBox(height: 12),
        // Summary row
        _summaryRow(dueMonth, overdue),
        const SizedBox(height: 16),
        // Actions
        _actions(),
      ])),
    ]);
  }

  // ── Overdue Banner ─────────────────────────────────────────────────────
  Widget _overdueBanner(double total, Map<String, dynamic>? worst) {
    final days = worst != null ? _i(worst['days_until_due']).abs() : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: _red,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_amber, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text('OVERDUE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.8)),
          const Spacer(),
          Text(_kes.format(total),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        if (days > 0) ...[
          const SizedBox(height: 4),
          Text('$days day${days == 1 ? '' : 's'} overdue',
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
        ],
      ]),
    );
  }

  // ── Next Payment ───────────────────────────────────────────────────────
  Widget _nextPayment(String date, Map<String, dynamic>? inst) {
    final days = inst != null ? _i(inst['days_until_due']) : 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _blue.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.calendar_today, size: 18, color: _blue),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Next Payment Due',
              style: TextStyle(fontSize: 12, color: _blue.withOpacity(0.7), fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(_fmtDate(date),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Text('Due in $days day${days == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _blue)),
        ),
      ]),
    );
  }

  // ── Summary Row ────────────────────────────────────────────────────────
  Widget _summaryRow(double dueMonth, double overdue) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Due this month', style: TextStyle(fontSize: 11, color: _grey)),
        const SizedBox(height: 2),
        Text(_kes.format(dueMonth),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
      ])),
      Container(width: 1, height: 28, color: Colors.grey.shade300),
      Expanded(child: Padding(padding: const EdgeInsets.only(left: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Overdue', style: TextStyle(fontSize: 11, color: _grey)),
          const SizedBox(height: 2),
          Text(_kes.format(overdue), style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: overdue > 0 ? _red : const Color(0xFF212121))),
        ]),
      )),
    ]),
  );

  // ── Action Buttons ─────────────────────────────────────────────────────
  Widget _actions() => Row(children: [
    Expanded(child: ElevatedButton.icon(
      onPressed: onPayNow,
      icon: const Icon(Icons.payment, size: 18),
      label: const Text('Pay Now'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _blue, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    )),
    const SizedBox(width: 12),
    TextButton.icon(
      onPressed: onViewAll,
      icon: const Icon(Icons.history, size: 18),
      label: const Text('View History'),
      style: TextButton.styleFrom(
        foregroundColor: _blue,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    ),
  ]);
}
