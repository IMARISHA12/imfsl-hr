import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ImfslExecutiveConsole — Top-level Ops Console executive summary.
///
/// Displays 12 KPI cards, alert banners, quick-nav grid,
/// top portfolio preview, and recent M-Pesa activity.
class ImfslExecutiveConsole extends StatefulWidget {
  final Map<String, dynamic> executiveKpis;
  final List<Map<String, dynamic>> topPortfolio;
  final List<Map<String, dynamic>> recentMpesa;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Function(String consoleName)? onNavigate;

  const ImfslExecutiveConsole({
    super.key,
    this.executiveKpis = const {},
    this.topPortfolio = const [],
    this.recentMpesa = const [],
    this.isLoading = false,
    this.onRefresh,
    this.onNavigate,
  });

  @override
  State<ImfslExecutiveConsole> createState() => _ImfslExecutiveConsoleState();
}

class _ImfslExecutiveConsoleState extends State<ImfslExecutiveConsole> {
  static const Color _primaryColor = Color(0xFF1565C0);
  static const Color _successGreen = Color(0xFF2E7D32);
  static const Color _warningOrange = Color(0xFFE65100);
  static const Color _alertRed = Color(0xFFC62828);
  static const Color _infoPurple = Color(0xFF6A1B9A);

  late final NumberFormat _currencyFormat;
  late final NumberFormat _compactFormat;

