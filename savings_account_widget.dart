import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// SavingsAccountWidget -- Savings accounts list with detail view.
///
/// Displays a horizontal account selector, gradient balance card with privacy
/// toggle, stats row, product details, action buttons (Deposit via M-Pesa /
/// Withdraw), and a recent transactions list loaded via the detail callback.
class SavingsAccountWidget extends StatefulWidget {
  final List<Map<String, dynamic>> savingsAccounts;
  final Future<Map<String, dynamic>> Function(String accountId)?
      onLoadAccountDetail;
  final Function(Map<String, dynamic> account)? onDepositMpesa;
  final Function(Map<String, dynamic> account)? onWithdraw;

  const SavingsAccountWidget({
    super.key,
    this.savingsAccounts = const [],
    this.onLoadAccountDetail,
    this.onDepositMpesa,
    this.onWithdraw,
  });

  @override
  State<SavingsAccountWidget> createState() => _SavingsAccountWidgetState();
}

class _SavingsAccountWidgetState extends State<SavingsAccountWidget> {
  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _primaryTeal = Color(0xFF00695C);
  static const Color _primaryColor = Color(0xFF1565C0);

  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');

  int _selectedIndex = 0;
  bool _balanceVisible = true;
  bool _loadingDetail = false;
  String? _detailError;
  Map<String, dynamic> _detailData = {};
  bool _productExpanded = false;

