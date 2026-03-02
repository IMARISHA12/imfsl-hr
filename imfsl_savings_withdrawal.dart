import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL Savings Withdrawal Widget.
///
/// Provides a withdrawal request form with account selector, amount input,
/// channel selection (M-Pesa / Bank / Cash), and destination phone field.
/// A confirmation bottom sheet is shown before submitting. Below the form,
/// a scrollable history list displays past withdrawal requests with status
/// badges, channel badges, and expandable rejection reasons.
class ImfslSavingsWithdrawal extends StatefulWidget {
  /// Active savings accounts. Each map: id, account_number, available_balance, status.
  final List<Map<String, dynamic>> savingsAccounts;

  /// Withdrawal records. Each map: withdrawal_number, amount, channel, status,
  /// destination, rejection_reason, created_at, account_number.
  final List<Map<String, dynamic>> withdrawals;

  /// Whether data is currently loading.
  final bool isLoading;

  /// Called when the user confirms a withdrawal request.
  final Function(
    String accountId,
    double amount,
    String channel,
    String? phone,
  )? onRequestWithdrawal;

  /// Called when the user pulls to refresh.
  final VoidCallback? onRefresh;

  /// Called when the user scrolls near the bottom of the history list.
  final VoidCallback? onLoadMore;

  /// Pre-filled phone number for M-Pesa withdrawals.
  final String profilePhone;

  const ImfslSavingsWithdrawal({
    super.key,
    this.savingsAccounts = const [],
    this.withdrawals = const [],
    this.isLoading = false,
    this.onRequestWithdrawal,
    this.onRefresh,
    this.onLoadMore,
    this.profilePhone = '',
  });

  @override
  State<ImfslSavingsWithdrawal> createState() =>
      _ImfslSavingsWithdrawalState();
}

class _ImfslSavingsWithdrawalState extends State<ImfslSavingsWithdrawal> {
  static const Color _primary = Color(0xFF1565C0);
  static const Color _success = Color(0xFF2E7D32);
  static const Color _warning = Color(0xFFEF6C00);
  static const Color _error = Color(0xFFC62828);

  final NumberFormat _kes =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dateTimeFmt = DateFormat('dd MMM yyyy HH:mm');

  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedAccountId;
  String _selectedChannel = 'M-Pesa';
  final Set<int> _expandedRejections = {};

  static const List<String> _channels = ['M-Pesa', 'Bank', 'Cash'];

