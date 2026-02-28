// IMFSL Loan Approval Queue - FlutterFlow Custom Widget
// =====================================================
// Admin loan approval queue with:
// - Status filter chips (Submitted, Approved, Rejected)
// - Queue stats card (pending count + total value)
// - Application list with risk badges and credit scores
// - Detail bottom sheet with credit score gauge and actions
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslLoanApprovalQueue extends StatefulWidget {
  const ImfslLoanApprovalQueue({
    super.key,
    this.applications = const [],
    this.totalCount = 0,
    this.pendingValue = 0.0,
    this.isLoading = false,
    this.currentFilter = 'SUBMITTED',
    this.onFilterChange,
    this.onLoadMore,
    this.onApprove,
    this.onReject,
    this.onRefresh,
  });

  final List<Map<String, dynamic>> applications;
  final int totalCount;
  final double pendingValue;
  final bool isLoading;
  final String currentFilter;
  final Function(String)? onFilterChange;
  final VoidCallback? onLoadMore;
  final Function(String appId, double amount)? onApprove;
  final Function(String appId, String reason)? onReject;
  final VoidCallback? onRefresh;

  @override
  State<ImfslLoanApprovalQueue> createState() => _ImfslLoanApprovalQueueState();
}

class _ImfslLoanApprovalQueueState extends State<ImfslLoanApprovalQueue> {
  final ScrollController _scrollController = ScrollController();
  final NumberFormat _currencyFmt =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !widget.isLoading) {
      widget.onLoadMore?.call();
    }
  }

  int _countByStatus(String status) {
    return widget.applications
        .where((a) => (a['status'] as String? ?? '') == status)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterChips(),
        _buildQueueStatsCard(),
        Expanded(
          child: widget.isLoading && widget.applications.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => widget.onRefresh?.call(),
                  child: _buildApplicationList(),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildChip(
              'SUBMITTED', 'Submitted', Colors.amber, _countByStatus('SUBMITTED')),
          const SizedBox(width: 8),
          _buildChip(
              'APPROVED', 'Approved', Colors.green, _countByStatus('APPROVED')),
          const SizedBox(width: 8),
          _buildChip(
              'REJECTED', 'Rejected', Colors.red, _countByStatus('REJECTED')),
        ],
      ),
    );
  }

  Widget _buildChip(String value, String label, Color color, int count) {
    final isSelected = widget.currentFilter == value;
    return ChoiceChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : color.shade700,
        ),
      ),
      selected: isSelected,
      selectedColor: color.shade600,
      backgroundColor: color.shade50,
      side: BorderSide(color: isSelected ? color.shade600 : color.shade200),
      onSelected: (_) => widget.onFilterChange?.call(value),
    );
  }

  Widget _buildQueueStatsCard() {
    final pendingCount = _countByStatus('SUBMITTED');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pending Applications',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '$pendingCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Pending Value',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  _currencyFmt.format(widget.pendingValue),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationList() {
    if (widget.applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No applications found',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.applications.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.applications.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildApplicationTile(widget.applications[index]);
      },
    );
  }

  Widget _buildApplicationTile(Map<String, dynamic> application) {
    final name = application['customer_name'] as String? ?? 'Unknown';
    final accountNo = application['account_number'] as String? ?? '-';
    final requestedAmount =
        (application['requested_amount'] as num?)?.toDouble() ?? 0.0;
    final productName = application['product_name'] as String? ?? '-';
    final productCode = application['product_code'] as String? ?? '';
    final riskCategory = application['risk_category'] as String? ?? 'MEDIUM';
    final creditScore = application['credit_score_at_application'] as num?;
    final submittedAt = application['submitted_at'] as String?;

    return GestureDetector(
      onTap: () => _showDetailSheet(application),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      const Color(0xFF1565C0).withValues(alpha: 0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text('Account: $accountNo',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),
                _buildRiskBadge(riskCategory),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Requested Amount',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(height: 2),
                      Text(_currencyFmt.format(requestedAmount),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      productCode.isNotEmpty
                          ? '$productName ($productCode)'
                          : productName,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    if (creditScore != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.speed, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text('Score: ${creditScore.toInt()}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _scoreColor(creditScore.toInt()))),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            if (submittedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                _formatTimestamp(submittedAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String riskCategory) {
    Color bgColor;
    Color textColor;
    switch (riskCategory) {
      case 'LOW':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'MEDIUM':
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade800;
        break;
      case 'HIGH':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case 'VERY_HIGH':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        riskCategory.replaceAll('_', ' '),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score < 300) return Colors.red.shade700;
    if (score <= 600) return Colors.amber.shade800;
    return Colors.green.shade700;
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return _dateFmt.format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  void _showDetailSheet(Map<String, dynamic> application) {
    final id = application['id']?.toString() ?? '';
    final name = application['customer_name'] as String? ?? 'Unknown';
    final accountNo = application['account_number'] as String? ?? '-';
    final phone = application['phone'] as String? ?? '-';
    final requestedAmount =
        (application['requested_amount'] as num?)?.toDouble() ?? 0.0;
    final tenureMonths = application['tenure_months'] as num? ?? 0;
    final purpose = application['purpose'] as String? ?? '-';
    final productName = application['product_name'] as String? ?? '-';
    final interestRate =
        (application['interest_rate'] as num?)?.toDouble() ?? 0.0;
    final minAmount =
        (application['min_amount'] as num?)?.toDouble() ?? 0.0;
    final maxAmount =
        (application['max_amount'] as num?)?.toDouble() ?? double.infinity;
    final maxTenure = application['max_tenure'] as num? ?? 0;
    final creditScore =
        (application['credit_score_at_application'] as num?)?.toInt() ?? 0;
    final riskCategory = application['risk_category'] as String? ?? 'MEDIUM';
    final recommendation = application['recommendation'] as String? ?? '-';
    final status = application['status'] as String? ?? 'SUBMITTED';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _buildDetailHeader(name, status),
                  const SizedBox(height: 20),
                  _buildDetailSection('Customer Information', [
                    _buildDetailRow('Name', name),
                    _buildDetailRow('Account', accountNo),
                    _buildDetailRow('Phone', phone),
                  ]),
                  const SizedBox(height: 16),
                  _buildCreditScoreGauge(creditScore, riskCategory, recommendation),
                  const SizedBox(height: 16),
                  _buildDetailSection('Product Details', [
                    _buildDetailRow('Product', productName),
                    _buildDetailRow('Interest Rate', '${interestRate.toStringAsFixed(1)}%'),
                    _buildDetailRow('Min Amount', _currencyFmt.format(minAmount)),
                    _buildDetailRow(
                        'Max Amount',
                        maxAmount == double.infinity
                            ? '-'
                            : _currencyFmt.format(maxAmount)),
                    _buildDetailRow('Max Tenure', '$maxTenure months'),
                  ]),
                  const SizedBox(height: 16),
                  _buildDetailSection('Request Details', [
                    _buildDetailRow(
                        'Requested Amount', _currencyFmt.format(requestedAmount)),
                    _buildDetailRow('Tenure', '$tenureMonths months'),
                    _buildDetailRow('Purpose', purpose),
                  ]),
                  const SizedBox(height: 24),
                  if (status == 'SUBMITTED')
                    _buildDetailActions(
                      ctx,
                      id,
                      requestedAmount,
                      minAmount,
                      maxAmount,
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailHeader(String name, String status) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF1565C0),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              _buildApplicationStatusBadge(status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'APPROVED':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'REJECTED':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  Widget _buildCreditScoreGauge(
      int score, String riskCategory, String recommendation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text('Credit Score',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            height: 100,
            child: CustomPaint(
              painter: _CreditScoreGaugePainter(score: score),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _scoreColor(score),
                      ),
                    ),
                    Text('/ 1000',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildRiskBadge(riskCategory),
          const SizedBox(height: 8),
          Text(
            recommendation,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailActions(
    BuildContext sheetContext,
    String appId,
    double requestedAmount,
    double minAmount,
    double maxAmount,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(sheetContext).pop();
              _showApproveDialog(appId, requestedAmount, minAmount, maxAmount);
            },
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(sheetContext).pop();
              _showRejectDialog(appId);
            },
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  void _showApproveDialog(
    String appId,
    double requestedAmount,
    double minAmount,
    double maxAmount,
  ) {
    final amountController =
        TextEditingController(text: requestedAmount.toStringAsFixed(2));
    final formKey = GlobalKey<FormState>();
    final effectiveMax =
        maxAmount == double.infinity ? requestedAmount : maxAmount;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Approve Loan Application',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Requested: ${_currencyFmt.format(requestedAmount)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Limits: ${_currencyFmt.format(minAmount)} - ${_currencyFmt.format(effectiveMax)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Approved Amount (KES)',
                    prefixText: 'KES ',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null) {
                      return 'Enter a valid number';
                    }
                    if (amount < minAmount) {
                      return 'Below minimum (${_currencyFmt.format(minAmount)})';
                    }
                    if (amount > effectiveMax) {
                      return 'Exceeds maximum (${_currencyFmt.format(effectiveMax)})';
                    }
                    if (amount > requestedAmount) {
                      return 'Cannot exceed requested amount';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child:
                  Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final amount =
                      double.parse(amountController.text.trim());
                  Navigator.of(dialogCtx).pop();
                  widget.onApprove?.call(appId, amount);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(String appId) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Reject Loan Application',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Enter the reason...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Reason is required';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child:
                  Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogCtx).pop();
                  widget.onReject?.call(appId, reasonController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}

class _CreditScoreGaugePainter extends CustomPainter {
  final int score;
  _CreditScoreGaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const startAngle = pi;
    const sweepAngle = pi;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Gradient arc
    final progress = (score / 1000).clamp(0.0, 1.0);
    final gradientSweep = sweepAngle * progress;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        Color(0xFFD32F2F),
        Color(0xFFF57C00),
        Color(0xFFFBC02D),
        Color(0xFF388E3C),
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, gradientSweep, false, fgPaint);

    // Needle indicator
    final needleAngle = startAngle + gradientSweep;
    final needleX = center.dx + radius * cos(needleAngle);
    final needleY = center.dy + radius * sin(needleAngle);
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = _dotColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(needleX, needleY), 7, dotPaint);
    canvas.drawCircle(Offset(needleX, needleY), 7, dotBorderPaint);
  }

  Color _dotColor() {
    if (score < 300) return const Color(0xFFD32F2F);
    if (score <= 600) return const Color(0xFFF57C00);
    return const Color(0xFF388E3C);
  }

  @override
  bool shouldRepaint(covariant _CreditScoreGaugePainter old) =>
      old.score != score;
}