  @override
  void initState() {
    super.initState();
    _currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
    _compactFormat = NumberFormat.compact();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int _kpiInt(String key) {
    final v = widget.executiveKpis[key];
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  double _kpiDouble(String key) {
    final v = widget.executiveKpis[key];
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return _currencyFormat.format(0);
    if (value is String) {
      final parsed = double.tryParse(value);
      return _currencyFormat.format(parsed ?? 0);
    }
    return _currencyFormat.format(value);
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is int) return NumberFormat('#,###').format(value);
    if (value is double) return NumberFormat('#,###').format(value.toInt());
    final parsed = int.tryParse(value.toString());
    return parsed != null ? NumberFormat('#,###').format(parsed) : '0';
  }

  /// True for KPI keys whose values represent monetary amounts.
  bool _isMonetaryKey(String key) {
    const monetaryKeys = {
      'total_outstanding',
      'total_disbursed_active',
      'total_savings_balance',
      'mpesa_collections_this_month',
    };
    return monetaryKeys.contains(key);
  }

  Color _statusBadgeColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
      case 'DISBURSED':
      case 'COMPLETED':
        return _successGreen;
      case 'IN_ARREARS':
      case 'DEFAULTED':
      case 'WRITTEN_OFF':
        return _alertRed;
      case 'PENDING':
      case 'SUBMITTED':
        return _warningOrange;
      case 'APPROVED':
        return _primaryColor;
      default:
        return Colors.grey;
    }
  }

  Color _purposeBadgeColor(String? purpose) {
    switch (purpose?.toUpperCase()) {
      case 'LOAN_REPAYMENT':
        return _primaryColor;
      case 'DEPOSIT':
        return _successGreen;
      case 'FEE_PAYMENT':
        return _warningOrange;
      default:
        return Colors.grey;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    final bool hasData = widget.executiveKpis.isNotEmpty ||
        widget.topPortfolio.isNotEmpty ||
        widget.recentMpesa.isNotEmpty;

    if (!hasData) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: () async {
        widget.onRefresh?.call();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildKpiGrid(),
          const SizedBox(height: 16),
          _buildAlertBanners(),
          const SizedBox(height: 16),
          _buildQuickNavGrid(),
          const SizedBox(height: 20),
          _buildTopPortfolioSection(),
          const SizedBox(height: 20),
          _buildRecentMpesaSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.dashboard_rounded, color: _primaryColor, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Executive Console',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        if (widget.onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh, color: _primaryColor),
            tooltip: 'Refresh',
            onPressed: widget.onRefresh,
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Loading State
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _primaryColor),
            SizedBox(height: 16),
            Text(
              'Loading executive summary...',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF616161),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh or check your connection.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            if (widget.onRefresh != null)
              ElevatedButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KPI Grid (3 columns x 4 rows = 12 cards)
  // ---------------------------------------------------------------------------

  Widget _buildKpiGrid() {
    final List<_KpiDefinition> kpis = [
      _KpiDefinition(
        key: 'total_active_customers',
        label: 'Active Customers',
        icon: Icons.people_alt_rounded,
        color: _primaryColor,
      ),
      _KpiDefinition(
        key: 'active_loans',
        label: 'Active Loans',
        icon: Icons.account_balance_wallet_rounded,
        color: _primaryColor,
      ),
      _KpiDefinition(
        key: 'total_outstanding',
        label: 'Total Outstanding',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF00838F),
      ),
      _KpiDefinition(
        key: 'total_disbursed_active',
        label: 'Total Disbursed',
        icon: Icons.payments_rounded,
        color: _successGreen,
      ),
      _KpiDefinition(
        key: 'loans_in_arrears',
        label: 'Loans in Arrears',
        icon: Icons.warning_amber_rounded,
        color: _alertRed,
      ),
      _KpiDefinition(
        key: 'pending_applications',
        label: 'Pending Applications',
        icon: Icons.pending_actions_rounded,
        color: _warningOrange,
      ),
      _KpiDefinition(
        key: 'total_savings_balance',
        label: 'Savings Balance',
        icon: Icons.savings_rounded,
        color: _successGreen,
      ),
      _KpiDefinition(
        key: 'active_savings_accounts',
        label: 'Savings Accounts',
        icon: Icons.account_balance_rounded,
        color: const Color(0xFF00695C),
      ),
      _KpiDefinition(
        key: 'mpesa_collections_this_month',
        label: 'M-Pesa This Month',
        icon: Icons.phone_android_rounded,
        color: _successGreen,
      ),
      _KpiDefinition(
        key: 'pending_mpesa_transactions',
        label: 'Pending M-Pesa',
        icon: Icons.hourglass_top_rounded,
        color: _warningOrange,
      ),
      _KpiDefinition(
        key: 'pending_approvals',
        label: 'Pending Approvals',
        icon: Icons.approval_rounded,
        color: _primaryColor,
      ),
      _KpiDefinition(
        key: 'pending_kyc',
        label: 'Pending KYC',
        icon: Icons.verified_user_rounded,
        color: _infoPurple,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Performance Indicators',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kpis.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final kpi = kpis[index];
            return _buildKpiCard(kpi);
          },
        ),
      ],
    );
  }

  Widget _buildKpiCard(_KpiDefinition kpi) {
    final bool isMoney = _isMonetaryKey(kpi.key);
    final String displayValue = isMoney
        ? _formatCurrencyCompact(_kpiDouble(kpi.key))
        : _formatNumber(widget.executiveKpis[kpi.key]);

    return Container(
      decoration: BoxDecoration(
        color: kpi.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kpi.color.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(kpi.icon, color: kpi.color, size: 24),
          const SizedBox(height: 6),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kpi.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            kpi.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF616161),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatCurrencyCompact(double value) {
    if (value >= 1000000) {
      return 'KES ${_compactFormat.format(value)}';
    }
    return _currencyFormat.format(value);
  }

  // ---------------------------------------------------------------------------
  // Alert Banners
  // ---------------------------------------------------------------------------

  Widget _buildAlertBanners() {
    final List<Widget> banners = [];

    final int loansInArrears = _kpiInt('loans_in_arrears');
    if (loansInArrears > 0) {
      banners.add(_buildAlertBanner(
        icon: Icons.error_outline_rounded,
        message: '$loansInArrears loan${loansInArrears == 1 ? '' : 's'} in arrears',
        backgroundColor: _alertRed.withOpacity(0.08),
        borderColor: _alertRed.withOpacity(0.3),
        textColor: _alertRed,
        iconColor: _alertRed,
      ));
    }

    final int pendingKyc = _kpiInt('pending_kyc');
    if (pendingKyc > 5) {
      banners.add(_buildAlertBanner(
        icon: Icons.assignment_late_rounded,
        message: '$pendingKyc KYC submissions pending review',
        backgroundColor: _warningOrange.withOpacity(0.08),
        borderColor: _warningOrange.withOpacity(0.3),
        textColor: _warningOrange,
        iconColor: _warningOrange,
      ));
    }

    final int pendingApprovals = _kpiInt('pending_approvals');
    if (pendingApprovals > 0) {
      banners.add(_buildAlertBanner(
        icon: Icons.notifications_active_rounded,
        message:
            '$pendingApprovals approval${pendingApprovals == 1 ? '' : 's'} awaiting action',
        backgroundColor: _primaryColor.withOpacity(0.08),
        borderColor: _primaryColor.withOpacity(0.3),
        textColor: _primaryColor,
        iconColor: _primaryColor,
      ));
    }

    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alerts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        ...banners,
      ],
    );
  }

  Widget _buildAlertBanner({
    required IconData icon,
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Quick-Nav Grid (2x2)
  // ---------------------------------------------------------------------------

  Widget _buildQuickNavGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Navigation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _buildQuickNavCard(
              title: 'Loan Operations',
              icon: Icons.account_balance,
              color: _primaryColor,
              consoleName: 'loanOps',
              metricLabel: 'Active Loans',
              metricValue: _formatNumber(widget.executiveKpis['active_loans']),
            ),
            _buildQuickNavCard(
              title: 'Payments & M-Pesa',
              icon: Icons.payment,
              color: _successGreen,
              consoleName: 'payments',
              metricLabel: 'This Month',
              metricValue: _formatCurrencyCompact(
                  _kpiDouble('mpesa_collections_this_month')),
            ),
            _buildQuickNavCard(
              title: 'Risk & Compliance',
              icon: Icons.shield,
              color: _warningOrange,
              consoleName: 'risk',
              metricLabel: 'In Arrears',
              metricValue:
                  _formatNumber(widget.executiveKpis['loans_in_arrears']),
            ),
            _buildQuickNavCard(
              title: 'Customer 360',
              icon: Icons.people,
              color: _infoPurple,
              consoleName: 'customer360',
              metricLabel: 'Customers',
              metricValue: _formatNumber(
                  widget.executiveKpis['total_active_customers']),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickNavCard({
    required String title,
    required IconData icon,
    required Color color,
    required String consoleName,
    required String metricLabel,
    required String metricValue,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onNavigate?.call(consoleName),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 26),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metricValue,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      metricLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Portfolio Preview
  // ---------------------------------------------------------------------------

  Widget _buildTopPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Portfolio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
            if (widget.topPortfolio.isNotEmpty)
              Text(
                '${widget.topPortfolio.length} loan${widget.topPortfolio.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (widget.topPortfolio.isEmpty)
          _buildSectionEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            message: 'No portfolio data available',
          )
        else
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount:
                  widget.topPortfolio.length > 10 ? 10 : widget.topPortfolio.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final loan = widget.topPortfolio[index];
                return _buildPortfolioCard(loan);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPortfolioCard(Map<String, dynamic> loan) {
    final String loanNumber =
        loan['loan_number']?.toString() ?? 'N/A';
    final String fullName =
        loan['full_name']?.toString() ?? 'Unknown';
    final String status =
        loan['status']?.toString() ?? 'UNKNOWN';
    final dynamic outstandingBalance = loan['outstanding_balance'];

    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
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
              Expanded(
                child: Text(
                  loanNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _formatCurrency(outstandingBalance),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color bgColor = _statusBadgeColor(status);
    final String displayText = _formatStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: bgColor.withOpacity(0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: bgColor,
        ),
      ),
    );
  }

  String _formatStatusText(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) =>
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  // ---------------------------------------------------------------------------
  // Recent M-Pesa Activity
  // ---------------------------------------------------------------------------

  Widget _buildRecentMpesaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent M-Pesa Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
            if (widget.recentMpesa.isNotEmpty)
              Text(
                '${widget.recentMpesa.length} transaction${widget.recentMpesa.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (widget.recentMpesa.isEmpty)
          _buildSectionEmptyState(
            icon: Icons.phone_android_outlined,
            message: 'No recent M-Pesa transactions',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                widget.recentMpesa.length > 10 ? 10 : widget.recentMpesa.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final txn = widget.recentMpesa[index];
              return _buildMpesaCard(txn);
            },
          ),
      ],
    );
  }

  Widget _buildMpesaCard(Map<String, dynamic> txn) {
    final String receipt =
        txn['mpesa_receipt_number']?.toString() ?? 'N/A';
    final String fullName =
        txn['full_name']?.toString() ?? 'Unknown';
    final dynamic amount = txn['amount'];
    final String purpose =
        txn['purpose']?.toString() ?? 'UNKNOWN';
    final String status =
        txn['status']?.toString() ?? 'UNKNOWN';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            blurRadius: 3,
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
              color: _successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.phone_android_rounded,
              color: _successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        receipt,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatCurrency(amount),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildPurposeBadge(purpose),
                    const SizedBox(width: 4),
                    _buildStatusBadge(status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeBadge(String purpose) {
    final Color bgColor = _purposeBadgeColor(purpose);
    final String displayText = _formatPurposeText(purpose);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: bgColor.withOpacity(0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: bgColor,
        ),
      ),
    );
  }

  String _formatPurposeText(String purpose) {
    switch (purpose.toUpperCase()) {
      case 'LOAN_REPAYMENT':
        return 'Repayment';
      case 'DEPOSIT':
        return 'Deposit';
      case 'FEE_PAYMENT':
        return 'Fee';
      default:
        return _formatStatusText(purpose);
    }
  }

  // ---------------------------------------------------------------------------
  // Section Empty State
  // ---------------------------------------------------------------------------

  Widget _buildSectionEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Supporting Data Class
// =============================================================================

class _KpiDefinition {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const _KpiDefinition({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}
