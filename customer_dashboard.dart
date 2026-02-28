// IMFSL Customer Dashboard - FlutterFlow Custom Widget
// =====================================================
// Full-featured microfinance customer dashboard with:
// - Balance card with privacy toggle
// - Quick actions grid (Pay Loan, Deposit, Withdraw, Send Money)
// - Active loan progress tracking
// - Recent transactions list
// - Savings goal ring indicator
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({
    super.key,
    required this.customerName,
    required this.customerId,
    this.accountBalance = 0.0,
    this.loanBalance = 0.0,
    this.savingsBalance = 0.0,
    this.loanLimit = 0.0,
    this.loanDueDate,
    this.savingsGoal = 0.0,
    this.recentTransactions = const [],
    this.onPayLoan,
    this.onDeposit,
    this.onWithdraw,
    this.onSendMoney,
    this.onViewAllTransactions,
    this.onViewLoanDetails,
  });

  final String customerName;
  final String customerId;
  final double accountBalance;
  final double loanBalance;
  final double savingsBalance;
  final double loanLimit;
  final DateTime? loanDueDate;
  final double savingsGoal;
  final List<Map<String, dynamic>> recentTransactions;
  final VoidCallback? onPayLoan;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onSendMoney;
  final VoidCallback? onViewAllTransactions;
  final VoidCallback? onViewLoanDetails;

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard>
    with SingleTickerProviderStateMixin {
  bool _balanceVisible = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final NumberFormat _currencyFmt =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _maskedBalance(double amount) {
    return _balanceVisible ? _currencyFmt.format(amount) : 'KES ****.**';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingHeader(),
            const SizedBox(height: 16),
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            if (widget.loanBalance > 0) ...[
              _buildActiveLoanCard(),
              const SizedBox(height: 20),
            ],
            if (widget.savingsGoal > 0) ...[
              _buildSavingsGoalCard(),
              const SizedBox(height: 20),
            ],
            _buildRecentTransactions(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF1565C0),
          child: Text(
            widget.customerName.isNotEmpty
                ? widget.customerName[0].toUpperCase()
                : '?',
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              Text(widget.customerName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 26),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              GestureDetector(
                onTap: () =>
                    setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _maskedBalance(widget.accountBalance),
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBalancePill('Savings', widget.savingsBalance),
              const SizedBox(width: 12),
              _buildBalancePill('Loan Due', widget.loanBalance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalancePill(String label, double amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 11)),
            const SizedBox(height: 2),
            Text(_maskedBalance(amount),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(Icons.payment, 'Pay Loan', const Color(0xFF2E7D32),
          widget.onPayLoan),
      _QuickAction(Icons.savings, 'Deposit', const Color(0xFF1565C0),
          widget.onDeposit),
      _QuickAction(Icons.account_balance_wallet, 'Withdraw',
          const Color(0xFFEF6C00), widget.onWithdraw),
      _QuickAction(Icons.send, 'Send Money', const Color(0xFF6A1B9A),
          widget.onSendMoney),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((a) => _buildActionButton(a)).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(action.icon, color: action.color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(action.label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActiveLoanCard() {
    final progress = widget.loanLimit > 0
        ? ((widget.loanLimit - widget.loanBalance) / widget.loanLimit)
            .clamp(0.0, 1.0)
        : 0.0;
    final daysLeft = widget.loanDueDate != null
        ? widget.loanDueDate!.difference(DateTime.now()).inDays
        : 0;
    final isOverdue = daysLeft < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Loan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: widget.onViewLoanDetails,
                child: Text('View Details',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Outstanding: ${_currencyFmt.format(widget.loanBalance)}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? Colors.red.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOverdue
                      ? '${daysLeft.abs()} days overdue'
                      : '$daysLeft days left',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isOverdue ? Colors.red : Colors.orange.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  AlwaysStoppedAnimation<Color>(isOverdue ? Colors.red : const Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(progress * 100).toStringAsFixed(0)}% repaid',
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalCard() {
    final progress = widget.savingsGoal > 0
        ? (widget.savingsBalance / widget.savingsGoal).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _SavingsRingPainter(progress: progress),
              child: Center(
                child: Text('${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Savings Goal',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                    '${_currencyFmt.format(widget.savingsBalance)} of ${_currencyFmt.format(widget.savingsGoal)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: widget.onViewAllTransactions,
              child: Text('View All',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.recentTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text('No recent transactions',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          )
        else
          ...widget.recentTransactions
              .take(5)
              .map((tx) => _buildTransactionTile(tx)),
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final type = tx['type'] as String? ?? 'UNKNOWN';
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final description = tx['description'] as String? ?? type;
    final dateStr = tx['date'] as String?;
    final isCredit =
        type == 'DEPOSIT' || type == 'LOAN_DISBURSEMENT' || type == 'CREDIT';

    IconData icon;
    Color iconColor;
    switch (type) {
      case 'DEPOSIT':
        icon = Icons.arrow_downward;
        iconColor = const Color(0xFF2E7D32);
        break;
      case 'WITHDRAWAL':
        icon = Icons.arrow_upward;
        iconColor = const Color(0xFFEF6C00);
        break;
      case 'LOAN_REPAYMENT':
        icon = Icons.payment;
        iconColor = const Color(0xFF1565C0);
        break;
      case 'LOAN_DISBURSEMENT':
        icon = Icons.account_balance;
        iconColor = const Color(0xFF6A1B9A);
        break;
      default:
        icon = Icons.swap_horiz;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (dateStr != null)
                  Text(dateStr,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'} ${_currencyFmt.format(amount)}',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCredit ? const Color(0xFF2E7D32) : Colors.red.shade700),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _QuickAction(this.icon, this.label, this.color, this.onTap);
}

class _SavingsRingPainter extends CustomPainter {
  final double progress;
  _SavingsRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final fgPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SavingsRingPainter old) =>
      old.progress != progress;
}
