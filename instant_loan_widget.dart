// IMFSL Instant Loan Widget - 2-Step Fast Loan Application
// ========================================================
// A streamlined 2-step loan application flow for pre-qualified customers.
//
// Step 1 (Offer):
//   - Pre-qualified amount banner with gradient design
//   - Amount slider (min_amount to max_amount) with quick-pick chips
//   - Tenure selector (1-6 months) with animated chip grid
//   - Live EMI calculator showing monthly installment, interest, fees, total
//   - Optional credit score pill display
//   - "Get Money Now" green CTA button with estimated time badge
//
// Step 2 (Confirm):
//   - Full loan summary card (amount, tenure, rate, EMI, fees, total)
//   - Disbursement details (M-PESA phone number, net amount)
//   - Repayment schedule timeline preview
//   - Terms & Conditions checkbox (required to proceed)
//   - "Confirm & Get Money" button (disabled until terms accepted)
//   - "Go Back" text button to return to Step 1
//
// After submit: calls onApply callback with full payload and shows
// a brief "Processing..." state with spinner.
//
// EMI Calculation (FLAT rate method):
//   total_interest = principal * annual_rate / 100 * months / 12
//   monthly = (principal + total_interest) / months
//   processing_fee = principal * processing_fee_pct / 100
//   net_disbursement = principal - processing_fee
//
// Product Map expected keys:
//   {id, product_name, min_amount, max_amount, interest_rate_annual,
//    min_tenure_months, max_tenure_months, processing_fee_pct}
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InstantLoanWidget extends StatefulWidget {
  const InstantLoanWidget({
    super.key,
    required this.prequalifiedAmount,
    required this.product,
    this.creditScore = 0,
    this.customerPhone = '',
    this.deviceDbId,
    required this.onApply,
    required this.onCancel,
  });

  /// The pre-qualified loan amount for this customer.
  final double prequalifiedAmount;

  /// Loan product configuration map. Expected keys:
  /// id, product_name, min_amount, max_amount, interest_rate_annual,
  /// min_tenure_months, max_tenure_months, processing_fee_pct.
  final Map<String, dynamic> product;

  /// Customer credit score (0 = hidden, >0 = displayed as pill).
  final int creditScore;

  /// Customer phone number where M-PESA disbursement will be sent.
  final String customerPhone;

  /// Optional device/session DB identifier for audit trail.
  final String? deviceDbId;

  /// Callback with full application payload map on final submission.
  final Function(Map<String, dynamic>) onApply;

  /// Callback invoked when the user cancels the entire flow.
  final VoidCallback onCancel;

  @override
  State<InstantLoanWidget> createState() => _InstantLoanWidgetState();
}

