import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL Admin Collections Overview Dashboard.
///
/// Displays collection KPIs, PAR distribution, recent collection actions,
/// and top overdue loans for the admin portal.
class ImfslCollectionsDashboard extends StatefulWidget {
  final Map<String, dynamic> dashboardData;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Function(String)? onLoanTap;
  final Function(Map<String, dynamic>)? onLogAction;

  const ImfslCollectionsDashboard({
    super.key,
    this.dashboardData = const {},
    this.isLoading = false,
    this.onRefresh,
    this.onLoanTap,
    this.onLogAction,
  });

  @override
  State<ImfslCollectionsDashboard> createState() =>
      _ImfslCollectionsDashboardState();
}

class _ImfslCollectionsDashboardState
    extends State<ImfslCollectionsDashboard> {
  static const Color _primary = Color(0xFF1565C0);

  final NumberFormat _kes =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  static const Map<String, Color> _parColors = {
    'CURRENT': Color(0xFF4CAF50),
    'PAR1_30': Color(0xFFCDDC39),
    'PAR31_60': Color(0xFFFFC107),
    'PAR61_90': Color(0xFFFF9800),
    'PAR91_180': Color(0xFFFF5722),
    'PAR180_PLUS': Color(0xFFF44336),
  };

  static const Map<String, String> _parLabels = {
    'CURRENT': 'Current',
    'PAR1_30': '1-30 days',
    'PAR31_60': '31-60 days',
    'PAR61_90': '61-90 days',
    'PAR91_180': '91-180 days',
    'PAR180_PLUS': '180+ days',
  };

  static const Map<String, IconData> _actionIcons = {
    'SMS': Icons.sms,
    'PHONE_CALL': Icons.phone,
    'FIELD_VISIT': Icons.directions_walk,
    'DEMAND_LETTER': Icons.mail,
    'EMAIL': Icons.email,
    'LEGAL_NOTICE': Icons.gavel,
    'RESTRUCTURE': Icons.autorenew,
    'WRITE_OFF': Icons.delete_forever,
  };

  static const Map<String, Color> _outcomeColors = {
    'PROMISED': Color(0xFF1565C0),
    'PAID': Color(0xFF4CAF50),
    'NO_ANSWER': Color(0xFF9E9E9E),
    'REFUSED': Color(0xFFF44336),
    'PARTIAL': Color(0xFFFF9800),
  };

  static const Map<String, Color> _priorityColors = {
    'CRITICAL': Color(0xFFF44336),
    'HIGH': Color(0xFFFF9800),
    'MEDIUM': Color(0xFFFFC107),
    'LOW': Color(0xFF9E9E9E),
  };

  // -- Data accessors ---------------------------------------------------------

  Map<String, dynamic> get _summary =>
      (widget.dashboardData['summary'] as Map<String, dynamic>?) ?? {};

  List<dynamic> get _parDist =>
      (widget.dashboardData['par_distribution'] as List<dynamic>?) ?? [];

  List<dynamic> get _actions =>
      (widget.dashboardData['recent_actions'] as List<dynamic>?) ?? [];

  List<dynamic> get _overdue =>
      (widget.dashboardData['top_overdue'] as List<dynamic>?) ?? [];

  // -- Helpers ----------------------------------------------------------------

  Future<void> _handleRefresh() async => widget.onRefresh?.call();

  BoxDecoration _cardDeco([double blur = 8, double op = 0.06]) =>
      BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(op),
            blurRadius: blur,
            offset: const Offset(0, 2),
          ),
        ],
      );

  String _titleCase(String s) => s
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isNotEmpty
          ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
          : '')
      .join(' ');

  String _fmtDate(String raw, [String pat = 'dd MMM yyyy, HH:mm']) {
    if (raw.isEmpty) return '';
    try {
      return DateFormat(pat).format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  // -- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _primary,
      onRefresh: _handleRefresh,
      child: widget.isLoading ? _buildSkeleton() : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Key Metrics'),
          const SizedBox(height: 12),
          _buildKpiCards(),
          const SizedBox(height: 24),
          _sectionHeader('PAR Distribution'),
          const SizedBox(height: 12),
          _buildParDistribution(),
          const SizedBox(height: 24),
          _sectionHeader('Collection Rate'),
          const SizedBox(height: 12),
          _buildCollectionRateRing(),
          const SizedBox(height: 24),
          _sectionHeader('Recent Actions'),
          const SizedBox(height: 12),
          _buildRecentActions(),
          const SizedBox(height: 24),
          _sectionHeader('Top Overdue Loans'),
          const SizedBox(height: 12),
          _buildTopOverdue(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
      );

  // -- 1. KPI Cards -----------------------------------------------------------

  Widget _buildKpiCards() {
    final overdue = (_summary['total_overdue_loans'] as int?) ?? 0;
    final arrears =
        (_summary['total_arrears_amount'] as num?)?.toDouble() ?? 0.0;
    final rate =
        (_summary['collection_rate_pct'] as num?)?.toDouble() ?? 0.0;
    final penalties =
        (_summary['penalties_outstanding'] as num?)?.toDouble() ?? 0.0;

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _kpiCard(Icons.warning_amber, const Color(0xFFF44336),
              'Total Overdue', '$overdue'),
          const SizedBox(width: 12),
          _kpiCard(Icons.money_off, const Color(0xFFFF9800),
              'Arrears Amount', _kes.format(arrears)),
          const SizedBox(width: 12),
          _kpiCard(Icons.trending_up, const Color(0xFF4CAF50),
              'Collection Rate', '${rate.toStringAsFixed(1)}%'),
          const SizedBox(width: 12),
          _kpiCard(Icons.gavel, const Color(0xFF7B1FA2),
              'Penalties', _kes.format(penalties)),
        ],
      ),
    );
  }

  Widget _kpiCard(IconData icon, Color c, String label, String value) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c, size: 28),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
          const SizedBox(height: 4),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121))),
            ),
          ),
        ],
      ),
    );
  }

  // -- 2. PAR Distribution ----------------------------------------------------

  Widget _buildParDistribution() {
    if (_parDist.isEmpty) return _emptyState('No PAR data available');

    final total = _parDist.fold<double>(
        0.0, (s, i) => s + ((i['total_amount'] as num?)?.toDouble() ?? 0.0));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 28,
              child: Row(
                children: _parDist.map<Widget>((item) {
                  final bucket = (item['bucket'] as String?) ?? 'CURRENT';
                  final amount =
                      (item['total_amount'] as num?)?.toDouble() ?? 0.0;
                  final frac = total > 0 ? amount / total : 0.0;
                  return Expanded(
                    flex: (frac * 1000).round().clamp(1, 1000),
                    child: Container(
                        color: _parColors[bucket] ?? Colors.grey),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: _parDist.map<Widget>((item) {
              final bucket = (item['bucket'] as String?) ?? 'CURRENT';
              final count = (item['loan_count'] as int?) ?? 0;
              final amount =
                  (item['total_amount'] as num?)?.toDouble() ?? 0.0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _parColors[bucket] ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_parLabels[bucket] ?? bucket}: '
                    '$count loans, ${_kes.format(amount)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // -- 3. Collection Rate Ring ------------------------------------------------

  Widget _buildCollectionRateRing() {
    final rate =
        (_summary['collection_rate_pct'] as num?)?.toDouble() ?? 0.0;
    final norm = (rate / 100).clamp(0.0, 1.0);
    final ringColor = rate >= 80
        ? const Color(0xFF4CAF50)
        : rate >= 50
            ? const Color(0xFFFFC107)
            : const Color(0xFFF44336);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _cardDeco(),
        child: SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: norm,
                  strokeWidth: 12,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${rate.toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ringColor)),
                  const Text('Collection Rate',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF757575))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -- 4. Recent Actions ------------------------------------------------------

  Widget _buildRecentActions() {
    if (_actions.isEmpty) return _emptyState('No recent collection actions');
    final count = _actions.length > 10 ? 10 : _actions.length;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, i) =>
          _actionItem(_actions[i] as Map<String, dynamic>),
    );
  }

  Widget _actionItem(Map<String, dynamic> a) {
    final staff = (a['staff_name'] as String?) ?? 'Unknown';
    final type = (a['action_type'] as String?) ?? '';
    final outcome = (a['outcome'] as String?) ?? '';
    final notes = (a['notes'] as String?) ?? '';
    final loanNum = (a['loan_number'] as String?) ?? '';
    final time = _fmtDate((a['created_at'] as String?) ?? '');
    final oc = _outcomeColors[outcome] ?? const Color(0xFF9E9E9E);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: _cardDeco(4, 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _actionIcons[type] ?? Icons.assignment,
              size: 20,
              color: _primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(staff,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121))),
                  ),
                  _badge(_titleCase(outcome), oc),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Text(_titleCase(type),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF616161))),
                  const SizedBox(width: 8),
                  Text(loanNum,
                      style: TextStyle(
                          fontSize: 12,
                          color: _primary,
                          fontWeight: FontWeight.w500)),
                ]),
                if (notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E))),
                  ),
                if (time.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(time,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFFBDBDBD))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: c.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: c)),
      );

  // -- 5. Top Overdue ---------------------------------------------------------

  Widget _buildTopOverdue() {
    if (_overdue.isEmpty) return _emptyState('No overdue loans');
    final count = _overdue.length > 10 ? 10 : _overdue.length;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, i) =>
          _overdueCard(_overdue[i] as Map<String, dynamic>),
    );
  }

  Widget _overdueCard(Map<String, dynamic> loan) {
    final loanId = (loan['loan_id'] as String?) ?? '';
    final loanNum = (loan['loan_number'] as String?) ?? '';
    final balance =
        (loan['outstanding_balance'] as num?)?.toDouble() ?? 0.0;
    final days = (loan['days_in_arrears'] as int?) ?? 0;
    final par = (loan['par_bucket'] as String?) ?? '';
    final prio = (loan['collection_priority'] as String?) ?? '';
    final due =
        _fmtDate((loan['next_due_date'] as String?) ?? '', 'dd MMM yyyy');
    final name = (loan['customer_name'] as String?) ?? 'Unknown';
    final phone = (loan['phone_number'] as String?) ?? '';
    final pc = _priorityColors[prio] ?? const Color(0xFF9E9E9E);

    return GestureDetector(
      onTap: loanId.isNotEmpty
          ? () => widget.onLoanTap?.call(loanId)
          : null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer name + priority
              Row(children: [
                Expanded(
                  child: Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121))),
                ),
                _badge(prio, pc),
              ]),
              const SizedBox(height: 6),
              // Phone & loan number
              Row(children: [
                const Icon(Icons.phone,
                    size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text(phone,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF616161))),
                const SizedBox(width: 16),
                const Icon(Icons.receipt_long,
                    size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text(loanNum,
                    style: TextStyle(
                        fontSize: 13,
                        color: _primary,
                        fontWeight: FontWeight.w500)),
              ]),
              const Divider(height: 20),
              // Balance & days overdue
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Outstanding Balance',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF9E9E9E))),
                      const SizedBox(height: 2),
                      Text(_kes.format(balance),
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF44336))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Days Overdue',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF9E9E9E))),
                      const SizedBox(height: 2),
                      Text('$days days',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _parColors[par] ??
                                  const Color(0xFFFF9800))),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              // Due date + log action
              Row(children: [
                if (due.isNotEmpty) ...[
                  const Icon(Icons.event,
                      size: 14, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 4),
                  Text('Next due: $due',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF757575))),
                ],
                const Spacer(),
                if (widget.onLogAction != null)
                  InkWell(
                    onTap: () => widget.onLogAction?.call(loan),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline,
                              size: 14, color: _primary),
                          const SizedBox(width: 4),
                          Text('Log Action',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _primary)),
                        ],
                      ),
                    ),
                  ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // -- Loading skeleton -------------------------------------------------------

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skelBar(120, 16),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _skelBox(170, 120),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _skelBar(140, 16),
          const SizedBox(height: 12),
          _skelBox(double.infinity, 100),
          const SizedBox(height: 24),
          _skelBar(120, 16),
          const SizedBox(height: 12),
          Center(child: _skelCircle(140)),
          const SizedBox(height: 24),
          _skelBar(130, 16),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _skelBox(double.infinity, 80),
            ),
          ),
          const SizedBox(height: 24),
          _skelBar(150, 16),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _skelBox(double.infinity, 140),
            ),
          ),
        ],
      ),
    );
  }

  static const _skelGrad = LinearGradient(
    colors: [Color(0xFFEEEEEE), Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
    stops: [0.0, 0.5, 1.0],
  );

  Widget _skelBox(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _skelGrad,
        ),
      );

  Widget _skelBar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xFFE0E0E0),
        ),
      );

  Widget _skelCircle(double d) => Container(
        width: d,
        height: d,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: _skelGrad,
        ),
      );

  // -- Empty state ------------------------------------------------------------

  Widget _emptyState(String msg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: _cardDeco(4, 0.04),
        child: Column(children: [
          const Icon(Icons.inbox, size: 40, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 8),
          Text(msg,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF9E9E9E))),
        ]),
      );
}
