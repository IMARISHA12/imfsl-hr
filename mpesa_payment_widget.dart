import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// MpesaPaymentWidget - M-Pesa STK push payment flow with status tracker
/// for the IMFSL customer mobile app.
///
/// Supports loan repayment and savings deposit via M-Pesa. Includes form
/// validation, payment initiation, timer-based polling for STK push status,
/// and success/failure states with proper lifecycle management.
class MpesaPaymentWidget extends StatefulWidget {
  final List<Map<String, dynamic>> loans;
  final List<Map<String, dynamic>> savingsAccounts;
  final String defaultPhoneNumber;
  final Future<Map<String, dynamic>> Function(
      Map<String, dynamic> paymentData)? onInitiatePayment;
  final Future<Map<String, dynamic>> Function(String transactionId)?
      onCheckPaymentStatus;
  /// Called to fetch full payment receipt (reconciliation status, receipt number).
  /// Uses the `payment_receipt` gateway action for real-time callback status.
  final Future<Map<String, dynamic>> Function(String transactionId)?
      onGetPaymentReceipt;
  final Function(Map<String, dynamic> result)? onSuccess;
  final VoidCallback? onCancel;

  /// Pre-selects a loan for repayment (loan ID from active_loans).
  /// When set, auto-selects "Loan Repayment" type and the matching loan.
  final String? preSelectedLoanId;

  /// Pre-fills the amount field (e.g. next due amount from payment center).
  final double? preFilledAmount;

  const MpesaPaymentWidget({
    super.key,
    this.loans = const [],
    this.savingsAccounts = const [],
    this.defaultPhoneNumber = '',
    this.onInitiatePayment,
    this.onCheckPaymentStatus,
    this.onGetPaymentReceipt,
    this.onSuccess,
    this.onCancel,
    this.preSelectedLoanId,
    this.preFilledAmount,
  });

  @override
  State<MpesaPaymentWidget> createState() => _MpesaPaymentWidgetState();
}

enum _PaymentType { loanRepayment, savingsDeposit }

enum _PaymentPhase { form, processing, success, failed, timedOut }

