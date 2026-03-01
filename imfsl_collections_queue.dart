import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL Admin Collections Queue Widget
///
/// A filterable, prioritized list of overdue loans for the collections team.
/// Supports PAR bucket and status filtering, action logging, and penalty waivers.
class ImfslCollectionsQueue extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final int totalCount;
  final bool isLoading;
  final String? currentParFilter;
  final String? currentStatusFilter;
  final Function(String?)? onFilterPar;
  final Function(String?)? onFilterStatus;
  final VoidCallback? onLoadMore;
  final Function(Map<String, dynamic>)? onLogAction;
  final Function(Map<String, dynamic>)? onWaivePenalty;
  final VoidCallback? onRefresh;
  final String currentUserRole;

  const ImfslCollectionsQueue({
    super.key,
    this.items = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.currentParFilter,
    this.currentStatusFilter,
    this.onFilterPar,
    this.onFilterStatus,
    this.onLoadMore,
    this.onLogAction,
    this.onWaivePenalty,
    this.onRefresh,
    this.currentUserRole = 'OFFICER',
  });

  @override
  State<ImfslCollectionsQueue> createState() => _ImfslCollectionsQueueState();
}

class _ImfslCollectionsQueueState extends State<ImfslCollectionsQueue> {
  static const Color _primaryColor = Color(0xFF1565C0);

  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'KES ',
    decimalDigits: 2,
  );

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  // ── PAR bucket definitions ──────────────────────────────────────────────

  static const List<String> _parBuckets = [
    'ALL',
    'PAR1-30',
    'PAR31-60',
    'PAR61-90',
    'PAR91-180',
    'PAR180+',
  ];

  static const List<String> _statusOptions = [
    'ALL',
    'ACTIVE',
    'OVERDUE',
    'DEFAULTED',
  ];

  // ── Action type + outcome enums ─────────────────────────────────────────

  static const List<String> _actionTypes = [
    'SMS_REMINDER',
    'PHONE_CALL',
    'FIELD_VISIT',
    'PROMISE_TO_PAY',
    'ESCALATION',
    'DEMAND_LETTER',
    'LEGAL_NOTICE',
    'OTHER',
  ];

  static const List<String> _outcomeOptions = [
    'PROMISED',
    'PAID',
    'NO_ANSWER',
    'REFUSED',
    'PARTIAL',
    'RESCHEDULED',
    'N/A',
  ];

  // ── Color helpers ───────────────────────────────────────────────────────

  Color _priorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.amber;
      case 'LOW':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _parBucketColor(String? bucket) {
    switch (bucket?.toUpperCase()) {
      case 'PAR1-30':
        return Colors.yellow.shade700;
      case 'PAR31-60':
        return Colors.orange;
      case 'PAR61-90':
        return Colors.deepOrange;
      case 'PAR91-180':
        return Colors.red;
      case 'PAR180+':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'OVERDUE':
        return Colors.orange;
      case 'DEFAULTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ── Date parsing helper ─────────────────────────────────────────────────

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    try {
      final date = DateTime.parse(dateStr);
      return _dateFormat.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // ── Human-readable labels ───────────────────────────────────────────────

  String _humanizeAction(String? action) {
    if (action == null || action.isEmpty) return '—';
    return action.replaceAll('_', ' ').toLowerCase().split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterChipsRow(),
        const Divider(height: 1),
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  // ── Filter Chips ────────────────────────────────────────────────────────

  Widget _buildFilterChipsRow() {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PAR filter row
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              'PAR Bucket',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _parBuckets.map((bucket) {
                final isAll = bucket == 'ALL';
                final isSelected = isAll
                    ? (widget.currentParFilter == null ||
                        widget.currentParFilter == 'ALL')
                    : widget.currentParFilter == bucket;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      bucket,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: isAll ? _primaryColor : _parBucketColor(bucket),
                    backgroundColor: Colors.white,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade300,
                    ),
                    onSelected: (_) {
                      widget.onFilterPar?.call(isAll ? null : bucket);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Status filter row
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              'Loan Status',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _statusOptions.map((status) {
                final isAll = status == 'ALL';
                final isSelected = isAll
                    ? (widget.currentStatusFilter == null ||
                        widget.currentStatusFilter == 'ALL')
                    : widget.currentStatusFilter == status;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: isAll ? _primaryColor : _statusColor(status),
                    backgroundColor: Colors.white,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade300,
                    ),
                    onSelected: (_) {
                      widget.onFilterStatus?.call(isAll ? null : status);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body — loading / empty / list ───────────────────────────────────────

  Widget _buildBody() {
    if (widget.isLoading && widget.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    if (widget.items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: () async {
        widget.onRefresh?.call();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: widget.items.length + _loadMoreCount,
        itemBuilder: (context, index) {
          if (index < widget.items.length) {
            return _buildLoanCard(widget.items[index]);
          }
          // Load-more or loading indicator at the bottom
          return _buildLoadMoreButton();
        },
      ),
    );
  }

  int get _loadMoreCount {
    if (widget.isLoading && widget.items.isNotEmpty) return 1;
    if (widget.items.length < widget.totalCount) return 1;
    return 0;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No overdue loans found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adjust your filters or check back later',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: _primaryColor),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: OutlinedButton.icon(
          icon: const Icon(Icons.expand_more, color: _primaryColor),
          label: Text(
            'Load More (${widget.items.length} of ${widget.totalCount})',
            style: const TextStyle(color: _primaryColor),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: widget.onLoadMore,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAN CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLoanCard(Map<String, dynamic> item) {
    final String loanId = item['loan_id']?.toString() ?? '';
    final String loanNumber = item['loan_number']?.toString() ?? '—';
    final double outstandingBalance =
        (item['outstanding_balance'] as num?)?.toDouble() ?? 0.0;
    final int daysInArrears = (item['days_in_arrears'] as num?)?.toInt() ?? 0;
    final String parBucket = item['par_bucket']?.toString() ?? '';
    final String collectionPriority =
        item['collection_priority']?.toString() ?? '';
    final String loanStatus = item['loan_status']?.toString() ?? '';
    final String customerName = item['customer_name']?.toString() ?? '—';
    final String phoneNumber = item['phone_number']?.toString() ?? '—';
    final String productName = item['product_name']?.toString() ?? '—';
    final String? lastActionType =
        item['last_collection_action_type']?.toString();
    final String? lastActionAt =
        item['last_collection_action_at']?.toString();
    final String? lastActionNotes = item['last_action_notes']?.toString();
    final String? lastActionOutcome = item['last_action_outcome']?.toString();
    final String? nextCollectionDate =
        item['next_collection_date']?.toString();
    final String? recommendedNextAction =
        item['recommended_next_action']?.toString();
    final String? promiseDate = item['promise_date']?.toString();
    final double promiseAmount =
        (item['promise_amount'] as num?)?.toDouble() ?? 0.0;
    final double totalPenalties =
        (item['total_penalties_accrued'] as num?)?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: customer name + priority badge ──
            _buildCardHeader(
              customerName: customerName,
              phoneNumber: phoneNumber,
              priority: collectionPriority,
            ),
            const SizedBox(height: 8),

            // ── Loan info row ──
            _buildLoanInfoRow(
              loanNumber: loanNumber,
              productName: productName,
              loanStatus: loanStatus,
            ),
            const SizedBox(height: 12),

            // ── Balance + arrears ──
            _buildBalanceRow(
              outstandingBalance: outstandingBalance,
              daysInArrears: daysInArrears,
              parBucket: parBucket,
            ),

            // ── Penalties ──
            if (totalPenalties > 0) ...[
              const SizedBox(height: 8),
              _buildPenaltiesRow(totalPenalties),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Last action ──
            if (lastActionType != null && lastActionType.isNotEmpty)
              _buildLastActionSection(
                actionType: lastActionType,
                outcome: lastActionOutcome,
                date: lastActionAt,
                notes: lastActionNotes,
              ),

            // ── Next collection date ──
            if (nextCollectionDate != null && nextCollectionDate.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.event, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Next follow-up: ${_formatDate(nextCollectionDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],

            // ── Recommended next action ──
            if (recommendedNextAction != null &&
                recommendedNextAction.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.tips_and_updates,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _humanizeAction(recommendedNextAction),
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // ── Promise info ──
            if (promiseDate != null && promiseDate.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildPromiseRow(promiseDate: promiseDate, amount: promiseAmount),
            ],

            const SizedBox(height: 12),

            // ── Action buttons ──
            _buildActionButtons(
              item: item,
              loanId: loanId,
              totalPenalties: totalPenalties,
            ),
          ],
        ),
      ),
    );
  }

  // ── Card sub-sections ───────────────────────────────────────────────────

  Widget _buildCardHeader({
    required String customerName,
    required String phoneNumber,
    required String priority,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.phone, size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    phoneNumber,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildPriorityBadge(priority),
      ],
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final color = _priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        priority.isNotEmpty ? priority.toUpperCase() : 'N/A',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLoanInfoRow({
    required String loanNumber,
    required String productName,
    required String loanStatus,
  }) {
    return Row(
      children: [
        Icon(Icons.receipt_long, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          loanNumber,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            productName,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _statusColor(loanStatus).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            loanStatus.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _statusColor(loanStatus),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceRow({
    required double outstandingBalance,
    required int daysInArrears,
    required String parBucket,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Outstanding',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                _currencyFormat.format(outstandingBalance),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _parBucketColor(parBucket).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                parBucket,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _parBucketColor(parBucket),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$daysInArrears days overdue',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: daysInArrears > 90
                    ? Colors.red.shade700
                    : Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPenaltiesRow(double totalPenalties) {
    return Row(
      children: [
        Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.shade300),
        const SizedBox(width: 4),
        Text(
          'Penalties accrued: ${_currencyFormat.format(totalPenalties)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLastActionSection({
    required String actionType,
    String? outcome,
    String? date,
    String? notes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              'Last Action',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _humanizeAction(actionType),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (outcome != null && outcome.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        outcome,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (date != null)
                    Text(
                      _formatDate(date),
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                ],
              ),
              if (notes != null && notes.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromiseRow({
    required String promiseDate,
    required double amount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.handshake, size: 15, color: Colors.blue.shade400),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Promised ${_currencyFormat.format(amount)} by ${_formatDate(promiseDate)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons({
    required Map<String, dynamic> item,
    required String loanId,
    required double totalPenalties,
  }) {
    final bool showWaiver =
        widget.currentUserRole == 'ADMIN' && totalPenalties > 0;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.note_add, size: 16),
            label: const Text('Log Action'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,
              side: const BorderSide(color: _primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _showActionDialog(item),
          ),
        ),
        if (showWaiver) ...[
          const SizedBox(width: 8),
          TextButton.icon(
            icon: Icon(Icons.money_off, size: 16, color: Colors.red.shade400),
            label: Text(
              'Waive Penalty',
              style: TextStyle(color: Colors.red.shade400, fontSize: 13),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
            onPressed: () => _showPenaltyWaiverDialog(item),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTION DIALOG (ModalBottomSheet)
  // ══════════════════════════════════════════════════════════════════════════

  void _showActionDialog(Map<String, dynamic> item) {
    String? selectedActionType;
    String notes = '';
    String? selectedOutcome;
    DateTime? promiseDateValue;
    String promiseAmountText = '';
    DateTime? nextActionDateValue;
    String? selectedNextActionType;

    final notesController = TextEditingController();
    final promiseAmountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(builderContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title bar ──
                    Row(
                      children: [
                        const Icon(Icons.note_add,
                            color: _primaryColor, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Log Collection Action',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(builderContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['customer_name']} — ${item['loan_number']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Action Type ──
                    _buildDialogLabel('Action Type *'),
                    DropdownButtonFormField<String>(
                      value: selectedActionType,
                      decoration: _dropdownDecoration('Select action type'),
                      items: _actionTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            _humanizeAction(type),
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setSheetState(() => selectedActionType = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Notes ──
                    _buildDialogLabel('Notes'),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter action notes...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (val) => notes = val,
                    ),
                    const SizedBox(height: 14),

                    // ── Outcome ──
                    _buildDialogLabel('Outcome *'),
                    DropdownButtonFormField<String>(
                      value: selectedOutcome,
                      decoration: _dropdownDecoration('Select outcome'),
                      items: _outcomeOptions.map((o) {
                        return DropdownMenuItem(
                          value: o,
                          child: Text(
                            _humanizeAction(o),
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setSheetState(() => selectedOutcome = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Promise fields (if outcome == PROMISED) ──
                    if (selectedOutcome == 'PROMISED') ...[
                      _buildDialogLabel('Promise Date'),
                      _buildDatePickerButton(
                        context: builderContext,
                        label: promiseDateValue != null
                            ? _dateFormat.format(promiseDateValue!)
                            : 'Select promise date',
                        onPicked: (date) {
                          setSheetState(() => promiseDateValue = date);
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildDialogLabel('Promise Amount (KES)'),
                      TextField(
                        controller: promiseAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: 'KES ',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (val) => promiseAmountText = val,
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Next action date (optional) ──
                    _buildDialogLabel('Next Action Date (optional)'),
                    _buildDatePickerButton(
                      context: builderContext,
                      label: nextActionDateValue != null
                          ? _dateFormat.format(nextActionDateValue!)
                          : 'Select next action date',
                      onPicked: (date) {
                        setSheetState(() => nextActionDateValue = date);
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Next action type (optional) ──
                    _buildDialogLabel('Next Action Type (optional)'),
                    DropdownButtonFormField<String>(
                      value: selectedNextActionType,
                      decoration:
                          _dropdownDecoration('Select next action type'),
                      items: _actionTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            _humanizeAction(type),
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setSheetState(() => selectedNextActionType = val);
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Submit ──
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text(
                          'Submit Action',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: (selectedActionType != null &&
                                selectedOutcome != null)
                            ? () {
                                final actionData = <String, dynamic>{
                                  'loan_id': item['loan_id'],
                                  'action_type': selectedActionType,
                                  'notes': notesController.text,
                                  'outcome': selectedOutcome,
                                };
                                if (promiseDateValue != null) {
                                  actionData['promise_date'] =
                                      promiseDateValue!.toIso8601String();
                                }
                                if (promiseAmountText.isNotEmpty) {
                                  actionData['promise_amount'] =
                                      double.tryParse(promiseAmountText) ?? 0.0;
                                }
                                if (nextActionDateValue != null) {
                                  actionData['next_action_date'] =
                                      nextActionDateValue!.toIso8601String();
                                }
                                if (selectedNextActionType != null) {
                                  actionData['next_action_type'] =
                                      selectedNextActionType;
                                }
                                widget.onLogAction?.call(actionData);
                                Navigator.pop(builderContext);
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PENALTY WAIVER DIALOG (AlertDialog)
  // ══════════════════════════════════════════════════════════════════════════

  void _showPenaltyWaiverDialog(Map<String, dynamic> item) {
    final double totalPenalties =
        (item['total_penalties_accrued'] as num?)?.toDouble() ?? 0.0;
    final amountController =
        TextEditingController(text: totalPenalties.toStringAsFixed(2));
    final reasonController = TextEditingController();
    bool reasonEmpty = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.money_off, color: Colors.red.shade400, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Waive Penalty',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['customer_name']} — ${item['loan_number']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    _buildDialogLabel('Waiver Amount (KES)'),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: 'KES ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Reason
                    _buildDialogLabel('Reason *'),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Enter reason for waiver...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (val) {
                        setDialogState(
                            () => reasonEmpty = val.trim().isEmpty);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Warning
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 18, color: Colors.amber.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This will create a reversal journal entry',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: reasonEmpty
                      ? null
                      : () {
                          final waiverData = <String, dynamic>{
                            'loan_id': item['loan_id'],
                            'amount':
                                double.tryParse(amountController.text) ?? 0.0,
                            'reason': reasonController.text.trim(),
                          };
                          widget.onWaivePenalty?.call(waiverData);
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED DIALOG HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildDialogLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildDatePickerButton({
    required BuildContext context,
    required String label,
    required void Function(DateTime) onPicked,
  }) {
    final bool hasValue = !label.startsWith('Select');
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(
          Icons.calendar_today,
          size: 16,
          color: hasValue ? _primaryColor : Colors.grey.shade500,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: hasValue ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (pickerContext, child) {
              return Theme(
                data: Theme.of(pickerContext).copyWith(
                  colorScheme: const ColorScheme.light(primary: _primaryColor),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onPicked(picked);
          }
        },
      ),
    );
  }
}
