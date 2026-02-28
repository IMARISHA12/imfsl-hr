// IMFSL Loan Products Catalog - Customer Mobile App
// ===================================================
// Browse loan products with grid/list toggle, product detail bottom sheet,
// built-in EMI calculator with reducing balance formula, and full amortization
// schedule preview.
//
// Loan product Map structure:
//   {id, product_name, product_code, min_amount, max_amount,
//    interest_rate_annual, interest_type, min_tenure_months, max_tenure_months,
//    processing_fee_pct, insurance_fee_pct, penalty_rate_daily,
//    grace_period_days, requires_guarantor, requires_collateral, is_active}
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanProductsCatalog extends StatefulWidget {
  const LoanProductsCatalog({
    super.key,
    this.loanProducts = const [],
    this.onCalculateSchedule,
    this.onApplyNow,
    this.maxLoanLimit = 500000,
  });

  final List<Map<String, dynamic>> loanProducts;
  final Future<List<Map<String, dynamic>>> Function(
      double principal, double rate, int months)? onCalculateSchedule;
  final Function(Map<String, dynamic> product)? onApplyNow;
  final double maxLoanLimit;

  @override
  State<LoanProductsCatalog> createState() => _LoanProductsCatalogState();
}

class _LoanProductsCatalogState extends State<LoanProductsCatalog> {
  static const _primaryColor = Color(0xFF1565C0);
  static const _successColor = Color(0xFF2E7D32);

