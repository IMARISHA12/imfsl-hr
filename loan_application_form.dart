// IMFSL Loan Application Form - FlutterFlow Custom Widget
// ========================================================
// 4-step wizard: Product Selection -> Amount/Tenure -> Purpose/Guarantor -> Review/Submit
// Features:
// - EMI calculator with reducing balance formula
// - Real-time affordability validation
// - Product comparison cards
// - Slider for amount/tenure selection
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanApplicationForm extends StatefulWidget {
  const LoanApplicationForm({
    super.key,
    required this.customerId,
    this.loanProducts = const [],
    this.maxLoanLimit = 500000.0,
    this.onSubmit,
    this.onCancel,
  });

  final String customerId;
  final List<Map<String, dynamic>> loanProducts;
  final double maxLoanLimit;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> application)?
      onSubmit;
  final VoidCallback? onCancel;

  @override
  State<LoanApplicationForm> createState() => _LoanApplicationFormState();
}

class _LoanApplicationFormState extends State<LoanApplicationForm> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  final NumberFormat _currencyFmt =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);
  final NumberFormat _currencyFmtDecimal =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  // Step 1: Product
  int? _selectedProductIndex;

  // Step 2: Amount & Tenure
  double _requestedAmount = 10000;
  int _tenureMonths = 6;

  // Step 3: Purpose & Guarantor
  final _purposeController = TextEditingController();
  final _guarantorNameController = TextEditingController();
  final _guarantorPhoneController = TextEditingController();
  final _guarantorIdController = TextEditingController();
  String _selectedPurpose = 'Business';

  final List<String> _purposeOptions = [
    'Business',
    'Agriculture',
    'Education',
    'Medical',
    'Home Improvement',
    'Emergency',
    'Other',
  ];

  @override
  void dispose() {
    _purposeController.dispose();
    _guarantorNameController.dispose();
    _guarantorPhoneController.dispose();
    _guarantorIdController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _selectedProduct {
    if (_selectedProductIndex == null ||
        _selectedProductIndex! >= widget.loanProducts.length) return null;
    return widget.loanProducts[_selectedProductIndex!];
  }

  double get _interestRate =>
      (_selectedProduct?['interest_rate'] as num?)?.toDouble() ?? 12.0;

  double get _minAmount =>
      (_selectedProduct?['min_amount'] as num?)?.toDouble() ?? 1000.0;

  double get _maxAmount {
    final productMax =
        (_selectedProduct?['max_amount'] as num?)?.toDouble() ?? 500000.0;
    return min(productMax, widget.maxLoanLimit);
  }

  int get _minTenure =>
      (_selectedProduct?['min_tenure_months'] as num?)?.toInt() ?? 1;

  int get _maxTenure =>
      (_selectedProduct?['max_tenure_months'] as num?)?.toInt() ?? 36;

  double _calculateEMI() {
    if (_requestedAmount <= 0 || _tenureMonths <= 0) return 0;
    final monthlyRate = _interestRate / 100 / 12;
    if (monthlyRate == 0) return _requestedAmount / _tenureMonths;
    final factor = pow(1 + monthlyRate, _tenureMonths);
    return _requestedAmount * monthlyRate * factor / (factor - 1);
  }

  double get _totalPayable => _calculateEMI() * _tenureMonths;
  double get _totalInterest => _totalPayable - _requestedAmount;

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedProductIndex != null;
      case 1:
        return _requestedAmount >= _minAmount &&
            _requestedAmount <= _maxAmount &&
            _tenureMonths >= _minTenure &&
            _tenureMonths <= _maxTenure;
      case 2:
        return _selectedPurpose.isNotEmpty &&
            _guarantorNameController.text.trim().isNotEmpty &&
            _guarantorPhoneController.text.trim().length >= 10;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _submit() async {
    if (widget.onSubmit == null) return;
    setState(() => _isSubmitting = true);

    final application = {
      'customer_id': widget.customerId,
      'loan_product_id': _selectedProduct?['id'],
      'requested_amount': _requestedAmount,
      'tenure_months': _tenureMonths,
      'purpose': _selectedPurpose == 'Other'
          ? _purposeController.text.trim()
          : _selectedPurpose,
      'guarantor_name': _guarantorNameController.text.trim(),
      'guarantor_phone': _guarantorPhoneController.text.trim(),
      'guarantor_national_id': _guarantorIdController.text.trim(),
      'estimated_emi': _calculateEMI(),
      'interest_rate': _interestRate,
    };

    try {
      final result = await widget.onSubmit!(application);
      if (!mounted) return;
      _showSuccessDialog(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 64),
            const SizedBox(height: 16),
            const Text('Application Submitted!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Reference: ${result['application_number'] ?? result['id'] ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text('Your loan application is under review.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onCancel?.call();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStepIndicator(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildCurrentStep(),
          ),
        ),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStepIndicator() {
    final labels = ['Product', 'Amount', 'Details', 'Review'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone
                          ? const Color(0xFF1565C0)
                          : Colors.grey.shade300,
                    ),
                  ),
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? const Color(0xFF1565C0)
                            : isActive
                                ? const Color(0xFF1565C0)
                                : Colors.grey.shade300,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : Text('${i + 1}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.grey[600])),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(labels[i],
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                            color: isActive
                                ? const Color(0xFF1565C0)
                                : Colors.grey[600])),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1ProductSelection();
      case 1:
        return _buildStep2AmountTenure();
      case 2:
        return _buildStep3PurposeGuarantor();
      case 3:
        return _buildStep4Review();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1ProductSelection() {
    if (widget.loanProducts.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No loan products available',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select a Loan Product',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Choose the product that best fits your needs',
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 16),
        ...widget.loanProducts.asMap().entries.map((entry) {
          final i = entry.key;
          final product = entry.value;
          final isSelected = _selectedProductIndex == i;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedProductIndex = i;
              _requestedAmount = max(
                  _minAmount, min(_requestedAmount, _maxAmount));
              _tenureMonths =
                  max(_minTenure, min(_tenureMonths, _maxTenure));
            }),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF1565C0) : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product['name'] ?? 'Loan Product',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF1565C0), size: 22),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _productDetail(
                          'Rate',
                          '${product['interest_rate'] ?? 12}% p.a.'),
                      _productDetail('Min',
                          _currencyFmt.format(product['min_amount'] ?? 1000)),
                      _productDetail('Max',
                          _currencyFmt.format(product['max_amount'] ?? 500000)),
                      _productDetail('Tenure',
                          '${product['min_tenure_months'] ?? 1}-${product['max_tenure_months'] ?? 36} months'),
                    ],
                  ),
                  if (product['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text(product['description'],
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _productDetail(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStep2AmountTenure() {
    final emi = _calculateEMI();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Loan Amount & Tenure',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),

        // Amount
        Text('Loan Amount', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Center(
          child: Text(_currencyFmt.format(_requestedAmount),
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0))),
        ),
        Slider(
          value: _requestedAmount,
          min: _minAmount,
          max: _maxAmount,
          divisions: ((_maxAmount - _minAmount) / 1000).round().clamp(1, 500),
          label: _currencyFmt.format(_requestedAmount),
          activeColor: const Color(0xFF1565C0),
          onChanged: (v) =>
              setState(() => _requestedAmount = (v / 1000).round() * 1000),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_currencyFmt.format(_minAmount),
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            Text(_currencyFmt.format(_maxAmount),
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),

        const SizedBox(height: 24),

        // Tenure
        Text('Repayment Period', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Center(
          child: Text('$_tenureMonths months',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0))),
        ),
        Slider(
          value: _tenureMonths.toDouble(),
          min: _minTenure.toDouble(),
          max: _maxTenure.toDouble(),
          divisions: (_maxTenure - _minTenure).clamp(1, 100),
          label: '$_tenureMonths months',
          activeColor: const Color(0xFF1565C0),
          onChanged: (v) => setState(() => _tenureMonths = v.round()),
        ),

        const SizedBox(height: 24),

        // EMI Summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBDEFB)),
          ),
          child: Column(
            children: [
              const Text('Estimated Monthly Payment',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(_currencyFmtDecimal.format(emi),
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('Principal', _currencyFmt.format(_requestedAmount)),
                  _summaryItem('Interest', _currencyFmt.format(_totalInterest)),
                  _summaryItem('Total', _currencyFmt.format(_totalPayable)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStep3PurposeGuarantor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Loan Purpose & Guarantor',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),

        Text('Purpose of Loan', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPurpose,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: _purposeOptions
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) => setState(() => _selectedPurpose = v ?? 'Business'),
        ),

        if (_selectedPurpose == 'Other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: _purposeController,
            decoration: InputDecoration(
              labelText: 'Specify purpose',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            maxLength: 200,
          ),
        ],

        const SizedBox(height: 24),
        const Text('Guarantor Information',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        TextField(
          controller: _guarantorNameController,
          decoration: InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: const Icon(Icons.person_outline),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _guarantorPhoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            prefixIcon: const Icon(Icons.phone_outlined),
            hintText: '254XXXXXXXXX',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _guarantorIdController,
          decoration: InputDecoration(
            labelText: 'National ID Number',
            prefixIcon: const Icon(Icons.badge_outlined),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildStep4Review() {
    final emi = _calculateEMI();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Your Application',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Please verify all details before submitting',
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 16),

        _reviewSection('Loan Product', [
          _reviewRow('Product', _selectedProduct?['name'] ?? 'N/A'),
          _reviewRow('Interest Rate', '${_interestRate}% per annum'),
        ]),
        _reviewSection('Loan Details', [
          _reviewRow('Amount', _currencyFmt.format(_requestedAmount)),
          _reviewRow('Tenure', '$_tenureMonths months'),
          _reviewRow('Monthly EMI', _currencyFmtDecimal.format(emi)),
          _reviewRow('Total Interest', _currencyFmtDecimal.format(_totalInterest)),
          _reviewRow('Total Payable', _currencyFmtDecimal.format(_totalPayable)),
        ]),
        _reviewSection('Purpose', [
          _reviewRow(
              'Loan Purpose',
              _selectedPurpose == 'Other'
                  ? _purposeController.text.trim()
                  : _selectedPurpose),
        ]),
        _reviewSection('Guarantor', [
          _reviewRow('Name', _guarantorNameController.text.trim()),
          _reviewRow('Phone', _guarantorPhoneController.text.trim()),
          if (_guarantorIdController.text.trim().isNotEmpty)
            _reviewRow('National ID', _guarantorIdController.text.trim()),
        ]),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'By submitting, you confirm the information is accurate and agree to the loan terms.',
                  style:
                      TextStyle(fontSize: 12, color: Colors.amber[900]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewSection(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed && !_isSubmitting
                  ? () {
                      if (_currentStep < 3) {
                        setState(() => _currentStep++);
                      } else {
                        _submit();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      _currentStep < 3 ? 'Continue' : 'Submit Application',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
