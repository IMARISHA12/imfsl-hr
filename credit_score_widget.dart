import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// CreditScoreWidget displays a credit score gauge, factor breakdown,
/// score history chart, risk badge, recommendation, and max loan amount
/// for the IMFSL microfinance customer mobile app.
class CreditScoreWidget extends StatefulWidget {
  final List<Map<String, dynamic>> scoreHistory;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onRequestScoreRefresh;

  const CreditScoreWidget({
    super.key,
    this.scoreHistory = const [],
    this.onRefresh,
    this.onRequestScoreRefresh,
  });

  @override
  State<CreditScoreWidget> createState() => _CreditScoreWidgetState();
}

class _CreditScoreWidgetState extends State<CreditScoreWidget> {
  static const Color _primaryColor = Color(0xFF1565C0);
  static const int _minScore = 300;
  static const int _maxScore = 850;

  bool _isRefreshing = false;

  NumberFormat get _currencyFormat =>
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  Map<String, dynamic>? get _latestScore {
    if (widget.scoreHistory.isEmpty) return null;
    final sorted = List<Map<String, dynamic>>.from(widget.scoreHistory);
    sorted.sort((a, b) {
      final dateA = DateTime.tryParse(a['scored_at']?.toString() ?? '') ??
          DateTime(2000);
      final dateB = DateTime.tryParse(b['scored_at']?.toString() ?? '') ??
          DateTime(2000);
      return dateB.compareTo(dateA);
    });
    return sorted.first;
  }

