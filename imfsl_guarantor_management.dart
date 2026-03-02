// IMFSL Guarantor Management Widget
// ===================================
// Customer-facing guarantor management screen with two sections:
//   1. My Commitments — guarantees the customer has made for others
//   2. Pending Invites — unlinked guarantor requests awaiting linking
//
// Supports accept/decline with confirmation dialogs, linking of unlinked
// invites, pull-to-refresh, and loading shimmer placeholders.
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslGuarantorManagement extends StatefulWidget {
  const ImfslGuarantorManagement({
    super.key,
    this.commitments = const [],
    this.invites = const [],
    this.isLoading = false,
    this.onRespond,
    this.onLink,
    this.onRefresh,
  });

  /// Guarantor commitments the current user has made. Keys: guarantor_id,
  /// borrower_name, loan_number, loan_amount, guarantee_amount, status,
  /// responded_at.
  final List<Map<String, dynamic>> commitments;

  /// Unlinked guarantor invites. Keys: guarantor_id, guarantor_name,
  /// borrower_name, loan_number, loan_amount, guarantee_amount.
  final List<Map<String, dynamic>> invites;

  final bool isLoading;

  /// Called on accept/decline: (guarantorId, 'ACCEPTED'|'DECLINED').
  final Function(String guarantorId, String response)? onRespond;

  /// Called when "Link & Respond" is tapped on an unlinked invite.
  final Function(String guarantorId)? onLink;

  final VoidCallback? onRefresh;

  @override
  State<ImfslGuarantorManagement> createState() =>
      _ImfslGuarantorManagementState();
}

class _ImfslGuarantorManagementState extends State<ImfslGuarantorManagement> {
  static const _primaryColor = Color(0xFF1565C0);
  static const _successGreen = Color(0xFF2E7D32);
  static const _errorRed = Color(0xFFC62828);
  static const _warningOrange = Color(0xFFEF6C00);

  final _currencyFmt = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  final _dateFmt = DateFormat('dd MMM yyyy');

  String? _respondingInviteId; // invite in respond-mode after linking

