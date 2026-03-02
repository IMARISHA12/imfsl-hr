// IMFSL Support Tickets Widget
// =============================
// Customer support ticketing with conversation threads.
// Filterable list, create ticket sheet, detail sheet with chat-style messages.
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslSupportTickets extends StatefulWidget {
  const ImfslSupportTickets({
    super.key,
    this.tickets = const [],
    this.isLoading = false,
    this.onCreateTicket,
    this.onAddMessage,
    this.onLoadTicketDetail,
    this.onRefresh,
    this.onLoadMore,
    this.onFilterStatus,
    this.loanOptions,
  });

  final List<Map<String, dynamic>> tickets;
  final bool isLoading;
  final Function(String category, String subject, String message,
      String? loanId, String? txnId)? onCreateTicket;
  final Function(String ticketId, String message)? onAddMessage;
  final Future<Map<String, dynamic>> Function(String ticketId)?
      onLoadTicketDetail;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final Function(String? status)? onFilterStatus;
  final List<Map<String, dynamic>>? loanOptions;

  @override
  State<ImfslSupportTickets> createState() => _ImfslSupportTicketsState();
}

class _ImfslSupportTicketsState extends State<ImfslSupportTickets> {
  static const _primaryColor = Color(0xFF1565C0);
  static const _successGreen = Color(0xFF2E7D32);
  static const _warningAmber = Color(0xFFEF6C00);
  static const _errorRed = Color(0xFFF44336);

  final _currencyFmt = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final _dateTimeFmt = DateFormat('dd MMM yyyy HH:mm');
  final _timeFmt = DateFormat('HH:mm');
  final _dateFmt = DateFormat('dd MMM yyyy');

  String _statusFilter = 'ALL';
  String _categoryFilter = 'ALL';

  // Create-ticket form state
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _createCat = 'GENERAL_INQUIRY';
  String? _createLoanId;
  bool _isSubmitting = false;

  // Detail state
  bool _loadingDetail = false;
  Map<String, dynamic>? _detail;
  final _replyCtrl = TextEditingController();
  bool _sendingReply = false;

  static const _categories = [
    'LOAN_DISPUTE', 'PAYMENT_ISSUE', 'ACCOUNT_INQUIRY', 'M_PESA_PROBLEM',
    'KYC_ISSUE', 'GENERAL_INQUIRY', 'COMPLAINT', 'SAVINGS_ISSUE',
  ];
  static const _catLabels = {
    'LOAN_DISPUTE': 'Loan Dispute', 'PAYMENT_ISSUE': 'Payment Issue',
    'ACCOUNT_INQUIRY': 'Account Inquiry', 'M_PESA_PROBLEM': 'M-Pesa Problem',
    'KYC_ISSUE': 'KYC Issue', 'GENERAL_INQUIRY': 'General Inquiry',
    'COMPLAINT': 'Complaint', 'SAVINGS_ISSUE': 'Savings Issue',
  };
  static const _catColors = <String, Color>{
    'LOAN_DISPUTE': Color(0xFFD32F2F), 'PAYMENT_ISSUE': Color(0xFFE65100),
    'ACCOUNT_INQUIRY': Color(0xFF1565C0), 'M_PESA_PROBLEM': Color(0xFF4CAF50),
    'KYC_ISSUE': Color(0xFF7B1FA2), 'GENERAL_INQUIRY': Color(0xFF546E7A),
    'COMPLAINT': Color(0xFFC62828), 'SAVINGS_ISSUE': Color(0xFF00838F),
  };
  static const _catIcons = <String, IconData>{
    'LOAN_DISPUTE': Icons.gavel, 'PAYMENT_ISSUE': Icons.payment,
    'ACCOUNT_INQUIRY': Icons.account_circle, 'M_PESA_PROBLEM': Icons.phone_android,
    'KYC_ISSUE': Icons.verified_user, 'GENERAL_INQUIRY': Icons.help_outline,
    'COMPLAINT': Icons.report_problem, 'SAVINGS_ISSUE': Icons.savings,
  };
  static const _statusColors = <String, Color>{
    'OPEN': Color(0xFF1565C0), 'IN_PROGRESS': Color(0xFFEF6C00),
    'WAITING_CUSTOMER': Color(0xFFF9A825), 'RESOLVED': Color(0xFF2E7D32),
    'CLOSED': Color(0xFF757575),
  };
  static const _statusLabels = {
    'OPEN': 'Open', 'IN_PROGRESS': 'In Progress',
    'WAITING_CUSTOMER': 'Waiting on You', 'RESOLVED': 'Resolved',
    'CLOSED': 'Closed',
  };
  static const _statusIcons = <String, IconData>{
    'OPEN': Icons.fiber_new, 'IN_PROGRESS': Icons.autorenew,
    'WAITING_CUSTOMER': Icons.hourglass_bottom, 'RESOLVED': Icons.check_circle,
    'CLOSED': Icons.lock,
  };