class _MpesaPaymentWidgetState extends State<MpesaPaymentWidget>
    with SingleTickerProviderStateMixin {
  static const Color _primaryColor = Color(0xFF1565C0);
  static const Color _mpesaGreen = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF388E3C);

  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  // Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  _PaymentType _selectedType = _PaymentType.loanRepayment;
  Map<String, dynamic>? _selectedLoan;
  Map<String, dynamic>? _selectedSavingsAccount;
  late TextEditingController _amountController;
  late TextEditingController _phoneController;

  // Payment processing
  _PaymentPhase _phase = _PaymentPhase.form;
  bool _isInitiating = false;
  String _transactionId = '';
  int _pollCount = 0;
  static const int _maxPolls = 20; // 20 * 3s = 60s timeout
  Timer? _pollTimer;
  String _errorMessage = '';
  String _statusMessage = 'Initiating payment...';
  Map<String, dynamic> _successResult = {};

  // Success animation
  late AnimationController _successAnimController;
  late Animation<double> _successScaleAnimation;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _phoneController = TextEditingController(text: widget.defaultPhoneNumber);

    _successAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScaleAnimation = CurvedAnimation(
      parent: _successAnimController,
      curve: Curves.elasticOut,
    );

    // Pre-fill from payment center quick-pay
    if (widget.preSelectedLoanId != null && widget.loans.isNotEmpty) {
      _selectedType = _PaymentType.loanRepayment;
      for (final loan in widget.loans) {
        final loanId = loan['id']?.toString() ?? '';
        if (loanId == widget.preSelectedLoanId) {
          _selectedLoan = loan;
          break;
        }
      }
    }
    if (widget.preFilledAmount != null && widget.preFilledAmount! > 0) {
      _amountController.text = widget.preFilledAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _amountController.dispose();
    _phoneController.dispose();
    _successAnimController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatCurrency(dynamic value) {
    if (value == null) return _currencyFormat.format(0);
    final num parsed =
        value is num ? value : num.tryParse(value.toString()) ?? 0;
    return _currencyFormat.format(parsed);
  }

  String _amountInWords(double amount) {
    if (amount <= 0) return '';
    final wholePart = amount.truncate();
    final centsPart = ((amount - wholePart) * 100).round();

    final words = _numberToWords(wholePart);
    if (centsPart > 0) {
      return 'Kenya Shillings $words and ${_numberToWords(centsPart)} cents';
    }
    return 'Kenya Shillings $words';
  }

  String _numberToWords(int number) {
    if (number == 0) return 'zero';

    const ones = [
      '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
      'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
      'sixteen', 'seventeen', 'eighteen', 'nineteen'
    ];
    const tens = [
      '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy',
      'eighty', 'ninety'
    ];

    String convert(int n) {
      if (n < 20) return ones[n];
      if (n < 100) {
        return '${tens[n ~/ 10]}${n % 10 > 0 ? '-${ones[n % 10]}' : ''}';
      }
      if (n < 1000) {
        return '${ones[n ~/ 100]} hundred${n % 100 > 0 ? ' and ${convert(n % 100)}' : ''}';
      }
      if (n < 1000000) {
        return '${convert(n ~/ 1000)} thousand${n % 1000 > 0 ? ' ${convert(n % 1000)}' : ''}';
      }
      return '${convert(n ~/ 1000000)} million${n % 1000000 > 0 ? ' ${convert(n % 1000000)}' : ''}';
    }

    return convert(number);
  }

  bool get _isFormValid {
    if (_selectedType == _PaymentType.loanRepayment &&
        _selectedLoan == null) {
      return false;
    }
    if (_selectedType == _PaymentType.savingsDeposit &&
        _selectedSavingsAccount == null) {
      return false;
    }
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount < 1 || amount > 150000) return false;

    final phone = _phoneController.text.replaceAll(RegExp(r'[\s\-]'), '');
    if (!phone.startsWith('254') || phone.length != 12) return false;

    return true;
  }

  // ---------------------------------------------------------------------------
  // Payment Actions
  // ---------------------------------------------------------------------------

  Future<void> _initiatePayment() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isInitiating = true);

    final paymentData = <String, dynamic>{
      'payment_type': _selectedType == _PaymentType.loanRepayment
          ? 'LOAN_REPAYMENT'
          : 'SAVINGS_DEPOSIT',
      'amount': double.tryParse(_amountController.text) ?? 0,
      'phone_number': _phoneController.text.replaceAll(RegExp(r'[\s\-]'), ''),
    };

    if (_selectedType == _PaymentType.loanRepayment &&
        _selectedLoan != null) {
      paymentData['loan_id'] = _selectedLoan!['id'];
    }
    if (_selectedType == _PaymentType.savingsDeposit &&
        _selectedSavingsAccount != null) {
      paymentData['savings_account_id'] = _selectedSavingsAccount!['id'];
    }

    try {
      Map<String, dynamic> response;
      if (widget.onInitiatePayment != null) {
        response = await widget.onInitiatePayment!(paymentData);
      } else {
        // Simulate for preview
        response = {
          'transaction_id': 'TXN${Random().nextInt(999999)}',
          'status': 'PENDING',
        };
      }

      if (!mounted) return;

      final txnId = response['transaction_id']?.toString() ?? '';
      if (txnId.isEmpty) {
        throw Exception('No transaction ID returned');
      }

      setState(() {
        _transactionId = txnId;
        _phase = _PaymentPhase.processing;
        _isInitiating = false;
        _pollCount = 0;
      });

      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitiating = false;
        _errorMessage = e.toString();
        _phase = _PaymentPhase.failed;
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollCount = 0;
    if (mounted) {
      setState(() => _statusMessage = 'Waiting for M-Pesa confirmation...');
    }

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _pollCount++;

      if (_pollCount > _maxPolls) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          _phase = _PaymentPhase.timedOut;
        });
        return;
      }

      // Update status message based on poll count
      if (mounted && _pollCount <= 3) {
        setState(() => _statusMessage = 'Waiting for M-Pesa confirmation...');
      } else if (mounted && _pollCount <= 8) {
        setState(() => _statusMessage = 'Processing payment...');
      } else if (mounted) {
        setState(() => _statusMessage = 'Still waiting... Please check your phone.');
      }

      try {
        Map<String, dynamic> statusResponse;

        // Prefer onGetPaymentReceipt (uses callback-aware payment_receipt action)
        if (widget.onGetPaymentReceipt != null) {
          statusResponse =
              await widget.onGetPaymentReceipt!(_transactionId);
        } else if (widget.onCheckPaymentStatus != null) {
          statusResponse =
              await widget.onCheckPaymentStatus!(_transactionId);
        } else {
          // Simulate - succeed after 3 polls
          if (_pollCount >= 3) {
            statusResponse = {
              'status': 'COMPLETED',
              'amount': _amountController.text,
              'mpesa_receipt_number': 'SIM${DateTime.now().millisecondsSinceEpoch}',
              'applied_to_type': 'LOAN_REPAYMENT',
            };
          } else {
            statusResponse = {'status': 'INITIATED'};
          }
        }

        if (!mounted) return;

        final status =
            statusResponse['status']?.toString().toUpperCase() ?? '';

        if (status == 'COMPLETED' || status == 'SUCCESS') {
          timer.cancel();
          _successResult = statusResponse;
          setState(() {
            _phase = _PaymentPhase.success;
          });
          _successAnimController.forward();
        } else if (status == 'FAILED') {
          timer.cancel();
          setState(() {
            _errorMessage = statusResponse['result_desc']?.toString() ??
                statusResponse['message']?.toString() ??
                'Payment failed. Please try again.';
            _phase = _PaymentPhase.failed;
          });
        } else if (status == 'EXPIRED' || status == 'CANCELLED') {
          timer.cancel();
          setState(() {
            _errorMessage = status == 'EXPIRED'
                ? 'Payment request expired. Please try again.'
                : 'Payment was cancelled.';
            _phase = _PaymentPhase.failed;
          });
        }
        // INITIATED / PROCESSING — keep polling
      } catch (e) {
        // Network error during poll — don't stop, try again next tick
        debugPrint('Poll error: $e');
      }
    });
  }

  void _cancelPayment() {
    _pollTimer?.cancel();
    widget.onCancel?.call();
    if (!mounted) return;
    setState(() {
      _phase = _PaymentPhase.form;
      _transactionId = '';
      _pollCount = 0;
      _errorMessage = '';
    });
  }

  void _resetToForm() {
    _pollTimer?.cancel();
    _successAnimController.reset();
    if (!mounted) return;
    setState(() {
      _phase = _PaymentPhase.form;
      _transactionId = '';
      _pollCount = 0;
      _errorMessage = '';
      _amountController.clear();
    });
  }

  void _handleSuccess() {
    widget.onSuccess?.call(_successResult);
  }

  // ---------------------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------------------

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Enter an amount';
    final amount = double.tryParse(value);
    if (amount == null) return 'Enter a valid number';
    if (amount < 1) return 'Minimum amount is KES 1';
    if (amount > 150000) return 'Maximum amount is KES 150,000';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!cleaned.startsWith('254')) return 'Must start with 254';
    if (cleaned.length != 12) return 'Must be 12 digits (254XXXXXXXXX)';
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) return 'Digits only';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'M-Pesa Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _phase == _PaymentPhase.form
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => widget.onCancel?.call(),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _phase == _PaymentPhase.form
            ? _buildPaymentForm()
            : _buildStatusTracker(),
      ),
    );
  }

  // ===========================================================================
  // PAYMENT FORM
  // ===========================================================================

  Widget _buildPaymentForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        key: const ValueKey('payment_form'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPaymentTypeSelector(),
            const SizedBox(height: 20),
            _buildTargetAccountSelector(),
            const SizedBox(height: 20),
            _buildAmountField(),
            const SizedBox(height: 20),
            _buildPhoneNumberField(),
            const SizedBox(height: 20),
            _buildPaymentSummary(),
            const SizedBox(height: 24),
            _buildPayButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Payment Type Selector
  // ---------------------------------------------------------------------------

  Widget _buildPaymentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                type: _PaymentType.loanRepayment,
                icon: Icons.account_balance,
                label: 'Loan Repayment',
                activeColor: _primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                type: _PaymentType.savingsDeposit,
                icon: Icons.savings,
                label: 'Savings Deposit',
                activeColor: _mpesaGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required _PaymentType type,
    required IconData icon,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedLoan = null;
          _selectedSavingsAccount = null;
          _amountController.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected ? activeColor : Colors.grey.shade500,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Target Account Selector
  // ---------------------------------------------------------------------------

  Widget _buildTargetAccountSelector() {
    if (_selectedType == _PaymentType.loanRepayment) {
      return _buildLoanSelector();
    } else {
      return _buildSavingsSelector();
    }
  }

  Widget _buildLoanSelector() {
    if (widget.loans.isEmpty) {
      return _buildEmptyAccountMessage(
        'No active loans found',
        Icons.account_balance,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Loan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Map<String, dynamic>>(
          value: _selectedLoan,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            prefixIcon:
                const Icon(Icons.account_balance, color: _primaryColor),
          ),
          hint: const Text('Choose a loan to repay'),
          items: widget.loans.map((loan) {
            final loanNumber = loan['loan_number']?.toString() ?? '';
            final outstanding = _formatCurrency(loan['outstanding_balance']);
            return DropdownMenuItem<Map<String, dynamic>>(
              value: loan,
              child: Text(
                '$loanNumber  -  Outstanding: $outstanding',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLoan = value;
              _amountController.clear();
            });
          },
          validator: (value) {
            if (_selectedType == _PaymentType.loanRepayment &&
                value == null) {
              return 'Please select a loan';
            }
            return null;
          },
        ),
        if (_selectedLoan != null) ...[
          const SizedBox(height: 12),
          _buildSelectedLoanDetails(),
        ],
      ],
    );
  }

  Widget _buildSelectedLoanDetails() {
    final loan = _selectedLoan!;
    final outstanding = _formatCurrency(loan['outstanding_balance']);
    final installment = _formatCurrency(loan['monthly_installment']);
    final status = loan['status']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          _buildDetailRow('Outstanding Balance', outstanding,
              valueColor: Colors.red.shade700, bold: true),
          const Divider(height: 16),
          _buildDetailRow('Monthly Installment', installment),
          const Divider(height: 16),
          _buildDetailRow('Loan Status', status,
              valueColor:
                  status.toUpperCase() == 'ACTIVE' ? _mpesaGreen : Colors.orange),
        ],
      ),
    );
  }

  Widget _buildSavingsSelector() {
    if (widget.savingsAccounts.isEmpty) {
      return _buildEmptyAccountMessage(
        'No savings accounts found',
        Icons.savings,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Savings Account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Map<String, dynamic>>(
          value: _selectedSavingsAccount,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            prefixIcon: const Icon(Icons.savings, color: _mpesaGreen),
          ),
          hint: const Text('Choose a savings account'),
          items: widget.savingsAccounts.map((acc) {
            final accNumber = acc['account_number']?.toString() ?? '';
            final product = acc['product_name']?.toString() ?? '';
            return DropdownMenuItem<Map<String, dynamic>>(
              value: acc,
              child: Text(
                '$accNumber  -  $product',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSavingsAccount = value;
              _amountController.clear();
            });
          },
          validator: (value) {
            if (_selectedType == _PaymentType.savingsDeposit &&
                value == null) {
              return 'Please select a savings account';
            }
            return null;
          },
        ),
        if (_selectedSavingsAccount != null) ...[
          const SizedBox(height: 12),
          _buildSelectedSavingsDetails(),
        ],
      ],
    );
  }

  Widget _buildSelectedSavingsDetails() {
    final acc = _selectedSavingsAccount!;
    final balance = _formatCurrency(acc['current_balance']);
    final product = acc['product_name']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _mpesaGreen.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _mpesaGreen.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          _buildDetailRow('Current Balance', balance,
              valueColor: _darkGreen, bold: true),
          const Divider(height: 16),
          _buildDetailRow('Product', product),
        ],
      ),
    );
  }

  Widget _buildEmptyAccountMessage(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Amount Field
  // ---------------------------------------------------------------------------

  Widget _buildAmountField() {
    final amount = double.tryParse(_amountController.text) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          validator: _validateAmount,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixText: 'KES  ',
            prefixStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 16,
            ),
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Quick-fill chips for loan repayment
        if (_selectedType == _PaymentType.loanRepayment &&
            _selectedLoan != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildQuickFillChip(
                label: 'Pay Full Installment',
                amount: _selectedLoan!['monthly_installment'],
                color: _primaryColor,
              ),
              _buildQuickFillChip(
                label: 'Pay Outstanding Balance',
                amount: _selectedLoan!['outstanding_balance'],
                color: Colors.red.shade700,
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        // Amount in words
        if (amount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _amountInWords(amount),
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickFillChip({
    required String label,
    required dynamic amount,
    required Color color,
  }) {
    final numAmount = amount is num ? amount : num.tryParse(amount?.toString() ?? '') ?? 0;
    if (numAmount <= 0) return const SizedBox.shrink();

    return ActionChip(
      avatar: Icon(Icons.flash_on, size: 16, color: color),
      label: Text(
        '$label (${_formatCurrency(numAmount)})',
        style: TextStyle(fontSize: 12, color: color),
      ),
      backgroundColor: color.withValues(alpha: 0.08),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      onPressed: () {
        _amountController.text = numAmount.toStringAsFixed(0);
        setState(() {});
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Phone Number Field
  // ---------------------------------------------------------------------------

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'M-Pesa Phone Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kenyan flag representation
                  Container(
                    width: 28,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(2),
                                topRight: Radius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(color: Colors.red.shade700),
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(2),
                                bottomRight: Radius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '+',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            hintText: '254XXXXXXXXX',
            helperText: 'Enter M-Pesa registered number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          style: const TextStyle(fontSize: 16, letterSpacing: 1),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Payment Summary
  // ---------------------------------------------------------------------------

  Widget _buildPaymentSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return const SizedBox.shrink();

    final phone = _phoneController.text.replaceAll(RegExp(r'[\s\-]'), '');
    final isLoan = _selectedType == _PaymentType.loanRepayment;
    String targetAccount = '';

    if (isLoan && _selectedLoan != null) {
      targetAccount = _selectedLoan!['loan_number']?.toString() ?? '';
    } else if (!isLoan && _selectedSavingsAccount != null) {
      targetAccount =
          _selectedSavingsAccount!['account_number']?.toString() ?? '';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, size: 20, color: _primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildSummaryRow(
              'Payment Type',
              isLoan ? 'Loan Repayment' : 'Savings Deposit',
            ),
            const SizedBox(height: 8),
            if (targetAccount.isNotEmpty) ...[
              _buildSummaryRow('Target Account', targetAccount),
              const SizedBox(height: 8),
            ],
            if (phone.isNotEmpty) ...[
              _buildSummaryRow('Phone Number', '+$phone'),
              const SizedBox(height: 8),
            ],
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _formatCurrency(amount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 18, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You will receive an M-Pesa prompt on your phone',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Pay Button
  // ---------------------------------------------------------------------------

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: (_isFormValid && !_isInitiating) ? _initiatePayment : null,
        icon: _isInitiating
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.phone_android, size: 22),
        label: Text(
          _isInitiating ? 'Initiating...' : 'Pay via M-Pesa',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _mpesaGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // ===========================================================================
  // STATUS TRACKER
  // ===========================================================================

  Widget _buildStatusTracker() {
    return SingleChildScrollView(
      key: const ValueKey('status_tracker'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildAmountDisplay(),
          const SizedBox(height: 32),
          _buildStepper(),
          const SizedBox(height: 32),
          _buildStatusActions(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    final amount = double.tryParse(_amountController.text) ?? 0;

    return Column(
      children: [
        Text(
          _formatCurrency(amount),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _selectedType == _PaymentType.loanRepayment
              ? 'Loan Repayment'
              : 'Savings Deposit',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Transaction: $_transactionId',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Column(
      children: [
        _buildStepItem(
          stepNumber: 1,
          title: 'Payment Initiated',
          subtitle: 'Request sent to M-Pesa',
          status: _StepStatus.completed,
        ),
        _buildStepConnector(
          isCompleted: _phase == _PaymentPhase.success,
          isActive: _phase == _PaymentPhase.processing,
        ),
        _buildStepItem(
          stepNumber: 2,
          title: _phase == _PaymentPhase.processing
              ? 'Waiting for M-Pesa confirmation'
              : _phase == _PaymentPhase.success
                  ? 'M-Pesa Confirmed'
                  : _phase == _PaymentPhase.timedOut
                      ? 'Confirmation Timed Out'
                      : 'M-Pesa Confirmation',
          subtitle: _phase == _PaymentPhase.processing
              ? _statusMessage
              : _phase == _PaymentPhase.success
                  ? 'Payment confirmed by M-Pesa'
                  : _phase == _PaymentPhase.timedOut
                      ? 'No response received within 60 seconds'
                      : 'Confirmation failed',
          status: _phase == _PaymentPhase.processing
              ? _StepStatus.inProgress
              : _phase == _PaymentPhase.success
                  ? _StepStatus.completed
                  : (_phase == _PaymentPhase.failed ||
                          _phase == _PaymentPhase.timedOut)
                      ? _StepStatus.failed
                      : _StepStatus.pending,
        ),
        _buildStepConnector(
          isCompleted: _phase == _PaymentPhase.success,
          isActive: false,
        ),
        _buildStepItem(
          stepNumber: 3,
          title: _phase == _PaymentPhase.success
              ? 'Payment Successful'
              : _phase == _PaymentPhase.failed
                  ? 'Payment Failed'
                  : _phase == _PaymentPhase.timedOut
                      ? 'Status Unknown'
                      : 'Payment Complete',
          subtitle: _phase == _PaymentPhase.success
              ? 'Your payment has been processed'
              : _phase == _PaymentPhase.failed
                  ? _errorMessage
                  : _phase == _PaymentPhase.timedOut
                      ? 'Check your M-Pesa messages for confirmation'
                      : 'Waiting for confirmation',
          status: _phase == _PaymentPhase.success
              ? _StepStatus.completed
              : (_phase == _PaymentPhase.failed ||
                      _phase == _PaymentPhase.timedOut)
                  ? _StepStatus.failed
                  : _StepStatus.pending,
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required String subtitle,
    required _StepStatus status,
  }) {
    Color circleColor;
    Widget circleChild;

    switch (status) {
      case _StepStatus.completed:
        circleColor = _mpesaGreen;
        circleChild = const Icon(Icons.check, size: 20, color: Colors.white);
        break;
      case _StepStatus.inProgress:
        circleColor = _primaryColor;
        circleChild = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        );
        break;
      case _StepStatus.failed:
        circleColor = Colors.red;
        circleChild = const Icon(Icons.close, size: 20, color: Colors.white);
        break;
      case _StepStatus.pending:
        circleColor = Colors.grey.shade300;
        circleChild = Text(
          '$stepNumber',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            boxShadow: status == _StepStatus.inProgress
                ? [
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(child: circleChild),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: status == _StepStatus.pending
                      ? Colors.grey.shade500
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              if (status == _StepStatus.inProgress)
                _buildAnimatedDots(subtitle)
              else
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: status == _StepStatus.failed
                        ? Colors.red.shade700
                        : Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedDots(String text) {
    return _AnimatedDotsText(text: text);
  }

  Widget _buildStepConnector({
    required bool isCompleted,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 32,
            color: isCompleted
                ? _mpesaGreen
                : isActive
                    ? _primaryColor.withValues(alpha: 0.4)
                    : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Status Actions
  // ---------------------------------------------------------------------------

  Widget _buildStatusActions() {
    switch (_phase) {
      case _PaymentPhase.success:
        return _buildSuccessActions();
      case _PaymentPhase.failed:
        return _buildFailedActions();
      case _PaymentPhase.timedOut:
        return _buildTimedOutActions();
      case _PaymentPhase.processing:
        return _buildProcessingActions();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSuccessActions() {
    return Column(
      children: [
        ScaleTransition(
          scale: _successScaleAnimation,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _mpesaGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 64,
              color: _mpesaGreen,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Payment Successful!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _mpesaGreen,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your ${_selectedType == _PaymentType.loanRepayment ? 'loan repayment' : 'savings deposit'} has been processed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        if (_successResult['mpesa_receipt_number'] != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Receipt', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    Text(
                      _successResult['mpesa_receipt_number'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                if (_successResult['amount'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      Text(
                        _formatCurrency(double.tryParse(_successResult['amount'].toString()) ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
                if (_successResult['applied_to_type'] != null &&
                    _successResult['applied_to_type'] != 'NONE') ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Applied To', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      Text(
                        _successResult['applied_to_type'] == 'LOAN_REPAYMENT'
                            ? 'Loan Repayment'
                            : _successResult['applied_to_type'] == 'SAVINGS_DEPOSIT'
                                ? 'Savings Deposit'
                                : _successResult['applied_to_type'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _mpesaGreen),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _handleSuccess,
            icon: const Icon(Icons.done_all),
            label: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _mpesaGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailedActions() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cancel,
            size: 64,
            color: Colors.red.shade400,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Payment Failed',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage.isNotEmpty
              ? _errorMessage
              : 'The payment could not be processed. Please try again.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _resetToForm,
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Try Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimedOutActions() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.timer_off,
            size: 56,
            color: Colors.amber.shade700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Payment Timed Out',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We did not receive a confirmation within 60 seconds.\nCheck your M-Pesa messages for payment status.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _resetToForm,
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Try Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingActions() {
    return Column(
      children: [
        // Poll count indicator
        Text(
          'Checking status... ($_pollCount/$_maxPolls)',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _pollCount / _maxPolls,
            backgroundColor: Colors.grey.shade200,
            valueColor:
                const AlwaysStoppedAnimation<Color>(_primaryColor),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: _cancelPayment,
          icon: const Icon(Icons.close, color: Colors.red),
          label: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// STEP STATUS ENUM
// =============================================================================

enum _StepStatus { pending, inProgress, completed, failed }

// =============================================================================
// ANIMATED DOTS TEXT WIDGET
// =============================================================================

/// A small stateful widget that appends animated dots to a text string to
/// convey an in-progress operation.
class _AnimatedDotsText extends StatefulWidget {
  final String text;

  const _AnimatedDotsText({required this.text});

  @override
  State<_AnimatedDotsText> createState() => _AnimatedDotsTextState();
}

class _AnimatedDotsTextState extends State<_AnimatedDotsText> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Text(
      '${widget.text}$dots',
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade600,
      ),
    );
  }
}