  // ---------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.profilePhone;
    _initSelectedAccount();
  }

  @override
  void didUpdateWidget(covariant ImfslSavingsWithdrawal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.savingsAccounts != widget.savingsAccounts) {
      _initSelectedAccount();
    }
    if (oldWidget.profilePhone != widget.profilePhone &&
        _phoneCtrl.text.isEmpty) {
      _phoneCtrl.text = widget.profilePhone;
    }
  }

  void _initSelectedAccount() {
    final active = _activeAccounts;
    if (active.isEmpty) {
      _selectedAccountId = null;
      return;
    }
    if (_selectedAccountId == null ||
        !active.any((a) => a['id']?.toString() == _selectedAccountId)) {
      _selectedAccountId = active.first['id']?.toString();
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Computed helpers
  // ---------------------------------------------------------------

  List<Map<String, dynamic>> get _activeAccounts =>
      widget.savingsAccounts
          .where((a) =>
              (a['status']?.toString().toUpperCase() ?? '') == 'ACTIVE')
          .toList();

  Map<String, dynamic>? get _selectedAccount {
    if (_selectedAccountId == null) return null;
    try {
      return widget.savingsAccounts
          .firstWhere((a) => a['id']?.toString() == _selectedAccountId);
    } catch (_) {
      return null;
    }
  }

  double get _availableBalance {
    final bal = _selectedAccount?['available_balance'];
    if (bal is num) return bal.toDouble();
    if (bal is String) return double.tryParse(bal) ?? 0.0;
    return 0.0;
  }

  double _parseAmount(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  // ---------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final amount = _parseAmount(value);
    if (amount <= 0) return 'Amount must be greater than zero';
    if (amount > _availableBalance) return 'Amount exceeds available balance';
    return null;
  }

  String? _validatePhone(String? value) {
    if (_selectedChannel != 'M-Pesa') return null;
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required for M-Pesa';
    }
    if (value.replaceAll(RegExp(r'[^0-9+]'), '').length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // ---------------------------------------------------------------
  // Shared input decoration
  // ---------------------------------------------------------------

  InputDecoration _inputDeco({
    String? hint,
    String? prefix,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      prefixStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF424242),
      ),
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC62828)),
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
    );
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading &&
        widget.savingsAccounts.isEmpty &&
        widget.withdrawals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primary),
        ),
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: () async => widget.onRefresh?.call(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 150) {
            widget.onLoadMore?.call();
          }
          return false;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _buildRequestForm(),
            const SizedBox(height: 24),
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Request Form
  // ---------------------------------------------------------------

  Widget _buildRequestForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: _primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Request Withdrawal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _buildAccountSelector(),
              const SizedBox(height: 16),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildChannelSelector(),
              const SizedBox(height: 16),
              if (_selectedChannel == 'M-Pesa') ...[
                _buildPhoneField(),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _activeAccounts.isEmpty ? null : _handleSubmit,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: const Text(
                    'Request Withdrawal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Account Selector
  // ---------------------------------------------------------------

  Widget _buildAccountSelector() {
    final active = _activeAccounts;
    if (active.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _warning.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(Icons.info_outline, color: _warning, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'No active savings accounts available for withdrawal.',
              style: TextStyle(fontSize: 14, color: Color(0xFF5D4037)),
            ),
          ),
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Savings Account',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF616161),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedAccountId,
          decoration: _inputDeco(),
          isExpanded: true,
          items: active.map((account) {
            final accNum =
                account['account_number']?.toString() ?? 'N/A';
            final bal = account['available_balance'];
            final balNum = bal is num
                ? bal.toDouble()
                : double.tryParse(bal?.toString() ?? '') ?? 0.0;
            return DropdownMenuItem<String>(
              value: account['id']?.toString(),
              child: Row(children: [
                Expanded(
                  child: Text(
                    accNum,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _kes.format(balNum),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _success,
                  ),
                ),
              ]),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedAccountId = val);
          },
          validator: (v) => v == null ? 'Please select an account' : null,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Amount Field
  // ---------------------------------------------------------------

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF616161),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _amountCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDeco(hint: '0.00', prefix: 'KES '),
          validator: _validateAmount,
        ),
        const SizedBox(height: 6),
        if (_selectedAccount != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _success.withOpacity(0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(children: [
              Icon(Icons.account_balance, size: 16, color: _success),
              const SizedBox(width: 8),
              Text(
                'Available: ${_kes.format(_availableBalance)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _success,
                ),
              ),
            ]),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Channel Selector
  // ---------------------------------------------------------------

  Widget _buildChannelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Withdrawal Channel',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF616161),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _channels.map((ch) {
            final sel = _selectedChannel == ch;
            final icon = ch == 'M-Pesa'
                ? Icons.phone_android
                : ch == 'Bank'
                    ? Icons.account_balance
                    : Icons.payments_outlined;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(ch),
                selected: sel,
                onSelected: (v) {
                  if (v) setState(() => _selectedChannel = ch);
                },
                selectedColor: _primary.withOpacity(0.15),
                backgroundColor: const Color(0xFFF5F5F5),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel ? _primary : const Color(0xFF757575),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: sel ? _primary : const Color(0xFFE0E0E0),
                    width: sel ? 1.5 : 1.0,
                  ),
                ),
                avatar: Icon(icon,
                    size: 16,
                    color: sel ? _primary : const Color(0xFF9E9E9E)),
                showCheckmark: false,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Phone Field
  // ---------------------------------------------------------------

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'M-Pesa Phone Number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF616161),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: _inputDeco(
            hint: '0712345678',
            prefixIcon: const Icon(Icons.phone, size: 20),
          ),
          validator: _validatePhone,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Submit & Confirmation
  // ---------------------------------------------------------------

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = _parseAmount(_amountCtrl.text);
    final phone =
        _selectedChannel == 'M-Pesa' ? _phoneCtrl.text.trim() : null;
    _buildConfirmationSheet(amount, _selectedChannel, phone);
  }

  void _buildConfirmationSheet(
      double amount, String channel, String? phone) {
    final accNum =
        _selectedAccount?['account_number']?.toString() ?? 'N/A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet,
                  color: _primary, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Confirm Withdrawal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please review the details below',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            // Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(children: [
                _confirmRow('Account', accNum),
                const Divider(height: 20),
                _confirmRow('Amount', _kes.format(amount)),
                const Divider(height: 20),
                _confirmRow('Channel', channel),
                if (phone != null && phone.isNotEmpty) ...[
                  const Divider(height: 20),
                  _confirmRow('Destination', phone),
                ],
                const Divider(height: 20),
                _confirmRow(
                  'Balance After',
                  _kes.format(_availableBalance - amount),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF757575),
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _confirmWithdrawal(amount, channel, phone);
                  },
                  icon:
                      const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'Confirm',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _confirmRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmWithdrawal(double amount, String channel, String? phone) {
    if (_selectedAccountId == null) return;
    widget.onRequestWithdrawal?.call(
      _selectedAccountId!,
      amount,
      channel,
      phone,
    );
    _amountCtrl.clear();
    _phoneCtrl.text = widget.profilePhone;
    _formKey.currentState?.reset();
  }

  // ---------------------------------------------------------------
  // History Section
  // ---------------------------------------------------------------

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.history, color: _primary, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Withdrawal History',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          if (widget.withdrawals.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.withdrawals.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF616161),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        if (widget.withdrawals.isEmpty)
          _buildEmptyState()
        else
          ...widget.withdrawals.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildWithdrawalCard(entry.value, entry.key),
            );
          }),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: _primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Withdrawals Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your withdrawal requests will appear here.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Withdrawal Card
  // ---------------------------------------------------------------

  Widget _buildWithdrawalCard(Map<String, dynamic> withdrawal, int index) {
    final wdNum =
        withdrawal['withdrawal_number']?.toString() ?? 'N/A';
    final amt = withdrawal['amount'];
    final amtNum = amt is num
        ? amt.toDouble()
        : double.tryParse(amt?.toString() ?? '') ?? 0.0;
    final channel = withdrawal['channel']?.toString() ?? 'N/A';
    final status =
        withdrawal['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final dest = withdrawal['destination']?.toString() ?? '';
    final reason = withdrawal['rejection_reason']?.toString() ?? '';
    final createdAt = withdrawal['created_at']?.toString() ?? '';
    final accNum = withdrawal['account_number']?.toString() ?? '';
    final dt =
        createdAt.isNotEmpty ? DateTime.tryParse(createdAt) : null;
    final isRejected = status == 'REJECTED' && reason.isNotEmpty;
    final isExpanded = _expandedRejections.contains(index);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Withdrawal number + status
            Row(children: [
              Expanded(
                child: Text(
                  wdNum,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(status),
            ]),
            const SizedBox(height: 10),
            // Amount + channel
            Row(children: [
              Text(
                _kes.format(amtNum),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              _buildChannelBadge(channel),
            ]),
            const SizedBox(height: 10),
            // Detail rows
            if (dest.isNotEmpty)
              _detailRow(Icons.near_me, 'Destination', dest),
            if (accNum.isNotEmpty)
              _detailRow(
                  Icons.account_balance_outlined, 'Account', accNum),
            if (dt != null)
              _detailRow(
                  Icons.access_time, 'Requested', _dateTimeFmt.format(dt)),
            // Expandable rejection reason
            if (isRejected) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() {
                  if (isExpanded) {
                    _expandedRejections.remove(index);
                  } else {
                    _expandedRejections.add(index);
                  }
                }),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _error.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _error.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.error_outline,
                            size: 16, color: _error),
                        const SizedBox(width: 6),
                        const Text(
                          'Rejection Reason',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC62828),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: _error,
                        ),
                      ]),
                      if (isExpanded) ...[
                        const SizedBox(height: 6),
                        Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5D4037),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9E9E9E),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF616161),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }

  // ---------------------------------------------------------------
  // Status Badge
  // ---------------------------------------------------------------

  Widget _buildStatusBadge(String status) {
    final Color bg, fg;
    final IconData icon;
    switch (status) {
      case 'PENDING':
        bg = _warning.withOpacity(0.12);
        fg = _warning;
        icon = Icons.hourglass_empty;
        break;
      case 'APPROVED':
        bg = _primary.withOpacity(0.12);
        fg = _primary;
        icon = Icons.thumb_up_alt_outlined;
        break;
      case 'PROCESSING':
        bg = const Color(0xFF283593).withOpacity(0.12);
        fg = const Color(0xFF283593);
        icon = Icons.sync;
        break;
      case 'COMPLETED':
        bg = _success.withOpacity(0.12);
        fg = _success;
        icon = Icons.check_circle_outline;
        break;
      case 'FAILED':
        bg = _error.withOpacity(0.12);
        fg = _error;
        icon = Icons.cancel_outlined;
        break;
      case 'REJECTED':
        bg = _error.withOpacity(0.12);
        fg = _error;
        icon = Icons.block;
        break;
      default:
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF757575);
        icon = Icons.help_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: fg,
            letterSpacing: 0.3,
          ),
        ),
      ]),
    );
  }

  // ---------------------------------------------------------------
  // Channel Badge
  // ---------------------------------------------------------------

  Widget _buildChannelBadge(String channel) {
    final Color bg, fg;
    final IconData icon;
    switch (channel.toUpperCase()) {
      case 'M-PESA':
      case 'MPESA':
        bg = const Color(0xFF43A047).withOpacity(0.12);
        fg = const Color(0xFF43A047);
        icon = Icons.phone_android;
        break;
      case 'BANK':
        bg = _primary.withOpacity(0.12);
        fg = _primary;
        icon = Icons.account_balance;
        break;
      case 'CASH':
        bg = const Color(0xFF6D4C41).withOpacity(0.12);
        fg = const Color(0xFF6D4C41);
        icon = Icons.payments_outlined;
        break;
      default:
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF757575);
        icon = Icons.payment;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 4),
        Text(
          channel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: fg,
            letterSpacing: 0.3,
          ),
        ),
      ]),
    );
  }
}
