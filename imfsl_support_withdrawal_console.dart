import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL Support & Withdrawal Console
///
/// A 2-tab ops console combining Support Ticket Queue and Savings Withdrawal Queue.
///
/// Data sources:
///   Tab 1 - Support Center  : vw_retool_imfsl_support_ticket_queue (V20)
///   Tab 2 - Withdrawal Queue: vw_retool_imfsl_withdrawal_queue (V21)
class ImfslSupportWithdrawalConsole extends StatefulWidget {
  final List<Map<String, dynamic>> ticketData;
  final List<Map<String, dynamic>> withdrawalData;

  final bool isTicketLoading;
  final bool isWithdrawalLoading;

  final Function(String?)? onTicketStatusFilter;
  final Function(String?)? onTicketCategoryFilter;
  final Function(String?)? onTicketPriorityFilter;
  final Function(String?)? onWithdrawalStatusFilter;
  final Function(String?)? onWithdrawalChannelFilter;

  final VoidCallback? onLoadMoreTickets;
  final VoidCallback? onLoadMoreWithdrawals;

  final VoidCallback? onRefreshTickets;
  final VoidCallback? onRefreshWithdrawals;

  final VoidCallback? onBack;

  const ImfslSupportWithdrawalConsole({
    super.key,
    this.ticketData = const [],
    this.withdrawalData = const [],
    this.isTicketLoading = false,
    this.isWithdrawalLoading = false,
    this.onTicketStatusFilter,
    this.onTicketCategoryFilter,
    this.onTicketPriorityFilter,
    this.onWithdrawalStatusFilter,
    this.onWithdrawalChannelFilter,
    this.onLoadMoreTickets,
    this.onLoadMoreWithdrawals,
    this.onRefreshTickets,
    this.onRefreshWithdrawals,
    this.onBack,
  });

  @override
  State<ImfslSupportWithdrawalConsole> createState() =>
      _ImfslSupportWithdrawalConsoleState();
}

