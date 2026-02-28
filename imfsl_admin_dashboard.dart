// IMFSL Admin Dashboard - FlutterFlow Custom Widget
// ==================================================
// Executive overview dashboard for microfinance admin portal with:
// - KPI grid (8 metrics in 2x4 layout)
// - Today's activity row (horizontal scrollable chips)
// - Loan portfolio breakdown by product
// - Savings summary card
// - KYC pipeline status badges
// - Quick action buttons for navigation
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslAdminDashboard extends StatefulWidget {
  const ImfslAdminDashboard({
    super.key,
    this.dashboardData = const {},
    this.isLoading = false,
    this.onRefresh,
    this.onNavigateStaff,
    this.onNavigateKyc,
    this.onNavigateLoans,
    this.onNavigateAudit,
    this.onNavigateReports,
  });

  final Map<String, dynamic> dashboardData;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final VoidCallback? onNavigateStaff;
  final VoidCallback? onNavigateKyc;
  final VoidCallback? onNavigateLoans;
  final VoidCallback? onNavigateAudit;
  final VoidCallback? onNavigateReports;

  @override
  State<ImfslAdminDashboard> createState() => _ImfslAdminDashboardState();
}

class _ImfslAdminDashboardState extends State<ImfslAdminDashboard> {
  final NumberFormat _currencyFmt =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  static const Color _primaryColor = Color(0xFF1565C0);

  // -- helpers to safely read nested data --

  Map<String, dynamic> get _data => widget.dashboardData;

  Map<String, dynamic> _map(String key) =>
      (_data[key] as Map<String, dynamic>?) ?? const {};

  List<dynamic> _list(String key) =>
      (_data[key] as List<dynamic>?) ?? const [];

  double _double(Map<String, dynamic> m, String key) =>
      (m[key] as num?)?.toDouble() ?? 0.0;

  int _int(Map<String, dynamic> m, String key) =>
      (m[key] as num?)?.toInt() ?? 0;

  String _string(Map<String, dynamic> m, String key) =>
      (m[key] as String?) ?? '';

  // -- color helpers for PAR / default rates --

  Color _rateColor(double rate) {
    if (rate > 10) return Colors.red;
    if (rate >= 5) return Colors.orange;
    return const Color(0xFF2E7D32);
  }

  Color _rateBackground(double rate) {
    if (rate > 10) return Colors.red.shade50;
    if (rate >= 5) return Colors.orange.shade50;
    return Colors.green.shade50;
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: () async {
        widget.onRefresh?.call();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Key Performance Indicators'),
            const SizedBox(height: 12),
            _buildKpiGrid(),
            const SizedBox(height: 20),
            _buildSectionTitle("Today's Activity"),
            const SizedBox(height: 12),
            _buildTodayActivityRow(),
            const SizedBox(height: 20),
            _buildLoanPortfolioCard(),
            const SizedBox(height: 16),
            _buildSavingsSummaryCard(),
            const SizedBox(height: 16),
            _buildKycPipelineCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            _buildQuickActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ========== SECTION TITLE ==========

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  // ========== KPI GRID (2x4) ==========

  Widget _buildKpiGrid() {
    final summary = _map('summary');
    final loans = _map('loan_portfolio');
    final today = _map('today_activity');

    final totalCustomers = _int(summary, 'total_customers');
    final activeLoans = _int(loans, 'active_loans');
    final outstandingBalance = _double(loans, 'outstanding_balance');
    final par30 = _double(loans, 'par30_rate');
    final par90 = _double(loans, 'par90_rate');
    final defaultRate = _double(loans, 'default_rate');
    final todayDisbursements = _double(today, 'disbursements_amount');
    final todayRepayments = _double(today, 'repayments_amount');

    final kpis = <_KpiItem>[
      _KpiItem(
        label: 'Total Customers',
        value: NumberFormat('#,###').format(totalCustomers),
        icon: Icons.people_outlined,
        color: _primaryColor,
      ),
      _KpiItem(
        label: 'Active Loans',
        value: NumberFormat('#,###').format(activeLoans),
        icon: Icons.account_balance_outlined,
        color: const Color(0xFF6A1B9A),
      ),
      _KpiItem(
        label: 'Outstanding Balance',
        value: _currencyFmt.format(outstandingBalance),
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFFEF6C00),
      ),
      _KpiItem(
        label: 'PAR30 Rate',
        value: '${par30.toStringAsFixed(1)}%',
        icon: Icons.trending_up,
        color: _rateColor(par30),
        backgroundColor: _rateBackground(par30),
      ),
      _KpiItem(
        label: 'PAR90 Rate',
        value: '${par90.toStringAsFixed(1)}%',
        icon: Icons.trending_up,
        color: _rateColor(par90),
        backgroundColor: _rateBackground(par90),
      ),
      _KpiItem(
        label: 'Default Rate',
        value: '${defaultRate.toStringAsFixed(1)}%',
        icon: Icons.warning_amber_outlined,
        color: _rateColor(defaultRate),
        backgroundColor: _rateBackground(defaultRate),
      ),
      _KpiItem(
        label: "Today's Disbursements",
        value: _currencyFmt.format(todayDisbursements),
        icon: Icons.arrow_upward,
        color: const Color(0xFF2E7D32),
      ),
      _KpiItem(
        label: "Today's Repayments",
        value: _currencyFmt.format(todayRepayments),
        icon: Icons.arrow_downward,
        color: _primaryColor,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.7,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) => _buildKpiCard(kpis[index]),
    );
  }

  Widget _buildKpiCard(_KpiItem kpi) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kpi.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(kpi.icon, color: kpi.color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  kpi.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            kpi.value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kpi.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ========== TODAY'S ACTIVITY ROW ==========

  Widget _buildTodayActivityRow() {
    final today = _map('today_activity');

    final chips = <_ActivityChip>[
      _ActivityChip(
        label: 'New Customers',
        value: _int(today, 'new_customers').toString(),
        icon: Icons.person_add_outlined,
        color: _primaryColor,
      ),
      _ActivityChip(
        label: 'Loan Apps',
        value: _int(today, 'loan_applications').toString(),
        icon: Icons.description_outlined,
        color: const Color(0xFF6A1B9A),
      ),
      _ActivityChip(
        label: 'Disbursements',
        value: _currencyFmt.format(_double(today, 'disbursements_amount')),
        icon: Icons.arrow_upward,
        color: const Color(0xFF2E7D32),
      ),
      _ActivityChip(
        label: 'Repayments',
        value: _currencyFmt.format(_double(today, 'repayments_amount')),
        icon: Icons.arrow_downward,
        color: const Color(0xFFEF6C00),
      ),
      _ActivityChip(
        label: 'M-Pesa Volume',
        value: _currencyFmt.format(_double(today, 'mpesa_volume')),
        icon: Icons.phone_android,
        color: const Color(0xFF2E7D32),
      ),
    ];

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _buildActivityChip(chips[index]),
      ),
    );
  }