class _InstantLoanWidgetState extends State<InstantLoanWidget>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Design tokens
  // ---------------------------------------------------------------------------
  static const _primary = Color(0xFF1565C0);
  static const _green = Color(0xFF2E7D32);
  static const _warn = Color(0xFFF57F17);
  static const _bg = Color(0xFFF5F7FA);
  static const _border = Color(0xFFE0E0E0);
  static const _txt1 = Color(0xFF212121);
  static const _txt2 = Color(0xFF757575);

  // ---------------------------------------------------------------------------
  // Formatters
  // ---------------------------------------------------------------------------
  final _cur = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final _cur0 = NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);
  final _pct = NumberFormat('0.0#');

  // ---------------------------------------------------------------------------
  // Mutable state
  // ---------------------------------------------------------------------------
  int _step = 0; // 0 = Offer, 1 = Confirm
  bool _terms = false;
  bool _processing = false;

  late double _amount;
  late int _tenure;

  // ---------------------------------------------------------------------------
  // Parsed product fields
  // ---------------------------------------------------------------------------
  late double _minAmt, _maxAmt, _rate, _feePct;
  late int _minTen, _maxTen;
  late String _prodName, _prodId;

  // ---------------------------------------------------------------------------
  // Animation
  // ---------------------------------------------------------------------------
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _parseProduct();
    _amount = widget.prequalifiedAmount.clamp(_minAmt, _maxAmt);
    _tenure = _minTen;
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _parseProduct() {
    final p = widget.product;
    _prodId = (p['id'] ?? '').toString();
    _prodName = p['product_name'] as String? ?? 'Instant Loan';
    _minAmt = (p['min_amount'] as num?)?.toDouble() ?? 500;
    _maxAmt = (p['max_amount'] as num?)?.toDouble() ?? 100000;
    _minTen = ((p['min_tenure_months'] as num?)?.toInt() ?? 1).clamp(1, 6);
    _maxTen = ((p['max_tenure_months'] as num?)?.toInt() ?? 6).clamp(1, 6);
    if (_minTen > _maxTen) _minTen = _maxTen;
    _rate = (p['interest_rate_annual'] as num?)?.toDouble() ?? 12.0;
    _feePct = (p['processing_fee_pct'] as num?)?.toDouble() ?? 1.0;
  }

  // ---------------------------------------------------------------------------
  // EMI calculations (FLAT rate method)
  // ---------------------------------------------------------------------------
  double get _interest => _amount * _rate / 100.0 * _tenure / 12.0;
  double get _total => _amount + _interest;
  double get _emi => _tenure > 0 ? _total / _tenure : 0;
  double get _fee => _amount * _feePct / 100.0;
  double get _net => _amount - _fee;

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------
  void _next() { setState(() => _step = 1); _anim.reset(); _anim.forward(); }
  void _back() { setState(() { _step = 0; _terms = false; }); _anim.reset(); _anim.forward(); }

  Future<void> _submit() async {
    if (!_terms || _processing) return;
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    widget.onApply({
      'product_id': _prodId, 'product_name': _prodName,
      'requested_amount': _amount, 'tenure_months': _tenure,
      'interest_rate_annual': _rate, 'monthly_installment': _emi,
      'total_interest': _interest, 'total_repayable': _total,
      'processing_fee': _fee, 'processing_fee_pct': _feePct,
      'net_disbursement': _net, 'customer_phone': widget.customerPhone,
      'credit_score': widget.creditScore, 'device_db_id': widget.deviceDbId,
      'applied_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  double _round(double v) => (v / 500).round() * 500.0;

  String _mask(String ph) {
    if (ph.length < 6) return ph;
    return '${ph.substring(0, 4)}${'*' * (ph.length - 6)}${ph.substring(ph.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          _topBar(),
          _stepBar(),
          Expanded(
            child: _processing ? _processingView() : FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: _step == 0 ? _offerStep() : _confirmStep(),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ---- Top Bar ----
  Widget _topBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: _border, width: 0.5)),
    ),
    child: Row(children: [
      _iconBtn(_step == 0 ? Icons.close : Icons.arrow_back,
          _processing ? null : (_step == 0 ? widget.onCancel : _back)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_prodName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _txt1)),
        const SizedBox(height: 2),
        Text('Step ${_step + 1} of 2 - ${_step == 0 ? 'Choose your offer' : 'Review & confirm'}',
            style: const TextStyle(fontSize: 12, color: _txt2)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _green.withOpacity(0.3)),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bolt, size: 14, color: _green),
          SizedBox(width: 4),
          Text('~2 min', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _green)),
        ]),
      ),
    ]),
  );

  Widget _iconBtn(IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 20, color: _txt1),
    ),
  );

  // ---- Step Indicator ----
  Widget _stepBar() => Container(
    color: Colors.white,
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
    child: Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: _step == 0 ? 0.5 : 1.0, minHeight: 4,
          backgroundColor: _border,
          valueColor: AlwaysStoppedAnimation(_step == 0 ? _primary : _green),
        ),
      ),
      const SizedBox(height: 8),
      Row(children: [_stepDot(0, 'Offer'), const Spacer(), _stepDot(1, 'Confirm')]),
    ]),
  );

  Widget _stepDot(int s, String label) {
    final active = _step >= s;
    final cur = _step == s;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: active ? _primary : Colors.white, shape: BoxShape.circle,
          border: Border.all(color: active ? _primary : _border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: active && !cur
            ? const Icon(Icons.check, size: 13, color: Colors.white)
            : Text('${s + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: active ? Colors.white : _txt2)),
      ),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12,
          fontWeight: cur ? FontWeight.w600 : FontWeight.w400,
          color: cur ? _primary : _txt2)),
    ]);
  }

  // ===========================================================================
  // STEP 1: OFFER
  // ===========================================================================
  Widget _offerStep() => SingleChildScrollView(
    padding: const EdgeInsets.all(16), physics: const BouncingScrollPhysics(),
    child: Column(children: [
      _prequal(), const SizedBox(height: 16),
      _amountCard(), const SizedBox(height: 16),
      _tenureCard(), const SizedBox(height: 16),
      _emiCard(), const SizedBox(height: 12),
      if (widget.creditScore > 0) ...[_creditPill(), const SizedBox(height: 12)],
      _disbNote(), const SizedBox(height: 24),
      _greenBtn('Get Money Now', Icons.bolt, _next),
      const SizedBox(height: 8),
      TextButton(onPressed: widget.onCancel,
          child: const Text('Not now', style: TextStyle(fontSize: 14, color: _txt2))),
      const SizedBox(height: 16),
    ]),
  );

  // Pre-qualified banner
  Widget _prequal() => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.verified, color: Colors.white, size: 18)),
        const SizedBox(width: 8),
        const Text('You\'re Pre-Qualified!',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
      ]),
      const SizedBox(height: 12),
      Text(_cur0.format(widget.prequalifiedAmount),
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
        child: Text('Up to ${_cur0.format(_maxAmt)} available',
            style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
      ),
    ]),
  );

  // Amount selector
  Widget _amountCard() => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _cardHeader(Icons.account_balance_wallet_outlined, 'How much do you need?'),
    const SizedBox(height: 20),
    Center(child: Text(_cur0.format(_amount),
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _primary))),
    const SizedBox(height: 8),
    SliderTheme(
      data: SliderThemeData(
        activeTrackColor: _primary, inactiveTrackColor: _primary.withOpacity(0.15),
        thumbColor: _primary, overlayColor: _primary.withOpacity(0.12), trackHeight: 5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      child: Slider(
        value: _amount, min: _minAmt, max: _maxAmt,
        divisions: ((_maxAmt - _minAmt) / 500).round().clamp(1, 9999),
        onChanged: (v) => setState(() => _amount = _round(v)),
      ),
    ),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_cur0.format(_minAmt), style: const TextStyle(fontSize: 11, color: _txt2)),
        Text(_cur0.format(_maxAmt), style: const TextStyle(fontSize: 11, color: _txt2)),
      ])),
    const SizedBox(height: 12),
    _quickPicks(),
  ]));

  Widget _quickPicks() {
    final r = _maxAmt - _minAmt;
    final picks = <double>{_minAmt, _round(_minAmt + r * 0.25), _round(_minAmt + r * 0.5),
        _round(_minAmt + r * 0.75), _maxAmt}.where((v) => v >= _minAmt && v <= _maxAmt).toList()..sort();
    return Wrap(spacing: 8, runSpacing: 8, children: picks.map((a) {
      final sel = (_amount - a).abs() < 1;
      return GestureDetector(onTap: () => setState(() => _amount = a),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? _primary : Colors.white, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? _primary : _border)),
          child: Text(_cur0.format(a), style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w600, color: sel ? Colors.white : _txt1)),
        ));
    }).toList());
  }

  // Tenure selector
  Widget _tenureCard() => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _cardHeader(Icons.calendar_month_outlined, 'Repayment period'),
    const SizedBox(height: 20),
    Center(child: RichText(text: TextSpan(children: [
      TextSpan(text: '$_tenure',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _primary)),
      TextSpan(text: ' month${_tenure == 1 ? '' : 's'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _txt2)),
    ]))),
    const SizedBox(height: 14),
    Center(child: Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
      children: List.generate(_maxTen - _minTen + 1, (i) => _minTen + i).map((m) {
        final sel = _tenure == m;
        return GestureDetector(onTap: () => setState(() => _tenure = m),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: sel ? _primary : Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sel ? _primary : _border, width: sel ? 2 : 1),
              boxShadow: sel ? [BoxShadow(color: _primary.withOpacity(0.25), blurRadius: 8)] : null),
            alignment: Alignment.center,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$m', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : _txt1)),
              Text('mo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                  color: sel ? Colors.white70 : _txt2)),
            ]),
          ));
      }).toList())),
  ]));

  // EMI breakdown
  Widget _emiCard() => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      _iconCircle(Icons.calculate_outlined, _green),
      const SizedBox(width: 10),
      const Expanded(child: Text('Loan Breakdown',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _txt1))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: _primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Text('${_pct.format(_rate)}% p.a.',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _primary)),
      ),
    ]),
    const SizedBox(height: 20),
    // Monthly installment highlight
    Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _green.withOpacity(0.05), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _green.withOpacity(0.2))),
      child: Column(children: [
        const Text('Monthly Installment', style: TextStyle(fontSize: 12, color: _txt2)),
        const SizedBox(height: 4),
        Text(_cur.format(_emi),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _green)),
        Text('for $_tenure month${_tenure == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 12, color: _txt2)),
      ]),
    ),
    const SizedBox(height: 16),
    _brkRow('Principal Amount', _cur.format(_amount), Icons.account_balance_wallet_outlined),
    const Divider(height: 1, color: _border),
    _brkRow('Total Interest', _cur.format(_interest), Icons.trending_up,
        sub: '${_pct.format(_rate)}% flat x $_tenure mo'),
    const Divider(height: 1, color: _border),
    _brkRow('Processing Fee', _cur.format(_fee), Icons.receipt_long_outlined,
        sub: '${_pct.format(_feePct)}% of principal'),
    const Divider(height: 1, color: _border),
    _brkRow('Total Repayable', _cur.format(_total), Icons.payments_outlined, bold: true),
  ]));

  Widget _brkRow(String label, String value, IconData icon, {String? sub, bool bold = false}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [
      Icon(icon, size: 16, color: bold ? _primary : _txt2), const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 13,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: bold ? _txt1 : _txt2)),
        if (sub != null) Text(sub, style: const TextStyle(fontSize: 11, color: _txt2)),
      ])),
      Text(value, style: TextStyle(fontSize: bold ? 15 : 14,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          color: bold ? _primary : _txt1)),
    ]));

  // Credit score pill
  Widget _creditPill() {
    final s = widget.creditScore;
    final (Color c, String l) = s >= 700 ? (_green, 'Excellent')
        : s >= 600 ? (_primary, 'Good') : s >= 500 ? (_warn, 'Fair') : (Colors.red, 'Needs Work');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: c.withOpacity(0.06), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.2))),
      child: Row(children: [
        Icon(Icons.shield_outlined, size: 18, color: c), const SizedBox(width: 10),
        Expanded(child: Text('Credit Score: $s',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Text(l, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
        ),
      ]),
    );
  }

  // Disbursement note
  Widget _disbNote() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: _primary.withOpacity(0.04), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primary.withOpacity(0.12))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline, size: 18, color: _primary.withOpacity(0.7)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('You will receive ${_cur.format(_net)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _txt1)),
        const SizedBox(height: 2),
        Text('Processing fee of ${_cur.format(_fee)} will be deducted upfront.',
            style: const TextStyle(fontSize: 12, color: _txt2)),
      ])),
    ]),
  );

  // ===========================================================================
  // STEP 2: CONFIRM
  // ===========================================================================
  Widget _confirmStep() => SingleChildScrollView(
    padding: const EdgeInsets.all(16), physics: const BouncingScrollPhysics(),
    child: Column(children: [
      _confirmHeader(), const SizedBox(height: 16),
      _summaryCard(), const SizedBox(height: 16),
      _disbCard(), const SizedBox(height: 16),
      _scheduleCard(), const SizedBox(height: 16),
      _termsBox(), const SizedBox(height: 20),
      _confirmBtn(), const SizedBox(height: 10),
      TextButton.icon(onPressed: _back,
          icon: const Icon(Icons.arrow_back, size: 18, color: _txt2),
          label: const Text('Go Back', style: TextStyle(fontSize: 14, color: _txt2))),
      const SizedBox(height: 16),
    ]),
  );

  Widget _confirmHeader() => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [_green, _green.withOpacity(0.85)]),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: _green.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Column(children: [
      Container(padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
        child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 32)),
      const SizedBox(height: 12),
      const Text('Almost there!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70)),
      const SizedBox(height: 4),
      const Text('Review your loan details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
    ]),
  );

  // Summary card
  Widget _summaryCard() => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      const Icon(Icons.summarize_outlined, size: 18, color: _primary), const SizedBox(width: 8),
      const Expanded(child: Text('Loan Summary',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _txt1))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: _primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Text(_prodName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _primary)),
      ),
    ]),
    const SizedBox(height: 16),
    _sumRow('Loan Amount', _cur.format(_amount)),
    _sumRow('Tenure', '$_tenure month${_tenure == 1 ? '' : 's'}'),
    _sumRow('Interest Rate', '${_pct.format(_rate)}% p.a. (flat)'),
    _sumRow('Monthly Payment', _cur.format(_emi), vc: _green, bold: true),
    _sumRow('Total Interest', _cur.format(_interest)),
    _sumRow('Processing Fee', _cur.format(_fee), sub: '${_pct.format(_feePct)}% of principal'),
    _sumRow('Total Repayable', _cur.format(_total), bold: true, vc: _primary),
  ]));

  Widget _sumRow(String label, String value, {Color? vc, bool bold = false, String? sub}) =>
    Column(children: [
      const Divider(height: 1, color: _border),
      Padding(padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: bold ? _txt1 : _txt2)),
            if (sub != null) Padding(padding: const EdgeInsets.only(top: 2),
                child: Text(sub, style: const TextStyle(fontSize: 11, color: _txt2))),
          ])),
          Text(value, style: TextStyle(fontSize: bold ? 15 : 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: vc ?? _txt1)),
        ])),
    ]);

  // Disbursement card
  Widget _disbCard() {
    final ph = widget.customerPhone.isNotEmpty ? widget.customerPhone : 'Not provided';
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.phone_android, size: 18, color: _green), SizedBox(width: 8),
        Text('Disbursement Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _txt1)),
      ]),
      const SizedBox(height: 16),
      Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _green.withOpacity(0.04), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _green.withOpacity(0.15))),
        child: Column(children: [
          Row(children: [
            _iconCircle(Icons.send_to_mobile, _green),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('M-PESA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                  color: _txt2, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(_mask(ph), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: _txt1, letterSpacing: 1)),
            ])),
            const Icon(Icons.check_circle, color: _green, size: 22),
          ]),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('You will receive', style: TextStyle(fontSize: 13, color: _txt2)),
              Text(_cur.format(_net),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _green)),
            ]),
          ),
        ]),
      ),
    ]));
  }

  // Schedule preview
  Widget _scheduleCard() {
    final now = DateTime.now();
    final df = DateFormat('dd MMM yyyy');
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.event_note_outlined, size: 18, color: _primary), SizedBox(width: 8),
        Text('Repayment Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _txt1)),
      ]),
      const SizedBox(height: 14),
      ...List.generate(_tenure, (i) {
        final due = DateTime(now.year, now.month + i + 1, now.day);
        final isLast = i == _tenure - 1;
        return Column(children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
            Container(width: 28, height: 28,
              decoration: BoxDecoration(color: _primary.withOpacity(0.08), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _primary))),
            const SizedBox(width: 12),
            Expanded(child: Text(df.format(due), style: const TextStyle(fontSize: 13, color: _txt2))),
            Text(_cur.format(_emi), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _txt1)),
          ])),
          if (!isLast) Padding(padding: const EdgeInsets.only(left: 13),
            child: Container(width: 2, height: 12,
                decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(1)))),
        ]);
      }),
    ]));
  }

  // Terms checkbox
  Widget _termsBox() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _terms ? _green.withOpacity(0.04) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _terms ? _green.withOpacity(0.3) : _border)),
    child: InkWell(
      onTap: () => setState(() => _terms = !_terms),
      borderRadius: BorderRadius.circular(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 24, height: 24, child: Checkbox(
          value: _terms, onChanged: (v) => setState(() => _terms = v ?? false),
          activeColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
        const SizedBox(width: 12),
        Expanded(child: RichText(text: const TextSpan(
          style: TextStyle(fontSize: 13, color: _txt1, height: 1.4),
          children: [
            TextSpan(text: 'I agree to the '),
            TextSpan(text: 'Terms & Conditions',
                style: TextStyle(color: _primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
            TextSpan(text: ' and '),
            TextSpan(text: 'Loan Agreement',
                style: TextStyle(color: _primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
            TextSpan(text: '. I understand the loan will be disbursed to my registered M-PESA number '
                'and repayments will be due monthly.'),
          ],
        ))),
      ]),
    ),
  );

  // Confirm button
  Widget _confirmBtn() => SizedBox(width: double.infinity, height: 54,
    child: ElevatedButton(
      onPressed: _terms ? _submit : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _terms ? _green : Colors.grey[300],
        foregroundColor: _terms ? Colors.white : Colors.grey[600],
        elevation: _terms ? 2 : 0, shadowColor: _green.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        disabledBackgroundColor: Colors.grey[300], disabledForegroundColor: Colors.grey[600]),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(_terms ? Icons.lock_outline : Icons.lock, size: 20), const SizedBox(width: 8),
        Text(_terms ? 'Confirm & Get Money' : 'Accept terms to continue',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
    ),
  );

  // ===========================================================================
  // PROCESSING STATE
  // ===========================================================================
  Widget _processingView() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80,
        decoration: BoxDecoration(color: _green.withOpacity(0.08), shape: BoxShape.circle),
        child: const Center(child: SizedBox(width: 40, height: 40,
            child: CircularProgressIndicator(strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(_green))))),
      const SizedBox(height: 28),
      const Text('Processing...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _txt1)),
      const SizedBox(height: 8),
      const Text('Submitting your loan application.\nThis will only take a moment.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: _txt2, height: 1.5)),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: _primary.withOpacity(0.06), borderRadius: BorderRadius.circular(24)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.shield_outlined, size: 16, color: _primary), SizedBox(width: 8),
          Text('Secured & encrypted',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _primary)),
        ]),
      ),
    ]),
  ));

  // ===========================================================================
  // SHARED HELPERS
  // ===========================================================================
  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
    child: child,
  );

  Widget _cardHeader(IconData icon, String title) => Row(children: [
    _iconCircle(icon, _primary), const SizedBox(width: 10),
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _txt1)),
  ]);

  Widget _iconCircle(IconData icon, Color c) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
    child: Icon(icon, size: 20, color: c),
  );

  Widget _greenBtn(String text, IconData icon, VoidCallback onTap) =>
    SizedBox(width: double.infinity, height: 54, child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _green, foregroundColor: Colors.white, elevation: 2,
        shadowColor: _green.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 22), const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
      ]),
    ));
}