  int _parseScore(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return double.tryParse(value)?.round() ?? _minScore;
    return _minScore;
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Color _riskCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.amber.shade700;
      case 'HIGH':
        return Colors.deepOrange;
      case 'VERY_HIGH':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _riskCategoryLabel(String category) {
    switch (category.toUpperCase()) {
      case 'LOW':
        return 'LOW RISK';
      case 'MEDIUM':
        return 'MEDIUM RISK';
      case 'HIGH':
        return 'HIGH RISK';
      case 'VERY_HIGH':
        return 'VERY HIGH RISK';
      default:
        return category.toUpperCase();
    }
  }

  Color _scoreColor(int score) {
    final progress = ((score - _minScore) / (_maxScore - _minScore)).clamp(0.0, 1.0);
    if (progress >= 0.75) return const Color(0xFF388E3C);
    if (progress >= 0.5) return const Color(0xFFFBC02D);
    if (progress >= 0.25) return const Color(0xFFF57C00);
    return const Color(0xFFD32F2F);
  }

  Color _factorColor(double value) {
    if (value >= 0.7) return Colors.green;
    if (value >= 0.4) return Colors.amber.shade700;
    return Colors.red;
  }

  IconData _factorIcon(String factorKey) {
    switch (factorKey) {
      case 'repayment_history':
        return Icons.payment;
      case 'credit_utilization':
        return Icons.pie_chart;
      case 'loan_diversity':
        return Icons.account_tree;
      case 'savings_behavior':
        return Icons.savings;
      case 'income_stability':
        return Icons.trending_up;
      case 'account_age':
        return Icons.calendar_today;
      case 'delinquency_record':
        return Icons.warning;
      default:
        return Icons.info_outline;
    }
  }

  String _factorLabel(String factorKey) {
    switch (factorKey) {
      case 'repayment_history':
        return 'Repayment History';
      case 'credit_utilization':
        return 'Credit Utilization';
      case 'loan_diversity':
        return 'Loan Diversity';
      case 'savings_behavior':
        return 'Savings Behavior';
      case 'income_stability':
        return 'Income Stability';
      case 'account_age':
        return 'Account Age';
      case 'delinquency_record':
        return 'Delinquency Record';
      default:
        return factorKey
            .split('_')
            .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
  }

  Future<void> _handleRequestScoreRefresh() async {
    if (widget.onRequestScoreRefresh == null) return;
    setState(() => _isRefreshing = true);
    try {
      await widget.onRequestScoreRefresh!();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: _handleRefresh,
      child: widget.scoreHistory.isEmpty
          ? _buildEmptyState()
          : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.speed,
                        size: 56,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No credit score yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your credit score will appear here once it has been calculated.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (widget.onRequestScoreRefresh != null)
                      OutlinedButton.icon(
                        onPressed:
                            _isRefreshing ? null : _handleRequestScoreRefresh,
                        icon: _isRefreshing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _primaryColor,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(
                            _isRefreshing ? 'Requesting...' : 'Request Score'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryColor,
                          side: const BorderSide(color: _primaryColor),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final latest = _latestScore!;
    final score = _parseScore(latest['credit_score']);
    final riskCategory = (latest['risk_category'] ?? 'MEDIUM').toString();
    final recommendation = (latest['recommendation'] ?? '').toString();
    final maxAmount = _parseDouble(latest['max_recommended_amount']);
    final factorsBreakdown =
        latest['factors_breakdown'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGaugeSection(score, riskCategory),
          const SizedBox(height: 16),
          _buildMaxLoanAmountCard(maxAmount),
          const SizedBox(height: 12),
          _buildRecommendationCard(recommendation),
          const SizedBox(height: 20),
          _buildFactorBreakdownSection(factorsBreakdown),
          const SizedBox(height: 20),
          _buildScoreHistorySection(),
          const SizedBox(height: 20),
          _buildRequestRefreshButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Credit Score Gauge
  // ---------------------------------------------------------------------------

  Widget _buildGaugeSection(int score, String riskCategory) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Column(
          children: [
            const Text(
              'Your Credit Score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: CustomPaint(
                painter: _CustomerCreditScoreGaugePainter(
                  score: score,
                  minScore: _minScore,
                  maxScore: _maxScore,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              score.toString(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _scoreColor(score),
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'out of $_maxScore',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 14),
            _buildRiskBadge(riskCategory),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String riskCategory) {
    final color = _riskCategoryColor(riskCategory);
    final label = _riskCategoryLabel(riskCategory);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Max Recommended Loan Amount
  // ---------------------------------------------------------------------------

  Widget _buildMaxLoanAmountCard(double maxAmount) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: _primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You qualify for up to',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormat.format(maxAmount),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Recommendation Card
  // ---------------------------------------------------------------------------

  Widget _buildRecommendationCard(String recommendation) {
    if (recommendation.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lightbulb,
              color: Color(0xFFF9A825),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommendation',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF57F17),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Factor Breakdown
  // ---------------------------------------------------------------------------

  Widget _buildFactorBreakdownSection(Map<String, dynamic> factors) {
    if (factors.isEmpty) return const SizedBox.shrink();

    const orderedKeys = [
      'repayment_history',
      'credit_utilization',
      'loan_diversity',
      'savings_behavior',
      'income_stability',
      'account_age',
      'delinquency_record',
    ];

    final keysToShow = orderedKeys.where((k) => factors.containsKey(k)).toList();
    if (keysToShow.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Score Factors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        ...keysToShow.map((key) {
          final value = _parseDouble(factors[key]).clamp(0.0, 1.0);
          return _buildFactorCard(key, value);
        }),
      ],
    );
  }

  Widget _buildFactorCard(String factorKey, double value) {
    final color = _factorColor(value);
    final percentage = (value * 100).round();

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _factorIcon(factorKey),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _factorLabel(factorKey),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Score History Chart
  // ---------------------------------------------------------------------------

  Widget _buildScoreHistorySection() {
    if (widget.scoreHistory.isEmpty) return const SizedBox.shrink();

    final sortedHistory = List<Map<String, dynamic>>.from(widget.scoreHistory);
    sortedHistory.sort((a, b) {
      final dateA = DateTime.tryParse(a['scored_at']?.toString() ?? '') ??
          DateTime(2000);
      final dateB = DateTime.tryParse(b['scored_at']?.toString() ?? '') ??
          DateTime(2000);
      return dateA.compareTo(dateB);
    });

    final dataPoints = sortedHistory.map((item) {
      return _ScoreDataPoint(
        date: DateTime.tryParse(item['scored_at']?.toString() ?? '') ??
            DateTime.now(),
        score: _parseScore(item['credit_score']),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Score History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: _ScoreHistoryPainter(
                  dataPoints: dataPoints,
                  minScore: _minScore,
                  maxScore: _maxScore,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Request Score Refresh Button
  // ---------------------------------------------------------------------------

  Widget _buildRequestRefreshButton() {
    if (widget.onRequestScoreRefresh == null) return const SizedBox.shrink();
    return Center(
      child: OutlinedButton.icon(
        onPressed: _isRefreshing ? null : _handleRequestScoreRefresh,
        icon: _isRefreshing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primaryColor,
                ),
              )
            : const Icon(Icons.refresh),
        label: Text(_isRefreshing
            ? 'Requesting Score Refresh...'
            : 'Request Score Refresh'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Data class for score history chart
// =============================================================================

class _ScoreDataPoint {
  final DateTime date;
  final int score;

  const _ScoreDataPoint({required this.date, required this.score});
}

// =============================================================================
// CustomPainter: Credit Score Gauge (semi-circle arc)
// =============================================================================

class _CustomerCreditScoreGaugePainter extends CustomPainter {
  final int score;
  final int minScore;
  final int maxScore;

  _CustomerCreditScoreGaugePainter({
    required this.score,
    required this.minScore,
    required this.maxScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = min(size.width / 2 - 20, size.height * 0.75);
    const strokeWidth = 14.0;
    const startAngle = pi; // 180 degrees (left)
    const sweepAngle = pi; // 180 degrees sweep (to right)

    // -- Background arc (grey) --
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // -- Progress --
    final progress =
        ((score - minScore) / (maxScore - minScore)).clamp(0.0, 1.0);
    final progressSweep = sweepAngle * progress;

    // -- Gradient foreground arc --
    if (progress > 0) {
      final gradientPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: const [
            Color(0xFFD32F2F), // Red
            Color(0xFFF57C00), // Orange
            Color(0xFFFBC02D), // Yellow
            Color(0xFF388E3C), // Green
          ],
          stops: const [0.0, 0.33, 0.66, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progressSweep,
        false,
        gradientPaint,
      );
    }

    // -- Scale labels --
    final labelStyle = TextStyle(
      fontSize: 11,
      color: Colors.grey.shade500,
      fontWeight: FontWeight.w500,
    );

    // Left label (min score)
    final minTP = TextPainter(
      text: TextSpan(text: minScore.toString(), style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    minTP.paint(
      canvas,
      Offset(center.dx - radius - minTP.width / 2, center.dy + 6),
    );

    // Right label (max score)
    final maxTP = TextPainter(
      text: TextSpan(text: maxScore.toString(), style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    maxTP.paint(
      canvas,
      Offset(center.dx + radius - maxTP.width / 2, center.dy + 6),
    );

    // -- Needle dot --
    final needleAngle = startAngle + progressSweep;
    final needleX = center.dx + radius * cos(needleAngle);
    final needleY = center.dy + radius * sin(needleAngle);
    final needlePos = Offset(needleX, needleY);

    // Determine needle color based on progress
    Color needleColor;
    if (progress >= 0.75) {
      needleColor = const Color(0xFF388E3C);
    } else if (progress >= 0.5) {
      needleColor = const Color(0xFFFBC02D);
    } else if (progress >= 0.25) {
      needleColor = const Color(0xFFF57C00);
    } else {
      needleColor = const Color(0xFFD32F2F);
    }

    // Outer colored circle
    final needleBorderPaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(needlePos, 10, needleBorderPaint);

    // Inner white circle
    final needleCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(needlePos, 6, needleCenterPaint);

    // Small shadow ring
    final needleShadow = Paint()
      ..color = needleColor.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(needlePos, 12, needleShadow);
  }

  @override
  bool shouldRepaint(covariant _CustomerCreditScoreGaugePainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.minScore != minScore ||
        oldDelegate.maxScore != maxScore;
  }
}

// =============================================================================
// CustomPainter: Score History Line Chart
// =============================================================================

class _ScoreHistoryPainter extends CustomPainter {
  final List<_ScoreDataPoint> dataPoints;
  final int minScore;
  final int maxScore;

  _ScoreHistoryPainter({
    required this.dataPoints,
    required this.minScore,
    required this.maxScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    const double leftPadding = 40;
    const double rightPadding = 16;
    const double topPadding = 12;
    const double bottomPadding = 32;

    final chartLeft = leftPadding;
    final chartRight = size.width - rightPadding;
    final chartTop = topPadding;
    final chartBottom = size.height - bottomPadding;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final labelStyle = TextStyle(
      fontSize: 10,
      color: Colors.grey.shade500,
    );

    // -- Y-axis grid lines and labels --
    const ySteps = 5;
    final scoreRange = maxScore - minScore;
    for (int i = 0; i <= ySteps; i++) {
      final fraction = i / ySteps;
      final y = chartBottom - fraction * chartHeight;
      final scoreLabel = (minScore + fraction * scoreRange).round();

      // Grid line
      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartRight, y),
        gridPaint,
      );

      // Label
      final tp = TextPainter(
        text: TextSpan(text: scoreLabel.toString(), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(chartLeft - tp.width - 6, y - tp.height / 2));
    }

    // -- Axes --
    // Y axis
    canvas.drawLine(
      Offset(chartLeft, chartTop),
      Offset(chartLeft, chartBottom),
      axisPaint,
    );
    // X axis
    canvas.drawLine(
      Offset(chartLeft, chartBottom),
      Offset(chartRight, chartBottom),
      axisPaint,
    );

    // -- Single data point --
    if (dataPoints.length == 1) {
      final point = dataPoints.first;
      final scoreFraction =
          ((point.score - minScore) / scoreRange).clamp(0.0, 1.0);
      final cx = chartLeft + chartWidth / 2;
      final cy = chartBottom - scoreFraction * chartHeight;

      // Dot
      final dotPaint = Paint()
        ..color = const Color(0xFF1565C0)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), 6, dotPaint);

      // White inner
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), 3, innerPaint);

      // Date label
      final dateStr = DateFormat('dd MMM').format(point.date);
      final dtp = TextPainter(
        text: TextSpan(text: dateStr, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      dtp.paint(canvas, Offset(cx - dtp.width / 2, chartBottom + 6));

      return;
    }

    // -- Multiple data points --
    final minDate = dataPoints.first.date;
    final maxDate = dataPoints.last.date;
    final dateRange = maxDate.difference(minDate).inMilliseconds.toDouble();

    // Calculate positions
    final positions = <Offset>[];
    for (final point in dataPoints) {
      double xFraction;
      if (dateRange == 0) {
        xFraction = 0.5;
      } else {
        xFraction = point.date.difference(minDate).inMilliseconds / dateRange;
      }
      final scoreFraction =
          ((point.score - minScore) / scoreRange).clamp(0.0, 1.0);
      final x = chartLeft + xFraction * chartWidth;
      final y = chartBottom - scoreFraction * chartHeight;
      positions.add(Offset(x, y));
    }

    // -- Gradient fill under the line --
    if (positions.length >= 2) {
      final fillPath = Path()
        ..moveTo(positions.first.dx, chartBottom);
      for (final pos in positions) {
        fillPath.lineTo(pos.dx, pos.dy);
      }
      fillPath
        ..lineTo(positions.last.dx, chartBottom)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1565C0).withOpacity(0.18),
            const Color(0xFF1565C0).withOpacity(0.02),
          ],
        ).createShader(
            Rect.fromLTRB(chartLeft, chartTop, chartRight, chartBottom));
      canvas.drawPath(fillPath, fillPaint);
    }

    // -- Line --
    final linePaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(positions.first.dx, positions.first.dy);
    for (int i = 1; i < positions.length; i++) {
      linePath.lineTo(positions[i].dx, positions[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // -- Data point dots --
    final dotPaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final pos in positions) {
      canvas.drawCircle(pos, 5, dotPaint);
      canvas.drawCircle(pos, 2.5, dotBorderPaint);
    }

    // -- X-axis date labels --
    final maxLabels = (chartWidth / 60).floor().clamp(2, dataPoints.length);
    final labelIndices = <int>[];
    if (dataPoints.length <= maxLabels) {
      labelIndices.addAll(List.generate(dataPoints.length, (i) => i));
    } else {
      for (int i = 0; i < maxLabels; i++) {
        labelIndices
            .add((i * (dataPoints.length - 1) / (maxLabels - 1)).round());
      }
    }

    for (final idx in labelIndices) {
      final dateStr = DateFormat('dd MMM').format(dataPoints[idx].date);
      final dtp = TextPainter(
        text: TextSpan(text: dateStr, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelX = positions[idx].dx - dtp.width / 2;
      dtp.paint(canvas, Offset(labelX.clamp(0, size.width - dtp.width), chartBottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreHistoryPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.minScore != minScore ||
        oldDelegate.maxScore != maxScore;
  }
}
