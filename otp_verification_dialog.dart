// IMFSL OTP Verification Dialog
// ==============================
// Full-screen dialog for entering a 6-digit OTP code sent via SMS.
//
// Features:
//   - 6 individual digit fields with auto-advance and backspace navigation
//   - 5-minute countdown timer with progress bar
//   - Resend OTP button (disabled for first 60 seconds)
//   - 3 attempt limit with remaining-attempts display
//   - Success animation (green checkmark with scale)
//   - Failure animation (red shake on digit fields)
//   - Loading state during verification
//
// Labels are in Swahili (Thibitisha OTP = Verify OTP).

import 'dart:async';
import 'package:flutter/material.dart';

class OtpVerificationDialog extends StatefulWidget {
  const OtpVerificationDialog({
    super.key,
    required this.phoneNumber,
    this.expiresInSeconds = 300,
    required this.onVerify,
    required this.onResend,
    required this.onCancel,
  });

  /// Full phone number — only last 4 digits are displayed.
  final String phoneNumber;

  /// OTP lifetime in seconds (default 300 = 5 minutes).
  final int expiresInSeconds;

  /// Called when user taps Verify.
  /// Must return `{verified: bool, remaining_attempts: int?}`.
  final Future<Map<String, dynamic>> Function(String otp) onVerify;

  /// Called when user taps Resend OTP.
  final Future<void> Function() onResend;

  /// Called when user taps Cancel.
  final VoidCallback onCancel;

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog>
    with SingleTickerProviderStateMixin {
  // ── Constants ──────────────────────────────────────────────────────────
  static const _primaryColor = Color(0xFF1565C0);
  static const _digitCount = 6;
  static const _resendCooldownSeconds = 60;
  static const _maxAttempts = 3;

  // ── Digit field controllers & focus nodes ──────────────────────────────
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  // ── Timer state ────────────────────────────────────────────────────────
  Timer? _countdownTimer;
  late int _remainingSeconds;
  late int _totalSeconds;

  // ── Resend state ───────────────────────────────────────────────────────
  Timer? _resendCooldownTimer;
  int _resendCooldown = _resendCooldownSeconds;
  bool _resendEnabled = false;
  int _resendCount = 0;

  // ── Attempt / verification state ───────────────────────────────────────
  int _attemptsRemaining = _maxAttempts;
  bool _isVerifying = false;
  bool _isExpired = false;

  // ── Result animation state ─────────────────────────────────────────────
  _ResultState _resultState = _ResultState.none;
  late final AnimationController _resultAnimController;
  late final Animation<double> _scaleAnimation;

  // ── Shake animation ────────────────────────────────────────────────────
  int _shakeCount = 0;
  Timer? _shakeTimer;
  double _shakeOffset = 0.0;

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _digitCount,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      _digitCount,
      (_) => FocusNode(),
    );