  List<Map<String, dynamic>> get _filtered {
    var r = widget.tickets;
    if (_statusFilter != 'ALL') {
      r = r.where((t) => t['status']?.toString() == _statusFilter).toList();
    }
    if (_categoryFilter != 'ALL') {
      r = r.where((t) => t['category']?.toString() == _categoryFilter).toList();
    }
    return r;
  }

  Map<String, int> get _counts {
    final c = <String, int>{'ALL': widget.tickets.length};
    for (final t in widget.tickets) {
      final s = t['status']?.toString() ?? 'OPEN';
      c[s] = (c[s] ?? 0) + 1;
    }
    return c;
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    _replyCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      RefreshIndicator(
        onRefresh: () async => widget.onRefresh?.call(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildSummaryHeader()),
            SliverToBoxAdapter(child: _buildStatusFilterChips()),
            SliverToBoxAdapter(child: _buildCategoryFilter()),
            if (widget.isLoading && widget.tickets.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: _primaryColor)),
              )
            else if (_filtered.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else ...[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => i < _filtered.length ? _buildTicketCard(_filtered[i]) : null,
                  childCount: _filtered.length,
                ),
              ),
              if (widget.onLoadMore != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: widget.isLoading
                          ? const CircularProgressIndicator(color: _primaryColor)
                          : TextButton.icon(
                              onPressed: widget.onLoadMore,
                              icon: const Icon(Icons.expand_more),
                              label: const Text('Load more'),
                            ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ],
        ),
      ),
      Positioned(
        right: 16, bottom: 16,
        child: FloatingActionButton.extended(
          onPressed: _showCreateSheet,
          backgroundColor: _primaryColor,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New Ticket',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SUMMARY HEADER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSummaryHeader() {
    final c = _counts;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.support_agent, color: _primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Support Tickets',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('${widget.tickets.length} total',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            )),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _statChip('Open', c['OPEN'] ?? 0, _statusColors['OPEN']!),
            const SizedBox(width: 8),
            _statChip('In Progress', c['IN_PROGRESS'] ?? 0, _statusColors['IN_PROGRESS']!),
            const SizedBox(width: 8),
            _statChip('Waiting', c['WAITING_CUSTOMER'] ?? 0, _statusColors['WAITING_CUSTOMER']!),
          ]),
        ]),
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: color),
              textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FILTERS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStatusFilterChips() {
    const filters = ['ALL', 'OPEN', 'IN_PROGRESS', 'RESOLVED'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: filters.map((s) {
          final sel = _statusFilter == s;
          final lbl = s == 'ALL'
              ? 'All (${_counts['ALL'] ?? 0})'
              : '${_statusLabels[s] ?? s} (${_counts[s] ?? 0})';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(lbl, style: TextStyle(
                color: sel ? Colors.white : Colors.grey.shade700,
                fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
              )),
              selected: sel,
              onSelected: (_) {
                setState(() => _statusFilter = s);
                widget.onFilterStatus?.call(s == 'ALL' ? null : s);
              },
              selectedColor: _primaryColor,
              backgroundColor: Colors.grey.shade100,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList()),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        Icon(Icons.filter_list, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text('Category:', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: _categoryFilter, isExpanded: true, isDense: true,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            items: [
              const DropdownMenuItem(value: 'ALL', child: Text('All Categories')),
              ..._categories.map((c) =>
                  DropdownMenuItem(value: c, child: Text(_catLabels[c] ?? c))),
            ],
            onChanged: (v) { if (v != null) setState(() => _categoryFilter = v); },
          )),
        )),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    final hasF = _statusFilter != 'ALL' || _categoryFilter != 'ALL';
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(hasF ? Icons.filter_list_off : Icons.support_agent,
            size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(hasF ? 'No tickets match your filters' : 'No support tickets yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                color: Colors.grey.shade600), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(hasF ? 'Try adjusting your filters or clear them to see all tickets.'
            : 'Tap "New Ticket" to create your first support request.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center),
        if (hasF) ...[
          const SizedBox(height: 16),
          TextButton(onPressed: () {
            setState(() { _statusFilter = 'ALL'; _categoryFilter = 'ALL'; });
            widget.onFilterStatus?.call(null);
          }, child: const Text('Clear Filters')),
        ],
      ]),
    ));
  }

  // ═══════════════════════════════════════════════════════════════════
  // TICKET CARD
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final num_ = ticket['ticket_number']?.toString() ?? '';
    final subj = ticket['subject']?.toString() ?? 'No subject';
    final cat = ticket['category']?.toString() ?? 'GENERAL_INQUIRY';
    final status = ticket['status']?.toString() ?? 'OPEN';
    final updated = ticket['updated_at']?.toString() ?? '';
    final msgCount = (ticket['message_count'] as num?)?.toInt() ?? 0;
    final priority = ticket['priority']?.toString() ?? 'NORMAL';
    final loanNum = ticket['linked_loan_number']?.toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showDetailSheet(ticket),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (num_.isNotEmpty)
                Text('#$num_', style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: Colors.grey.shade500,
                    fontFamily: 'monospace')),
              const Spacer(),
              _buildStatusBadge(status),
            ]),
            const SizedBox(height: 8),
            Text(subj, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              _buildCategoryBadge(cat),
              if (priority == 'HIGH' || priority == 'URGENT') ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (priority == 'URGENT' ? _errorRed : _warningAmber).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(priority, style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: priority == 'URGENT' ? _errorRed : _warningAmber)),
                ),
              ],
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(_relativeTime(updated), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text('$msgCount', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              if (loanNum != null && loanNum.isNotEmpty) ...[
                const Spacer(),
                Icon(Icons.link, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(loanNum, style: const TextStyle(fontSize: 11,
                    color: _primaryColor, fontFamily: 'monospace')),
              ],
            ]),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STATUS / CATEGORY BADGES
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStatusBadge(String status) {
    final clr = _statusColors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: clr.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_statusIcons[status] ?? Icons.info_outline, size: 12, color: clr),
        const SizedBox(width: 4),
        Text(_statusLabels[status] ?? status,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: clr)),
      ]),
    );
  }

  Widget _buildCategoryBadge(String cat) {
    final clr = _catColors[cat] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: clr.withOpacity(0.08), borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_catIcons[cat] ?? Icons.label, size: 12, color: clr),
        const SizedBox(width: 4),
        Text(_catLabels[cat] ?? cat,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: clr)),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE TICKET SHEET
  // ═══════════════════════════════════════════════════════════════════

  void _showCreateSheet() {
    _subjectCtrl.clear();
    _messageCtrl.clear();
    _createCat = 'GENERAL_INQUIRY';
    _createLoanId = null;
    _isSubmitting = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sc, setSS) => _buildCreateTicketSheet(sc, setSS),
      ),
    );
  }

  Widget _buildCreateTicketSheet(BuildContext sc, StateSetter setSS) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), children: [
          // Handle
          Center(child: Container(width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
          const Row(children: [
            Icon(Icons.add_circle, color: _primaryColor, size: 24),
            SizedBox(width: 10),
            Text('New Support Ticket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          Text('Describe your issue and we will get back to you soon.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          // Category
          const Text('Category *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _dropdownWrap(DropdownButton<String>(
            value: _createCat, isExpanded: true,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            items: _categories.map((c) => DropdownMenuItem(value: c,
                child: Row(children: [
                  Icon(_catIcons[c], size: 18, color: _catColors[c]),
                  const SizedBox(width: 10), Text(_catLabels[c] ?? c),
                ]))).toList(),
            onChanged: (v) { if (v != null) setSS(() => _createCat = v); },
          )),
          const SizedBox(height: 16),
          // Subject
          const Text('Subject *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _inputField(_subjectCtrl, 'Brief description of your issue', maxLen: 100),
          const SizedBox(height: 16),
          // Message
          const Text('Message *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _inputField(_messageCtrl, 'Provide as much detail as possible...',
              maxLines: 5, minLines: 3, maxLen: 2000),
          const SizedBox(height: 16),
          // Loan link
          if (widget.loanOptions != null && widget.loanOptions!.isNotEmpty) ...[
            const Text('Link to Loan (optional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _dropdownWrap(DropdownButton<String?>(
              value: _createLoanId, isExpanded: true,
              hint: Text('Select a loan', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('None')),
                ...widget.loanOptions!.map((l) {
                  final id = l['id']?.toString() ?? '';
                  final num = l['loan_number']?.toString() ?? id;
                  final prod = l['product_name']?.toString() ?? '';
                  return DropdownMenuItem<String?>(value: id,
                      child: Text(prod.isNotEmpty ? '$num - $prod' : num,
                          overflow: TextOverflow.ellipsis));
                }),
              ],
              onChanged: (v) => setSS(() => _createLoanId = v),
            )),
            const SizedBox(height: 20),
          ],
          // Submit
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitTicket(sc, setSS),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Text('Submit Ticket',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  void _submitTicket(BuildContext sc, StateSetter setSS) {
    final subj = _subjectCtrl.text.trim();
    final msg = _messageCtrl.text.trim();
    if (subj.isEmpty) { _snack(sc, 'Please enter a subject.', err: true); return; }
    if (msg.isEmpty) { _snack(sc, 'Please describe your issue.', err: true); return; }

    setSS(() => _isSubmitting = true);
    widget.onCreateTicket?.call(_createCat, subj, msg, _createLoanId, null);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (sc.mounted) Navigator.of(sc).pop();
      if (mounted) setState(() => _isSubmitting = false);
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // TICKET DETAIL SHEET
  // ═══════════════════════════════════════════════════════════════════

  void _showDetailSheet(Map<String, dynamic> ticket) {
    final ticketId = ticket['id']?.toString() ?? '';
    _replyCtrl.clear();
    _detail = null;
    _loadingDetail = true;
    _sendingReply = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (sc, setSS) {
        if (_loadingDetail && _detail == null) _loadDetail(ticketId, setSS);
        return _buildTicketDetailSheet(ticket, sc, setSS);
      }),
    );
  }

  Future<void> _loadDetail(String id, StateSetter setSS) async {
    if (widget.onLoadTicketDetail == null) {
      setSS(() { _loadingDetail = false; _detail = {}; });
      return;
    }
    try {
      final d = await widget.onLoadTicketDetail!(id);
      if (mounted) setSS(() { _detail = d; _loadingDetail = false; });
    } catch (e) {
      if (mounted) setSS(() { _loadingDetail = false; _detail = {'error': '$e'}; });
    }
  }

  Widget _buildTicketDetailSheet(
      Map<String, dynamic> ticket, BuildContext sc, StateSetter setSS) {
    final num_ = ticket['ticket_number']?.toString() ?? '';
    final subj = ticket['subject']?.toString() ?? 'No subject';
    final cat = ticket['category']?.toString() ?? 'GENERAL_INQUIRY';
    final status = ticket['status']?.toString() ?? 'OPEN';
    final priority = ticket['priority']?.toString() ?? 'NORMAL';
    final created = ticket['created_at']?.toString() ?? '';
    final ticketId = ticket['id']?.toString() ?? '';

    final det = _detail ?? {};
    final msgs = (det['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final err = det['error']?.toString();
    final closed = status == 'CLOSED' || status == 'RESOLVED';

    return DraggableScrollableSheet(
      initialChildSize: 0.9, maxChildSize: 0.95, minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          // Header
          Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)))),
              Row(children: [
                Expanded(child: Text(num_.isNotEmpty ? 'Ticket #$num_' : 'Ticket Detail',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
                IconButton(icon: const Icon(Icons.close, size: 22),
                    onPressed: () => Navigator.of(sc).pop(),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ]),
              const SizedBox(height: 6),
              Text(subj, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: [
                _buildStatusBadge(status),
                _buildCategoryBadge(cat),
                if (priority != 'NORMAL') Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (priority == 'URGENT' ? _errorRed : _warningAmber).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(priority, style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: priority == 'URGENT' ? _errorRed : _warningAmber)),
                ),
              ]),
              if (created.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('Opened ${_relativeTime(created)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
              const Divider(height: 20),
            ]),
          ),
          // Messages
          Expanded(
            child: _loadingDetail
                ? const Center(child: CircularProgressIndicator(color: _primaryColor))
                : err != null
                    ? _buildDetailError(err)
                    : msgs.isEmpty
                        ? Center(child: Text('No messages yet.',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14)))
                        : ListView.builder(
                            controller: ctrl,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            itemCount: msgs.length,
                            itemBuilder: (_, i) => _buildMessageBubble(msgs[i]),
                          ),
          ),
          // Reply input or closed notice
          if (!closed)
            _buildReplyBar(ticketId, sc, setSS, det, msgs)
          else
            Container(
              padding: const EdgeInsets.all(16), color: Colors.grey.shade50,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text('This ticket is ${status.toLowerCase()}.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ]),
            ),
        ]),
      ),
    );
  }

  Widget _buildDetailError(String err) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text('Could not load ticket details',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(err, style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center),
      ]),
    ));
  }

  Widget _buildReplyBar(String ticketId, BuildContext sc, StateSetter setSS,
      Map<String, dynamic> det, List<Map<String, dynamic>> msgs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8,
            offset: const Offset(0, -2)),
      ]),
      child: SafeArea(child: Row(children: [
        Expanded(child: TextField(
          controller: _replyCtrl, textCapitalization: TextCapitalization.sentences,
          maxLines: 3, minLines: 1,
          decoration: InputDecoration(
            hintText: 'Type your reply...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true, fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        )),
        const SizedBox(width: 8),
        Material(color: _primaryColor, borderRadius: BorderRadius.circular(24),
          child: InkWell(borderRadius: BorderRadius.circular(24),
            onTap: _sendingReply ? null : () => _sendReply(ticketId, setSS, det, msgs),
            child: SizedBox(width: 44, height: 44,
              child: Center(child: _sendingReply
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Icon(Icons.send, color: Colors.white, size: 20))),
          ),
        ),
      ])),
    );
  }

  void _sendReply(String ticketId, StateSetter setSS,
      Map<String, dynamic> det, List<Map<String, dynamic>> msgs) {
    final msg = _replyCtrl.text.trim();
    if (msg.isEmpty) return;
    setSS(() => _sendingReply = true);
    widget.onAddMessage?.call(ticketId, msg);
    final updated = List<Map<String, dynamic>>.from(msgs)
      ..add({'sender_type': 'CUSTOMER', 'message': msg,
          'created_at': DateTime.now().toIso8601String()});
    setSS(() {
      _detail = {...det, 'messages': updated};
      _sendingReply = false;
    });
    _replyCtrl.clear();
  }

  // ═══════════════════════════════════════════════════════════════════
  // MESSAGE BUBBLE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final type = message['sender_type']?.toString() ?? 'CUSTOMER';
    final text = message['message']?.toString() ?? '';
    final name = message['sender_name']?.toString();
    final time = message['created_at']?.toString() ?? '';
    if (type == 'SYSTEM') return _systemMsg(text, time);

    final isCust = type == 'CUSTOMER';
    final bgClr = isCust ? _primaryColor : Colors.grey.shade200;
    final txtClr = isCust ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(crossAxisAlignment: isCust ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCust && name != null && name.isNotEmpty)
            Padding(padding: const EdgeInsets.only(left: 36, bottom: 2),
              child: Text(name, style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w600, color: Colors.grey.shade600))),
          Row(mainAxisAlignment: isCust ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isCust) ...[
                CircleAvatar(radius: 14, backgroundColor: Colors.grey.shade400,
                  child: const Icon(Icons.support_agent, size: 16, color: Colors.white)),
                const SizedBox(width: 8),
              ],
              Flexible(child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: bgClr,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isCust ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isCust ? Radius.zero : const Radius.circular(16),
                  )),
                child: Text(text, style: TextStyle(fontSize: 14, color: txtClr, height: 1.3)),
              )),
              if (isCust) ...[
                const SizedBox(width: 8),
                CircleAvatar(radius: 14, backgroundColor: _primaryColor.withOpacity(0.7),
                  child: const Icon(Icons.person, size: 16, color: Colors.white)),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: isCust ? 48 : 36, right: isCust ? 36 : 48, top: 2),
            child: Text(_msgTime(time), style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ),
        ],
      ),
    );
  }

  Widget _systemMsg(String text, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16)),
          child: Text(text, style: TextStyle(fontSize: 12,
              fontStyle: FontStyle.italic, color: Colors.grey.shade600),
              textAlign: TextAlign.center),
        ),
        if (time.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2),
          child: Text(_msgTime(time), style: TextStyle(fontSize: 10, color: Colors.grey.shade400))),
      ])),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Widget _dropdownWrap(Widget dropdown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(child: dropdown),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint,
      {int maxLines = 1, int minLines = 1, int maxLen = 100}) {
    return TextField(
      controller: ctrl, textCapitalization: TextCapitalization.sentences,
      maxLines: maxLines, minLines: minLines, maxLength: maxLen,
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        counterText: '',
      ),
    );
  }

  String _relativeTime(String iso) {
    if (iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return _dateFmt.format(d);
    } catch (_) { return iso; }
  }

  String _msgTime(String iso) {
    if (iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inDays == 0) return _timeFmt.format(d);
      if (diff.inDays < 7) return '${diff.inDays}d ago, ${_timeFmt.format(d)}';
      return _dateTimeFmt.format(d);
    } catch (_) { return iso; }
  }

  void _snack(BuildContext ctx, String msg, {bool err = false}) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: err ? _errorRed : _successGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }
}
