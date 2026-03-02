// IMFSL Multi-Level Approval Workflow Widget
// =============================================
// Unified "Approvals" tab for the admin portal showing pending approval
// items across loan applications, restructures, and write-offs. Supports
// multi-level approval chains, role-based filtering, and ADMIN rule management.
//
// Usage:
//   ImfslApprovalWorkflow(
//     pendingApprovals: [...],
//     pendingTotalCount: 12,
//     currentUserRole: 'MANAGER',
//     onProcessApproval: (data) { ... },
//     onViewChain: (entityType, entityId) { ... },
//   )
//
// Dependencies (add to pubspec.yaml):
//   flutter/material.dart
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslApprovalWorkflow extends StatefulWidget {
  const ImfslApprovalWorkflow({
    super.key,
    this.pendingApprovals = const [],
    this.pendingTotalCount = 0,
    this.approvalRules = const [],
    this.isLoading = false,
    this.currentUserRole = 'OFFICER',
    this.currentFilter = 'ALL',
    this.onFilterChange,
    this.onProcessApproval,
    this.onViewChain,
    this.onRefresh,
    this.onLoadMore,
    this.onManageRules,
  });

  final List<Map<String, dynamic>> pendingApprovals;
  final int pendingTotalCount;
  final List<Map<String, dynamic>> approvalRules;
  final bool isLoading;
  final String currentUserRole;
  final String currentFilter;
  final Function(String)? onFilterChange;
  final Function(Map<String, dynamic>)? onProcessApproval;
  final Function(String entityType, String entityId)? onViewChain;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final Function({required String operation, Map<String, dynamic> ruleData})?
      onManageRules;

  @override
  State<ImfslApprovalWorkflow> createState() => _ImfslApprovalWorkflowState();
}

class _ImfslApprovalWorkflowState extends State<ImfslApprovalWorkflow> {
  static const _primaryColor = Color(0xFF1565C0);
  static const _kCurrency = 'KES ';
  final _currencyFormat =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  bool _showRulesOverlay = false;

  // ═══════════════════════════════════════════════════════════════════
  // COMPUTED STATS
  // ═══════════════════════════════════════════════════════════════════

