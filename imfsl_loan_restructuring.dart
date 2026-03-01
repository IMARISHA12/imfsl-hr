import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL Loan Restructuring and Write-Off Management.
///
/// Manages restructure queue, write-off queue, recovery recording,
/// and completed history for loan portfolio management.
class ImfslLoanRestructuring extends StatefulWidget {
  final Map<String, dynamic> queueData;
  final bool isLoading;
  final Function(Map<String, dynamic>)? onApproveRestructure;
  final Function(Map<String, dynamic>)? onRejectRestructure;
  final Function(Map<String, dynamic>)? onApproveWriteoff;
  final Function(Map<String, dynamic>)? onRejectWriteoff;
  final Function(Map<String, dynamic>)? onRecordRecovery;
  final Function(Map<String, dynamic>)? onRequestRestructure;
  final Function(Map<String, dynamic>)? onRequestWriteoff;
  final VoidCallback? onRefresh;

  const ImfslLoanRestructuring({
    super.key,
    this.queueData = const {},
    this.isLoading = false,
    this.onApproveRestructure,
    this.onRejectRestructure,
    this.onApproveWriteoff,
    this.onRejectWriteoff,
    this.onRecordRecovery,
    this.onRequestRestructure,
    this.onRequestWriteoff,
    this.onRefresh,
  });

  @override
  State<ImfslLoanRestructuring> createState() =>
      _ImfslLoanRestructuringState();
}

class _ImfslLoanRestructuringState extends State<ImfslLoanRestructuring> {
  static const Color _primary = Color(0xFF1565C0);

  final NumberFormat _kes =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');
  final DateFormat _dateTimeFmt = DateFormat('dd MMM yyyy HH:mm');

  String _activeTab = 'restructure';
  String _completedFilter = 'ALL';

  // Restructure dialog state
  String _restructureType = 'TERM_EXTENSION';
  final TextEditingController _newTenureCtrl = TextEditingController();
  final TextEditingController _newRateCtrl = TextEditingController();
  final TextEditingController _newAmountCtrl = TextEditingController();
  final TextEditingController _restructureReasonCtrl =
      TextEditingController();

  // Write-off dialog state
  final TextEditingController _writeoffReasonCtrl = TextEditingController();

  // Recovery state
  final TextEditingController _recoveryAmountCtrl = TextEditingController();
  final TextEditingController _recoveryRefCtrl = TextEditingController();

  static const Map<String, String> _restructureTypes = {
    'TERM_EXTENSION': 'Term Extension',
    'RATE_REDUCTION': 'Rate Reduction',
    'PRINCIPAL_RESCHEDULE': 'Principal Reschedule',
  };

  static const Map<String, Color> _restructureTypeColors = {
    'TERM_EXTENSION': Color(0xFF1565C0),
    'RATE_REDUCTION': Color(0xFF43A047),
    'PRINCIPAL_RESCHEDULE': Color(0xFFFF8F00),
  };

  static const Map<String, IconData> _restructureTypeIcons = {
    'TERM_EXTENSION': Icons.schedule,
    'RATE_REDUCTION': Icons.trending_down,
    'PRINCIPAL_RESCHEDULE': Icons.account_balance_wallet,
  };

  // ---------------------------------------------------------------------------
  // Data helpers
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> get _restructureQueue =>
      (widget.queueData['restructure_queue'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> get _writeoffQueue =>
      (widget.queueData['writeoff_queue'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> get _completedList {
    final raw =
        (widget.queueData['completed'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];
    if (_completedFilter == 'ALL') return raw;
    return raw
        .where((c) => c['type']?.toString() == _completedFilter)
        .toList();
  }

  List<Map<String, dynamic>> get _writtenOffLoans =>
      (widget.queueData['written_off_loans'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  Map<String, dynamic> get _kpi =>
      widget.queueData['kpi'] as Map<String, dynamic>? ?? {};

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Loan Restructuring'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.isLoading ? null : widget.onRefresh,
          ),
        ],
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTabSelector(),
                Expanded(child: _buildBody()),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab selector
  // ---------------------------------------------------------------------------

  Widget _buildTabSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'restructure',
                  label: const Text('Restructure'),
                  icon: Badge(
                    isLabelVisible: _restructureQueue.isNotEmpty,
                    label: Text('${_restructureQueue.length}',
                        style: const TextStyle(fontSize: 9)),
                    child: const Icon(Icons.build, size: 18),
                  ),
                ),
                ButtonSegment(
                  value: 'writeoff',
                  label: const Text('Write-Off'),
                  icon: Badge(
                    isLabelVisible: _writeoffQueue.isNotEmpty,
                    label: Text('${_writeoffQueue.length}',
                        style: const TextStyle(fontSize: 9)),
                    child: const Icon(Icons.delete_forever, size: 18),
                  ),
                ),
                const ButtonSegment(
                  value: 'completed',
                  label: Text('Completed'),
                  icon: Icon(Icons.check_circle, size: 18),
                ),
              ],
              selected: {_activeTab},
              onSelectionChanged: (s) =>
                  setState(() => _activeTab = s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: _primary,
                selectedForegroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_activeTab) {
      case 'restructure':
        return _buildRestructureQueue();
      case 'writeoff':
        return _buildWriteoffQueue();
      case 'completed':
        return _buildCompletedList();
      default:
        return const SizedBox();
    }
  }

  // ---------------------------------------------------------------------------
  // Restructure Queue
  // ---------------------------------------------------------------------------

  Widget _buildRestructureQueue() {
    final queue = _restructureQueue;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildKPIRow(),
        const SizedBox(height: 12),
        _sectionHeader(
            'Restructure Queue (${queue.length})'),
        const SizedBox(height: 8),
        if (queue.isEmpty)
          _emptyState('No pending restructure requests')
        else
          ...queue.map(_buildRestructureCard),
      ],
    );
  }