  static const _statusColors = <String, Color>{
    'ACCEPTED': _successGreen,
    'DECLINED': _errorRed,
    'PENDING': _warningOrange,
  };
  static const _statusIcons = <String, IconData>{
    'ACCEPTED': Icons.check_circle,
    'DECLINED': Icons.cancel,
    'PENDING': Icons.hourglass_empty,
  };

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.commitments.isEmpty && widget.invites.isEmpty) {
      return _buildLoadingShimmer();
    }
    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh?.call(),
      color: _primaryColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildSectionHeader('My Commitments', widget.commitments.length),
          if (widget.commitments.isEmpty)
            _buildEmptyState(
              Icons.handshake_outlined,
              'No guarantor commitments yet',
              'When you guarantee a loan for someone, it will appear here.',
            )
          else
            ...widget.commitments.map(_buildCommitmentCard),
          const SizedBox(height: 8),
          _buildSectionHeader('Pending Invites', widget.invites.length),
          if (widget.invites.isEmpty)
            _buildEmptyState(
              Icons.mail_outline,
              'No pending invites',
              'Guarantor requests that need your attention will show here.',
            )
          else
            ...widget.invites.map(_buildInviteCard),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(count.toString(),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor)),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // COMMITMENT CARD
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildCommitmentCard(Map<String, dynamic> c) {
    final status = (c['status']?.toString() ?? 'PENDING').toUpperCase();
    final borrower = c['borrower_name']?.toString() ?? 'Unknown';
    final loanNo = c['loan_number']?.toString() ?? '--';
    final loanAmt = (c['loan_amount'] as num?) ?? 0;
    final guarAmt = (c['guarantee_amount'] as num?) ?? 0;
    final respondedAt = c['responded_at']?.toString();
    final gId = c['guarantor_id']?.toString() ?? '';
    final isPending = status == 'PENDING';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header: borrower name + status badge
          Row(children: [
            _iconBox(Icons.person_outline, _primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(borrower,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF212121)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('Loan #$loanNo', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ]),
            ),
            _buildStatusBadge(status),
          ]),
          const SizedBox(height: 14),
          // Amounts row
          _buildAmountsRow(loanAmt, guarAmt),
          // Responded at
          if (respondedAt != null) ...[
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('Responded on ${_fmtDate(respondedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ]),
          ],
          // Action buttons for PENDING
          if (isPending) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildAcceptDeclineRow(borrower, gId, isInvite: false),
          ],
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // INVITE CARD
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildInviteCard(Map<String, dynamic> inv) {
    final guarName = inv['guarantor_name']?.toString() ?? 'Unknown';
    final borrower = inv['borrower_name']?.toString() ?? 'Unknown';
    final loanNo = inv['loan_number']?.toString() ?? '--';
    final loanAmt = (inv['loan_amount'] as num?) ?? 0;
    final guarAmt = (inv['guarantee_amount'] as num?) ?? 0;
    final gId = inv['guarantor_id']?.toString() ?? '';
    final isResponding = _respondingInviteId == gId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _warningOrange.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              _iconBox(Icons.link, _warningOrange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(guarName,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF212121)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('Invited to guarantee',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _warningOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('UNLINKED',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _warningOrange,
                        letterSpacing: 0.5)),
              ),
            ]),
            const SizedBox(height: 14),
            // Borrower details
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(children: [
                _detailRow('Borrower', borrower, Icons.person),
                const SizedBox(height: 6),
                _detailRow('Loan #', loanNo, Icons.receipt_long),
                const SizedBox(height: 6),
                _detailRow('Loan Amount', _currencyFmt.format(loanAmt),
                    Icons.account_balance_wallet),
                const SizedBox(height: 6),
                _detailRow('Your Guarantee', _currencyFmt.format(guarAmt), Icons.shield,
                    valueColor: _primaryColor, bold: true),
              ]),
            ),
            const SizedBox(height: 14),
            // Action area
            if (isResponding) ...[
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text('Account linked successfully. Please respond:',
                  style: TextStyle(
                      fontSize: 13, color: _successGreen, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              _buildAcceptDeclineRow(borrower, gId, isInvite: true),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLink(gId),
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Link & Respond'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STATUS BADGE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStatusBadge(String status) {
    final color = _statusColors[status] ?? Colors.grey;
    final icon = _statusIcons[status] ?? Icons.help_outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(_capFirst(status),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CONFIRM DIALOG
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _showConfirm(String action, String borrower, String gId,
      {bool isInvite = false}) async {
    final ok = await _buildConfirmDialog(action, borrower);
    if (ok == true) {
      if (isInvite) setState(() => _respondingInviteId = null);
      widget.onRespond?.call(gId, action);
    }
  }

  Future<bool?> _buildConfirmDialog(String action, String borrowerName) {
    final isAccept = action == 'ACCEPTED';
    final color = isAccept ? _successGreen : _errorRed;
    final icon = isAccept ? Icons.check_circle : Icons.cancel;
    final label = isAccept ? 'Accept' : 'Decline';
    final desc = isAccept
        ? 'You are agreeing to guarantee the loan for $borrowerName. '
            'This means you may be liable if the borrower defaults.'
        : 'You are declining the guarantee request from $borrowerName. '
            'This action cannot be undone.';

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
              child: Text('$label Guarantee?',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc,
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      isAccept
                          ? 'Your commitment will be recorded.'
                          : 'The borrower will be notified of your decision.',
                      style:
                          TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(IconData icon, String message, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
          child: Icon(icon, size: 40, color: Colors.grey[400]),
        ),
        const SizedBox(height: 16),
        Text(message,
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        const SizedBox(height: 6),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.3)),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOADING SHIMMER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildLoadingShimmer() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _shimmerHeader(140),
        ...List.generate(3, (_) => _buildCardShimmer()),
        const SizedBox(height: 8),
        _shimmerHeader(130),
        ...List.generate(2, (_) => _buildCardShimmer()),
      ],
    );
  }

  Widget _shimmerHeader(double titleW) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        _shimmerBox(width: titleW, height: 20),
        const SizedBox(width: 8),
        _shimmerBox(width: 28, height: 20, radius: 12),
      ]),
    );
  }

  Widget _buildCardShimmer() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _shimmerBox(width: 38, height: 38, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _shimmerBox(width: 150, height: 16),
                const SizedBox(height: 6),
                _shimmerBox(width: 90, height: 12),
              ]),
            ),
            _shimmerBox(width: 80, height: 26, radius: 16),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Expanded(
                  child: Column(children: [
                _shimmerBox(width: 80, height: 10),
                const SizedBox(height: 6),
                _shimmerBox(width: 100, height: 14),
              ])),
              Container(width: 1, height: 30, color: Colors.grey[200]),
              Expanded(
                  child: Column(children: [
                _shimmerBox(width: 80, height: 10),
                const SizedBox(height: 6),
                _shimmerBox(width: 100, height: 14),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
          _shimmerBox(width: double.infinity, height: 12),
        ]),
      ),
    );
  }

  Widget _shimmerBox({required double height, double? width, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(radius)),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SHARED HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildAmountsRow(num loanAmt, num guarAmt) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(children: [
        Expanded(child: _amtCol('Loan Amount', _currencyFmt.format(loanAmt))),
        Container(width: 1, height: 36, color: Colors.grey[300]),
        Expanded(child: _amtCol('Your Guarantee', _currencyFmt.format(guarAmt))),
      ]),
    );
  }

  Widget _amtCol(String label, String value) {
    return Column(children: [
      Text(label,
          style:
              TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF212121)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
    ]);
  }

  Widget _detailRow(String label, String value, IconData icon,
      {Color? valueColor, bool bold = false}) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey[500]),
      const SizedBox(width: 8),
      Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      Expanded(
        child: Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? const Color(0xFF212121)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end),
      ),
    ]);
  }

  Widget _buildAcceptDeclineRow(String borrower, String gId,
      {required bool isInvite}) {
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () =>
              _showConfirm('DECLINED', borrower, gId, isInvite: isInvite),
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Decline'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _errorRed,
            side: const BorderSide(color: _errorRed),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () =>
              _showConfirm('ACCEPTED', borrower, gId, isInvite: isInvite),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Accept'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _successGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 10),
            elevation: 0,
          ),
        ),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════

  void _handleLink(String guarantorId) {
    widget.onLink?.call(guarantorId);
    setState(() => _respondingInviteId = guarantorId);
  }

  String _fmtDate(String s) {
    try {
      return _dateFmt.format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  String _capFirst(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}