    _totalSeconds = widget.expiresInSeconds;
    _remainingSeconds = _totalSeconds;

    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.elasticOut,
    );

    _startCountdown();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _resendCooldownTimer?.cancel();
    _shakeTimer?.cancel();
    _resultAnimController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ── Timer helpers ──────────────────────────────────────────────────────

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_remainingSeconds <= 1) {
          _countdownTimer?.cancel();
          setState(() {
            _remainingSeconds = 0;
            _isExpired = true;
          });
        } else {
          setState(() {
            _remainingSeconds--;
          });
        }
      },
    );
  }

  void _startResendCooldown() {
    _resendCooldown = _resendCooldownSeconds;
    _resendEnabled = false;
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_resendCooldown <= 1) {
          _resendCooldownTimer?.cancel();
          setState(() {
            _resendCooldown = 0;
            _resendEnabled = true;
          });
        } else {
          setState(() {
            _resendCooldown--;
          });
        }
      },
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Phone masking ──────────────────────────────────────────────────────

  String get _maskedPhone {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) return '***$digits';
    return '***${digits.substring(digits.length - 4)}';
  }

  // ── OTP helpers ────────────────────────────────────────────────────────

  String get _currentOtp =>
      _controllers.map((c) => c.text).join();

  bool get _isOtpComplete =>
      _controllers.every((c) => c.text.length == 1);

  void _clearDigits() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  // ── Digit field input handler ──────────────────────────────────────────

  void _onDigitChanged(int index, String value) {
    // Allow only single digit.
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: 1),
      );
    }

    if (value.isNotEmpty && index < _digitCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    setState(() {});
  }

  /// Handles raw key events so backspace on an empty field moves focus back.
  KeyEventResult _onDigitKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        setState(() {});
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // ── Shake animation ────────────────────────────────────────────────────

  void _triggerShake() {
    _shakeCount = 0;
    _shakeTimer?.cancel();
    _shakeTimer = Timer.periodic(
      const Duration(milliseconds: 60),
      (timer) {
        setState(() {
          _shakeCount++;
          if (_shakeCount >= 6) {
            _shakeOffset = 0.0;
            timer.cancel();
          } else {
            _shakeOffset = (_shakeCount.isEven ? 12.0 : -12.0);
          }
        });
      },
    );
  }

  // ── Verify action ──────────────────────────────────────────────────────

  Future<void> _handleVerify() async {
    if (!_isOtpComplete || _isVerifying || _isExpired) return;

    setState(() {
      _isVerifying = true;
      _resultState = _ResultState.none;
    });

    try {
      final result = await widget.onVerify(_currentOtp);
      final verified = result['verified'] == true;
      final remaining = result['remaining_attempts'] as int?;

      if (!mounted) return;

      if (verified) {
        setState(() {
          _isVerifying = false;
          _resultState = _ResultState.success;
        });
        _resultAnimController.forward(from: 0.0);
        // Hold success state briefly before closing.
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _isVerifying = false;
          _resultState = _ResultState.failure;
          if (remaining != null) {
            _attemptsRemaining = remaining;
          } else {
            _attemptsRemaining = (_attemptsRemaining - 1).clamp(0, _maxAttempts);
          }
        });
        _triggerShake();
        _clearDigits();

        if (_attemptsRemaining <= 0) {
          // Out of attempts — wait a beat then close.
          await Future.delayed(const Duration(milliseconds: 1200));
          if (mounted) {
            Navigator.of(context).pop(false);
          }
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _resultState = _ResultState.failure;
      });
      _triggerShake();
      _clearDigits();
    }
  }

  // ── Resend action ──────────────────────────────────────────────────────

  Future<void> _handleResend() async {
    if (!_resendEnabled) return;

    setState(() {
      _resendEnabled = false;
    });

    try {
      await widget.onResend();
    } catch (_) {
      // silently ignore resend errors
    }

    if (!mounted) return;

    setState(() {
      _resendCount++;
      _remainingSeconds = _totalSeconds;
      _isExpired = false;
      _resultState = _ResultState.none;
    });

    _clearDigits();
    _startCountdown();
    _startResendCooldown();
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 12.0),
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40.0),
                      _buildHeader(),
                      const SizedBox(height: 36.0),
                      _buildDigitFields(),
                      const SizedBox(height: 8.0),
                      _buildAttemptsLabel(),
                      const SizedBox(height: 24.0),
                      _buildTimerSection(),
                      const SizedBox(height: 24.0),
                      _buildResendSection(),
                      const SizedBox(height: 36.0),
                      _buildResultOverlay(),
                      const SizedBox(height: 16.0),
                      _buildVerifyButton(),
                      const SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar with Cancel ────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop(false);
          },
          child: const Text(
            'Ghairi',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
            ),
          ),
        ),
        // Spacer for symmetry.
        const SizedBox(width: 64.0),
      ],
    );
  }

  // ── Header (icon, title, subtitle) ─────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72.0,
          height: 72.0,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 36.0,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 20.0),
        const Text(
          'Thibitisha OTP',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Nambari imetumwa kwa $_maskedPhone',
          style: const TextStyle(
            fontSize: 15.0,
            color: Color(0xFF757575),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── 6 digit input fields ───────────────────────────────────────────────

  Widget _buildDigitFields() {
    return Transform.translate(
      offset: Offset(_shakeOffset, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_digitCount, (i) {
          final bool hasValue = _controllers[i].text.isNotEmpty;
          final bool isFocused = _focusNodes[i].hasFocus;

          Color borderColor;
          if (_resultState == _ResultState.failure) {
            borderColor = Colors.red.shade400;
          } else if (_resultState == _ResultState.success) {
            borderColor = Colors.green.shade400;
          } else if (isFocused) {
            borderColor = _primaryColor;
          } else if (hasValue) {
            borderColor = _primaryColor.withOpacity(0.5);
          } else {
            borderColor = const Color(0xFFBDBDBD);
          }

          return Container(
            width: 48.0,
            height: 56.0,
            margin: EdgeInsets.only(
              left: i == 0 ? 0.0 : 6.0,
              right: i == _digitCount - 1 ? 0.0 : 6.0,
            ),
            child: KeyboardListener(
              focusNode: FocusNode(), // wrapper focus node for key events
              onKeyEvent: (event) => _onDigitKeyEvent(i, event),
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                enabled: !_isVerifying &&
                    !_isExpired &&
                    _attemptsRemaining > 0 &&
                    _resultState != _ResultState.success,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                  color: _resultState == _ResultState.failure
                      ? Colors.red.shade700
                      : const Color(0xFF212121),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: borderColor, width: 2.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: const Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (v) => _onDigitChanged(i, v),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Attempts remaining ─────────────────────────────────────────────────

  Widget _buildAttemptsLabel() {
    if (_attemptsRemaining >= _maxAttempts &&
        _resultState != _ResultState.failure) {
      return const SizedBox(height: 20.0);
    }

    final Color labelColor;
    if (_attemptsRemaining <= 1) {
      labelColor = Colors.red.shade700;
    } else {
      labelColor = const Color(0xFF757575);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        _attemptsRemaining > 0
            ? 'Majaribio $_attemptsRemaining yaliyobaki'
            : 'Majaribio yote yametumika',
        style: TextStyle(
          fontSize: 13.0,
          color: labelColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Countdown timer + progress bar ─────────────────────────────────────

  Widget _buildTimerSection() {
    final double progress =
        _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;

    return Column(
      children: [
        // Timer label.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 18.0,
              color: _isExpired ? Colors.red.shade400 : const Color(0xFF757575),
            ),
            const SizedBox(width: 6.0),
            Text(
              _isExpired
                  ? 'OTP imeisha muda'
                  : 'Muda uliobaki: ${_formatTime(_remainingSeconds)}',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: _isExpired
                    ? Colors.red.shade400
                    : const Color(0xFF424242),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        // Progress bar.
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4.0,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(
              _isExpired ? Colors.red.shade300 : _primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ── Resend OTP section ─────────────────────────────────────────────────

  Widget _buildResendSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hukupokea nambari? ',
              style: TextStyle(
                fontSize: 14.0,
                color: Color(0xFF757575),
              ),
            ),
            GestureDetector(
              onTap: _resendEnabled ? _handleResend : null,
              child: Text(
                _resendEnabled
                    ? 'Tuma tena'
                    : 'Tuma tena (${_resendCooldown}s)',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: _resendEnabled
                      ? _primaryColor
                      : const Color(0xFFBDBDBD),
                ),
              ),
            ),
          ],
        ),
        if (_resendCount > 0) ...[
          const SizedBox(height: 4.0),
          Text(
            'Imetumwa mara $_resendCount',
            style: const TextStyle(
              fontSize: 12.0,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ],
    );
  }

  // ── Success / failure overlay ──────────────────────────────────────────

  Widget _buildResultOverlay() {
    if (_resultState == _ResultState.success) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 48.0,
            color: Colors.green.shade500,
          ),
        ),
      );
    }

    if (_resultState == _ResultState.failure && _attemptsRemaining > 0) {
      return Text(
        'OTP si sahihi. Jaribu tena.',
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.red.shade600,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (_resultState == _ResultState.failure && _attemptsRemaining <= 0) {
      return Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40.0,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Majaribio yote yametumika.\nTuma OTP mpya.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ── Verify button ──────────────────────────────────────────────────────

  Widget _buildVerifyButton() {
    final bool canVerify = _isOtpComplete &&
        !_isVerifying &&
        !_isExpired &&
        _attemptsRemaining > 0 &&
        _resultState != _ResultState.success;

    return SizedBox(
      width: double.infinity,
      height: 52.0,
      child: ElevatedButton(
        onPressed: canVerify ? _handleVerify : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          disabledBackgroundColor: const Color(0xFFBBDEFB),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          elevation: canVerify ? 2.0 : 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isVerifying
            ? const SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Thibitisha',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ── Private enum for result animation state ──────────────────────────────

enum _ResultState { none, success, failure }
