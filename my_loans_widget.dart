import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// MyLoansWidget -- Loan list with detail view and repayment schedule.
///
/// Displays a summary stats bar, a scrollable list of loan cards with status
/// badges and progress indicators, and a full-screen detail view containing
/// a gradient header, info grid, repayment schedule DataTable, and action
/// buttons (Pay Now / View Statement).
class MyLoansWidget extends StatefulWidget {
  final List<Map<String, dynamic>> loans;
  final Future<Map<String, dynamic>> Function(String loanId)? onLoadLoanDetail;
  final Function(Map<String, dynamic> loan)? onPayNow;
  final Function(String loanId)? onViewStatement;

  const MyLoansWidget({
    super.key,
    this.loans = const [],
    this.onLoadLoanDetail,
    this.onPayNow,
    this.onViewStatement,
  });

  @override
  State<MyLoansWidget> createState() => _MyLoansWidgetState();
}

class _MyLoansWidgetState extends State<MyLoansWidget> {
  static const Color _primaryColor = Color(0xFF1565C0);
  static const Color _primaryLight = Color(0xFF1E88E5);

  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');

  // ---------------------------------------------------------------
  // Summary helpers
  // ---------------------------------------------------------------

  int get _totalLoans => widget.loans.length;

  double get _totalOutstanding {
    double sum = 0;
    for (final loan in widget.loans) {
      sum += _toDouble(loan['outstanding_balance']);
    }
    return sum;
  }

  int get _activeCount {
    int count = 0;
    for (final loan in widget.loans) {
      if (_statusString(loan['status']) == 'ACTIVE') count++;
    }
    return count;
  }

  // ---------------------------------------------------------------
  // Utility helpers
  // ---------------------------------------------------------------

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String _statusString(dynamic v) {
    if (v == null) return 'UNKNOWN';
    return v.toString().toUpperCase();
  }

  String _formatDate(dynamic v) {
    if (v == null) return '--';
    try {
      final dt = DateTime.parse(v.toString());
      return _dateFormat.format(dt);
    } catch (_) {
      return v.toString();
    }
  }

  String _formatDateTime(dynamic v) {
    if (v == null) return '--';
    try {
      final dt = DateTime.parse(v.toString());
      return _dateTimeFormat.format(dt);
    } catch (_) {
      return v.toString();
    }
  }

