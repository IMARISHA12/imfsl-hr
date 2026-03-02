// IMFSL Loan Calculator — Customer Mobile App
// =============================================
// Standalone loan calculator that supports both FLAT and REDUCING_BALANCE
// interest types. Customers can compare products, adjust amount/tenure,
// see fee breakdowns, and view full amortization schedules — all client-side.
//
// Params:
//   loanProducts — List<Map<String,dynamic>> (already loaded at startup)
//   onApplyNow   — callback receiving the selected product map
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslLoanCalculator extends StatefulWidget {
  const ImfslLoanCalculator({
    super.key,
    this.loanProducts = const [],
    this.onApplyNow,
  });

  final List<Map<String, dynamic>> loanProducts;
  final Function(Map<String, dynamic> product)? onApplyNow;

  @override
  State<ImfslLoanCalculator> createState() => _ImfslLoanCalculatorState();
}

class _ImfslLoanCalculatorState extends State<ImfslLoanCalculator> {
  static const _primaryColor = Color(0xFF1565C0);
  static const _successColor = Color(0xFF2E7D32);

  final NumberFormat _currencyFmt =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  int _selectedProductIndex = 0;
  double _selectedAmount = 0;
  int _selectedTenure = 1;
  bool _showSchedule = false;

  @override
  void initState() {
    super.initState();
    _resetToProduct(0);
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Map<String, dynamic> get _product =>
      widget.loanProducts.isEmpty ? {} : widget.loanProducts[_selectedProductIndex];

  double _dbl(dynamic v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;
  int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

  void _resetToProduct(int index) {
    if (widget.loanProducts.isEmpty) return;
    final p = widget.loanProducts[index];
    _selectedProductIndex = index;
    _selectedAmount = _roundToThousand(_dbl(p['min_amount']));
    _selectedTenure = _int(p['min_tenure_months']).clamp(1, 120);
  }

  double _roundToThousand(double v) => (v / 1000).round() * 1000.0;

  String _interestType(Map<String, dynamic> p) =>
      (p['interest_type'] as String? ?? 'REDUCING_BALANCE').toUpperCase();

  // ── Calculation engine ───────────────────────────────────────────────

  double _calcEmi(double principal, double annualRate, int months, String type) {
    if (months <= 0 || principal <= 0) return 0;
    if (type == 'FLAT') {
      final totalInterest = principal * annualRate / 100 * months / 12;
      return (principal + totalInterest) / months;
    }
    // REDUCING_BALANCE
    final r = annualRate / 100 / 12;
    if (r == 0) return principal / months;
    final factor = pow(1 + r, months);
    return principal * r * factor / (factor - 1);
  }

  double _calcTotalInterest(
      double principal, double annualRate, int months, String type) {
    if (months <= 0 || principal <= 0) return 0;
    if (type == 'FLAT') {
      return principal * annualRate / 100 * months / 12;
    }
    final emi = _calcEmi(principal, annualRate, months, type);
    return emi * months - principal;
  }

  List<Map<String, dynamic>> _buildSchedule(
      double principal, double annualRate, int months, String type) {
    final rows = <Map<String, dynamic>>[];
    if (months <= 0 || principal <= 0) return rows;

    final emi = _calcEmi(principal, annualRate, months, type);
    double balance = principal;
    final now = DateTime.now();

    for (int i = 1; i <= months; i++) {
      final dueDate = DateTime(now.year, now.month + i, now.day);
      double interest;
      double principalPart;

      if (type == 'FLAT') {
        interest = principal * annualRate / 100 / 12;
        principalPart = emi - interest;
      } else {
        final r = annualRate / 100 / 12;
        interest = balance * r;
        principalPart = emi - interest;
      }

      balance -= principalPart;
      if (balance.abs() < 1) balance = 0;

      rows.add({
        'month': i,
        'due_date': dueDate,
        'principal': principalPart,
        'interest': interest,
        'emi': principalPart + interest,
        'balance': balance < 0 ? 0.0 : balance,
      });
    }
    return rows;
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.loanProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calculate_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No loan products available',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final p = _product;
    final annualRate = _dbl(p['interest_rate_annual']);
    final type = _interestType(p);
    final emi = _calcEmi(_selectedAmount, annualRate, _selectedTenure, type);
    final totalInterest =
        _calcTotalInterest(_selectedAmount, annualRate, _selectedTenure, type);
    final totalRepayable = _selectedAmount + totalInterest;
    final processingFeePct = _dbl(p['processing_fee_pct']);
    final insuranceFeePct = _dbl(p['insurance_fee_pct']);
    final processingFee = _selectedAmount * processingFeePct / 100;
    final insuranceFee = _selectedAmount * insuranceFeePct / 100;
    final netDisbursement = _selectedAmount - processingFee - insuranceFee;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductSelector(),
          const SizedBox(height: 20),
          _buildAmountSlider(p),
          const SizedBox(height: 16),
          _buildTenureSlider(p),
          const SizedBox(height: 20),
          _buildResultsCard(emi, totalInterest, totalRepayable, processingFee,
              insuranceFee, type),
          const SizedBox(height: 12),
          _buildDisbursementCard(netDisbursement, processingFee, insuranceFee),
          const SizedBox(height: 16),
          _buildScheduleSection(annualRate, type),
          const SizedBox(height: 20),
          _buildApplyButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Product selector chips ───────────────────────────────────────────

  Widget _buildProductSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Product',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.loanProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final p = widget.loanProducts[i];
              final selected = i == _selectedProductIndex;
              final rate = _dbl(p['interest_rate_annual']);
              final type = _interestType(p);
              final badge = type == 'FLAT' ? 'F' : 'R';
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p['product_name'] ?? p['product_code'] ?? 'Product'),
                    const SizedBox(width: 6),
                    Text('${rate.toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 11,
                            color: selected ? Colors.white70 : Colors.grey)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(badge,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.white : Colors.grey[600])),
                    ),
                  ],
                ),
                selected: selected,
                selectedColor: _primaryColor,
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal),
                onSelected: (_) {
                  setState(() {
                    _resetToProduct(i);
                    _showSchedule = false;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Amount slider ────────────────────────────────────────────────────

  Widget _buildAmountSlider(Map<String, dynamic> p) {
    final minAmt = _dbl(p['min_amount']);
    final maxAmt = _dbl(p['max_amount']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Loan Amount',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text(_currencyFmt.format(_selectedAmount),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor)),
          ],
        ),
        Slider(
          value: _selectedAmount.clamp(minAmt, maxAmt),
          min: minAmt,
          max: maxAmt,
          divisions: ((maxAmt - minAmt) / 1000).round().clamp(1, 1000),
          activeColor: _primaryColor,
          onChanged: (v) => setState(() => _selectedAmount = _roundToThousand(v)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_currencyFmt.format(minAmt),
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            Text(_currencyFmt.format(maxAmt),
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  // ── Tenure slider ────────────────────────────────────────────────────

  Widget _buildTenureSlider(Map<String, dynamic> p) {
    final minT = _int(p['min_tenure_months']).clamp(1, 120);
    final maxT = _int(p['max_tenure_months']).clamp(minT, 120);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tenure',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text('$_selectedTenure months',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor)),
          ],
        ),
        Slider(
          value: _selectedTenure.toDouble().clamp(minT.toDouble(), maxT.toDouble()),
          min: minT.toDouble(),
          max: maxT.toDouble(),
          divisions: (maxT - minT).clamp(1, 120),
          activeColor: _primaryColor,
          onChanged: (v) => setState(() => _selectedTenure = v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$minT months',
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            Text('$maxT months',
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  // ── Results card ─────────────────────────────────────────────────────

  Widget _buildResultsCard(double emi, double totalInterest,
      double totalRepayable, double processingFee, double insuranceFee,
      String type) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // EMI prominent display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text('Monthly Instalment (EMI)',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(_currencyFmt.format(emi),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 2×3 detail grid
            Row(
              children: [
                Expanded(
                    child: _detailTile(
                        'Total Interest', _currencyFmt.format(totalInterest))),
                Expanded(
                    child: _detailTile(
                        'Total Repayable', _currencyFmt.format(totalRepayable))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _detailTile(
                        'Processing Fee', _currencyFmt.format(processingFee))),
                Expanded(
                    child: _detailTile(
                        'Insurance Fee', _currencyFmt.format(insuranceFee))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _detailTile('Interest Type', type == 'FLAT' ? 'Flat Rate' : 'Reducing Balance')),
                Expanded(
                    child: _detailTile('Net Disbursement',
                        _currencyFmt.format(_selectedAmount - processingFee - insuranceFee))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Disbursement highlight ───────────────────────────────────────────

  Widget _buildDisbursementCard(
      double netDisbursement, double processingFee, double insuranceFee) {
    final totalFees = processingFee + insuranceFee;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _successColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _successColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: _successColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You will receive',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(_currencyFmt.format(netDisbursement),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _successColor)),
                if (totalFees > 0)
                  Text('After ${_currencyFmt.format(totalFees)} in fees deducted',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Amortization schedule ────────────────────────────────────────────

  Widget _buildScheduleSection(double annualRate, String type) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('Amortization Schedule',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: Icon(
        _showSchedule ? Icons.expand_less : Icons.expand_more,
        color: _primaryColor,
      ),
      initiallyExpanded: _showSchedule,
      onExpansionChanged: (v) => setState(() => _showSchedule = v),
      children: [_buildScheduleTable(annualRate, type)],
    );
  }

  Widget _buildScheduleTable(double annualRate, String type) {
    final schedule =
        _buildSchedule(_selectedAmount, annualRate, _selectedTenure, type);
    if (schedule.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Adjust amount and tenure to see schedule.'),
      );
    }

    final dateFmt = DateFormat('MMM yyyy');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowColor:
            WidgetStateProperty.all(_primaryColor.withValues(alpha: 0.06)),
        columns: const [
          DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Principal', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('Interest', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
        ],
        rows: schedule.map((r) {
          return DataRow(cells: [
            DataCell(Text('${r['month']}')),
            DataCell(Text(dateFmt.format(r['due_date'] as DateTime))),
            DataCell(Text(_currencyFmt.format(r['principal']))),
            DataCell(Text(_currencyFmt.format(r['interest']))),
            DataCell(Text(_currencyFmt.format(r['emi']))),
            DataCell(Text(_currencyFmt.format(r['balance']))),
          ]);
        }).toList(),
      ),
    );
  }

  // ── Apply Now button ─────────────────────────────────────────────────

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => widget.onApplyNow?.call(_product),
        icon: const Icon(Icons.send, size: 20),
        label: const Text('Apply Now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _successColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