class _ImfslSupportWithdrawalConsoleState
    extends State<ImfslSupportWithdrawalConsole>
    with SingleTickerProviderStateMixin {
  static const Color _primaryColor = Color(0xFF1565C0);
  static const Color _successGreen = Color(0xFF2E7D32);
  static const Color _warningOrange = Color(0xFFE65100);
  static const Color _alertRed = Color(0xFFC62828);
  static const Color _infoPurple = Color(0xFF6A1B9A);

  late final TabController _tabController;
  late final NumberFormat _currencyFormat;

  // Ticket filters
  String? _ticketStatusFilter;
  String? _ticketCategoryFilter;
  String? _ticketPriorityFilter;

  // Withdrawal filters
  String? _withdrawalStatusFilter;
  String? _withdrawalChannelFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    try {
      final dt = DateTime.parse(value.toString());
      return DateFormat('dd MMM yyyy, HH:mm').format(dt.toLocal());
    } catch (_) {
      return value.toString();
    }
  }

  String _formatShortDate(dynamic value) {
    if (value == null) return '-';
    try {
      final dt = DateTime.parse(value.toString());
      return DateFormat('dd MMM, HH:mm').format(dt.toLocal());
    } catch (_) {
      return value.toString();
    }
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return _currencyFormat.format(0);
    if (value is String) {
      final parsed = double.tryParse(value);
      return _currencyFormat.format(parsed ?? 0);
    }
    return _currencyFormat.format(value);
  }

  String _formatStatusText(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) =>
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  int _countByField(List<Map<String, dynamic>> data, String field, String value) {
    return data.where((d) => d[field]?.toString().toUpperCase() == value.toUpperCase()).length;
  }

  // ---------------------------------------------------------------------------
  // Colors
  // ---------------------------------------------------------------------------

  Color _ticketStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'OPEN':
        return _warningOrange;
      case 'IN_PROGRESS':
        return _primaryColor;
      case 'WAITING_CUSTOMER':
        return _infoPurple;
      case 'RESOLVED':
        return _successGreen;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _ticketPriorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'URGENT':
        return _alertRed;
      case 'HIGH':
        return _warningOrange;
      case 'MEDIUM':
        return _primaryColor;
      case 'LOW':
        return _successGreen;
      default:
        return Colors.grey;
    }
  }

  Color _withdrawalStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return _warningOrange;
      case 'APPROVED':
        return _primaryColor;
      case 'PROCESSING':
        return _infoPurple;
      case 'COMPLETED':
        return _successGreen;
      case 'FAILED':
        return _alertRed;
      case 'REJECTED':
        return Colors.grey.shade700;
      default:
        return Colors.grey;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        TabBar(
          controller: _tabController,
          labelColor: _primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: _primaryColor,
          tabs: [
            Tab(
              icon: const Icon(Icons.support_agent, size: 20),
              text: 'Support Center (${widget.ticketData.length})',
            ),
            Tab(
              icon: const Icon(Icons.account_balance_wallet, size: 20),
              text: 'Withdrawals (${widget.withdrawalData.length})',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSupportTab(),
              _buildWithdrawalTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _primaryColor),
            tooltip: 'Back to Executive Console',
            onPressed: widget.onBack,
          ),
          const Icon(Icons.support_agent, color: _infoPurple, size: 26),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Support Center',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TAB 1 — SUPPORT CENTER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSupportTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          widget.onLoadMoreTickets?.call();
        }
        return false;
      },
      child: RefreshIndicator(
        color: _primaryColor,
        onRefresh: () async => widget.onRefreshTickets?.call(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _buildTicketStatsRow(),
            const SizedBox(height: 14),
            _buildTicketCategoryChips(),
            const SizedBox(height: 14),
            _buildTicketFilters(),
            const SizedBox(height: 14),
            _buildTicketTable(),
            if (widget.isTicketLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: _primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Ticket Stats Row ──

  Widget _buildTicketStatsRow() {
    final data = widget.ticketData;
    final open = _countByField(data, 'status', 'OPEN');
    final inProgress = _countByField(data, 'status', 'IN_PROGRESS');
    final waiting = _countByField(data, 'status', 'WAITING_CUSTOMER');
    final resolved = _countByField(data, 'status', 'RESOLVED');

    return Row(
      children: [
        Expanded(child: _buildStatCard('Open', open, _warningOrange)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('In Progress', inProgress, _primaryColor)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Waiting', waiting, _infoPurple)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Resolved', resolved, _successGreen)),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Category Chips ──

  Widget _buildTicketCategoryChips() {
    final categories = <String, int>{};
    for (final t in widget.ticketData) {
      final cat = t['category']?.toString() ?? 'OTHER';
      categories[cat] = (categories[cat] ?? 0) + 1;
    }
    if (categories.isEmpty) return const SizedBox.shrink();

    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'By Category',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final entry = sorted[index];
              final isSelected = _ticketCategoryFilter == entry.key;
              return FilterChip(
                label: Text(
                  '${_formatStatusText(entry.key)} (${entry.value})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF424242),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _ticketCategoryFilter = selected ? entry.key : null;
                  });
                  widget.onTicketCategoryFilter?.call(
                      selected ? entry.key : null);
                },
                selectedColor: _infoPurple,
                backgroundColor: Colors.grey.shade100,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Ticket Filters ──

  Widget _buildTicketFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            label: 'Status',
            value: _ticketStatusFilter,
            items: const ['OPEN', 'IN_PROGRESS', 'WAITING_CUSTOMER', 'RESOLVED', 'CLOSED'],
            onChanged: (val) {
              setState(() => _ticketStatusFilter = val);
              widget.onTicketStatusFilter?.call(val);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(
            label: 'Priority',
            value: _ticketPriorityFilter,
            items: const ['URGENT', 'HIGH', 'MEDIUM', 'LOW'],
            onChanged: (val) {
              setState(() => _ticketPriorityFilter = val);
              widget.onTicketPriorityFilter?.call(val);
            },
          ),
        ),
      ],
    );
  }

  // ── Ticket Table ──

  Widget _buildTicketTable() {
    if (widget.ticketData.isEmpty && !widget.isTicketLoading) {
      return _buildEmptyState(
        icon: Icons.support_agent_outlined,
        message: 'No support tickets found',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.ticketData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = widget.ticketData[index];
        return _buildTicketCard(t);
      },
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> t) {
    final ticketNumber = t['ticket_number']?.toString() ?? 'N/A';
    final customerName = t['customer_name']?.toString() ?? 'Unknown';
    final category = t['category']?.toString() ?? '';
    final subject = t['subject']?.toString() ?? '';
    final status = t['status']?.toString() ?? 'OPEN';
    final priority = t['priority']?.toString() ?? 'MEDIUM';
    final assigned = t['assigned_staff']?.toString();
    final msgCount = (t['message_count'] as num?)?.toInt() ?? 0;
    final createdAt = _formatShortDate(t['created_at']);

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Ticket # + badges
          Row(
            children: [
              Expanded(
                child: Text(
                  ticketNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
              ),
              _buildBadge(status, _ticketStatusColor(status)),
              const SizedBox(width: 4),
              _buildBadge(priority, _ticketPriorityColor(priority)),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2: Subject
          Text(
            subject,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Row 3: Customer + category + assigned
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  customerName,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildBadge(_formatStatusText(category), Colors.grey.shade600),
            ],
          ),
          const SizedBox(height: 4),
          // Row 4: Metadata
          Row(
            children: [
              Icon(Icons.access_time, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 3),
              Text(
                createdAt,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const Spacer(),
              if (msgCount > 0) ...[
                Icon(Icons.chat_bubble_outline, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text(
                  '$msgCount',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 10),
              ],
              if (assigned != null && assigned.isNotEmpty) ...[
                Icon(Icons.assignment_ind_outlined, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text(
                  assigned,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TAB 2 — WITHDRAWAL QUEUE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildWithdrawalTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          widget.onLoadMoreWithdrawals?.call();
        }
        return false;
      },
      child: RefreshIndicator(
        color: _primaryColor,
        onRefresh: () async => widget.onRefreshWithdrawals?.call(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _buildWithdrawalStatsRow(),
            const SizedBox(height: 14),
            _buildWithdrawalFilters(),
            const SizedBox(height: 14),
            _buildWithdrawalTable(),
            if (widget.isWithdrawalLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: _primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Withdrawal Stats Row ──

  Widget _buildWithdrawalStatsRow() {
    final data = widget.withdrawalData;
    final pending = _countByField(data, 'status', 'PENDING');
    final approved = _countByField(data, 'status', 'APPROVED');
    final processing = _countByField(data, 'status', 'PROCESSING');
    final completed = _countByField(data, 'status', 'COMPLETED');
    final failed = _countByField(data, 'status', 'FAILED');
    final rejected = _countByField(data, 'status', 'REJECTED');

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Pending', pending, _warningOrange)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard('Approved', approved, _primaryColor)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard('Processing', processing, _infoPurple)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildStatCard('Completed', completed, _successGreen)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard('Failed', failed, _alertRed)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard('Rejected', rejected, Colors.grey.shade700)),
          ],
        ),
      ],
    );
  }

  // ── Withdrawal Filters ──

  Widget _buildWithdrawalFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            label: 'Status',
            value: _withdrawalStatusFilter,
            items: const ['PENDING', 'APPROVED', 'PROCESSING', 'COMPLETED', 'FAILED', 'REJECTED'],
            onChanged: (val) {
              setState(() => _withdrawalStatusFilter = val);
              widget.onWithdrawalStatusFilter?.call(val);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(
            label: 'Channel',
            value: _withdrawalChannelFilter,
            items: const ['MPESA', 'BANK', 'CASH'],
            onChanged: (val) {
              setState(() => _withdrawalChannelFilter = val);
              widget.onWithdrawalChannelFilter?.call(val);
            },
          ),
        ),
      ],
    );
  }

  // ── Withdrawal Table ──

  Widget _buildWithdrawalTable() {
    if (widget.withdrawalData.isEmpty && !widget.isWithdrawalLoading) {
      return _buildEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        message: 'No withdrawal requests found',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.withdrawalData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final w = widget.withdrawalData[index];
        return _buildWithdrawalCard(w);
      },
    );
  }

  Widget _buildWithdrawalCard(Map<String, dynamic> w) {
    final withdrawalNumber = w['withdrawal_number']?.toString() ?? 'N/A';
    final customerName = w['customer_name']?.toString() ?? 'Unknown';
    final accountNumber = w['account_number']?.toString() ?? '-';
    final amount = w['amount'];
    final channel = w['channel']?.toString() ?? '-';
    final status = w['status']?.toString() ?? 'PENDING';
    final destination = w['destination_phone']?.toString() ??
        w['destination_bank_account']?.toString() ??
        '-';
    final createdAt = _formatShortDate(w['created_at']);
    final completedAt = w['completed_at'] != null
        ? _formatShortDate(w['completed_at'])
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Withdrawal # + status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  withdrawalNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
              ),
              _buildBadge(status, _withdrawalStatusColor(status)),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2: Amount + channel
          Row(
            children: [
              Text(
                _formatCurrency(amount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const Spacer(),
              _buildBadge(channel, _primaryColor),
            ],
          ),
          const SizedBox(height: 4),
          // Row 3: Customer + account
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  customerName,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                accountNumber,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Row 4: Destination + dates
          Row(
            children: [
              Icon(Icons.send, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  destination,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.access_time, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 3),
              Text(
                createdAt,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              if (completedAt != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle_outline, size: 13, color: _successGreen),
                const SizedBox(width: 3),
                Text(
                  completedAt,
                  style: const TextStyle(fontSize: 11, color: _successGreen),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _formatStatusText(text),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          isExpanded: true,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
          style: const TextStyle(fontSize: 12, color: Color(0xFF212121)),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All $label', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ...items.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(_formatStatusText(s)),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
