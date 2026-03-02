import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Risk & Compliance Console — 4-tab dashboard for collections,
/// restructure/writeoff, instant loan decisions, and approval workflows.
///
/// Data sources:
///   Tab 1 Collections        — vw_retool_imfsl_collections_queue (V9)
///   Tab 2 Restructure/WO     — vw_retool_imfsl_restructure_writeoff_queue (V12)
///   Tab 3 Instant Loans      — vw_retool_imfsl_instant_loan_monitor (V13)
///   Tab 4 Approvals          — vw_retool_imfsl_approval_queue (V11)
class ImfslRiskComplianceConsole extends StatefulWidget {
  final List<Map<String, dynamic>> collectionsData;
  final List<Map<String, dynamic>> restructureData;
  final List<Map<String, dynamic>> instantLoanData;
  final List<Map<String, dynamic>> approvalsData;

  final bool isCollectionsLoading;
  final bool isRestructureLoading;
  final bool isInstantLoanLoading;
  final bool isApprovalsLoading;

  final String? collectionsParFilter;
  final String? collectionsPriorityFilter;
  final String? restructureTypeFilter;
  final String? restructureStatusFilter;
  final String? instantLoanDecisionFilter;
  final String? approvalsStatusFilter;
  final String? approvalsEntityTypeFilter;

  final Function(String?)? onCollectionsParFilter;
  final Function(String?)? onCollectionsPriorityFilter;
  final Function(String?)? onRestructureTypeFilter;
  final Function(String?)? onRestructureStatusFilter;
  final Function(String?)? onInstantLoanDecisionFilter;
  final Function(String?)? onApprovalsStatusFilter;
  final Function(String?)? onApprovalsEntityTypeFilter;

  final VoidCallback? onLoadMoreCollections;
  final VoidCallback? onLoadMoreRestructure;
  final VoidCallback? onLoadMoreInstantLoans;
  final VoidCallback? onLoadMoreApprovals;

  final VoidCallback? onRefreshCollections;
  final VoidCallback? onRefreshRestructure;
  final VoidCallback? onRefreshInstantLoans;
  final VoidCallback? onRefreshApprovals;

  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onItemTap;

  const ImfslRiskComplianceConsole({
    super.key,
    this.collectionsData = const [],
    this.restructureData = const [],
    this.instantLoanData = const [],
    this.approvalsData = const [],
    this.isCollectionsLoading = false,
    this.isRestructureLoading = false,
    this.isInstantLoanLoading = false,
    this.isApprovalsLoading = false,
    this.collectionsParFilter,
    this.collectionsPriorityFilter,
    this.onCollectionsParFilter,
    this.onCollectionsPriorityFilter,
    this.restructureTypeFilter,
    this.restructureStatusFilter,
    this.onRestructureTypeFilter,
    this.onRestructureStatusFilter,
    this.instantLoanDecisionFilter,
    this.onInstantLoanDecisionFilter,
    this.approvalsStatusFilter,
    this.approvalsEntityTypeFilter,
    this.onApprovalsStatusFilter,
    this.onApprovalsEntityTypeFilter,
    this.onLoadMoreCollections,
    this.onLoadMoreRestructure,
    this.onLoadMoreInstantLoans,
    this.onLoadMoreApprovals,
    this.onRefreshCollections,
    this.onRefreshRestructure,
    this.onRefreshInstantLoans,
    this.onRefreshApprovals,
    this.onBack,
    this.onItemTap,
  });

  @override
  State<ImfslRiskComplianceConsole> createState() =>
      _ImfslRiskComplianceConsoleState();
}