  // ---------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    if (widget.savingsAccounts.isNotEmpty) {
      _loadAccountDetail();
    }
  }

  @override
  void didUpdateWidget(covariant SavingsAccountWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.savingsAccounts != widget.savingsAccounts) {
      if (_selectedIndex >= widget.savingsAccounts.length) {
        _selectedIndex = 0;
      }
      if (widget.savingsAccounts.isNotEmpty) {
        _loadAccountDetail();
      }
    }
  }

  // ---------------------------------------------------------------
  // Detail loading
  // ---------------------------------------------------------------

  Future<void> _loadAccountDetail() async {
    if (widget.onLoadAccountDetail == null) {
      setState(() {
        _loadingDetail = false;
        _detailData = {};
      });
      return;
    }
    final account = _currentAccount;
    if (account == null) return;
    final accountId = account['id']?.toString();
    if (accountId == null) return;

    setState(() {
      _loadingDetail = true;
      _detailError = null;
    });

    try {
      final result = await widget.onLoadAccountDetail!(accountId);
      if (!mounted) return;
      setState(() {
        _detailData = result;
        _loadingDetail = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _detailError = e.toString();
        _loadingDetail = false;
      });
    }
  }

  // ---------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------

  Map<String, dynamic>? get _currentAccount {
    if (widget.savingsAccounts.isEmpty) return null;
    if (_selectedIndex >= widget.savingsAccounts.length) return null;
    return widget.savingsAccounts[_selectedIndex];
  }

  Map<String, dynamic> get _savingsProduct =>
      (_detailData['savings_product'] as Map<String, dynamic>?) ?? {};

  List<Map<String, dynamic>> get _recentTransactions {
    final raw = _detailData['recent_transactions'];
    if (raw is List) {
      return raw.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
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

  String _maskedBalance(double amount) {
    if (_balanceVisible) {
      return _currencyFormat.format(amount);
    }
    return 'KES ****.**';
  }

  String _transactionTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'DEPOSIT':
        return 'Deposit';
      case 'WITHDRAWAL':
        return 'Withdrawal';
      case 'INTEREST':
        return 'Interest';
      case 'FEE':
        return 'Fee';
      case 'TRANSFER_IN':
        return 'Transfer In';
      case 'TRANSFER_OUT':
        return 'Transfer Out';
      default:
        return type;
    }
  }

  IconData _transactionIcon(String type) {
    switch (type.toUpperCase()) {
      case 'DEPOSIT':
      case 'TRANSFER_IN':
        return Icons.arrow_downward;
      case 'WITHDRAWAL':
      case 'TRANSFER_OUT':
        return Icons.arrow_upward;
      case 'INTEREST':
        return Icons.star;
      case 'FEE':
        return Icons.receipt;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _transactionColor(String type) {
    switch (type.toUpperCase()) {
      case 'DEPOSIT':
      case 'TRANSFER_IN':
        return Colors.green;
      case 'WITHDRAWAL':
      case 'TRANSFER_OUT':
      case 'FEE':
        return Colors.red;
      case 'INTEREST':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  bool _isCredit(String type) {
    switch (type.toUpperCase()) {
      case 'DEPOSIT':
      case 'TRANSFER_IN':
      case 'INTEREST':
        return true;
      default:
        return false;
    }
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (widget.savingsAccounts.isEmpty) {
      return _buildEmptyState();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account selector (only if multiple)
          if (widget.savingsAccounts.length > 1) ...[
            _buildAccountSelector(),
            const SizedBox(height: 4),
          ],

          // Gradient balance card
          _buildBalanceCard(),
          const SizedBox(height: 16),

          // Stats row
          _buildStatsRow(),
          const SizedBox(height: 16),

          // Product details expandable
          _buildProductDetailsSection(),
          const SizedBox(height: 16),

          // Action buttons
          _buildActionButtons(),
          const SizedBox(height: 20),

          // Recent transactions
          _buildRecentTransactionsSection(),
        ],
      ),
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
            Icon(Icons.savings_outlined,
                size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Savings Accounts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Open a savings account to start earning interest on your deposits.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Account selector
  // ---------------------------------------------------------------

  Widget _buildAccountSelector() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        itemCount: widget.savingsAccounts.length,
        itemBuilder: (context, index) {
          final account = widget.savingsAccounts[index];
          final product =
              account['imfsl_savings_products'] as Map<String, dynamic>? ?? {};
          final productName =
              product['product_name']?.toString() ?? 'Savings';
          final accountNumber =
              account['account_number']?.toString() ?? '--';
          final isSelected = index == _selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              selected: isSelected,
              onSelected: (_) {
                if (index != _selectedIndex) {
                  setState(() {
                    _selectedIndex = index;
                    _detailData = {};
                  });
                  _loadAccountDetail();
                }
              },
              selectedColor: _primaryGreen.withOpacity(0.15),
              backgroundColor: Colors.grey.shade100,
              side: BorderSide(
                color: isSelected
                    ? _primaryGreen
                    : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color:
                          isSelected ? _primaryGreen : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    accountNumber,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isSelected ? _primaryGreen : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------
  // Gradient balance card
  // ---------------------------------------------------------------

  Widget _buildBalanceCard() {
    final account = _currentAccount;
    if (account == null) return const SizedBox.shrink();

    final accountNumber = account['account_number']?.toString() ?? '--';
    final currentBalance = _toDouble(account['current_balance']);
    final availableBalance = _toDouble(account['available_balance']);
    final product =
        account['imfsl_savings_products'] as Map<String, dynamic>? ?? {};
    final interestRate = _toDouble(product['interest_rate_annual']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryGreen, _primaryTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _primaryGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account number + interest rate badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    accountNumber,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (interestRate > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${interestRate.toStringAsFixed(1)}% p.a.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // "Current Balance" label
              const Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),

              // Balance + privacy toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      _maskedBalance(currentBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _balanceVisible = !_balanceVisible);
                    },
                    icon: Icon(
                      _balanceVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                      size: 22,
                    ),
                    tooltip: _balanceVisible ? 'Hide balance' : 'Show balance',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Available balance
              Row(
                children: [
                  const Text(
                    'Available: ',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    _maskedBalance(availableBalance),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Stats row
  // ---------------------------------------------------------------

  Widget _buildStatsRow() {
    final account = _currentAccount;
    if (account == null) return const SizedBox.shrink();

    final totalDeposits = _toDouble(account['total_deposits']);
    final totalWithdrawals = _toDouble(account['total_withdrawals']);
    final interestEarned = _toDouble(account['total_interest_earned']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _MiniStatCard(
              label: 'Total Deposits',
              value: _currencyFormat.format(totalDeposits),
              icon: Icons.arrow_downward,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStatCard(
              label: 'Total Withdrawals',
              value: _currencyFormat.format(totalWithdrawals),
              icon: Icons.arrow_upward,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStatCard(
              label: 'Interest Earned',
              value: _currencyFormat.format(interestEarned),
              icon: Icons.star_outline,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Product details (expandable)
  // ---------------------------------------------------------------

  Widget _buildProductDetailsSection() {
    final account = _currentAccount;
    if (account == null) return const SizedBox.shrink();

    // Try detail-level product, fall back to embedded product
    final product = _savingsProduct.isNotEmpty
        ? _savingsProduct
        : (account['imfsl_savings_products'] as Map<String, dynamic>? ?? {});

    if (product.isEmpty) return const SizedBox.shrink();

    final productName = product['product_name']?.toString() ?? 'Savings Product';
    final interestRate = _toDouble(product['interest_rate_annual']);
    final minBalance = _toDouble(product['min_balance']);
    final minOpening = _toDouble(product['min_opening_balance']);
    final maxWithdrawalPerDay = _toDouble(product['max_withdrawal_per_day']);
    final withdrawalFee = _toDouble(product['withdrawal_fee']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: _productExpanded,
            onExpansionChanged: (expanded) {
              setState(() => _productExpanded = expanded);
            },
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            childrenPadding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Icon(Icons.info_outline,
                color: _primaryGreen, size: 22),
            title: Text(
              'Product Details',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
            subtitle: Text(
              productName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            children: [
              const Divider(),
              const SizedBox(height: 6),
              _productInfoRow('Interest Rate (p.a.)',
                  '${interestRate.toStringAsFixed(2)}%'),
              _productInfoRow('Minimum Balance',
                  _currencyFormat.format(minBalance)),
              if (minOpening > 0)
                _productInfoRow('Min Opening Balance',
                    _currencyFormat.format(minOpening)),
              if (maxWithdrawalPerDay > 0)
                _productInfoRow('Max Withdrawal / Day',
                    _currencyFormat.format(maxWithdrawalPerDay)),
              if (withdrawalFee > 0)
                _productInfoRow('Withdrawal Fee',
                    _currencyFormat.format(withdrawalFee)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Action buttons
  // ---------------------------------------------------------------

  Widget _buildActionButtons() {
    final account = _currentAccount;
    if (account == null) return const SizedBox.shrink();

    final status = account['status']?.toString().toUpperCase() ?? '';
    final isActive = status == 'ACTIVE' || status == 'OPEN';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isActive && widget.onDepositMpesa != null
                  ? () => widget.onDepositMpesa!(account)
                  : null,
              icon: const Icon(Icons.phone_android, size: 18),
              label: const Text('Deposit via M-Pesa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isActive && widget.onWithdraw != null
                  ? () => widget.onWithdraw!(account)
                  : null,
              icon: const Icon(Icons.money_off, size: 18),
              label: const Text('Withdraw'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryGreen,
                side: BorderSide(
                  color: isActive ? _primaryGreen : Colors.grey.shade300,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Recent transactions
  // ---------------------------------------------------------------

  Widget _buildRecentTransactionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, size: 20, color: _primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (_loadingDetail)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_detailError != null) _buildTransactionError(),
          if (_loadingDetail && _recentTransactions.isEmpty)
            _buildTransactionsLoading(),
          if (!_loadingDetail && _recentTransactions.isEmpty && _detailError == null)
            _buildNoTransactions(),
          if (_recentTransactions.isNotEmpty)
            _buildTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildTransactionError() {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Could not load transactions',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _detailError ?? '',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _loadAccountDetail,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildNoTransactions() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined,
                  size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                'No transactions yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Deposits and withdrawals will appear here.',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _recentTransactions.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final tx = _recentTransactions[index];
          return _buildTransactionTile(tx);
        },
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final type = tx['transaction_type']?.toString() ?? 'UNKNOWN';
    final description = tx['description']?.toString() ?? '';
    final amount = _toDouble(tx['amount']);
    final createdAt = tx['created_at'];
    final status = tx['status']?.toString().toUpperCase() ?? '';
    final channel = tx['channel']?.toString() ?? '';
    final transactionRef = tx['transaction_ref']?.toString() ?? '';
    final runningBalance = _toDouble(tx['running_balance']);

    final txColor = _transactionColor(type);
    final credit = _isCredit(type);
    final amountPrefix = credit ? '+' : '-';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: txColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          _transactionIcon(type),
          color: txColor,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              _transactionTypeLabel(type),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '$amountPrefix${_currencyFormat.format(amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: credit ? Colors.green.shade700 : Colors.red.shade600,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _formatDateTime(createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              if (channel.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    channel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              _transactionStatusChip(status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transactionStatusChip(String status) {
    Color color;
    switch (status) {
      case 'COMPLETED':
      case 'SUCCESS':
        color = Colors.green;
        break;
      case 'PENDING':
        color = Colors.amber.shade700;
        break;
      case 'FAILED':
      case 'REVERSED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
      ),
    );
  }
}

// =================================================================
// Mini Stat Card (private)
// =================================================================

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
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
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
