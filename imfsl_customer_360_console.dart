import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL Customer 360 Console
///
/// A comprehensive 4-tab admin console combining Customer Directory, KYC Queue,
/// Savings Overview, and Guarantor Registry into a single unified view.
///
/// Data sources:
///   Tab 1 - Directory : vw_retool_imfsl_customer_directory (V1)
///   Tab 2 - KYC       : vw_retool_imfsl_kyc_queue (V2)
///   Tab 3 - Savings   : vw_retool_imfsl_savings_overview (V6)
///   Tab 4 - Guarantors: vw_retool_imfsl_guarantor_registry (V7)
class ImfslCustomer360Console extends StatefulWidget {
  final List<Map<String, dynamic>> directoryData;
  final List<Map<String, dynamic>> kycData;
  final List<Map<String, dynamic>> savingsData;
  final List<Map<String, dynamic>> guarantorData;

  final bool isDirectoryLoading;
  final bool isKycLoading;
  final bool isSavingsLoading;
  final bool isGuarantorLoading;

  final String? directorySearch;
  final String? kycStatusFilter;
  final String? savingsStatusFilter;
  final String? guarantorStatusFilter;

  final Function(String)? onDirectorySearch;
  final Function(String?)? onKycStatusFilter;
  final Function(String?)? onSavingsStatusFilter;
  final Function(String?)? onGuarantorStatusFilter;

  final VoidCallback? onLoadMoreDirectory;
  final VoidCallback? onLoadMoreKyc;
  final VoidCallback? onLoadMoreSavings;
  final VoidCallback? onLoadMoreGuarantors;

  final VoidCallback? onRefreshDirectory;
  final VoidCallback? onRefreshKyc;
  final VoidCallback? onRefreshSavings;
  final VoidCallback? onRefreshGuarantors;

  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onItemTap;

  const ImfslCustomer360Console({
    super.key,
    this.directoryData = const [],
    this.kycData = const [],
    this.savingsData = const [],
    this.guarantorData = const [],
    this.isDirectoryLoading = false,
    this.isKycLoading = false,
    this.isSavingsLoading = false,
    this.isGuarantorLoading = false,
    this.directorySearch,
    this.kycStatusFilter,
    this.savingsStatusFilter,
    this.guarantorStatusFilter,
    this.onDirectorySearch,
    this.onKycStatusFilter,
    this.onSavingsStatusFilter,
    this.onGuarantorStatusFilter,
    this.onLoadMoreDirectory,
    this.onLoadMoreKyc,
    this.onLoadMoreSavings,
    this.onLoadMoreGuarantors,
    this.onRefreshDirectory,
    this.onRefreshKyc,
    this.onRefreshSavings,
    this.onRefreshGuarantors,
    this.onBack,
    this.onItemTap,
  });

  @override
  State<ImfslCustomer360Console> createState() =>
      _ImfslCustomer360ConsoleState();
}

class _ImfslCustomer360ConsoleState extends State<ImfslCustomer360Console> {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const Color _primary = Color(0xFF1565C0);
  static const Color _green = Color(0xFF2E7D32);
  static const Color _yellow = Color(0xFFF9A825);
  static const Color _red = Color(0xFFC62828);
  static const Color _orange = Color(0xFFEF6C00);
  static const Color _grey = Color(0xFF757575);

  final NumberFormat _currency =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');
  final DateFormat _dateTimeFmt = DateFormat('dd MMM yyyy, HH:mm');