class _ImfslRiskComplianceConsoleState
    extends State<ImfslRiskComplianceConsole> {
  static const Color _primary = Color(0xFF1565C0);

  final NumberFormat _currency =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');
  final DateFormat _dateTimeFmt = DateFormat('dd MMM yyyy HH:mm');

  // ---------------------------------------------------------------------------
  // Formatting helpers
  // ---------------------------------------------------------------------------

  String _fmt(dynamic v) => v?.toString() ?? '-';

  String _fmtCurrency(dynamic v) {
    if (v == null) return '-';
    final n = v is num ? v : num.tryParse(v.toString());
    return n == null ? '-' : _currency.format(n);
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

  String _truncate(String? s, int max) {
    if (s == null) return '-';
    return s.length <= max ? s : '${s.substring(0, max)}...';
  }

  // ---------------------------------------------------------------------------
  // Color helpers
  // ---------------------------------------------------------------------------

  Color _parColor(String? par) => switch (par?.toUpperCase()) {
        'CURRENT' => Colors.green,
        'PAR_1_30' => Colors.orange,
        'PAR_31_60' => Colors.deepOrange,
        'PAR_61_90' => Colors.red,
        'PAR_90_PLUS' => Colors.red.shade900,
        _ => Colors.grey,
      };

  Color _priorityColor(String? p) => switch (p?.toUpperCase()) {
        'LOW' => Colors.green,
        'MEDIUM' => Colors.orange,
        'HIGH' => Colors.deepOrange,
        'CRITICAL' => Colors.red.shade900,
        _ => Colors.grey,
      };

  Color _statusColor(String? s) => switch (s?.toUpperCase()) {
        'APPROVED' => Colors.green,
        'REJECTED' => Colors.red,
        'PENDING' => Colors.orange,
        _ => Colors.grey,
      };

  Color _decisionColor(String? d) => switch (d?.toUpperCase()) {
        'APPROVED' => Colors.green,
        'REJECTED' => Colors.red,
        'MANUAL_REVIEW' => Colors.orange,
        _ => Colors.grey,
      };

  Color _entityTypeColor(String? e) => switch (e?.toUpperCase()) {
        'LOAN' => _primary,
        'RESTRUCTURE' => Colors.teal,
        'WRITEOFF' => Colors.red,
        _ => Colors.grey,
      };

  Color _fraudScoreColor(dynamic score) {
    if (score == null) return Colors.grey;
    final n = score is num ? score : num.tryParse(score.toString()) ?? 0;
    if (n >= 70) return Colors.red;
    if (n >= 40) return Colors.orange;
    return Colors.green;
  }

  // ---------------------------------------------------------------------------
  // Reusable UI components
  // ---------------------------------------------------------------------------

  Widget _badge(String? text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text?.toUpperCase() ?? '-',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _filterRow(List<String> options, String? current,
      Function(String?)? onChanged,
      {String allLabel = 'All'}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: options.map((o) {
            final isAll = o == 'ALL';
            final selected = (current ?? 'ALL') == o;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(
                  isAll ? allLabel : o.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 12),
                ),
                selected: selected,
                selectedColor: _primary.withOpacity(0.2),
                onSelected: (_) => onChanged?.call(isAll ? null : o),
                visualDensity: VisualDensity.compact,
                labelStyle: TextStyle(
                  color: selected ? _primary : Colors.grey.shade700,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value,
      {Color? color, IconData? icon}) {
    final c = color ?? _primary;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: c),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: c)),
          ],
        ),
      ),
    );
  }

  Widget _loadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(color: _primary),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message,
                style:
                    TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _loadMoreButton(VoidCallback? onTap) {
    if (onTap == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.expand_more, size: 18),
          label: const Text('Load More'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary),
          ),
        ),
      ),
    );
  }

  Widget _tabListView(
      bool loading,
      List<Map<String, dynamic>> data,
      String emptyMsg,
      VoidCallback? loadMore,
      Widget Function(Map<String, dynamic>) cardBuilder) {
    if (loading && data.isEmpty) return _loadingIndicator();
    if (data.isEmpty) return _emptyState(emptyMsg);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: data.length + 1,
      itemBuilder: (_, i) {
        if (i == data.length) {
          return loading ? _loadingIndicator() : _loadMoreButton(loadMore);
        }
        return cardBuilder(data[i]);
      },
    );
  }

  // Detail sheet helpers
  void _showDetailSheet(List<Widget> children) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: children,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
          ),
          Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _detailSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: _primary)),
    );
  }

  Widget _checkIcon(dynamic passed) {
    final ok = passed == true || passed == 'true' || passed == 1;
    return Icon(ok ? Icons.check_circle : Icons.cancel,
        size: 18, color: ok ? Colors.green : Colors.red);
  }

  String _boolLabel(dynamic v) {
    if (v == null) return '-';
    return (v == true || v == 'true' || v == 1) ? 'PASSED' : 'FAILED';
  }

  Widget _checkColumn(String label, dynamic passed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _checkIcon(passed),
        const SizedBox(height: 2),
        Text(label,
            style:
                TextStyle(fontSize: 9, color: Colors.grey.shade600)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1 — Collections
  // ---------------------------------------------------------------------------

  Widget _buildCollectionsTab() {
    final data = widget.collectionsData;

    // KPI calculations
    final totalOverdue =
        data.where((r) => (r['par_bucket'] ?? '') != 'CURRENT').length;
    final criticalCount = data
        .where((r) =>
            r['collection_priority']?.toString().toUpperCase() ==
            'CRITICAL')
        .length;
    double totalOutstanding = 0;
    for (final r in data) {
      final v = r['outstanding_balance'];
      if (v != null) {
        totalOutstanding +=
            (v is num ? v : num.tryParse(v.toString()) ?? 0);
      }
    }

    return Column(children: [
      // KPI row
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Row(children: [
          _kpiCard('Total Overdue', '$totalOverdue',
              color: Colors.deepOrange,
              icon: Icons.warning_amber_rounded),
          _kpiCard('Critical', '$criticalCount',
              color: Colors.red.shade900, icon: Icons.priority_high),
          _kpiCard('Outstanding', _fmtCurrency(totalOutstanding),
              icon: Icons.account_balance_wallet),
        ]),
      ),
      // PAR bucket filter
      _filterRow(
        ['ALL', 'CURRENT', 'PAR_1_30', 'PAR_31_60', 'PAR_61_90', 'PAR_90_PLUS'],
        widget.collectionsParFilter,
        widget.onCollectionsParFilter,
        allLabel: 'All PAR',
      ),
      // Priority filter
      _filterRow(
        ['ALL', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
        widget.collectionsPriorityFilter,
        widget.onCollectionsPriorityFilter,
        allLabel: 'All Priority',
      ),
      // Card list
      Expanded(
        child: _tabListView(
          widget.isCollectionsLoading,
          data,
          'No collection actions found',
          widget.onLoadMoreCollections,
          _buildCollectionCard,
        ),
      ),
    ]);
  }

  Widget _buildCollectionCard(Map<String, dynamic> r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          widget.onItemTap?.call(r);
          _showCollectionDetail(r);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + PAR badge
              Row(children: [
                Expanded(
                  child: Text(_fmt(r['full_name']),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                _badge(r['par_bucket']?.toString(),
                    _parColor(r['par_bucket']?.toString())),
              ]),
              const SizedBox(height: 6),
              // Loan number + priority badge
              Row(children: [
                Icon(Icons.receipt_long,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(_fmt(r['loan_number']),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
                const Spacer(),
                _badge(r['collection_priority']?.toString(),
                    _priorityColor(r['collection_priority']?.toString())),
              ]),
              const Divider(height: 16),
              // Outstanding + days in arrears
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Outstanding',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                      Text(_fmtCurrency(r['outstanding_balance']),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Days in Arrears',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                      Text('${_fmt(r['days_in_arrears'])} days',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _parColor(
                                  r['par_bucket']?.toString()))),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              // Collector
              Row(children: [
                Icon(Icons.person_outline,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('Collector: ${_fmt(r['collector_name'])}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ]),
              const SizedBox(height: 4),
              // Action + next action date
              Row(children: [
                Icon(Icons.play_arrow,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('Action: ${_fmt(r['action_type'])}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
                const Spacer(),
                if (r['next_action_date'] != null) ...[
                  Icon(Icons.event,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text('Next: ${_fmtDate(r['next_action_date'])}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showCollectionDetail(Map<String, dynamic> r) {
    _showDetailSheet([
      _detailSection('Collection Detail'),
      _detailRow('Loan Number', _fmt(r['loan_number'])),
      _detailRow('Customer', _fmt(r['full_name'])),
      _detailRow('Phone', _fmt(r['phone_number'])),
      _detailRow('Outstanding', _fmtCurrency(r['outstanding_balance'])),
      _detailRow('Days in Arrears', _fmt(r['days_in_arrears'])),
      _detailRow('PAR Bucket', _fmt(r['par_bucket'])),
      _detailRow('Priority', _fmt(r['collection_priority'])),
      const Divider(),
      _detailSection('Action Details'),
      _detailRow('Action Type', _fmt(r['action_type'])),
      _detailRow('Outcome', _fmt(r['outcome'])),
      _detailRow('Notes', _fmt(r['notes'])),
      _detailRow('Promise Amount', _fmtCurrency(r['promise_amount'])),
      _detailRow('Promise Date', _fmtDate(r['promise_date'])),
      _detailRow('Next Action', _fmt(r['next_action_type'])),
      _detailRow('Next Action Date', _fmtDate(r['next_action_date'])),
      const Divider(),
      _detailSection('Assignment'),
      _detailRow('Collector', _fmt(r['collector_name'])),
      _detailRow('Created At', _fmtDateTime(r['created_at'])),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Tab 2 — Restructure / Writeoff
  // ---------------------------------------------------------------------------

  Widget _buildRestructureTab() {
    final data = widget.restructureData;
    return Column(children: [
      // Type filter
      _filterRow(
        ['ALL', 'RESTRUCTURE', 'WRITEOFF'],
        widget.restructureTypeFilter,
        widget.onRestructureTypeFilter,
        allLabel: 'All Types',
      ),
      // Status filter
      _filterRow(
        ['ALL', 'PENDING', 'APPROVED', 'REJECTED'],
        widget.restructureStatusFilter,
        widget.onRestructureStatusFilter,
        allLabel: 'All Status',
      ),
      // Card list
      Expanded(
        child: _tabListView(
          widget.isRestructureLoading,
          data,
          'No restructure or writeoff records found',
          widget.onLoadMoreRestructure,
          _buildRestructureCard,
        ),
      ),
    ]);
  }

  Widget _buildRestructureCard(Map<String, dynamic> r) {
    final queueType = r['queue_type']?.toString().toUpperCase() ?? '';
    final isWriteoff = queueType == 'WRITEOFF';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          widget.onItemTap?.call(r);
          _showRestructureDetail(r);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Queue type badge + name + status badge
              Row(children: [
                _badge(queueType, isWriteoff ? Colors.red : _primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_fmt(r['full_name']),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                _badge(r['status']?.toString(),
                    _statusColor(r['status']?.toString())),
              ]),
              const SizedBox(height: 8),
              // Loan number + outstanding
              Row(children: [
                Icon(Icons.receipt_long,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(_fmt(r['loan_number']),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
                const Spacer(),
                Text('Outstanding: ${_fmtCurrency(r['outstanding_balance'])}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
              const Divider(height: 16),
              // Writeoff amount or restructure type
              if (isWriteoff)
                Row(children: [
                  Text('Writeoff Amount: ',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                  Text(_fmtCurrency(r['writeoff_amount']),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.red)),
                ])
              else
                Row(children: [
                  Text('Restructure Type: ',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                  Text(_fmt(r['restructure_type']),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              const SizedBox(height: 6),
              // Reason (truncated)
              Text(
                'Reason: ${_truncate(r['reason']?.toString(), 80)}',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text('Created: ${_fmtDateTime(r['created_at'])}',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestructureDetail(Map<String, dynamic> r) {
    final isWriteoff =
        r['queue_type']?.toString().toUpperCase() == 'WRITEOFF';

    String formatTerms(dynamic terms) {
      if (terms == null) return '-';
      if (terms is Map) {
        return terms.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('\n');
      }
      return terms.toString();
    }

    _showDetailSheet([
      _detailSection(
          isWriteoff ? 'Writeoff Detail' : 'Restructure Detail'),
      _detailRow('Queue Type', _fmt(r['queue_type'])),
      _detailRow('Status', _fmt(r['status'])),
      _detailRow('Customer', _fmt(r['full_name'])),
      _detailRow('Phone', _fmt(r['phone_number'])),
      _detailRow('Loan Number', _fmt(r['loan_number'])),
      _detailRow('Outstanding', _fmtCurrency(r['outstanding_balance'])),
      const Divider(),
      if (isWriteoff) ...[
        _detailSection('Writeoff Details'),
        _detailRow(
            'Writeoff Amount', _fmtCurrency(r['writeoff_amount'])),
        _detailRow(
            'Provision Amount', _fmtCurrency(r['provision_amount'])),
      ] else ...[
        _detailSection('Restructure Details'),
        _detailRow('Restructure Type', _fmt(r['restructure_type'])),
        _detailRow('Original Terms', formatTerms(r['original_terms'])),
        _detailRow('New Terms', formatTerms(r['new_terms'])),
      ],
      _detailRow('Reason', _fmt(r['reason'])),
      const Divider(),
      _detailRow('Created At', _fmtDateTime(r['created_at'])),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Tab 3 — Instant Loans
  // ---------------------------------------------------------------------------

  Widget _buildInstantLoansTab() {
    final data = widget.instantLoanData;

    // KPI calculations
    final totalCount = data.length;
    final approvedCount = data
        .where((r) =>
            r['decision']?.toString().toUpperCase() == 'APPROVED')
        .length;
    final approvalRate =
        totalCount > 0 ? (approvedCount / totalCount * 100) : 0.0;

    double totalProcessingMs = 0;
    int processingCount = 0;
    for (final r in data) {
      final v = r['processing_time_ms'];
      if (v != null) {
        totalProcessingMs +=
            (v is num ? v : num.tryParse(v.toString()) ?? 0);
        processingCount++;
      }
    }
    final avgProcessingMs = processingCount > 0
        ? (totalProcessingMs / processingCount).round()
        : 0;

    return Column(children: [
      // KPI row
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Row(children: [
          _kpiCard('Total', '$totalCount', icon: Icons.flash_on),
          _kpiCard('Approval Rate',
              '${approvalRate.toStringAsFixed(1)}%',
              color: Colors.green, icon: Icons.trending_up),
          _kpiCard('Avg Time', '${avgProcessingMs}ms',
              color: Colors.teal, icon: Icons.speed),
        ]),
      ),
      // Decision filter
      _filterRow(
        ['ALL', 'APPROVED', 'REJECTED', 'MANUAL_REVIEW'],
        widget.instantLoanDecisionFilter,
        widget.onInstantLoanDecisionFilter,
        allLabel: 'All Decisions',
      ),
      // Card list
      Expanded(
        child: _tabListView(
          widget.isInstantLoanLoading,
          data,
          'No instant loan decisions found',
          widget.onLoadMoreInstantLoans,
          _buildInstantLoanCard,
        ),
      ),
    ]);
  }

  Widget _buildInstantLoanCard(Map<String, dynamic> r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          widget.onItemTap?.call(r);
          _showInstantLoanDetail(r);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + decision badge
              Row(children: [
                Expanded(
                  child: Text(_fmt(r['full_name']),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                _badge(r['decision']?.toString(),
                    _decisionColor(r['decision']?.toString())),
              ]),
              const SizedBox(height: 6),
              // Application number + risk category
              Row(children: [
                Icon(Icons.confirmation_number,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(_fmt(r['application_number']),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
                const Spacer(),
                if (r['risk_category'] != null)
                  _badge(
                      r['risk_category']?.toString(), Colors.blueGrey),
              ]),
              const Divider(height: 16),
              // Credit score, fraud score, processing time
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Credit Score',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                      Text(_fmt(r['credit_score']),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fraud Score',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                      Text(_fmt(r['fraud_score']),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _fraudScoreColor(
                                  r['fraud_score']))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                      Text('${_fmt(r['processing_time_ms'])}ms',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              // 6 check icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _checkColumn('Credit', r['check_credit_passed']),
                  _checkColumn(
                      'Velocity', r['check_fraud_velocity_passed']),
                  _checkColumn('Fraud', r['check_fraud_scan_passed']),
                  _checkColumn(
                      'Eligible', r['check_eligibility_passed']),
                  _checkColumn(
                      'Device', r['check_device_trust_passed']),
                  _checkColumn('Amount', r['check_amount_passed']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstantLoanDetail(Map<String, dynamic> r) {
    _showDetailSheet([
      _detailSection('Instant Loan Decision'),
      _detailRow('Customer', _fmt(r['full_name'])),
      _detailRow('Phone', _fmt(r['phone_number'])),
      _detailRow('Application', _fmt(r['application_number'])),
      _detailRow('Decision', _fmt(r['decision'])),
      _detailRow('Decision Reason', _fmt(r['decision_reason'])),
      const Divider(),
      _detailSection('Risk Assessment'),
      _detailRow('Credit Score', _fmt(r['credit_score'])),
      _detailRow('Risk Category', _fmt(r['risk_category'])),
      _detailRow('Fraud Score', _fmt(r['fraud_score'])),
      _detailRow('OTP Required', _fmt(r['otp_required'])),
      _detailRow(
          'Processing Time', '${_fmt(r['processing_time_ms'])}ms'),
      const Divider(),
      _detailSection('Decision Checks'),
      _detailRow('Credit Check', _boolLabel(r['check_credit_passed'])),
      _detailRow('Fraud Velocity',
          _boolLabel(r['check_fraud_velocity_passed'])),
      _detailRow(
          'Fraud Scan', _boolLabel(r['check_fraud_scan_passed'])),
      _detailRow(
          'Eligibility', _boolLabel(r['check_eligibility_passed'])),
      _detailRow(
          'Device Trust', _boolLabel(r['check_device_trust_passed'])),
      _detailRow(
          'Amount Check', _boolLabel(r['check_amount_passed'])),
      const Divider(),
      _detailSection('Device Information'),
      _detailRow('Device Name', _fmt(r['device_name'])),
      _detailRow('Platform', _fmt(r['platform'])),
      _detailRow('Fingerprint', _fmt(r['fingerprint'])),
      _detailRow('Is Trusted', _boolLabel(r['is_trusted'])),
      _detailRow('Trust Level', _fmt(r['trust_level'])),
      const Divider(),
      _detailSection('Additional'),
      _detailRow('Fraud Flags', _fmt(r['fraud_flags'])),
      _detailRow(
          'Approval Conditions', _fmt(r['approval_conditions'])),
      _detailRow('Decided At', _fmtDateTime(r['decided_at'])),
      _detailRow('Created At', _fmtDateTime(r['created_at'])),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Tab 4 — Approvals
  // ---------------------------------------------------------------------------

  Widget _buildApprovalsTab() {
    final data = widget.approvalsData;

    // KPIs — pending counts by entity type
    int pendingCount(String entityType) => data
        .where((r) =>
            r['status']?.toString().toUpperCase() == 'PENDING' &&
            r['entity_type']?.toString().toUpperCase() == entityType)
        .length;

    return Column(children: [
      // KPI row
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Row(children: [
          _kpiCard('Pending Loans', '${pendingCount('LOAN')}',
              icon: Icons.account_balance),
          _kpiCard(
              'Pending Restruct.', '${pendingCount('RESTRUCTURE')}',
              color: Colors.teal, icon: Icons.build_circle),
          _kpiCard('Pending W/O', '${pendingCount('WRITEOFF')}',
              color: Colors.red, icon: Icons.delete_sweep),
        ]),
      ),
      // Status filter
      _filterRow(
        ['ALL', 'PENDING', 'APPROVED', 'REJECTED'],
        widget.approvalsStatusFilter,
        widget.onApprovalsStatusFilter,
        allLabel: 'All Status',
      ),
      // Entity type filter
      _filterRow(
        ['ALL', 'LOAN', 'RESTRUCTURE', 'WRITEOFF'],
        widget.approvalsEntityTypeFilter,
        widget.onApprovalsEntityTypeFilter,
        allLabel: 'All Types',
      ),
      // Card list
      Expanded(
        child: _tabListView(
          widget.isApprovalsLoading,
          data,
          'No approval steps found',
          widget.onLoadMoreApprovals,
          _buildApprovalCard,
        ),
      ),
    ]);
  }

  Widget _buildApprovalCard(Map<String, dynamic> r) {
    final stepNum = r['step_number'] ?? 0;
    final totalSteps = r['total_steps'] ?? 1;
    final progress = (totalSteps is num && totalSteps > 0)
        ? ((stepNum is num ? stepNum : 0) / totalSteps)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          widget.onItemTap?.call(r);
          _showApprovalDetail(r);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entity type badge + step label + status badge
              Row(children: [
                _badge(r['entity_type']?.toString(),
                    _entityTypeColor(r['entity_type']?.toString())),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Step $stepNum of $totalSteps',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                _badge(r['status']?.toString(),
                    _statusColor(r['status']?.toString())),
              ]),
              const SizedBox(height: 10),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.toDouble().clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                      _statusColor(r['status']?.toString())),
                ),
              ),
              const SizedBox(height: 10),
              // Required role + reviewer
              Row(children: [
                Icon(Icons.security,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('Required: ${_fmt(r['required_min_role'])}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
                const Spacer(),
                if (r['reviewer_name'] != null) ...[
                  Icon(Icons.person,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(_fmt(r['reviewer_name']),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ]),
              // Approved amount (if present)
              if (r['approved_amount'] != null) ...[
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.monetization_on,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                      'Amount: ${_fmtCurrency(r['approved_amount'])}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ],
              const SizedBox(height: 6),
              // Rule description (truncated)
              Text(
                _truncate(r['rule_description']?.toString(), 80),
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApprovalDetail(Map<String, dynamic> r) {
    _showDetailSheet([
      _detailSection('Approval Step Detail'),
      _detailRow('Entity Type', _fmt(r['entity_type'])),
      _detailRow('Entity ID', _fmt(r['entity_id'])),
      _detailRow('Step',
          '${_fmt(r['step_number'])} of ${_fmt(r['total_steps'])}'),
      _detailRow('Status', _fmt(r['status'])),
      _detailRow(
          'Required Min Role', _fmt(r['required_min_role'])),
      const Divider(),
      _detailSection('Reviewer'),
      _detailRow('Reviewer Name', _fmt(r['reviewer_name'])),
      _detailRow('Reviewer Role', _fmt(r['reviewer_role'])),
      _detailRow(
          'Approved Amount', _fmtCurrency(r['approved_amount'])),
      _detailRow('Comments', _fmt(r['comments'])),
      _detailRow('Reviewed At', _fmtDateTime(r['reviewed_at'])),
      const Divider(),
      _detailSection('Rule Configuration'),
      _detailRow(
          'Rule Description', _fmt(r['rule_description'])),
      _detailRow(
          'Rule Entity Type', _fmt(r['rule_entity_type'])),
      _detailRow('Min Amount', _fmtCurrency(r['min_amount'])),
      _detailRow('Max Amount', _fmtCurrency(r['max_amount'])),
      _detailRow(
          'Risk Category', _fmt(r['rule_risk_category'])),
      _detailRow(
          'Required Levels', _fmt(r['required_levels'])),
      _detailRow('Rule Priority', _fmt(r['rule_priority'])),
      const Divider(),
      _detailRow('Created At', _fmtDateTime(r['created_at'])),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
          title: const Text('Risk & Compliance',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          actions: [
            _RefreshTabAction(
              onRefreshCollections: widget.onRefreshCollections,
              onRefreshRestructure: widget.onRefreshRestructure,
              onRefreshInstantLoans: widget.onRefreshInstantLoans,
              onRefreshApprovals: widget.onRefreshApprovals,
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 13),
            tabs: [
              Tab(
                  icon: Icon(Icons.collections_bookmark, size: 18),
                  text: 'Collections'),
              Tab(
                  icon: Icon(Icons.swap_horiz, size: 18),
                  text: 'Restructure'),
              Tab(
                  icon: Icon(Icons.flash_on, size: 18),
                  text: 'Instant Loans'),
              Tab(
                  icon: Icon(Icons.approval, size: 18),
                  text: 'Approvals'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCollectionsTab(),
            _buildRestructureTab(),
            _buildInstantLoansTab(),
            _buildApprovalsTab(),
          ],
        ),
      ),
    );
  }
}

/// Helper widget that listens to DefaultTabController to show the correct
/// refresh button for the currently active tab.
class _RefreshTabAction extends StatefulWidget {
  final VoidCallback? onRefreshCollections;
  final VoidCallback? onRefreshRestructure;
  final VoidCallback? onRefreshInstantLoans;
  final VoidCallback? onRefreshApprovals;

  const _RefreshTabAction({
    this.onRefreshCollections,
    this.onRefreshRestructure,
    this.onRefreshInstantLoans,
    this.onRefreshApprovals,
  });

  @override
  State<_RefreshTabAction> createState() => _RefreshTabActionState();
}

class _RefreshTabActionState extends State<_RefreshTabAction> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.of(context);
    controller.addListener(_onTabChanged);
    _currentIndex = controller.index;
  }

  void _onTabChanged() {
    final controller = DefaultTabController.of(context);
    if (mounted && controller.index != _currentIndex) {
      setState(() => _currentIndex = controller.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final callback = switch (_currentIndex) {
      0 => widget.onRefreshCollections,
      1 => widget.onRefreshRestructure,
      2 => widget.onRefreshInstantLoans,
      3 => widget.onRefreshApprovals,
      _ => null,
    };
    if (callback == null) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.refresh, size: 22),
      onPressed: callback,
      tooltip: 'Refresh',
      color: Colors.white,
    );
  }
}