  Widget _buildActivityChip(_ActivityChip chip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: chip.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chip.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.icon, color: chip.color, size: 18),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chip.label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                chip.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: chip.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== LOAN PORTFOLIO BREAKDOWN ==========

  Widget _buildLoanPortfolioCard() {
    final products = _list('loan_products');

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loan Portfolio Breakdown',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No loan products available',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ),
            )
          else
            ...products.map((p) {
              final product = p as Map<String, dynamic>;
              final name = _string(product, 'product_name');
              final count = _int(product, 'loan_count');
              final balance = _double(product, 'outstanding_balance');
              return _buildPortfolioRow(name, count, balance);
            }),
        ],
      ),
    );
  }

  Widget _buildPortfolioRow(String name, int count, double balance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count loans',
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _currencyFmt.format(balance),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ========== SAVINGS SUMMARY ==========

  Widget _buildSavingsSummaryCard() {
    final savings = _map('savings_summary');

    final totalAccounts = _int(savings, 'total_accounts');
    final activeAccounts = _int(savings, 'active_accounts');
    final totalBalance = _double(savings, 'total_balance');
    final todayDeposits = _double(savings, 'today_deposits');

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Savings Summary',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSavingsStat(
                'Total Accounts',
                NumberFormat('#,###').format(totalAccounts),
                Icons.account_balance_outlined,
              ),
              const SizedBox(width: 12),
              _buildSavingsStat(
                'Active Accounts',
                NumberFormat('#,###').format(activeAccounts),
                Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSavingsStat(
                'Total Balance',
                _currencyFmt.format(totalBalance),
                Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(width: 12),
              _buildSavingsStat(
                "Today's Deposits",
                _currencyFmt.format(todayDeposits),
                Icons.arrow_downward,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== KYC PIPELINE ==========

  Widget _buildKycPipelineCard() {
    final kyc = _map('kyc_pipeline');

    final pending = _int(kyc, 'pending');
    final approved = _int(kyc, 'approved');
    final rejected = _int(kyc, 'rejected');

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KYC Pipeline',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildKycBadge('Pending', pending, Colors.amber),
              const SizedBox(width: 12),
              _buildKycBadge('Approved', approved, const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              _buildKycBadge('Rejected', rejected, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKycBadge(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== QUICK ACTION BUTTONS ==========

  Widget _buildQuickActionButtons() {
    final actions = <_AdminAction>[
      _AdminAction('Staff', Icons.people_outlined, widget.onNavigateStaff),
      _AdminAction(
          'KYC Queue', Icons.verified_user_outlined, widget.onNavigateKyc),
      _AdminAction(
          'Loan Queue', Icons.assignment_outlined, widget.onNavigateLoans),
      _AdminAction(
          'Audit Log', Icons.history_outlined, widget.onNavigateAudit),
      _AdminAction(
          'Reports', Icons.bar_chart_outlined, widget.onNavigateReports),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions.map((a) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: OutlinedButton.icon(
              onPressed: a.onTap,
              icon: Icon(a.icon, size: 18),
              label: Text(a.label),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: const BorderSide(color: _primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ========== Private data classes ==========

class _KpiItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;

  const _KpiItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.backgroundColor,
  });
}

class _ActivityChip {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ActivityChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _AdminAction {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _AdminAction(this.label, this.icon, this.onTap);
}