  Map<String, int> get _countsByType {
    final counts = <String, int>{
      'LOAN_APPLICATION': 0,
      'LOAN_RESTRUCTURE': 0,
      'LOAN_WRITEOFF': 0,
    };
    for (final item in widget.pendingApprovals) {
      final type = item['entity_type']?.toString() ?? '';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  List<Map<String, dynamic>> get _filteredApprovals {
    if (widget.currentFilter == 'ALL') return widget.pendingApprovals;
    return widget.pendingApprovals
        .where((item) => item['entity_type'] == widget.currentFilter)
        .toList();
  }

  bool get _isAdmin => widget.currentUserRole.toUpperCase() == 'ADMIN';

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => widget.onRefresh?.call(),
          child: CustomScrollView(
            slivers: [
              // ── Summary Stats Card ──
              SliverToBoxAdapter(child: _buildSummaryCard()),
              // ── Filter Chips ──
              SliverToBoxAdapter(child: _buildFilterChips()),
              // ── Pending List ──
              if (widget.isLoading && widget.pendingApprovals.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: _primaryColor)),
                )
              else if (_filteredApprovals.isEmpty)
                SliverFillRemaining(child: _buildEmptyState())
              else ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _filteredApprovals.length) {
                        return null;
                      }
                      return _buildApprovalCard(_filteredApprovals[index]);
                    },
                    childCount: _filteredApprovals.length,
                  ),
                ),
                // Load more
                if (widget.pendingApprovals.length < widget.pendingTotalCount)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: widget.isLoading
                            ? const CircularProgressIndicator(color: _primaryColor)
                            : TextButton.icon(
                                onPressed: widget.onLoadMore,
                                icon: const Icon(Icons.expand_more),
                                label: Text(
                                  'Load more (${widget.pendingTotalCount - widget.pendingApprovals.length} remaining)',
                                ),
                              ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ],
          ),
        ),
        // ── Rules Management Overlay ──
        if (_showRulesOverlay) _buildRulesOverlay(),
        // ── ADMIN gear FAB ──
        if (_isAdmin && !_showRulesOverlay)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => setState(() => _showRulesOverlay = true),
              backgroundColor: _primaryColor,
              child: const Icon(Icons.settings, color: Colors.white),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SUMMARY CARD
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSummaryCard() {
    final counts = _countsByType;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.approval, color: _primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pending Approvals',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${widget.pendingTotalCount} items awaiting your review',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.pendingTotalCount > 0
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${widget.pendingTotalCount}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.pendingTotalCount > 0
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatChip(
                  'Loans',
                  counts['LOAN_APPLICATION'] ?? 0,
                  Icons.account_balance,
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  'Restructures',
                  counts['LOAN_RESTRUCTURE'] ?? 0,
                  Icons.build_circle,
                  Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  'Write-offs',
                  counts['LOAN_WRITEOFF'] ?? 0,
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color.shade700),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color.shade800),
            ),
            Text(label,
                style: TextStyle(fontSize: 10, color: color.shade600),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FILTER CHIPS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'ALL', 'label': 'All'},
      {'key': 'LOAN_APPLICATION', 'label': 'Loans'},
      {'key': 'LOAN_RESTRUCTURE', 'label': 'Restructures'},
      {'key': 'LOAN_WRITEOFF', 'label': 'Write-offs'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Wrap(
        spacing: 8,
        children: filters.map((f) {
          final isSelected = widget.currentFilter == f['key'];
          return FilterChip(
            label: Text(f['label']!),
            selected: isSelected,
            onSelected: (_) =>
                widget.onFilterChange?.call(f['key']!),
            selectedColor: _primaryColor.withOpacity(0.15),
            checkmarkColor: _primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? _primaryColor : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // APPROVAL CARD
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildApprovalCard(Map<String, dynamic> item) {
    final entityType = item['entity_type']?.toString() ?? '';
    final customerName = item['customer_name']?.toString() ?? 'Unknown';
    final amount = (item['amount'] as num?)?.toDouble() ?? 0;
    final stepNumber = (item['step_number'] as num?)?.toInt() ?? 1;
    final totalSteps = (item['total_steps'] as num?)?.toInt() ?? 1;
    final riskCategory = item['risk_category']?.toString();
    final requiredRole = item['required_min_role']?.toString() ?? '';
    final createdAt = item['created_at']?.toString() ?? '';
    final entityId = item['entity_id']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => _showApprovalDetailSheet(item),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Entity type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _entityColor(entityType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _entityIcon(entityType),
                  color: _entityColor(entityType),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(amount),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildEntityBadge(entityType),
                        const SizedBox(width: 6),
                        _buildStepBadge(stepNumber, totalSteps),
                        if (riskCategory != null) ...[
                          const SizedBox(width: 6),
                          _buildRiskBadge(riskCategory),
                        ],
                        const Spacer(),
                        Text(
                          _timeAgo(createdAt),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntityBadge(String entityType) {
    final label = _entityShortLabel(entityType);
    final color = _entityColor(entityType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildStepBadge(int step, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Step $step/$total',
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.purple.shade700),
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    final color = _riskColor(risk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        risk,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // DETAIL BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════════

  void _showApprovalDetailSheet(Map<String, dynamic> item) {
    final entityType = item['entity_type']?.toString() ?? '';
    final entityId = item['entity_id']?.toString() ?? '';
    final customerName = item['customer_name']?.toString() ?? 'Unknown';
    final amount = (item['amount'] as num?)?.toDouble() ?? 0;
    final stepNumber = (item['step_number'] as num?)?.toInt() ?? 1;
    final totalSteps = (item['total_steps'] as num?)?.toInt() ?? 1;
    final riskCategory = item['risk_category']?.toString();
    final ruleDesc = item['rule_description']?.toString() ?? '';

    final commentsController = TextEditingController();
    final amountController = TextEditingController(text: amount.toStringAsFixed(2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _entityColor(entityType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_entityIcon(entityType),
                            color: _entityColor(entityType), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_entityLabel(entityType),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                            Text(customerName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Info rows
                  _buildInfoRow('Amount', _currencyFormat.format(amount)),
                  _buildInfoRow('Approval Step', 'Step $stepNumber of $totalSteps'),
                  _buildInfoRow('Required Role', item['required_min_role']?.toString() ?? '-'),
                  if (riskCategory != null)
                    _buildInfoRow('Risk Category', riskCategory),
                  if (ruleDesc.isNotEmpty)
                    _buildInfoRow('Rule', ruleDesc),
                  const SizedBox(height: 16),
                  // View full chain button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onViewChain?.call(entityType, entityId);
                    },
                    icon: const Icon(Icons.timeline, size: 18),
                    label: const Text('View Full Approval Chain'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryColor,
                      side: const BorderSide(color: _primaryColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Approved amount (loans only)
                  if (entityType == 'LOAN_APPLICATION') ...[
                    const Text('Approved Amount',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixText: _kCurrency,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        hintText: 'Enter approved amount',
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  // Comments
                  const Text('Comments',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: commentsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Add comments (required for rejection)',
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final comments = commentsController.text.trim();
                            if (comments.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Comments are required for rejection'),
                                  backgroundColor: Colors.red.shade700,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            Navigator.pop(ctx);
                            widget.onProcessApproval?.call({
                              'entity_type': entityType,
                              'entity_id': entityId,
                              'decision': 'REJECT',
                              'comments': comments,
                            });
                          },
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final data = <String, dynamic>{
                              'entity_type': entityType,
                              'entity_id': entityId,
                              'decision': 'APPROVE',
                              'comments': commentsController.text.trim().isNotEmpty
                                  ? commentsController.text.trim()
                                  : null,
                            };
                            if (entityType == 'LOAN_APPLICATION') {
                              final parsed =
                                  double.tryParse(amountController.text.trim());
                              if (parsed != null && parsed > 0) {
                                data['approved_amount'] = parsed;
                              }
                            }
                            Navigator.pop(ctx);
                            widget.onProcessApproval?.call(data);
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(stepNumber < totalSteps
                              ? 'Approve & Escalate'
                              : 'Final Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text(
              'All caught up!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              widget.currentFilter == 'ALL'
                  ? 'No pending approvals for your role.'
                  : 'No pending ${_entityLabel(widget.currentFilter).toLowerCase()} approvals.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // RULES MANAGEMENT OVERLAY (ADMIN ONLY)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildRulesOverlay() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.settings, color: _primaryColor, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Approval Rules Configuration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showRulesOverlay = false),
                ),
              ],
            ),
          ),
          // Rules list
          Expanded(
            child: widget.approvalRules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rule, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No rules loaded',
                            style: TextStyle(color: Colors.grey.shade500)),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => widget.onManageRules
                              ?.call(operation: 'LIST', ruleData: {}),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Load Rules'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.approvalRules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      return _buildRuleCard(widget.approvalRules[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(Map<String, dynamic> rule) {
    final entityType = rule['entity_type']?.toString() ?? '';
    final levels = (rule['required_levels'] as num?)?.toInt() ?? 1;
    final isActive = rule['is_active'] == true;
    final desc = rule['description']?.toString() ?? '';
    final minAmt = (rule['min_amount'] as num?)?.toDouble() ?? 0;
    final maxAmt = rule['max_amount'] as num?;
    final risk = rule['risk_category']?.toString();
    final priority = (rule['priority'] as num?)?.toInt() ?? 0;

    final roles = <String>[];
    if (rule['level_1_min_role'] != null) roles.add(rule['level_1_min_role'].toString());
    if (rule['level_2_min_role'] != null) roles.add(rule['level_2_min_role'].toString());
    if (rule['level_3_min_role'] != null) roles.add(rule['level_3_min_role'].toString());

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildEntityBadge(entityType),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    desc.isNotEmpty ? desc : 'Rule (priority $priority)',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Inactive',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade600)),
                  ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      size: 18, color: Colors.grey.shade600),
                  onSelected: (value) {
                    if (value == 'deactivate') {
                      widget.onManageRules?.call(
                        operation: 'DEACTIVATE',
                        ruleData: {'rule_id': rule['id']},
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    if (isActive)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Text('Deactivate',
                            style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Amount range
            Row(
              children: [
                Icon(Icons.payments_outlined,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  maxAmt != null
                      ? '${_currencyFormat.format(minAmt)} - ${_currencyFormat.format(maxAmt)}'
                      : '${_currencyFormat.format(minAmt)}+',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                if (risk != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.warning_amber, size: 14, color: _riskColor(risk)),
                  const SizedBox(width: 4),
                  Text(risk,
                      style: TextStyle(fontSize: 12, color: _riskColor(risk))),
                ],
              ],
            ),
            const SizedBox(height: 6),
            // Approval chain
            Row(
              children: [
                Text('$levels-level: ',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
                ...roles.asMap().entries.map((entry) {
                  final i = entry.key;
                  final role = entry.value;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (i > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.arrow_forward,
                              size: 12, color: Colors.grey.shade400),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(role,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════

  IconData _entityIcon(String entityType) {
    switch (entityType) {
      case 'LOAN_APPLICATION':
        return Icons.account_balance;
      case 'LOAN_RESTRUCTURE':
        return Icons.build_circle;
      case 'LOAN_WRITEOFF':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _entityColor(String entityType) {
    switch (entityType) {
      case 'LOAN_APPLICATION':
        return Colors.blue;
      case 'LOAN_RESTRUCTURE':
        return Colors.orange;
      case 'LOAN_WRITEOFF':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _entityLabel(String entityType) {
    switch (entityType) {
      case 'LOAN_APPLICATION':
        return 'Loan Application';
      case 'LOAN_RESTRUCTURE':
        return 'Loan Restructure';
      case 'LOAN_WRITEOFF':
        return 'Loan Write-off';
      default:
        return entityType;
    }
  }

  String _entityShortLabel(String entityType) {
    switch (entityType) {
      case 'LOAN_APPLICATION':
        return 'LOAN';
      case 'LOAN_RESTRUCTURE':
        return 'RESTR';
      case 'LOAN_WRITEOFF':
        return 'W/OFF';
      default:
        return '?';
    }
  }

  Color _riskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'LOW':
        return Colors.green.shade700;
      case 'MEDIUM':
        return Colors.orange.shade700;
      case 'HIGH':
        return Colors.deepOrange.shade700;
      case 'VERY_HIGH':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade600;
    }
  }

  String _timeAgo(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('dd MMM').format(date);
    } catch (_) {
      return '';
    }
  }
}