  bool _isGridView = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final NumberFormat _currencyFmt =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final NumberFormat _currencyFmtShort =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);

  List<Map<String, dynamic>> get _filteredProducts {
    if (_searchQuery.isEmpty) return widget.loanProducts;
    final q = _searchQuery.toLowerCase();
    return widget.loanProducts.where((p) {
      final name = (p['product_name'] as String? ?? '').toLowerCase();
      final code = (p['product_code'] as String? ?? '').toLowerCase();
      return name.contains(q) || code.contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  EMI Calculation (reducing balance)
  // ═══════════════════════════════════════════════════════════════════════

  double _calculateEMI(double principal, double annualRate, int months) {
    if (principal <= 0 || months <= 0) return 0;
    final r = annualRate / 12.0 / 100.0;
    if (r == 0) return principal / months;
    final factor = pow(1 + r, months).toDouble();
    return principal * r * factor / (factor - 1);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Loan Products',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'Switch to list view' : 'Switch to grid view',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? _buildGridView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        decoration: InputDecoration(
          hintText: 'Search loan products...',
          prefixIcon: const Icon(Icons.search, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_outlined,
                size: 72, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No products match "$_searchQuery"'
                  : 'No loan products available',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term.'
                  : 'Check back later for new loan offerings.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear Search'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: const BorderSide(color: _primaryColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Grid View ────────────────────────────────────────────────────────

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, i) => _buildGridCard(_filteredProducts[i]),
    );
  }

  Widget _buildGridCard(Map<String, dynamic> product) {
    final name = product['product_name'] as String? ?? 'Loan Product';
    final rate = (product['interest_rate_annual'] as num?)?.toDouble() ?? 0;
    final minAmt = (product['min_amount'] as num?)?.toDouble() ?? 0;
    final maxAmt = (product['max_amount'] as num?)?.toDouble() ?? 0;
    final minTenure = (product['min_tenure_months'] as num?)?.toInt() ?? 1;
    final maxTenure = (product['max_tenure_months'] as num?)?.toInt() ?? 12;
    final isActive = product['is_active'] == true;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _showProductDetail(product),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: icon + rate badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_balance,
                        color: _primaryColor, size: 22),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${rate.toStringAsFixed(1)}% p.a.',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _successColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product name
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),

              // Amount range
              Text(
                '${_currencyFmtShort.format(minAmt)} - ${_currencyFmtShort.format(maxAmt)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Tenure range
              Text('$minTenure - $maxTenure months',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),

              const Spacer(),

              // View Details button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isActive ? () => _showProductDetail(product) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: Text(isActive ? 'View Details' : 'Unavailable'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── List View ────────────────────────────────────────────────────────

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, i) => _buildListCard(_filteredProducts[i]),
    );
  }

  Widget _buildListCard(Map<String, dynamic> product) {
    final name = product['product_name'] as String? ?? 'Loan Product';
    final code = product['product_code'] as String? ?? '';
    final rate = (product['interest_rate_annual'] as num?)?.toDouble() ?? 0;
    final minAmt = (product['min_amount'] as num?)?.toDouble() ?? 0;
    final maxAmt = (product['max_amount'] as num?)?.toDouble() ?? 0;
    final minTenure = (product['min_tenure_months'] as num?)?.toInt() ?? 1;
    final maxTenure = (product['max_tenure_months'] as num?)?.toInt() ?? 12;
    final isActive = product['is_active'] == true;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showProductDetail(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Leading icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance,
                    color: _primaryColor, size: 26),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${rate.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _successColor),
                          ),
                        ),
                      ],
                    ),
                    if (code.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(code,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500])),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.payments_outlined,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${_currencyFmtShort.format(minAmt)} - ${_currencyFmtShort.format(maxAmt)}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.schedule,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('$minTenure-$maxTenure mo',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  PRODUCT DETAIL BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════════════

  void _showProductDetail(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductDetailSheet(
        product: product,
        maxLoanLimit: widget.maxLoanLimit,
        currencyFmt: _currencyFmt,
        currencyFmtShort: _currencyFmtShort,
        calculateEMI: _calculateEMI,
        onCalculateSchedule: widget.onCalculateSchedule,
        onApplyNow: widget.onApplyNow,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PRODUCT DETAIL SHEET (stateful for slider / calculator)
// ═══════════════════════════════════════════════════════════════════════════

class _ProductDetailSheet extends StatefulWidget {
  const _ProductDetailSheet({
    required this.product,
    required this.maxLoanLimit,
    required this.currencyFmt,
    required this.currencyFmtShort,
    required this.calculateEMI,
    this.onCalculateSchedule,
    this.onApplyNow,
  });

  final Map<String, dynamic> product;
  final double maxLoanLimit;
  final NumberFormat currencyFmt;
  final NumberFormat currencyFmtShort;
  final double Function(double, double, int) calculateEMI;
  final Future<List<Map<String, dynamic>>> Function(
      double principal, double rate, int months)? onCalculateSchedule;
  final Function(Map<String, dynamic> product)? onApplyNow;

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  static const _primaryColor = Color(0xFF1565C0);
  static const _successColor = Color(0xFF2E7D32);

  late double _selectedAmount;
  late int _selectedTenure;
  bool _isLoadingSchedule = false;
  List<Map<String, dynamic>>? _schedule;

  double get _minAmount =>
      (widget.product['min_amount'] as num?)?.toDouble() ?? 1000;
  double get _maxAmount {
    final prodMax =
        (widget.product['max_amount'] as num?)?.toDouble() ?? 500000;
    return min(prodMax, widget.maxLoanLimit);
  }

  int get _minTenure =>
      (widget.product['min_tenure_months'] as num?)?.toInt() ?? 1;
  int get _maxTenure =>
      (widget.product['max_tenure_months'] as num?)?.toInt() ?? 36;
  double get _annualRate =>
      (widget.product['interest_rate_annual'] as num?)?.toDouble() ?? 0;
  double get _processingFeePct =>
      (widget.product['processing_fee_pct'] as num?)?.toDouble() ?? 0;
  double get _insuranceFeePct =>
      (widget.product['insurance_fee_pct'] as num?)?.toDouble() ?? 0;

  double get _emi =>
      widget.calculateEMI(_selectedAmount, _annualRate, _selectedTenure);
  double get _totalPayable => _emi * _selectedTenure;
  double get _totalInterest => _totalPayable - _selectedAmount;
  double get _processingFee => _selectedAmount * _processingFeePct / 100;
  double get _insuranceFee => _selectedAmount * _insuranceFeePct / 100;

  @override
  void initState() {
    super.initState();
    _selectedAmount = _minAmount;
    _selectedTenure = _minTenure;
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoadingSchedule = true;
      _schedule = null;
    });

    if (widget.onCalculateSchedule != null) {
      try {
        final result = await widget.onCalculateSchedule!(
            _selectedAmount, _annualRate, _selectedTenure);
        setState(() {
          _schedule = result;
          _isLoadingSchedule = false;
        });
      } catch (e) {
        setState(() => _isLoadingSchedule = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load schedule: $e')),
          );
        }
      }
    } else {
      // Generate schedule locally
      final schedule = <Map<String, dynamic>>[];
      double balance = _selectedAmount;
      final monthlyRate = _annualRate / 12.0 / 100.0;
      final emi = _emi;
      final now = DateTime.now();

      for (int i = 1; i <= _selectedTenure; i++) {
        final interest = balance * monthlyRate;
        final principalPart = emi - interest;
        balance = balance - principalPart;
        if (balance < 0) balance = 0;

        final dueDate = DateTime(now.year, now.month + i, now.day);
        schedule.add({
          'month': i,
          'due_date': DateFormat('dd MMM yyyy').format(dueDate),
          'principal': principalPart,
          'interest': interest,
          'total': emi,
          'balance': balance,
        });
      }
      setState(() {
        _schedule = schedule;
        _isLoadingSchedule = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _buildDetailHeader(),
                    const SizedBox(height: 20),
                    _buildOverviewSection(),
                    const SizedBox(height: 16),
                    _buildFeesSection(),
                    const SizedBox(height: 16),
                    _buildRequirementsSection(),
                    const SizedBox(height: 16),
                    _buildTermsSection(),
                    const SizedBox(height: 24),
                    _buildEmiCalculatorSection(),
                    if (_schedule != null) ...[
                      const SizedBox(height: 20),
                      _buildScheduleTable(),
                    ],
                    const SizedBox(height: 24),
                    _buildApplyButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Detail Header ────────────────────────────────────────────────────

  Widget _buildDetailHeader() {
    final name = widget.product['product_name'] as String? ?? 'Loan Product';
    final code = widget.product['product_code'] as String? ?? '';
    final interestType = widget.product['interest_type'] as String? ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.account_balance,
              color: _primaryColor, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              if (code.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(code,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_annualRate.toStringAsFixed(1)}% p.a.',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _successColor),
                    ),
                  ),
                  if (interestType.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(interestType,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700])),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Overview Section ─────────────────────────────────────────────────

  Widget _buildOverviewSection() {
    return _buildDetailCard(
      title: 'Overview',
      icon: Icons.info_outline,
      children: [
        _buildDetailRow(
            'Loan Amount',
            '${widget.currencyFmtShort.format(_minAmount)} - '
                '${widget.currencyFmtShort.format(_maxAmount)}'),
        _buildDetailRow(
            'Tenure', '$_minTenure - $_maxTenure months'),
        _buildDetailRow(
            'Interest Rate', '${_annualRate.toStringAsFixed(2)}% per annum'),
        _buildDetailRow('Interest Type',
            widget.product['interest_type'] as String? ?? 'Reducing Balance'),
      ],
    );
  }

  // ─── Fees Section ─────────────────────────────────────────────────────

  Widget _buildFeesSection() {
    final penaltyRate =
        (widget.product['penalty_rate_daily'] as num?)?.toDouble() ?? 0;
    return _buildDetailCard(
      title: 'Fees & Charges',
      icon: Icons.receipt_long_outlined,
      children: [
        _buildDetailRow(
            'Processing Fee', '${_processingFeePct.toStringAsFixed(2)}%'),
        _buildDetailRow(
            'Insurance Fee', '${_insuranceFeePct.toStringAsFixed(2)}%'),
        _buildDetailRow(
            'Late Payment Penalty', '${penaltyRate.toStringAsFixed(2)}% daily'),
      ],
    );
  }

  // ─── Requirements Section ─────────────────────────────────────────────

  Widget _buildRequirementsSection() {
    final requiresGuarantor = widget.product['requires_guarantor'] == true;
    final requiresCollateral = widget.product['requires_collateral'] == true;
    return _buildDetailCard(
      title: 'Requirements',
      icon: Icons.checklist_outlined,
      children: [
        _buildRequirementRow('Guarantor Required', requiresGuarantor),
        _buildRequirementRow('Collateral Required', requiresCollateral),
        _buildRequirementRow('KYC Verification', true),
        _buildRequirementRow('Active Savings Account', true),
      ],
    );
  }

  Widget _buildRequirementRow(String label, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            required ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: required ? _successColor : Colors.grey[400],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            required ? 'Yes' : 'No',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: required ? _successColor : Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ─── Terms Section ────────────────────────────────────────────────────

  Widget _buildTermsSection() {
    final gracePeriod =
        (widget.product['grace_period_days'] as num?)?.toInt() ?? 0;
    return _buildDetailCard(
      title: 'Terms',
      icon: Icons.gavel_outlined,
      children: [
        _buildDetailRow('Grace Period', '$gracePeriod days'),
        _buildDetailRow('Disbursement', 'To savings account'),
        _buildDetailRow('Repayment', 'Monthly installments'),
        _buildDetailRow('Early Repayment', 'Allowed, no penalty'),
      ],
    );
  }

  // ─── EMI Calculator Section ───────────────────────────────────────────

  Widget _buildEmiCalculatorSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _primaryColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined,
                  color: _primaryColor, size: 22),
              const SizedBox(width: 8),
              const Text('EMI Calculator',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 20),

          // Amount slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Loan Amount',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text(widget.currencyFmt.format(_selectedAmount),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _primaryColor,
              inactiveTrackColor: _primaryColor.withOpacity(0.15),
              thumbColor: _primaryColor,
              overlayColor: _primaryColor.withOpacity(0.1),
              valueIndicatorColor: _primaryColor,
              showValueIndicator: ShowValueIndicator.onlyForContinuous,
            ),
            child: Slider(
              value: _selectedAmount,
              min: _minAmount,
              max: _maxAmount,
              divisions: max(1, ((_maxAmount - _minAmount) / 1000).round()),
              label: widget.currencyFmtShort.format(_selectedAmount),
              onChanged: (v) => setState(() {
                _selectedAmount = v;
                _schedule = null;
              }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.currencyFmtShort.format(_minAmount),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              Text(widget.currencyFmtShort.format(_maxAmount),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 16),

          // Tenure slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tenure (Months)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text('$_selectedTenure months',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _primaryColor,
              inactiveTrackColor: _primaryColor.withOpacity(0.15),
              thumbColor: _primaryColor,
              overlayColor: _primaryColor.withOpacity(0.1),
              valueIndicatorColor: _primaryColor,
              showValueIndicator: ShowValueIndicator.onlyForContinuous,
            ),
            child: Slider(
              value: _selectedTenure.toDouble(),
              min: _minTenure.toDouble(),
              max: _maxTenure.toDouble(),
              divisions: max(1, _maxTenure - _minTenure),
              label: '$_selectedTenure months',
              onChanged: (v) => setState(() {
                _selectedTenure = v.round();
                _schedule = null;
              }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_minTenure mo',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              Text('$_maxTenure mo',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 24),

          // EMI results
          _buildEmiResultGrid(),
          const SizedBox(height: 16),

          // Preview schedule button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoadingSchedule ? null : _loadSchedule,
              icon: _isLoadingSchedule
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _primaryColor))
                  : const Icon(Icons.table_chart_outlined, size: 18),
              label: Text(_isLoadingSchedule
                  ? 'Loading...'
                  : 'Preview Full Schedule'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: const BorderSide(color: _primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmiResultGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Monthly EMI — prominent
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text('Monthly EMI',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(widget.currencyFmt.format(_emi),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grid of other values
          Row(
            children: [
              Expanded(
                child: _buildEmiMetric(
                    'Total Interest', widget.currencyFmt.format(_totalInterest)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmiMetric(
                    'Total Repayable', widget.currencyFmt.format(_totalPayable)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEmiMetric(
                    'Processing Fee', widget.currencyFmt.format(_processingFee)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmiMetric(
                    'Insurance Fee', widget.currencyFmt.format(_insuranceFee)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmiMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ─── Schedule Table ───────────────────────────────────────────────────

  Widget _buildScheduleTable() {
    if (_schedule == null || _schedule!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.table_chart, color: _primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text('Repayment Schedule',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor)),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor:
                WidgetStateProperty.all(_primaryColor.withOpacity(0.08)),
            headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: _primaryColor),
            dataTextStyle:
                const TextStyle(fontSize: 12, color: Colors.black87),
            columnSpacing: 16,
            horizontalMargin: 12,
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Due Date')),
              DataColumn(label: Text('Principal'), numeric: true),
              DataColumn(label: Text('Interest'), numeric: true),
              DataColumn(label: Text('Total'), numeric: true),
              DataColumn(label: Text('Balance'), numeric: true),
            ],
            rows: _schedule!.map((row) {
              final month = row['month'] as int? ?? 0;
              final dueDate = row['due_date'] as String? ?? '';
              final principal = (row['principal'] as num?)?.toDouble() ?? 0;
              final interest = (row['interest'] as num?)?.toDouble() ?? 0;
              final total = (row['total'] as num?)?.toDouble() ?? 0;
              final balance = (row['balance'] as num?)?.toDouble() ?? 0;

              return DataRow(cells: [
                DataCell(Text('$month')),
                DataCell(Text(dueDate)),
                DataCell(Text(widget.currencyFmt.format(principal))),
                DataCell(Text(widget.currencyFmt.format(interest))),
                DataCell(Text(widget.currencyFmt.format(total))),
                DataCell(Text(widget.currencyFmt.format(balance))),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── Apply Button ─────────────────────────────────────────────────────

  Widget _buildApplyButton() {
    final isActive = widget.product['is_active'] == true;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isActive && widget.onApplyNow != null
            ? () {
                Navigator.pop(context);
                widget.onApplyNow!(widget.product);
              }
            : null,
        icon: const Icon(Icons.send, size: 20),
        label: Text(isActive ? 'Apply Now' : 'Product Unavailable',
            style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ─── Shared Detail Helpers ────────────────────────────────────────────

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