  Widget _buildKPIRow() {
    return Row(
      children: [
        Expanded(
          child: _miniKpiCard(
            'Pending Restructures',
            '${_kpi['pending_restructures'] ?? _restructureQueue.length}',
            const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _miniKpiCard(
            'Pending Write-offs',
            '${_kpi['pending_writeoffs'] ?? _writeoffQueue.length}',
            const Color(0xFFE53935),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _miniKpiCard(
            'Completed (Month)',
            '${_kpi['completed_month'] ?? 0}',
            const Color(0xFF43A047),
          ),
        ),
      ],
    );
  }

  Widget _miniKpiCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 9, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRestructureCard(Map<String, dynamic> item) {
    final type = item['restructure_type']?.toString() ?? 'TERM_EXTENSION';
    final typeColor =
        _restructureTypeColors[type] ?? _primary;
    final typeIcon =
        _restructureTypeIcons[type] ?? Icons.build;
    final typeLabel =
        _restructureTypes[type] ?? type;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: typeColor.withOpacity(0.1),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          item['customer_name']?.toString() ?? 'Unknown',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                          'Loan# ${item['loan_number'] ?? '-'}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(typeLabel,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: typeColor)),
                ),
              ],
            ),
            const Divider(height: 20),

            // Original terms
            const Text('Original Terms',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _termStat('Principal',
                    _kes.format((item['original_principal'] as num?)?.toDouble() ?? 0)),
                _termStat('Rate',
                    '${(item['original_rate'] as num?)?.toDouble() ?? 0}%'),
                _termStat('Tenure',
                    '${item['original_tenure'] ?? 0} months'),
              ],
            ),
            const SizedBox(height: 8),

            // Proposed terms
            const Text('Proposed Terms',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0))),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _termStat('Principal',
                    _kes.format((item['proposed_principal'] as num?)?.toDouble() ?? 0)),
                _termStat('Rate',
                    '${(item['proposed_rate'] as num?)?.toDouble() ?? 0}%'),
                _termStat('Tenure',
                    '${item['proposed_tenure'] ?? 0} months'),
              ],
            ),
            if (item['reason'] != null) ...[
              const SizedBox(height: 8),
              Text('Reason: ${item['reason']}',
                  style: const TextStyle(
                      fontSize: 11, fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(item, 'restructure'),
                  icon: const Icon(Icons.close, size: 16,
                      color: Color(0xFFE53935)),
                  label: const Text('Reject',
                      style: TextStyle(color: Color(0xFFE53935))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE53935)),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () =>
                      widget.onApproveRestructure?.call(item),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve'),
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _termStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Write-Off Queue
  // ---------------------------------------------------------------------------

  Widget _buildWriteoffQueue() {
    final queue = _writeoffQueue;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildKPIRow(),
        const SizedBox(height: 12),
        _sectionHeader('Write-Off Queue (${queue.length})'),
        const SizedBox(height: 8),
        if (queue.isEmpty)
          _emptyState('No pending write-off requests')
        else
          ...queue.map(_buildWriteoffCard),
        const SizedBox(height: 24),
        _sectionHeader('Recovery on Written-Off Loans'),
        const SizedBox(height: 8),
        _buildRecoverySection(),
      ],
    );
  }

  Widget _buildWriteoffCard(Map<String, dynamic> item) {
    final outstanding =
        (item['outstanding_balance'] as num?)?.toDouble() ?? 0;
    final daysInArrears = item['days_in_arrears'] ?? 0;
    final provision =
        (item['provision_amount'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE53935).withOpacity(0.1),
                  child: const Icon(Icons.delete_forever,
                      color: Color(0xFFE53935), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          item['customer_name']?.toString() ?? 'Unknown',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                          'Loan# ${item['loan_number'] ?? '-'}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$daysInArrears days',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE53935))),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _termStat('Outstanding', _kes.format(outstanding)),
                _termStat('Provision', _kes.format(provision)),
                _termStat('Coverage',
                    '${outstanding > 0 ? ((provision / outstanding) * 100).toStringAsFixed(0) : 0}%'),
              ],
            ),
            const SizedBox(height: 12),

            // Journal entry preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Journal Entry Preview',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Expanded(
                          flex: 4,
                          child: Text('DR 1390 - Loan Write-Off',
                              style: TextStyle(fontSize: 11))),
                      Expanded(
                          flex: 3,
                          child: Text(_kes.format(outstanding),
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 11))),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                          flex: 4,
                          child: Text('CR 1300 - Loan Portfolio',
                              style: TextStyle(fontSize: 11))),
                      Expanded(
                          flex: 3,
                          child: Text(_kes.format(outstanding),
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 11))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(item, 'writeoff'),
                  icon: const Icon(Icons.close, size: 16,
                      color: Color(0xFFE53935)),
                  label: const Text('Reject',
                      style: TextStyle(color: Color(0xFFE53935))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE53935)),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _showWriteoffConfirmDialog(item),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve Write-Off'),
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Recovery section
  // ---------------------------------------------------------------------------

  Widget _buildRecoverySection() {
    final loans = _writtenOffLoans;

    if (loans.isEmpty) {
      return _emptyState('No written-off loans with recovery option');
    }

    return Column(
      children: loans.map((loan) => _buildRecoveryCard(loan)).toList(),
    );
  }

  Widget _buildRecoveryCard(Map<String, dynamic> loan) {
    final outstanding =
        (loan['outstanding'] as num?)?.toDouble() ?? 0;
    final recovered =
        (loan['recovered'] as num?)?.toDouble() ?? 0;
    final remaining = outstanding - recovered;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF43A047).withOpacity(0.1),
                  child: const Icon(Icons.replay,
                      color: Color(0xFF43A047), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          loan['customer_name']?.toString() ?? 'Unknown',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                          'Loan# ${loan['loan_number'] ?? '-'}  |  Written off: ${_formatDate(loan['writeoff_date']?.toString())}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _termStat('Written Off', _kes.format(outstanding)),
                _termStat('Recovered', _kes.format(recovered)),
                _termStat('Remaining', _kes.format(remaining)),
              ],
            ),
            if (remaining > 0) ...[
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _recoveryAmountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _recoveryRefCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Reference',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final amount = double.tryParse(
                          _recoveryAmountCtrl.text);
                      if (amount == null || amount <= 0) return;
                      widget.onRecordRecovery?.call({
                        'loan_id': loan['loan_id'],
                        'amount': amount,
                        'reference': _recoveryRefCtrl.text,
                      });
                      _recoveryAmountCtrl.clear();
                      _recoveryRefCtrl.clear();
                    },
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047)),
                    child: const Text('Record'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Completed list
  // ---------------------------------------------------------------------------

  Widget _buildCompletedList() {
    final list = _completedList;

    return Column(
      children: [
        _buildCompletedFilter(),
        Expanded(
          child: list.isEmpty
              ? _emptyState('No completed items')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) =>
                      _buildCompletedCard(list[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildCompletedFilter() {
    const filters = ['ALL', 'RESTRUCTURE', 'WRITEOFF'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: filters.map((f) {
          final selected = _completedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(f,
                  style: TextStyle(
                      fontSize: 11,
                      color: selected
                          ? Colors.white
                          : Colors.black87)),
              selected: selected,
              selectedColor: _primary,
              checkmarkColor: Colors.white,
              onSelected: (_) =>
                  setState(() => _completedFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompletedCard(Map<String, dynamic> item) {
    final type = item['type']?.toString() ?? 'RESTRUCTURE';
    final isRestructure = type == 'RESTRUCTURE';
    final color =
        isRestructure ? const Color(0xFF1565C0) : const Color(0xFFE53935);
    final icon = isRestructure ? Icons.build : Icons.delete_forever;
    final outcome = item['outcome']?.toString() ?? 'APPROVED';

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
            item['customer_name']?.toString() ?? 'Unknown',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan# ${item['loan_number'] ?? '-'}  |  ${_kes.format((item['amount'] as num?)?.toDouble() ?? 0)}',
              style: const TextStyle(fontSize: 11),
            ),
            Text(
              '${_formatDate(item['completed_at']?.toString())}  |  $outcome',
              style:
                  const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(type,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ),
        isThreeLine: true,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _showRejectDialog(Map<String, dynamic> item, String type) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject ${type == 'restructure' ? 'Restructure' : 'Write-Off'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reject ${type == 'restructure' ? 'restructure' : 'write-off'} for ${item['customer_name'] ?? 'Unknown'}?',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final data = {
                ...item,
                'reject_reason': reasonCtrl.text,
              };
              if (type == 'restructure') {
                widget.onRejectRestructure?.call(data);
              } else {
                widget.onRejectWriteoff?.call(data);
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showWriteoffConfirmDialog(Map<String, dynamic> item) {
    final outstanding =
        (item['outstanding_balance'] as num?)?.toDouble() ?? 0;
    _writeoffReasonCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Write-Off'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write off loan for ${item['customer_name'] ?? 'Unknown'}?',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text('Write-Off Amount',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey)),
                    Text(_kes.format(outstanding),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE53935))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Journal Entry',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    _journalRow('DR', '1390', 'Loan Write-Off Expense',
                        outstanding),
                    _journalRow(
                        'CR', '1300', 'Loan Portfolio', outstanding),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _writeoffReasonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for write-off',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              widget.onApproveWriteoff?.call({
                ...item,
                'writeoff_reason': _writeoffReasonCtrl.text,
              });
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            child: const Text('Confirm Write-Off'),
          ),
        ],
      ),
    );
  }

  Widget _journalRow(
      String dr, String code, String name, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 24,
            alignment: Alignment.center,
            child: Text(dr,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: dr == 'DR'
                        ? const Color(0xFF1565C0)
                        : const Color(0xFFE53935))),
          ),
          const SizedBox(width: 4),
          Text('$code - $name',
              style: const TextStyle(fontSize: 11)),
          const Spacer(),
          Text(_kes.format(amount),
              style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  void _showRestructureDialog(Map<String, dynamic> loan) {
    _restructureType = 'TERM_EXTENSION';
    _newTenureCtrl.text =
        (loan['tenure_months'] ?? 12).toString();
    _newRateCtrl.text =
        ((loan['annual_rate'] as num?)?.toDouble() ?? 30)
            .toStringAsFixed(1);
    _newAmountCtrl.text =
        ((loan['principal'] as num?)?.toDouble() ?? 0)
            .toStringAsFixed(0);
    _restructureReasonCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialogState) => AlertDialog(
          title: const Text('Request Restructure'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type selector
                const Text('Restructure Type',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                ...(_restructureTypes.entries.map((e) {
                  return RadioListTile<String>(
                    title: Text(e.value,
                        style: const TextStyle(fontSize: 13)),
                    value: e.key,
                    groupValue: _restructureType,
                    dense: true,
                    onChanged: (v) => setDialogState(
                        () => _restructureType = v ?? 'TERM_EXTENSION'),
                  );
                })),
                const Divider(),

                // New terms
                const Text('New Terms',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _newTenureCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tenure (months)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newRateCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Annual Rate (%)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newAmountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Principal Amount',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _restructureReasonCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Comparison table
                _buildComparisonTable(loan),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                widget.onRequestRestructure?.call({
                  'loan_id': loan['loan_id'],
                  'restructure_type': _restructureType,
                  'new_tenure': int.tryParse(_newTenureCtrl.text),
                  'new_rate': double.tryParse(_newRateCtrl.text),
                  'new_amount': double.tryParse(_newAmountCtrl.text),
                  'reason': _restructureReasonCtrl.text,
                });
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                  backgroundColor: _primary),
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(Map<String, dynamic> loan) {
    final oldTenure = loan['tenure_months'] ?? 0;
    final oldRate =
        (loan['annual_rate'] as num?)?.toDouble() ?? 0;
    final oldPrincipal =
        (loan['principal'] as num?)?.toDouble() ?? 0;
    final newTenure =
        int.tryParse(_newTenureCtrl.text) ?? oldTenure;
    final newRate =
        double.tryParse(_newRateCtrl.text) ?? oldRate;
    final newPrincipal =
        double.tryParse(_newAmountCtrl.text) ?? oldPrincipal;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Old vs New Comparison',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 6),
          _compRow('', 'Old', 'New'),
          _compRow('Tenure', '$oldTenure mo', '$newTenure mo'),
          _compRow(
              'Rate', '${oldRate.toStringAsFixed(1)}%', '${newRate.toStringAsFixed(1)}%'),
          _compRow('Principal', _kes.format(oldPrincipal),
              _kes.format(newPrincipal)),
        ],
      ),
    );
  }

  Widget _compRow(String label, String old, String newVal) {
    final isHeader = label.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: isHeader
                          ? FontWeight.w600
                          : FontWeight.normal))),
          Expanded(
              flex: 3,
              child: Text(old,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: isHeader
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isHeader ? Colors.grey : null))),
          Expanded(
              flex: 3,
              child: Text(newVal,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: isHeader
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isHeader
                          ? const Color(0xFF1565C0)
                          : null))),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Common helpers
  // ---------------------------------------------------------------------------

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121))),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message,
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      return _dateFmt.format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}