  // ---------------------------------------------------------------
  // Status badge helpers
  // ---------------------------------------------------------------

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.blue;
      case 'OVERDUE':
        return Colors.red;
      case 'CLOSED':
        return Colors.grey;
      case 'DEFAULTED':
        return Colors.deepOrange;
      case 'PENDING':
        return Colors.amber.shade700;
      case 'DISBURSED':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _statusBadge(String status, {double fontSize = 11}) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (widget.loans.isEmpty) {
      return _buildEmptyState();
    }
    return Column(
      children: [
        _buildSummaryStatsBar(),
        const SizedBox(height: 8),
        Expanded(child: _buildLoanCardsList()),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Loans Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your loan history will appear here once you apply for and receive a loan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Summary stats bar
  // ---------------------------------------------------------------

  Widget _buildSummaryStatsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStatCard(
              label: 'Total Loans',
              value: _totalLoans.toString(),
              icon: Icons.receipt_long,
              color: _primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryStatCard(
              label: 'Outstanding',
              value: _currencyFormat.format(_totalOutstanding),
              icon: Icons.account_balance,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryStatCard(
              label: 'Active',
              value: _activeCount.toString(),
              icon: Icons.check_circle_outline,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Loan cards list
  // ---------------------------------------------------------------

  Widget _buildLoanCardsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: widget.loans.length,
      itemBuilder: (context, index) {
        final loan = widget.loans[index];
        return _buildLoanCard(loan);
      },
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> loan) {
    final status = _statusString(loan['status']);
    final product = loan['imfsl_loan_products'] as Map<String, dynamic>? ?? {};
    final productName = product['product_name']?.toString() ?? 'Loan';
    final loanNumber = loan['loan_number']?.toString() ?? '--';
    final principal = _toDouble(loan['principal_amount']);
    final totalRepayable = _toDouble(loan['total_repayable']);
    final outstanding = _toDouble(loan['outstanding_balance']);
    final monthlyInstallment = _toDouble(loan['monthly_installment']);
    final nextDueDate = loan['next_due_date'];
    final daysInArrears = _toInt(loan['days_in_arrears']);

    final paid = totalRepayable - outstanding;
    final progress =
        totalRepayable > 0 ? (paid / totalRepayable).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openLoanDetail(loan),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: product name + loan number | status badge
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loanNumber,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(status),
                ],
              ),
              const SizedBox(height: 14),

              // Principal amount
              Text(
                _currencyFormat.format(principal),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(height: 6),

              // Paid label
              Text(
                'Paid: ${_currencyFormat.format(paid)} / ${_currencyFormat.format(totalRepayable)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),

              // Monthly installment + next due
              Row(
                children: [
                  _iconDetail(
                    Icons.calendar_today,
                    'Installment',
                    _currencyFormat.format(monthlyInstallment),
                  ),
                  const SizedBox(width: 20),
                  _iconDetail(
                    Icons.event,
                    'Next Due',
                    _formatDate(nextDueDate),
                  ),
                ],
              ),

              // Days in arrears warning
              if (daysInArrears > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 16, color: Colors.red.shade700),
                      const SizedBox(width: 6),
                      Text(
                        '$daysInArrears days overdue',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconDetail(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade500)),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Open loan detail
  // ---------------------------------------------------------------

  Future<void> _openLoanDetail(Map<String, dynamic> loan) async {
    final loanId = loan['id']?.toString();
    if (loanId == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LoanDetailPage(
          loan: loan,
          onLoadLoanDetail: widget.onLoadLoanDetail,
          onPayNow: widget.onPayNow,
          onViewStatement: widget.onViewStatement,
          currencyFormat: _currencyFormat,
          dateFormat: _dateFormat,
          dateTimeFormat: _dateTimeFormat,
        ),
      ),
    );
  }
}

// =================================================================
// Summary Stat Card (private)
// =================================================================

class _SummaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// Loan Detail Page (full-screen, pushed via Navigator)
// =================================================================

class _LoanDetailPage extends StatefulWidget {
  final Map<String, dynamic> loan;
  final Future<Map<String, dynamic>> Function(String loanId)? onLoadLoanDetail;
  final Function(Map<String, dynamic> loan)? onPayNow;
  final Function(String loanId)? onViewStatement;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;
  final DateFormat dateTimeFormat;

  const _LoanDetailPage({
    required this.loan,
    this.onLoadLoanDetail,
    this.onPayNow,
    this.onViewStatement,
    required this.currencyFormat,
    required this.dateFormat,
    required this.dateTimeFormat,
  });

  @override
  State<_LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<_LoanDetailPage> {
  static const Color _primaryColor = Color(0xFF1565C0);

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _detailData = {};

  // Extracted parts
  Map<String, dynamic> get _loanData =>
      (_detailData['loan'] as Map<String, dynamic>?) ?? widget.loan;
  Map<String, dynamic> get _productData =>
      (_detailData['loan_product'] as Map<String, dynamic>?) ?? {};
  List<Map<String, dynamic>> get _schedule {
    final raw = _detailData['repayment_schedule'];
    if (raw is List) {
      return raw.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final loanId = widget.loan['id']?.toString();
    if (loanId == null || widget.onLoadLoanDetail == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final result = await widget.onLoadLoanDetail!(loanId);
      if (!mounted) return;
      setState(() {
        _detailData = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ---------------------------------------------------------------
  // Utility helpers (local copies for detail page)
  // ---------------------------------------------------------------

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String _statusString(dynamic v) {
    if (v == null) return 'UNKNOWN';
    return v.toString().toUpperCase();
  }

  String _formatDate(dynamic v) {
    if (v == null) return '--';
    try {
      final dt = DateTime.parse(v.toString());
      return widget.dateFormat.format(dt);
    } catch (_) {
      return v.toString();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.blue;
      case 'OVERDUE':
        return Colors.red;
      case 'CLOSED':
        return Colors.grey;
      case 'DEFAULTED':
        return Colors.deepOrange;
      case 'PENDING':
        return Colors.amber.shade700;
      case 'DISBURSED':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _statusBadge(String status, {double fontSize = 11}) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _scheduleStatusColor(String status) {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'OVERDUE':
        return Colors.red;
      case 'PENDING':
      default:
        return Colors.grey;
    }
  }

  Widget _scheduleStatusChip(String status) {
    final color = _scheduleStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final loan = _loanData;
    final status = _statusString(loan['status']);
    final loanNumber = loan['loan_number']?.toString() ?? '--';
    final outstanding = _toDouble(loan['outstanding_balance']);
    final product = loan['imfsl_loan_products'] as Map<String, dynamic>? ?? {};
    final productName =
        _productData['product_name']?.toString() ??
        product['product_name']?.toString() ??
        'Loan';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(
                      loanNumber: loanNumber,
                      status: status,
                      outstanding: outstanding,
                      productName: productName,
                    ),
                    SliverToBoxAdapter(child: _buildBody(loan)),
                  ],
                ),
    );
  }

  // ---------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Failed to load loan details',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _loadDetail();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Sliver App Bar with gradient
  // ---------------------------------------------------------------

  SliverAppBar _buildSliverAppBar({
    required String loanNumber,
    required String status,
    required double outstanding,
    required String productName,
  }) {
    return SliverAppBar(
      expandedHeight: 210,
      pinned: true,
      backgroundColor: _primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF283593)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        loanNumber,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _statusBadgeWhite(status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productName,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Outstanding Balance',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.currencyFormat.format(outstanding),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadgeWhite(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color == Colors.blue ? Colors.white : color.withOpacity(0.9),
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Body content
  // ---------------------------------------------------------------

  Widget _buildBody(Map<String, dynamic> loan) {
    final daysInArrears = _toInt(loan['days_in_arrears']);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Days in arrears warning
          if (daysInArrears > 0) ...[
            _buildArrearsWarning(daysInArrears),
            const SizedBox(height: 16),
          ],

          // Info grid
          _buildInfoGrid(loan),
          const SizedBox(height: 20),

          // Repayment schedule
          if (_schedule.isNotEmpty) ...[
            _buildRepaymentScheduleSection(),
            const SizedBox(height: 20),
          ],

          // Action buttons
          _buildActionButtons(loan),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Arrears warning
  // ---------------------------------------------------------------

  Widget _buildArrearsWarning(int days) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.red.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Overdue',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'This loan is $days days in arrears. Please make a payment as soon as possible to avoid additional penalties.',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Info grid
  // ---------------------------------------------------------------

  Widget _buildInfoGrid(Map<String, dynamic> loan) {
    final principal = _toDouble(loan['principal_amount']);
    final interestRate = _toDouble(loan['interest_rate_applied']);
    final interestType = loan['interest_type']?.toString() ?? '--';
    final tenureMonths = _toInt(loan['tenure_months']);
    final disbursedDate = loan['disbursed_at'];
    final maturityDate = loan['maturity_date'];
    final monthlyInstallment = _toDouble(loan['monthly_installment']);
    final totalInterest = _toDouble(loan['total_interest']);
    final totalFees = _toDouble(loan['total_fees']);
    final totalRepayable = _toDouble(loan['total_repayable']);
    final disbursedAmount = _toDouble(loan['disbursed_amount']);

    // Product-level data
    final processingFee = _toDouble(_productData['processing_fee_pct']);
    final insuranceFee = _toDouble(_productData['insurance_fee_pct']);
    final penaltyRate = _toDouble(_productData['penalty_rate_daily']);
    final gracePeriod = _toInt(_productData['grace_period_days']);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Information',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const Divider(height: 20),
            _infoRow('Principal Amount', widget.currencyFormat.format(principal)),
            _infoRow('Disbursed Amount',
                widget.currencyFormat.format(disbursedAmount)),
            _infoRow('Interest Rate', '${interestRate.toStringAsFixed(2)}%'),
            _infoRow('Interest Type', interestType),
            _infoRow('Tenure', '$tenureMonths months'),
            _infoRow('Total Interest',
                widget.currencyFormat.format(totalInterest)),
            _infoRow(
                'Total Fees', widget.currencyFormat.format(totalFees)),
            _infoRow('Total Repayable',
                widget.currencyFormat.format(totalRepayable)),
            _infoRow('Monthly Installment',
                widget.currencyFormat.format(monthlyInstallment)),
            _infoRow('Disbursed On', _formatDate(disbursedDate)),
            _infoRow('Maturity Date', _formatDate(maturityDate)),
            if (_productData.isNotEmpty) ...[
              const Divider(height: 20),
              const Text(
                'Product Terms',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              if (processingFee > 0)
                _infoRow('Processing Fee',
                    '${processingFee.toStringAsFixed(2)}%'),
              if (insuranceFee > 0)
                _infoRow('Insurance Fee',
                    '${insuranceFee.toStringAsFixed(2)}%'),
              if (penaltyRate > 0)
                _infoRow('Daily Penalty Rate',
                    '${penaltyRate.toStringAsFixed(3)}%'),
              if (gracePeriod > 0)
                _infoRow('Grace Period', '$gracePeriod days'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Repayment schedule
  // ---------------------------------------------------------------

  Widget _buildRepaymentScheduleSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.table_chart_outlined,
                    size: 20, color: _primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Repayment Schedule',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_schedule.length} installments',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildScheduleDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  DataTable _buildScheduleDataTable() {
    return DataTable(
      columnSpacing: 16,
      headingRowHeight: 42,
      dataRowMinHeight: 40,
      dataRowMaxHeight: 52,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: _primaryColor,
      ),
      columns: const [
        DataColumn(label: Text('#')),
        DataColumn(label: Text('Due Date')),
        DataColumn(label: Text('Amount Due'), numeric: true),
        DataColumn(label: Text('Paid'), numeric: true),
        DataColumn(label: Text('Status')),
      ],
      rows: List<DataRow>.generate(_schedule.length, (index) {
        final item = _schedule[index];
        final installmentNumber = _toInt(item['installment_number']);
        final dueDate = item['due_date'];
        final totalDue = _toDouble(item['total_due']);
        final totalPaid = _toDouble(item['total_paid']);
        final status = _statusString(item['status']);

        // Alternating row colors
        final rowColor = index.isEven
            ? Colors.transparent
            : Colors.grey.shade50;

        return DataRow(
          color: WidgetStateProperty.all(rowColor),
          cells: [
            DataCell(Text(
              installmentNumber.toString(),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12),
            )),
            DataCell(Text(
              _formatDate(dueDate),
              style: const TextStyle(fontSize: 12),
            )),
            DataCell(Text(
              widget.currencyFormat.format(totalDue),
              style: const TextStyle(fontSize: 12),
            )),
            DataCell(Text(
              widget.currencyFormat.format(totalPaid),
              style: TextStyle(
                fontSize: 12,
                color:
                    totalPaid >= totalDue ? Colors.green.shade700 : null,
                fontWeight:
                    totalPaid >= totalDue ? FontWeight.w600 : null,
              ),
            )),
            DataCell(_scheduleStatusChip(status)),
          ],
        );
      }),
    );
  }

  // ---------------------------------------------------------------
  // Action buttons
  // ---------------------------------------------------------------

  Widget _buildActionButtons(Map<String, dynamic> loan) {
    final loanId = loan['id']?.toString() ?? '';
    final status = _statusString(loan['status']);
    final canPay = status == 'ACTIVE' || status == 'OVERDUE' || status == 'DISBURSED';

    return Row(
      children: [
        if (canPay)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onPayNow != null
                  ? () => widget.onPayNow!(loan)
                  : null,
              icon: const Icon(Icons.payment, size: 18),
              label: const Text('Pay Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        if (canPay) const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onViewStatement != null
                ? () => widget.onViewStatement!(loanId)
                : null,
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text('View Statement'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,
              side: const BorderSide(color: _primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
