// IMFSL Loan Prequalification Card - Home Screen Offer Card
// =========================================================
// A visually premium card displayed on the customer home screen to
// promote instant loan offers ("Mkopo Chap Chap"). Three visual states:
//
//   1. Collapsed (default) — gradient banner with lightning bolt,
//      headline, and amber "Omba Sasa" chip.
//   2. Expanded (qualified) — reveals 4 qualification checks with
//      green/red indicators, estimated time, and large CTA button.
//   3. Not Qualified — muted grey gradient with improvement guidance
//      and failed-check indicators.
//
// Smooth expand/collapse via AnimatedCrossFade + AnimatedContainer.
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanPrequalificationCard extends StatefulWidget {
  const LoanPrequalificationCard({
    super.key,
    this.qualified = false,
    this.maxAmount = 0,
    this.creditScore = 0,
    this.kycApproved = false,
    this.deviceTrusted = false,
    this.noArrears = false,
    this.isLoading = false,
    required this.onApplyNow,
    required this.onRefresh,
  });

  /// Whether the customer meets all qualification criteria.
  final bool qualified;

  /// Maximum pre-qualified loan amount in KES.
  final double maxAmount;

  /// Customer's current credit score (0–900 typical range).
  final int creditScore;

  /// Whether KYC documents have been approved.
  final bool kycApproved;

  /// Whether the current device is trusted / enrolled.
  final bool deviceTrusted;

  /// Whether the customer has no overdue loan arrears.
  final bool noArrears;

  /// Show a loading shimmer while qualification data is being fetched.
  final bool isLoading;

  /// Called when the customer taps "Omba Sasa" (Apply Now).
  final VoidCallback onApplyNow;

  /// Called when the customer taps the refresh / re-check button.
  final VoidCallback onRefresh;

  @override
  State<LoanPrequalificationCard> createState() =>
      _LoanPrequalificationCardState();
}

