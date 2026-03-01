// IMFSL Instant Loan Status Tracker - FlutterFlow Custom Widget
// =============================================================
// Real-time animated step indicator tracking the instant loan process.
// Auto-polls every 3s, OTP request/verify flow, confetti on success.
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _LoanStep { checking, decision, otpRequired, disbursing, complete, review, rejected }

class _StepDef {
  final _LoanStep step;
  final IconData icon;
  final String sw;
  final String en;
  const _StepDef(this.step, this.icon, this.sw, this.en);
}

class InstantLoanStatusTracker extends StatefulWidget {
  const InstantLoanStatusTracker({
    super.key,
    required this.applicationId,
    required this.requestedAmount,
    this.phoneNumber = '',
    this.initialDecision,
    required this.onCheckStatus,
    required this.onRequestOtp,
    required this.onVerifyOtp,
    required this.onComplete,
    this.onClose,
  });

  final String applicationId;
  final double requestedAmount;
  final String phoneNumber;
  final Map<String, dynamic>? initialDecision;
  final Future<Map<String, dynamic>> Function(String applicationId) onCheckStatus;
  final Future<Map<String, dynamic>> Function(String applicationId) onRequestOtp;
  final Future<Map<String, dynamic>> Function(String applicationId, String code) onVerifyOtp;
  final Function(Map<String, dynamic> result) onComplete;
  final VoidCallback? onClose;

  @override
  State<InstantLoanStatusTracker> createState() => _InstantLoanStatusTrackerState();
}