  late TextEditingController _searchCtrl;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.directorySearch ?? '');
  }

  @override
  void didUpdateWidget(covariant ImfslCustomer360Console old) {
    super.didUpdateWidget(old);
    if (widget.directorySearch != old.directorySearch) {
      _searchCtrl.text = widget.directorySearch ?? '';
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Value helpers
  // ---------------------------------------------------------------------------

  double _dbl(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '-';
    try {
      return _dateFmt.format(DateTime.parse(v.toString()));
    } catch (_) {
      return v.toString();
    }
  }

  String _fmtDateTime(dynamic v) {
    if (v == null) return '-';
    try {
      return _dateTimeFmt.format(DateTime.parse(v.toString()));
    } catch (_) {
      return v.toString();
    }
  }

  // ---------------------------------------------------------------------------
  // Color helpers
  // ---------------------------------------------------------------------------

  Color _statusColor(String? s) {
    switch (s?.toUpperCase()) {
      case 'APPROVED':
      case 'ACTIVE':
      case 'RELEASED':
        return _green;
      case 'PENDING':
      case 'DORMANT':
        return _yellow;
      case 'REJECTED':
      case 'DEFAULTED':
      case 'CLOSED':
        return _red;
      default:
        return _grey;
    }
  }

  Color _riskColor(int score) =>
      score < 30 ? _green : (score < 60 ? _orange : _red);

  // ---------------------------------------------------------------------------
  // Reusable micro-widgets
  // ---------------------------------------------------------------------------

  Widget _badge(String? status) {
    final label = status?.toUpperCase() ?? 'UNKNOWN';
    final c = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _kpi(String label, String value, {IconData? icon, Color? color}) {
    final c = color ?? _primary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: c.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            if (icon != null) Icon(icon, size: 20, color: c),
            if (icon != null) const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: c),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChips(
      List<String> opts, String? selected, Function(String?)? onSel) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: opts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final o = opts[i];
          final isAll = o == 'ALL';
          final isSel =
              isAll ? (selected == null || selected == 'ALL') : selected == o;
          return FilterChip(
            label: Text(o),
            selected: isSel,
            onSelected: (_) => onSel?.call(isAll ? null : o),
            selectedColor: _primary.withOpacity(0.15),
            checkmarkColor: _primary,
            labelStyle: TextStyle(
              color: isSel ? _primary : Colors.grey.shade700,
              fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
              fontSize: 12,
            ),
            side: BorderSide(
                color: isSel ? _primary : Colors.grey.shade300),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _loading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(color: _primary),
      ),
    );
  }

  Widget _empty(String msg, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              msg,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadMore(VoidCallback? cb) {
    if (cb == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: cb,
          icon: const Icon(Icons.expand_more, size: 18),
          label: const Text('Load More'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _iconLabel(IconData ic, String txt, {double size = 14}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ic, size: size, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            txt,
            style: TextStyle(
                fontSize: size - 1, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData ic, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ic, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _balanceColumn(String label, String value,
      {bool bold = false, Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: color ?? Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Detail bottom sheet
  // ---------------------------------------------------------------------------

  void _showDetail(
      BuildContext ctx, Map<String, dynamic> item, String tabLabel) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        builder: (_, scrollController) {
          final entries = item.entries.toList();
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_tabIcon(tabLabel),
                            color: _primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['full_name']?.toString() ??
                                  item['account_number']?.toString() ??
                                  '$tabLabel Detail',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              tabLabel,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      if (item['status'] != null ||
                          item['kyc_status'] != null)
                        _badge(item['status']?.toString() ??
                            item['kyc_status']?.toString()),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Summary row for monetary fields
                _detailSummaryRow(item, tabLabel),
                // All fields
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding:
                        const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, color: Colors.grey.shade100),
                    itemBuilder: (_, i) {
                      final key = entries[i].key;
                      final val = entries[i].value;
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                _humanKey(key),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _fmtDetailVal(key, val),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailSummaryRow(Map<String, dynamic> item, String tab) {
    // Show a brief monetary summary above the full field list
    if (tab == 'Directory') {
      final outstanding = _dbl(item['total_outstanding']);
      final income = _dbl(item['monthly_income']);
      if (outstanding == 0 && income == 0) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Row(
          children: [
            if (income > 0) ...[
              _summaryPill('Income', _currency.format(income), _green),
              const SizedBox(width: 8),
            ],
            if (outstanding > 0)
              _summaryPill('Outstanding', _currency.format(outstanding), _red),
          ],
        ),
      );
    }
    if (tab == 'Savings') {
      final bal = _dbl(item['current_balance']);
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: _summaryPill('Balance', _currency.format(bal), _primary),
      );
    }
    if (tab == 'Guarantors') {
      final amt = _dbl(item['guarantee_amount']);
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: _summaryPill('Guarantee', _currency.format(amt), _primary),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _summaryPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _tabIcon(String t) {
    switch (t) {
      case 'Directory':
        return Icons.people_outline;
      case 'KYC':
        return Icons.verified_user_outlined;
      case 'Savings':
        return Icons.savings_outlined;
      case 'Guarantors':
        return Icons.handshake_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _humanKey(String k) {
    return k
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) =>
            w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _fmtDetailVal(String key, dynamic v) {
    if (v == null) return '-';
    final s = v.toString();
    final lk = key.toLowerCase();
    if (lk.contains('amount') ||
        lk.contains('balance') ||
        lk.contains('income') ||
        lk.contains('outstanding') ||
        lk.contains('deposits') ||
        lk.contains('withdrawals') ||
        lk.contains('interest_earned')) {
      final n = double.tryParse(s);
      if (n != null) return _currency.format(n);
    }
    if (lk.endsWith('_at') || lk == 'date_of_birth') {
      return _fmtDateTime(v);
    }
    if (v is bool) return v ? 'Yes' : 'No';
    if (s == 'true') return 'Yes';
    if (s == 'false') return 'No';
    return s;
  }

  // ---------------------------------------------------------------------------
  // Tab 1 -- Directory
  // ---------------------------------------------------------------------------

  Widget _buildDirectoryTab() {
    final data = widget.directoryData;
    final total = data.length;
    final active = data
        .where(
            (d) => d['is_active'] == true || d['is_active'] == 'true')
        .length;
    final avgIncome = total > 0
        ? data.fold<double>(
                0.0, (s, d) => s + _dbl(d['monthly_income'])) /
            total
        : 0.0;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: widget.onDirectorySearch,
            decoration: InputDecoration(
              hintText: 'Search by name, phone, ID...',
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(Icons.search,
                  color: Colors.grey.shade400, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          color: Colors.grey.shade400, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        widget.onDirectorySearch?.call('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary),
              ),
            ),
          ),
        ),
        // KPIs
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _kpi('Total Customers', total.toString(),
                  icon: Icons.people),
              const SizedBox(width: 8),
              _kpi('Active', active.toString(),
                  icon: Icons.check_circle_outline, color: _green),
              const SizedBox(width: 8),
              _kpi('Avg Income', _currency.format(avgIncome),
                  icon: Icons.trending_up, color: _orange),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Card list
        Expanded(
          child: widget.isDirectoryLoading && data.isEmpty
              ? _loading()
              : data.isEmpty
                  ? _empty(
                      'No customers found', Icons.people_outline)
                  : RefreshIndicator(
                      color: _primary,
                      onRefresh: () async {
                        widget.onRefreshDirectory?.call();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16, 4, 16, 16),
                        itemCount: data.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == data.length) {
                            if (widget.isDirectoryLoading) {
                              return _loading();
                            }
                            return _loadMore(
                                widget.onLoadMoreDirectory);
                          }
                          return _directoryCard(data[i]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _directoryCard(Map<String, dynamic> item) {
    final risk = _int(item['risk_score']);
    final loans = _int(item['loan_count']);
    final savings = _int(item['savings_count']);
    final outstanding = _dbl(item['total_outstanding']);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          widget.onItemTap?.call(item);
          _showDetail(context, item, 'Directory');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + KYC badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item['full_name']?.toString() ?? '-',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _badge(item['kyc_status']?.toString()),
                ],
              ),
              const SizedBox(height: 8),
              // Phone + National ID
              Row(
                children: [
                  Expanded(
                    child: _iconLabel(Icons.phone_outlined,
                        item['phone_number']?.toString() ?? '-'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _iconLabel(Icons.badge_outlined,
                        item['national_id']?.toString() ?? '-'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Account number + risk score
              Row(
                children: [
                  Expanded(
                    child: _iconLabel(
                      Icons.account_balance_outlined,
                      'Acc: ${item['account_number'] ?? '-'}',
                      size: 13,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _riskColor(risk).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Risk: $risk',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _riskColor(risk),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Info chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _infoChip(Icons.receipt_long_outlined,
                      '$loans loan${loans != 1 ? 's' : ''}'),
                  _infoChip(Icons.savings_outlined,
                      '$savings saving${savings != 1 ? 's' : ''}'),
                  _infoChip(Icons.account_balance_wallet_outlined,
                      _currency.format(outstanding)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2 -- KYC
  // ---------------------------------------------------------------------------

  Widget _buildKycTab() {
    final data = widget.kycData;
    int cnt(String s) => data
        .where((d) => d['status']?.toString().toUpperCase() == s)
        .length;

    return Column(
      children: [
        const SizedBox(height: 12),
        _filterChips(
          ['ALL', 'PENDING', 'APPROVED', 'REJECTED'],
          widget.kycStatusFilter,
          widget.onKycStatusFilter,
        ),
        const SizedBox(height: 8),
        // KPIs
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _kpi('Pending', cnt('PENDING').toString(),
                  icon: Icons.hourglass_empty, color: _yellow),
              const SizedBox(width: 8),
              _kpi('Approved', cnt('APPROVED').toString(),
                  icon: Icons.check_circle_outline, color: _green),
              const SizedBox(width: 8),
              _kpi('Rejected', cnt('REJECTED').toString(),
                  icon: Icons.cancel_outlined, color: _red),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // List
        Expanded(
          child: widget.isKycLoading && data.isEmpty
              ? _loading()
              : data.isEmpty
                  ? _empty('No KYC submissions found',
                      Icons.verified_user_outlined)
                  : RefreshIndicator(
                      color: _primary,
                      onRefresh: () async {
                        widget.onRefreshKyc?.call();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16, 4, 16, 16),
                        itemCount: data.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == data.length) {
                            if (widget.isKycLoading) {
                              return _loading();
                            }
                            return _loadMore(
                                widget.onLoadMoreKyc);
                          }
                          return _kycCard(data[i]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _kycCard(Map<String, dynamic> item) {
    final reviewedAt = item['reviewed_at'];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          widget.onItemTap?.call(item);
          _showDetail(context, item, 'KYC');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item['full_name']?.toString() ?? '-',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _badge(item['status']?.toString()),
                ],
              ),
              const SizedBox(height: 8),
              // Phone
              _iconLabel(Icons.phone_outlined,
                  item['phone_number']?.toString() ?? '-'),
              const SizedBox(height: 4),
              // Email
              _iconLabel(Icons.email_outlined,
                  item['email']?.toString() ?? '-'),
              const SizedBox(height: 4),
              // National ID
              _iconLabel(Icons.badge_outlined,
                  'ID: ${item['national_id'] ?? '-'}',
                  size: 13),
              const SizedBox(height: 8),
              // Dates
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted: ${_fmtDate(item['submitted_at'])}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                  if (reviewedAt != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.check_circle_outline,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Reviewed: ${_fmtDate(reviewedAt)}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3 -- Savings
  // ---------------------------------------------------------------------------

  Widget _buildSavingsTab() {
    final data = widget.savingsData;
    final totalBal = data.fold<double>(
        0.0, (s, d) => s + _dbl(d['current_balance']));
    final totalInt = data.fold<double>(
        0.0, (s, d) => s + _dbl(d['total_interest_earned']));

    return Column(
      children: [
        const SizedBox(height: 12),
        _filterChips(
          ['ALL', 'ACTIVE', 'DORMANT', 'CLOSED'],
          widget.savingsStatusFilter,
          widget.onSavingsStatusFilter,
        ),
        const SizedBox(height: 8),
        // KPIs
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _kpi('Total Accounts', data.length.toString(),
                  icon: Icons.account_balance),
              const SizedBox(width: 8),
              _kpi('Total Balance', _currency.format(totalBal),
                  icon: Icons.savings, color: _green),
              const SizedBox(width: 8),
              _kpi('Total Interest', _currency.format(totalInt),
                  icon: Icons.trending_up, color: _orange),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // List
        Expanded(
          child: widget.isSavingsLoading && data.isEmpty
              ? _loading()
              : data.isEmpty
                  ? _empty('No savings accounts found',
                      Icons.savings_outlined)
                  : RefreshIndicator(
                      color: _primary,
                      onRefresh: () async {
                        widget.onRefreshSavings?.call();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16, 4, 16, 16),
                        itemCount: data.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == data.length) {
                            if (widget.isSavingsLoading) {
                              return _loading();
                            }
                            return _loadMore(
                                widget.onLoadMoreSavings);
                          }
                          return _savingsCard(data[i]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _savingsCard(Map<String, dynamic> item) {
    final bal = _dbl(item['current_balance']);
    final avail = _dbl(item['available_balance']);
    final dep = _dbl(item['total_deposits']);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          widget.onItemTap?.call(item);
          _showDetail(context, item, 'Savings');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account number + status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item['account_number']?.toString() ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _badge(item['status']?.toString()),
                ],
              ),
              const SizedBox(height: 6),
              // Full name
              Text(
                item['full_name']?.toString() ?? '-',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Product name
              Text(
                item['product_name']?.toString() ?? '-',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 10),
              // Balances
              Row(
                children: [
                  _balanceColumn('Current Balance',
                      _currency.format(bal),
                      bold: true, color: _primary),
                  _balanceColumn(
                      'Available', _currency.format(avail)),
                  _balanceColumn('Total Deposits',
                      _currency.format(dep),
                      color: _green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4 -- Guarantors
  // ---------------------------------------------------------------------------

  Widget _buildGuarantorsTab() {
    final data = widget.guarantorData;
    final activeCnt = data
        .where(
            (d) => d['status']?.toString().toUpperCase() == 'ACTIVE')
        .length;
    final totalAmt = data.fold<double>(
        0.0, (s, d) => s + _dbl(d['guarantee_amount']));

    return Column(
      children: [
        const SizedBox(height: 12),
        _filterChips(
          ['ALL', 'ACTIVE', 'RELEASED', 'DEFAULTED'],
          widget.guarantorStatusFilter,
          widget.onGuarantorStatusFilter,
        ),
        const SizedBox(height: 8),
        // KPIs
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _kpi('Total Guarantors', data.length.toString(),
                  icon: Icons.handshake),
              const SizedBox(width: 8),
              _kpi('Active', activeCnt.toString(),
                  icon: Icons.check_circle_outline, color: _green),
              const SizedBox(width: 8),
              _kpi('Total Guaranteed',
                  _currency.format(totalAmt),
                  icon: Icons.shield_outlined, color: _orange),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // List
        Expanded(
          child: widget.isGuarantorLoading && data.isEmpty
              ? _loading()
              : data.isEmpty
                  ? _empty('No guarantors found',
                      Icons.handshake_outlined)
                  : RefreshIndicator(
                      color: _primary,
                      onRefresh: () async {
                        widget.onRefreshGuarantors?.call();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16, 4, 16, 16),
                        itemCount: data.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == data.length) {
                            if (widget.isGuarantorLoading) {
                              return _loading();
                            }
                            return _loadMore(
                                widget.onLoadMoreGuarantors);
                          }
                          return _guarantorCard(data[i]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _guarantorCard(Map<String, dynamic> item) {
    final amt = _dbl(item['guarantee_amount']);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          widget.onItemTap?.call(item);
          _showDetail(context, item, 'Guarantors');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item['full_name']?.toString() ?? '-',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _badge(item['status']?.toString()),
                ],
              ),
              const SizedBox(height: 8),
              // Phone + guarantee amount
              Row(
                children: [
                  Expanded(
                    child: _iconLabel(Icons.phone_outlined,
                        item['phone_number']?.toString() ?? '-'),
                  ),
                  Text(
                    _currency.format(amt),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Borrower
              _iconLabel(Icons.person_outline,
                  'Borrower: ${item['borrower_name'] ?? '-'}',
                  size: 13),
              const SizedBox(height: 4),
              // Application number
              _iconLabel(Icons.receipt_outlined,
                  'App: ${item['application_number'] ?? '-'}',
                  size: 13),
              const SizedBox(height: 8),
              // Relationship chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item['relationship']?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: widget.onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                )
              : null,
          title: const Text(
            'Customer 360',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 22),
              tooltip: 'Refresh all tabs',
              onPressed: () {
                widget.onRefreshDirectory?.call();
                widget.onRefreshKyc?.call();
                widget.onRefreshSavings?.call();
                widget.onRefreshGuarantors?.call();
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            tabs: [
              Tab(
                  icon: Icon(Icons.people_outline, size: 18),
                  text: 'Directory'),
              Tab(
                  icon:
                      Icon(Icons.verified_user_outlined, size: 18),
                  text: 'KYC'),
              Tab(
                  icon: Icon(Icons.savings_outlined, size: 18),
                  text: 'Savings'),
              Tab(
                  icon: Icon(Icons.handshake_outlined, size: 18),
                  text: 'Guarantors'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDirectoryTab(),
            _buildKycTab(),
            _buildSavingsTab(),
            _buildGuarantorsTab(),
          ],
        ),
      ),
    );
  }
}