class _LoanPrequalificationCardState extends State<LoanPrequalificationCard>
    with SingleTickerProviderStateMixin {
  // ── Constants ──────────────────────────────────────────────────────────
  static const _primaryBlue = Color(0xFF1565C0);
  static const _deepBlue = Color(0xFF0D47A1);
  static const _amber = Color(0xFFFFB300);
  static const _amberDark = Color(0xFFF57F17);
  static const _successGreen = Color(0xFF2E7D32);
  static const _failRed = Color(0xFFC62828);
  static const _mutedGrey = Color(0xFF616161);
  static const _mutedGreyDark = Color(0xFF424242);
  static const _cardRadius = 20.0;
  static const _animDuration = Duration(milliseconds: 400);

  // ── State ──────────────────────────────────────────────────────────────
  bool _expanded = false;
  late AnimationController _arrowController;
  late Animation<double> _arrowTurn;
  late NumberFormat _kes;

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      duration: _animDuration,
      vsync: this,
    );
    _arrowTurn = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
    _kes = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
    if (_expanded) {
      _arrowController.forward();
    } else {
      _arrowController.reverse();
    }
  }

  int get _passedChecks {
    int count = 0;
    if (widget.creditScore > 0) count++;
    if (widget.kycApproved) count++;
    if (widget.deviceTrusted) count++;
    if (widget.noArrears) count++;
    return count;
  }

  LinearGradient get _activeGradient => const LinearGradient(
        colors: [_primaryBlue, _deepBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get _mutedGradient => const LinearGradient(
        colors: [_mutedGrey, _mutedGreyDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get _currentGradient =>
      widget.qualified ? _activeGradient : _mutedGradient;

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingSkeleton();
    }

    return AnimatedContainer(
      duration: _animDuration,
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: (widget.qualified ? _primaryBlue : _mutedGrey)
                .withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpand,
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: AnimatedCrossFade(
              duration: _animDuration,
              sizeCurve: Curves.easeInOut,
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: _buildCollapsed(),
              secondChild: _buildExpanded(),
            ),
          ),
        ),
      ),
    );
  }

  // ── Collapsed State ────────────────────────────────────────────────────
  Widget _buildCollapsed() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: _currentGradient),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCollapsedHeader(),
            const SizedBox(height: 14),
            _buildCollapsedBody(),
            const SizedBox(height: 16),
            _buildCollapsedFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedHeader() {
    return Row(
      children: [
        // Lightning bolt icon in a frosted circle
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.18),
          ),
          child: const Center(
            child: Icon(Icons.bolt_rounded, color: _amber, size: 28),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mkopo Chap Chap',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              if (widget.qualified)
                Text(
                  'Pre-qualified',
                  style: TextStyle(
                    color: _amber.withOpacity(0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        // Expand arrow
        RotationTransition(
          turns: _arrowTurn,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedBody() {
    if (widget.qualified) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pata hadi ${_kes.format(widget.maxAmount)} kwa dakika 2!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Get up to ${_kes.format(widget.maxAmount)} in 2 minutes!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Boresha alama yako ya mkopo ili kupata mkopo wa papo hapo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Improve your credit score to qualify for instant loans',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCollapsedFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Progress dots showing how many checks pass
        _buildCheckProgressDots(),
        if (widget.qualified)
          _buildAmberChip('Omba Sasa', Icons.arrow_forward_rounded)
        else
          _buildMutedChip('Angalia Masharti', Icons.info_outline_rounded),
      ],
    );
  }

  Widget _buildCheckProgressDots() {
    final checks = [
      widget.creditScore > 0,
      widget.kycApproved,
      widget.deviceTrusted,
      widget.noArrears,
    ];
    return Row(
      children: List.generate(4, (i) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: checks[i]
                ? _amber
                : Colors.white.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  Widget _buildAmberChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_amber, _amberDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _amber.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, color: Colors.black87, size: 16),
        ],
      ),
    );
  }

  Widget _buildMutedChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Expanded State ─────────────────────────────────────────────────────
  Widget _buildExpanded() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: widget.qualified ? null : _mutedGradient,
        color: widget.qualified ? Colors.white : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient header — same as collapsed
          _buildExpandedHeader(),
          // Qualification checks
          _buildQualificationSection(),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: widget.qualified
                  ? Colors.grey.shade200
                  : Colors.white.withOpacity(0.15),
              height: 1,
            ),
          ),
          // Estimated time + CTA row
          _buildExpandedFooter(),
        ],
      ),
    );
  }

  Widget _buildExpandedHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: _currentGradient),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + title + arrow
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                ),
                child: const Center(
                  child: Icon(Icons.bolt_rounded, color: _amber, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Mkopo Chap Chap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              RotationTransition(
                turns: _arrowTurn,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Loan amount banner
          if (widget.qualified) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Hadi',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _kes.format(widget.maxAmount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pre-qualified instant loan',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ] else ...[
            const Text(
              'Boresha alama yako ya mkopo ili kupata mkopo wa papo hapo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Improve your credit score to qualify for instant loans',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQualificationSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.qualified ? 'Masharti Yote Yametimizwa' : 'Masharti',
            style: TextStyle(
              color: widget.qualified ? _primaryBlue : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            widget.qualified
                ? 'All requirements met'
                : 'Qualification requirements',
            style: TextStyle(
              color: widget.qualified
                  ? Colors.grey.shade500
                  : Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 14),
          _buildCheckItem(
            passed: widget.creditScore > 0,
            titleSw: 'Alama ya Mkopo',
            titleEn: 'Credit Score',
            icon: Icons.speed_rounded,
            trailing: _buildScoreBadge(),
          ),
          const SizedBox(height: 10),
          _buildCheckItem(
            passed: widget.kycApproved,
            titleSw: widget.kycApproved ? 'KYC Imekamilika' : 'KYC Haijakamilika',
            titleEn: widget.kycApproved ? 'KYC Complete' : 'KYC Incomplete',
            icon: Icons.verified_user_rounded,
          ),
          const SizedBox(height: 10),
          _buildCheckItem(
            passed: widget.deviceTrusted,
            titleSw: widget.deviceTrusted
                ? 'Kifaa Kinachoaminika'
                : 'Kifaa Hakijathibitishwa',
            titleEn: widget.deviceTrusted
                ? 'Trusted Device'
                : 'Device Not Verified',
            icon: Icons.smartphone_rounded,
          ),
          const SizedBox(height: 10),
          _buildCheckItem(
            passed: widget.noArrears,
            titleSw: widget.noArrears
                ? 'Hakuna Deni Lililochelewa'
                : 'Kuna Deni Lililochelewa',
            titleEn: widget.noArrears ? 'No Arrears' : 'Outstanding Arrears',
            icon: Icons.account_balance_wallet_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required bool passed,
    required String titleSw,
    required String titleEn,
    required IconData icon,
    Widget? trailing,
  }) {
    final bool onDark = !widget.qualified;
    final Color iconBg = passed
        ? _successGreen.withOpacity(0.12)
        : _failRed.withOpacity(0.10);
    final Color iconColor = passed ? _successGreen : _failRed;
    final Color textColor = onDark ? Colors.white : Colors.grey.shade800;
    final Color subtitleColor =
        onDark ? Colors.white.withOpacity(0.55) : Colors.grey.shade500;

    return Row(
      children: [
        // Status icon circle
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: onDark ? iconColor.withOpacity(0.2) : iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Category icon + labels
        Icon(icon, color: passed ? iconColor : subtitleColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleSw,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                titleEn,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildScoreBadge() {
    final int score = widget.creditScore;
    final Color badgeColor;
    if (score >= 700) {
      badgeColor = _successGreen;
    } else if (score >= 400) {
      badgeColor = _amber;
    } else if (score > 0) {
      badgeColor = _failRed;
    } else {
      badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(widget.qualified ? 0.12 : 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.4)),
      ),
      child: Text(
        score > 0 ? '$score' : '--',
        style: TextStyle(
          color: widget.qualified ? badgeColor : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildExpandedFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          // Estimated time row
          if (widget.qualified) ...[
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    color: Colors.grey.shade500, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Muda wa maombi: ~2 dakika',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Estimated: ~2 min',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
          // CTA row: Refresh + Apply / Improve
          Row(
            children: [
              // Refresh button
              _buildRefreshButton(),
              const SizedBox(width: 12),
              // Main CTA
              Expanded(child: _buildCTAButton()),
            ],
          ),
          // Qualification summary
          const SizedBox(height: 14),
          _buildQualificationSummary(),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    final bool onDark = !widget.qualified;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Stop event from toggling card
          widget.onRefresh();
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: onDark
                ? Colors.white.withOpacity(0.12)
                : Colors.grey.shade100,
            border: Border.all(
              color: onDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            Icons.refresh_rounded,
            color: onDark ? Colors.white70 : _primaryBlue,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    if (widget.qualified) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: widget.onApplyNow,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_amber, _amberDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _amber.withOpacity(0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.black87, size: 20),
                SizedBox(width: 8),
                Text(
                  'Omba Sasa',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '(Apply Now)',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _toggleExpand,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Boresha Sasa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(Improve)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildQualificationSummary() {
    final bool onDark = !widget.qualified;
    final Color textColor =
        onDark ? Colors.white.withOpacity(0.5) : Colors.grey.shade400;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.qualified
              ? Icons.verified_rounded
              : Icons.info_outline_rounded,
          color: widget.qualified ? _successGreen : textColor,
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          widget.qualified
              ? '$_passedChecks/4 masharti yametimizwa'
              : '$_passedChecks/4 masharti yametimizwa — boresha ili kufuzu',
          style: TextStyle(
            color: widget.qualified
                ? _successGreen.withOpacity(0.8)
                : textColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Loading Skeleton ───────────────────────────────────────────────────
  Widget _buildLoadingSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: _activeGradient),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header shimmer
              Row(
                children: [
                  _shimmerCircle(44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(width: 160, height: 18),
                        const SizedBox(height: 6),
                        _shimmerBox(width: 90, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Body shimmer
              _shimmerBox(width: double.infinity, height: 14),
              const SizedBox(height: 8),
              _shimmerBox(width: 200, height: 14),
              const SizedBox(height: 18),
              // Footer shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      4,
                      (_) => Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: _shimmerCircle(8),
                      ),
                    ),
                  ),
                  _shimmerBox(width: 110, height: 32, radius: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _shimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
    );
  }
}