class _InstantLoanStatusTrackerState extends State<InstantLoanStatusTracker>
    with TickerProviderStateMixin {
  static const _primary = Color(0xFF1565C0);
  static const _green = Color(0xFF2E7D32);
  static const _red = Color(0xFFC62828);
  static const _amber = Color(0xFFF57F17);
  static const _grey = Color(0xFFBDBDBD);

  final _fmt = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  _LoanStep _step = _LoanStep.checking;
  Map<String, dynamic> _data = {};
  bool _busy = false;
  String? _err;

  Timer? _poll;
  Timer? _tick;
  final DateTime _start = DateTime.now();
  Duration _elapsed = Duration.zero;

  bool _otpSent = false;
  bool _otpBusy = false;
  final _otpCtrl = TextEditingController();
  String? _otpErr;

  late final AnimationController _pulseCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  late final Animation<double> _pulse =
      Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

  late final AnimationController _confCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
  late final Animation<double> _conf =
      CurvedAnimation(parent: _confCtrl, curve: Curves.easeOut);

  static const _steps = [
    _StepDef(_LoanStep.checking, Icons.search, 'Tunaangalia ombi lako...', 'Checking your application'),
    _StepDef(_LoanStep.decision, Icons.gavel, 'Uamuzi umefanywa!', 'Decision made'),
    _StepDef(_LoanStep.otpRequired, Icons.lock_outline, 'Thibitisha kwa OTP', 'Verify with OTP'),
    _StepDef(_LoanStep.disbursing, Icons.send_rounded, 'Tunatuma pesa...', 'Sending money'),
    _StepDef(_LoanStep.complete, Icons.check_circle, 'Hongera!', 'Congratulations'),
  ];

  int get _idx {
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i].step == _step) return i;
    }
    return 1;
  }

  String get _timer {
    final m = _elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialDecision != null) _apply(widget.initialDecision!);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed = DateTime.now().difference(_start));
    });
    _poll = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (_step == _LoanStep.complete || _step == _LoanStep.rejected) { _poll?.cancel(); return; }
      if (_step == _LoanStep.otpRequired && _otpSent) return;
      _fetch();
    });
    _fetch();
  }

  Future<void> _fetch() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final r = await widget.onCheckStatus(widget.applicationId);
      if (mounted) _apply(r);
    } catch (e) {
      if (mounted) setState(() { _err = e.toString(); _busy = false; });
    }
  }

  void _apply(Map<String, dynamic> d) {
    final s = (d['status'] ?? d['step'] ?? 'CHECKING').toString().toUpperCase();
    final prev = _step;
    setState(() {
      _data = d; _busy = false; _err = null;
      _step = switch (s) {
        'CHECKING' || 'PENDING' || 'PROCESSING' => _LoanStep.checking,
        'DECISION' || 'APPROVED' || 'DECIDED' => _LoanStep.decision,
        'OTP_REQUIRED' || 'OTP' || 'VERIFY' => _LoanStep.otpRequired,
        'DISBURSING' || 'SENDING' => _LoanStep.disbursing,
        'COMPLETE' || 'DISBURSED' || 'DONE' => _LoanStep.complete,
        'REVIEW' || 'MANUAL_REVIEW' || 'UNDER_REVIEW' => _LoanStep.review,
        'REJECTED' || 'DECLINED' || 'DENIED' => _LoanStep.rejected,
        _ => _LoanStep.checking,
      };
    });
    if (_step == _LoanStep.complete) { _poll?.cancel(); _confCtrl.forward(); widget.onComplete(d); }
    if (_step == _LoanStep.rejected) _poll?.cancel();
    if (prev != _step) {} // step changed
  }

  Future<void> _reqOtp() async {
    setState(() { _otpSent = false; _otpErr = null; _busy = true; });
    try {
      final r = await widget.onRequestOtp(widget.applicationId);
      if (!mounted) return;
      setState(() { _otpSent = true; _busy = false; if (r['error'] != null) _otpErr = r['error'].toString(); });
    } catch (e) { if (mounted) setState(() { _otpErr = e.toString(); _busy = false; }); }
  }

  Future<void> _verifyOtp() async {
    final c = _otpCtrl.text.trim();
    if (c.length != 6) { setState(() => _otpErr = 'Ingiza tarakimu 6 / Enter 6 digits'); return; }
    setState(() { _otpBusy = true; _otpErr = null; });
    try {
      final r = await widget.onVerifyOtp(widget.applicationId, c);
      if (!mounted) return;
      if (r['error'] != null) { setState(() { _otpErr = r['error'].toString(); _otpBusy = false; }); }
      else { _apply(r); setState(() => _otpBusy = false); }
    } catch (e) { if (mounted) setState(() { _otpErr = e.toString(); _otpBusy = false; }); }
  }

  @override
  void dispose() {
    _poll?.cancel(); _tick?.cancel();
    _pulseCtrl.dispose(); _confCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ---- BUILD ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primary, foregroundColor: Colors.white, elevation: 0,
        title: const Text('Hali ya Mkopo / Loan Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: widget.onClose != null ? IconButton(icon: const Icon(Icons.close), onPressed: widget.onClose) : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.timer_outlined, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(_timer, style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: Colors.white)),
              ]),
            )),
          ),
        ],
      ),
      body: Column(children: [
        _header(),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _stepIndicator(),
            const SizedBox(height: 16),
            _content(),
          ]),
        )),
        if (_step == _LoanStep.complete || _step == _LoanStep.rejected) _bottomBar(),
      ]),
    );
  }

  Widget _header() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: const BoxDecoration(
      color: _primary,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    child: Column(children: [
      Text(_fmt.format(widget.requestedAmount),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
      if (widget.phoneNumber.isNotEmpty) ...[
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.phone_android, size: 14, color: Colors.white60),
          const SizedBox(width: 4),
          Text(widget.phoneNumber, style: const TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 1.2)),
        ]),
      ],
      const SizedBox(height: 4),
      Text('ID: ${widget.applicationId}', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
    ]),
  );

  // ---- STEP INDICATOR ----

  Widget _stepIndicator() {
    final diverted = _step == _LoanStep.review || _step == _LoanStep.rejected;
    final show = diverted ? _steps.sublist(0, 2) : _steps;
    final ai = _idx;
    return Column(children: [
      for (int i = 0; i < show.length; i++) ...[
        _stepRow(show[i], i, ai),
        if (i < show.length - 1) _line(i < ai, i == ai),
      ],
      if (diverted) ...[_line(false, true), _divertedRow()],
    ]);
  }

  Widget _stepRow(_StepDef d, int i, int ai) {
    final passed = i < ai;
    final cur = i == ai && !(_step == _LoanStep.review || _step == _LoanStep.rejected);
    final color = passed ? _green : cur ? _primary : _grey;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedBuilder(animation: _pulse, builder: (_, __) => Transform.scale(
        scale: cur ? _pulse.value : 1.0,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle,
            boxShadow: cur ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)] : null),
          child: Center(child: passed
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : cur ? _activeIcon(d.step) : Icon(d.icon, color: Colors.white70, size: 18)),
        ),
      )),
      const SizedBox(width: 16),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.sw, style: TextStyle(fontSize: 15,
              fontWeight: cur ? FontWeight.bold : FontWeight.w500,
              color: passed ? _green : cur ? _primary : Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(d.en, style: TextStyle(fontSize: 12,
              color: (passed ? _green : cur ? _primary : Colors.grey.shade400).withOpacity(0.7))),
        ]),
      )),
      if (passed) Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: const Text('Done', style: TextStyle(fontSize: 10, color: _green, fontWeight: FontWeight.w600)),
      ),
    ]);
  }

  Widget _activeIcon(_LoanStep s) => (s == _LoanStep.checking || s == _LoanStep.disbursing)
      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
      : Icon(_steps.firstWhere((d) => d.step == s).icon, color: Colors.white, size: 18);

  Widget _line(bool passed, bool cur) => Row(children: [
    const SizedBox(width: 19),
    Container(width: 2, height: 32,
        color: cur ? _primary.withOpacity(0.5) : passed ? _green : _grey.withOpacity(0.4)),
  ]);

  Widget _divertedRow() {
    final rev = _step == _LoanStep.review;
    final c = rev ? _amber : _red;
    final ic = rev ? Icons.hourglass_top : Icons.cancel_outlined;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedBuilder(animation: _pulse, builder: (_, __) => Transform.scale(
        scale: _pulse.value,
        child: Container(width: 40, height: 40,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)]),
          child: Icon(ic, color: Colors.white, size: 20)),
      )),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 2),
        Text(rev ? 'Inapitiwa' : 'Imekataliwa',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)),
        Text(rev ? 'Under review' : 'Rejected', style: TextStyle(fontSize: 12, color: c.withOpacity(0.7))),
      ])),
    ]);
  }

  // ---- STEP CONTENT ----

  Widget _content() => switch (_step) {
    _LoanStep.checking => _checkingCard(),
    _LoanStep.decision => _decisionCard(),
    _LoanStep.otpRequired => _otpCard(),
    _LoanStep.disbursing => _disbursingCard(),
    _LoanStep.complete => _completeCard(),
    _LoanStep.review => _reviewCard(),
    _LoanStep.rejected => _rejectedCard(),
  };

  Widget _card(Color c, Widget child) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: c.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))]),
    child: child,
  );

  Widget _checkingCard() => _card(_primary, Column(children: [
    AnimatedBuilder(animation: _pulse, builder: (_, __) =>
        Opacity(opacity: _pulse.value, child: const Icon(Icons.search, size: 48, color: _primary))),
    const SizedBox(height: 12),
    const Text('Tunaangalia ombi lako...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    const SizedBox(height: 4),
    Text('Checking credit score, loan history, and eligibility',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
    const SizedBox(height: 16),
    const LinearProgressIndicator(backgroundColor: Color(0xFFE3F2FD), valueColor: AlwaysStoppedAnimation(_primary)),
    const SizedBox(height: 8),
    Text('Muda: $_timer', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontFamily: 'monospace')),
  ]));

  Widget _decisionCard() {
    final ok = _data['approved'] == true || _data['decision'] == 'APPROVED';
    final amt = (_data['approved_amount'] ?? widget.requestedAmount) as num;
    final c = ok ? _green : _amber;
    return _card(c, Column(children: [
      Icon(ok ? Icons.thumb_up_alt : Icons.info_outline, size: 48, color: c),
      const SizedBox(height: 12),
      Text(ok ? 'Ombi Limekubaliwa!' : 'Uamuzi Umefanywa',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
      Text(ok ? 'Application Approved!' : 'Decision Made',
          style: TextStyle(fontSize: 12, color: c.withOpacity(0.7))),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: c.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Kiasi: ', style: TextStyle(fontSize: 14)),
          Text(_fmt.format(amt), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c)),
        ]),
      ),
      if (_data['message'] != null) ...[
        const SizedBox(height: 8),
        Text(_data['message'].toString(), textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    ]));
  }

  Widget _otpCard() => _card(_primary, Column(children: [
    const Icon(Icons.sms_outlined, size: 48, color: _primary),
    const SizedBox(height: 12),
    const Text('Thibitisha kwa OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(widget.phoneNumber.isNotEmpty ? 'Nambari itatumwa kwa ${widget.phoneNumber}' : 'Nambari ya uthibitisho inahitajika',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
    const SizedBox(height: 16),
    if (!_otpSent) SizedBox(width: double.infinity, child: ElevatedButton.icon(
      onPressed: _busy ? null : _reqOtp,
      icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send),
      label: Text(_busy ? 'Inatuma...' : 'Omba OTP / Request OTP'),
      style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    ))
    else ...[
      Text('Ingiza tarakimu 6 / Enter 6 digits', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      const SizedBox(height: 8),
      TextField(
        controller: _otpCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, maxLength: 6,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 12, color: _primary),
        decoration: InputDecoration(counterText: '', hintText: '------',
          hintStyle: TextStyle(fontSize: 28, color: Colors.grey.shade300, letterSpacing: 12),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primary.withOpacity(0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary, width: 2)),
          filled: true, fillColor: const Color(0xFFE3F2FD)),
      ),
      if (_otpErr != null) Padding(padding: const EdgeInsets.only(top: 8),
          child: Text(_otpErr!, style: const TextStyle(fontSize: 12, color: _red))),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: _otpBusy ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: _otpBusy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Thibitisha / Verify', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      )),
      const SizedBox(height: 8),
      TextButton(onPressed: _busy ? null : _reqOtp,
          child: Text('Tuma tena / Resend OTP', style: TextStyle(fontSize: 13, color: _primary.withOpacity(0.8)))),
    ],
  ]));

  Widget _disbursingCard() => _card(_primary, Column(children: [
    AnimatedBuilder(animation: _pulse, builder: (_, __) => Transform.scale(
      scale: _pulse.value,
      child: Container(width: 72, height: 72,
          decoration: BoxDecoration(color: _primary.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.send_rounded, size: 36, color: _primary)),
    )),
    const SizedBox(height: 16),
    const Text('Tunatuma pesa...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text('Sending ${_fmt.format(widget.requestedAmount)} to M-Pesa',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
    if (widget.phoneNumber.isNotEmpty) ...[
      const SizedBox(height: 4),
      Text(widget.phoneNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primary)),
    ],
    const SizedBox(height: 16),
    ClipRRect(borderRadius: BorderRadius.circular(8),
        child: const LinearProgressIndicator(minHeight: 6, backgroundColor: Color(0xFFE3F2FD),
            valueColor: AlwaysStoppedAnimation(_primary))),
    const SizedBox(height: 8),
    Text('Usifunge programu / Do not close the app',
        style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.w500)),
  ]));

  Widget _completeCard() {
    final ln = _data['loan_number'] ?? _data['loan_id'];
    final da = _data['disbursed_amount'] ?? _data['approved_amount'];
    final mr = _data['mpesa_receipt'] ?? _data['receipt_number'];
    return Stack(children: [
      if (_conf.value > 0) ..._confetti(_conf.value),
      _card(_green, Column(children: [
        AnimatedBuilder(animation: _conf, builder: (_, __) => Transform.scale(
          scale: 0.5 + _conf.value * 0.5,
          child: Opacity(opacity: _conf.value.clamp(0.0, 1.0),
            child: Container(width: 80, height: 80,
              decoration: BoxDecoration(color: _green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.celebration, size: 44, color: _green))),
        )),
        const SizedBox(height: 12),
        const Text('Hongera! / Congratulations!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _green)),
        const SizedBox(height: 4),
        const Text('Mkopo umefanikiwa kutumwa!', style: TextStyle(fontSize: 14, color: Color(0xFF424242))),
        Text('Loan disbursed successfully!', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 20),
        Container(width: double.infinity, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _green.withOpacity(0.05), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _green.withOpacity(0.2))),
          child: Column(children: [
            if (ln != null) _row('Nambari ya Mkopo / Loan No.', ln.toString(), bold: true),
            if (da != null) ...[const SizedBox(height: 8), _row('Kiasi / Amount', _fmt.format((da as num).toDouble()))],
            if (widget.phoneNumber.isNotEmpty) ...[const SizedBox(height: 8), _row('Simu / Phone', widget.phoneNumber)],
            if (mr != null) ...[const SizedBox(height: 8), _row('M-Pesa Receipt', mr.toString(), bold: true)],
            const SizedBox(height: 8), _row('Muda / Time', _timer),
          ]),
        ),
      ])),
    ]);
  }

  List<Widget> _confetti(double p) {
    const colors = [Color(0xFFE53935), Color(0xFF43A047), Color(0xFFFDD835), Color(0xFF1E88E5),
        Color(0xFFE91E63), Color(0xFF00ACC1), Color(0xFFFF9800), Color(0xFF8E24AA)];
    return List.generate(16, (i) {
      final a = (i / 16) * 3.14159 * 2;
      final r = 80.0 + p * 120.0;
      final s = 6.0 + (i % 3) * 4.0;
      // sin/cos via Taylor approximation to avoid dart:math import
      final sa = a * (1 - a * a / 6 * (1 - a * a / 20));
      final ca = (a + 1.5708) * (1 - (a + 1.5708) * (a + 1.5708) / 6 * (1 - (a + 1.5708) * (a + 1.5708) / 20));
      return Positioned(
        left: MediaQuery.of(context).size.width / 2 + r * ca - s / 2 - 20,
        top: 60 + r * sa - s / 2,
        child: Opacity(opacity: (1.0 - p).clamp(0.0, 1.0),
          child: Container(width: s, height: s,
            decoration: BoxDecoration(color: colors[i % colors.length],
                shape: i.isEven ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: i.isOdd ? BorderRadius.circular(2) : null))),
      );
    });
  }

  Widget _reviewCard() {
    final t = _data['estimated_time'] ?? _data['estimated_minutes'] ?? 30;
    final r = _data['review_reason'] ?? _data['reason'] ?? '';
    return _card(_amber, Column(children: [
      Container(width: 64, height: 64,
          decoration: BoxDecoration(color: _amber.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.hourglass_top, size: 32, color: _amber)),
      const SizedBox(height: 12),
      const Text('Inapitiwa na Afisa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      Text('Under Manual Review', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      const SizedBox(height: 16),
      Container(width: double.infinity, padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _amber.withOpacity(0.05), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _amber.withOpacity(0.2))),
        child: Column(children: [
          Row(children: [
            Icon(Icons.access_time, size: 18, color: _amber.withOpacity(0.8)),
            const SizedBox(width: 8),
            Expanded(child: Text('Muda wa kusubiri: ~$t dakika',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          ]),
          Row(children: [const SizedBox(width: 26), Expanded(child: Text('Estimated wait: ~$t minutes',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)))]),
          if (r.toString().isNotEmpty) ...[
            const Divider(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, size: 18, color: _amber.withOpacity(0.8)),
              const SizedBox(width: 8),
              Expanded(child: Text(r.toString(), style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
            ]),
          ],
        ]),
      ),
      const SizedBox(height: 16),
      Text('Utapokea ujumbe ukikamilika.\nYou will receive a notification when complete.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
    ]));
  }

  Widget _rejectedCard() {
    final r = _data['rejection_reason'] ?? _data['reason'] ?? _data['message']
        ?? 'Ombi lako halikukidhi vigezo. / Your application did not meet the criteria.';
    return _card(_red, Column(children: [
      Container(width: 64, height: 64,
          decoration: BoxDecoration(color: _red.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.cancel_outlined, size: 36, color: _red)),
      const SizedBox(height: 12),
      const Text('Imekataliwa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _red)),
      Text('Application Rejected', style: TextStyle(fontSize: 12, color: _red.withOpacity(0.7))),
      const SizedBox(height: 16),
      Container(width: double.infinity, padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _red.withOpacity(0.05), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _red.withOpacity(0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.report_outlined, size: 18, color: _red.withOpacity(0.8)),
            const SizedBox(width: 8),
            Text('Sababu / Reason:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _red.withOpacity(0.8))),
          ]),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.only(left: 26),
              child: Text(r.toString(), style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4))),
        ]),
      ),
      const SizedBox(height: 16),
      Row(children: [
        const Icon(Icons.lightbulb_outline, size: 16, color: _amber),
        const SizedBox(width: 8),
        Expanded(child: Text(
            'Jaribu tena baada ya kuboresha historia yako ya mkopo.\nTry again after improving your credit history.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4))),
      ]),
    ]));
  }

  Widget _bottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
    decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
    child: SizedBox(width: double.infinity, child: ElevatedButton(
      onPressed: widget.onClose,
      style: ElevatedButton.styleFrom(
          backgroundColor: _step == _LoanStep.complete ? _green : const Color(0xFFF5F5F5),
          foregroundColor: _step == _LoanStep.complete ? Colors.white : Colors.grey.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      child: Text(_step == _LoanStep.complete ? 'Rudi Nyumbani / Go Home' : 'Funga / Close',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    )),
  );

  Widget _row(String label, String value, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      const SizedBox(width: 12),
      Flexible(child: Text(value, textAlign: TextAlign.end,
          style: TextStyle(fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: bold ? _green : const Color(0xFF212121)))),
    ]);
}
