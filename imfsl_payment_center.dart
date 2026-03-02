// IMFSL Payment Center Widget
// ============================
// Dedicated "Pay" tab for the customer app, providing:
//   - Payment stats summary (total paid this month, all-time)
//   - Quick-pay cards for active loans and savings accounts
//   - Pending payments banner
//   - Filterable recent payment history
//   - Formatted receipt bottom sheet
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslPaymentCenter extends StatelessWidget {
  const ImfslPaymentCenter({
    super.key,
    this.summary = const {},
    this.recentPayments = const [],
    this.recentPaymentsTotalCount = 0,
    this.isLoading = false,
    this.currentFilter = 'ALL',
    this.onFilterChange,
    this.onPayLoan,
    this.onDepositSavings,
    this.onViewReceipt,
    this.onRefresh,
    this.onLoadMore,
    this.onInitiatePayment,
  });

  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> recentPayments;
  final int recentPaymentsTotalCount;
  final bool isLoading;
  final String currentFilter;
  final Function(String filter)? onFilterChange;
  final Function(Map<String, dynamic> loan)? onPayLoan;
  final Function(Map<String, dynamic> account)? onDepositSavings;
  final Function(String transactionId)? onViewReceipt;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final VoidCallback? onInitiatePayment;

  static const _primaryColor = Color(0xFF1565C0);
  static const _successGreen = Color(0xFF2E7D32);
  static const _warningAmber = Color(0xFFEF6C00);

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

    if (isLoading && recentPayments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Payment Stats Card ──
          SliverToBoxAdapter(
            child: _buildStatsCard(currencyFmt),
          ),

          // ── Quick Pay Section ──
          SliverToBoxAdapter(
            child: _buildQuickPaySection(currencyFmt),
          ),

          // ── Pending Payments Banner ──
          SliverToBoxAdapter(
            child: _buildPendingBanner(currencyFmt),
          ),

          // ── Filter Chips ──
          SliverToBoxAdapter(
            child: _buildFilterChips(),
          ),

          // ── Recent Payments List ──
          _buildPaymentsList(currencyFmt),

          // ── Load More Button ──
          if (recentPayments.length < recentPaymentsTotalCount)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: TextButton.icon(
                    onPressed: onLoadMore,
                    icon: const Icon(Icons.expand_more, size: 20),
                    label: const Text('Load More'),
                    style: TextButton.styleFrom(foregroundColor: _primaryColor),
                  ),
                ),
              ),
            ),

          // ── Bottom Padding ──
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAYMENT STATS CARD
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStatsCard(NumberFormat fmt) {
    final totalMonth = _toDouble(summary['total_paid_this_month']);
    final countMonth = _toInt(summary['payment_count_this_month']);
    final totalAll = _toDouble(summary['total_paid_all_time']);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryColor, Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Paid This Month',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$countMonth payment${countMonth == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              fmt.format(totalMonth),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('All-time total: ',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                  Text(
                    fmt.format(totalAll),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // QUICK PAY SECTION
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildQuickPaySection(NumberFormat fmt) {
    final loans = _asList(summary['active_loans']);
    final savings = _asList(summary['active_savings']);

    if (loans.isEmpty && savings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildEmptyQuickPay(),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Pay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...loans.map((loan) => _buildLoanQuickCard(loan, fmt)),
                ...savings.map((acct) => _buildSavingsQuickCard(acct, fmt)),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQuickPay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No active loans or savings accounts for quick payment.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          if (onInitiatePayment != null)
            TextButton(
              onPressed: onInitiatePayment,
              child: const Text('Pay'),
            ),
        ],
      ),
    );
  }

  Widget _buildLoanQuickCard(Map<String, dynamic> loan, NumberFormat fmt) {
    final daysUntilDue = _toIntOrNull(loan['days_until_due']);
    final isOverdue = daysUntilDue != null && daysUntilDue < 0;
    final isDueSoon = daysUntilDue != null && daysUntilDue >= 0 && daysUntilDue <= 3;
    final cardColor = isOverdue
        ? Colors.red
        : isDueSoon
            ? _warningAmber
            : _primaryColor;
    final nextDueAmount = _toDouble(loan['next_due_amount']);
    final loanNumber = loan['loan_number']?.toString() ?? '';
    final productName = loan['product_name']?.toString() ?? 'Loan';

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: cardColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  productName,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cardColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(loanNumber,
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text(
            nextDueAmount > 0 ? fmt.format(nextDueAmount) : 'No due amount',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (daysUntilDue != null)
            Text(
              isOverdue
                  ? '${daysUntilDue.abs()} days overdue'
                  : daysUntilDue == 0
                      ? 'Due today'
                      : 'Due in $daysUntilDue days',
              style: TextStyle(fontSize: 11, color: cardColor),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () => onPayLoan?.call(loan),
              style: ElevatedButton.styleFrom(
                backgroundColor: cardColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Pay Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsQuickCard(Map<String, dynamic> acct, NumberFormat fmt) {
    final balance = _toDouble(acct['current_balance']);
    final accountNumber = acct['account_number']?.toString() ?? '';
    final productName = acct['product_name']?.toString() ?? 'Savings';

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _successGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings, color: _successGreen, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  productName,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _successGreen),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(accountNumber,
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text(
            fmt.format(balance),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Text('Balance',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () => onDepositSavings?.call(acct),
              style: ElevatedButton.styleFrom(
                backgroundColor: _successGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Deposit'),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PENDING PAYMENTS BANNER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPendingBanner(NumberFormat fmt) {
    final pending = _asList(summary['pending_payments']);
    if (pending.isEmpty) return const SizedBox.shrink();

    final total = pending.fold<double>(
        0.0, (sum, p) => sum + _toDouble(p['amount']));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _warningAmber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _warningAmber.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_warningAmber),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pending.length} pending payment${pending.length == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _warningAmber),
                  ),
                  Text(
                    'Total: ${fmt.format(total)} - Checking status...',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FILTER CHIPS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildFilterChips() {
    const filters = [
      {'key': 'ALL', 'label': 'All'},
      {'key': 'LOAN_REPAYMENT', 'label': 'Loan'},
      {'key': 'DEPOSIT', 'label': 'Deposit'},
      {'key': 'FEE_PAYMENT', 'label': 'Fee'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Payments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              if (onInitiatePayment != null)
                TextButton.icon(
                  onPressed: onInitiatePayment,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Payment'),
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryColor,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: filters.map((f) {
              final isActive = currentFilter == f['key'];
              return ChoiceChip(
                label: Text(f['label']!),
                selected: isActive,
                onSelected: (_) => onFilterChange?.call(f['key']!),
                selectedColor: _primaryColor.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isActive ? _primaryColor : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isActive
                        ? _primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                backgroundColor: Colors.white,
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAYMENTS LIST
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPaymentsList(NumberFormat fmt) {
    if (recentPayments.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'No payments found',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final payment = recentPayments[index];
            return _buildPaymentItem(payment, fmt, context);
          },
          childCount: recentPayments.length,
        ),
      ),
    );
  }

  Widget _buildPaymentItem(
      Map<String, dynamic> payment, NumberFormat fmt, BuildContext context) {
    final purpose = payment['purpose']?.toString() ?? '';
    final amount = _toDouble(payment['amount']);
    final status = payment['status']?.toString() ?? '';
    final receipt = payment['mpesa_receipt_number']?.toString() ?? '';
    final createdAt = payment['created_at']?.toString() ?? '';
    final txnId = payment['id']?.toString() ?? '';

    IconData purposeIcon;
    Color purposeColor;
    switch (purpose) {
      case 'LOAN_REPAYMENT':
        purposeIcon = Icons.account_balance;
        purposeColor = _primaryColor;
        break;
      case 'DEPOSIT':
        purposeIcon = Icons.savings;
        purposeColor = _successGreen;
        break;
      case 'FEE_PAYMENT':
        purposeIcon = Icons.receipt;
        purposeColor = _warningAmber;
        break;
      default:
        purposeIcon = Icons.payment;
        purposeColor = Colors.grey;
    }

    Color statusColor;
    String statusLabel;
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        statusColor = _successGreen;
        statusLabel = 'Completed';
        break;
      case 'PENDING':
      case 'INITIATED':
        statusColor = _warningAmber;
        statusLabel = 'Pending';
        break;
      case 'FAILED':
        statusColor = Colors.red;
        statusLabel = 'Failed';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = status;
    }

    String formattedDate = '';
    if (createdAt.isNotEmpty) {
      final dt = DateTime.tryParse(createdAt);
      if (dt != null) {
        formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dt.toLocal());
      }
    }

    return InkWell(
      onTap: txnId.isNotEmpty ? () => _showReceiptSheet(context, txnId) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: purposeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(purposeIcon, color: purposeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _purposeLabel(purpose),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  if (receipt.isNotEmpty)
                    Text(receipt,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500])),
                  Text(formattedDate,
                      style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fmt.format(amount),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // RECEIPT BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════════

  void _showReceiptSheet(BuildContext context, String transactionId) {
    onViewReceipt?.call(transactionId);
  }

  /// Static helper to show a formatted receipt bottom sheet from outside.
  static void showReceiptBottomSheet(
      BuildContext context, Map<String, dynamic> receipt) {
    final fmt = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            final amount = _toDoubleStatic(receipt['amount']);
            final status = receipt['status']?.toString() ?? '';
            final mpesaReceipt = receipt['mpesa_receipt_number']?.toString() ?? '';
            final phone = receipt['phone_number']?.toString() ?? '';
            final purpose = receipt['purpose']?.toString() ?? '';
            final createdAt = receipt['created_at']?.toString() ?? '';
            final reconciledAt = receipt['reconciled_at']?.toString() ?? '';
            final appliedTo = receipt['applied_to'] is Map
                ? receipt['applied_to'] as Map<String, dynamic>
                : <String, dynamic>{};
            final customer = receipt['customer'] is Map
                ? receipt['customer'] as Map<String, dynamic>
                : <String, dynamic>{};

            String formattedDate = '';
            if (createdAt.isNotEmpty) {
              final dt = DateTime.tryParse(createdAt);
              if (dt != null) {
                formattedDate =
                    DateFormat('dd MMM yyyy, HH:mm:ss').format(dt.toLocal());
              }
            }

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: status == 'COMPLETED'
                          ? _successGreen.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      status == 'COMPLETED'
                          ? Icons.check_circle
                          : Icons.receipt_long,
                      color:
                          status == 'COMPLETED' ? _successGreen : Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'IMFSL Payment Receipt',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800]),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: status == 'COMPLETED'
                          ? _successGreen.withValues(alpha: 0.1)
                          : _warningAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: status == 'COMPLETED'
                            ? _successGreen
                            : _warningAmber,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Amount
                Center(
                  child: Text(
                    fmt.format(amount),
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Details
                _receiptRow('M-Pesa Receipt', mpesaReceipt),
                _receiptRow('Phone Number', phone),
                _receiptRow('Purpose', _purposeLabelStatic(purpose)),
                _receiptRow('Date', formattedDate),
                if (reconciledAt.isNotEmpty)
                  _receiptRow('Reconciled', () {
                    final dt = DateTime.tryParse(reconciledAt);
                    return dt != null
                        ? DateFormat('dd MMM yyyy, HH:mm').format(dt.toLocal())
                        : reconciledAt;
                  }()),

                // Applied-to info
                if (appliedTo.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('Applied To',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  if (appliedTo['type'] == 'LOAN_REPAYMENT') ...[
                    _receiptRow('Loan',
                        appliedTo['loan_number']?.toString() ?? ''),
                    _receiptRow('Product',
                        appliedTo['product_name']?.toString() ?? ''),
                  ],
                  if (appliedTo['type'] == 'DEPOSIT') ...[
                    _receiptRow('Account',
                        appliedTo['account_number']?.toString() ?? ''),
                    _receiptRow('Product',
                        appliedTo['product_name']?.toString() ?? ''),
                  ],
                ],

                // Customer info
                if (customer.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('Customer',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  _receiptRow('Name', customer['name']?.toString() ?? ''),
                  _receiptRow('Phone', customer['phone']?.toString() ?? ''),
                ],

                const SizedBox(height: 24),

                // Share placeholder
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share functionality placeholder
                      Navigator.of(ctx).pop();
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share Receipt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════

  static String _purposeLabel(String purpose) {
    switch (purpose) {
      case 'LOAN_REPAYMENT':
        return 'Loan Repayment';
      case 'DEPOSIT':
        return 'Savings Deposit';
      case 'FEE_PAYMENT':
        return 'Fee Payment';
      default:
        return purpose.isNotEmpty ? purpose : 'Payment';
    }
  }

  static String _purposeLabelStatic(String purpose) => _purposeLabel(purpose);

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static double _toDoubleStatic(dynamic v) => _toDouble(v);

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => e is Map<String, dynamic>
              ? e
              : Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }
}
