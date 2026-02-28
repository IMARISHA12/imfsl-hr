// IMFSL KYC Review Queue - FlutterFlow Custom Widget
// ===================================================
// Admin KYC review queue with:
// - Status filter chips (Pending, Approved, Rejected)
// - Bulk action bar for multi-select approve/reject
// - Submission list with liveness badges
// - Detail bottom sheet with applicant info and actions
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslKycReviewQueue extends StatefulWidget {
  const ImfslKycReviewQueue({
    super.key,
    this.submissions = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.currentFilter = 'PENDING',
    this.onFilterChange,
    this.onLoadMore,
    this.onApprove,
    this.onReject,
    this.onBulkApprove,
    this.onBulkReject,
    this.onRefresh,
  });

  final List<Map<String, dynamic>> submissions;
  final int totalCount;
  final bool isLoading;
  final String currentFilter;
  final Function(String)? onFilterChange;
  final VoidCallback? onLoadMore;
  final Function(String kycId)? onApprove;
  final Function(String kycId, String reason)? onReject;
  final Function(List<String> kycIds)? onBulkApprove;
  final Function(List<String> kycIds, String reason)? onBulkReject;
  final VoidCallback? onRefresh;

  @override
  State<ImfslKycReviewQueue> createState() => _ImfslKycReviewQueueState();
}

class _ImfslKycReviewQueueState extends State<ImfslKycReviewQueue> {
  final Set<String> _selectedIds = {};
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !widget.isLoading) {
      widget.onLoadMore?.call();
    }
  }

  bool get _allSelected =>
      widget.submissions.isNotEmpty &&
      widget.submissions.every(
          (s) => _selectedIds.contains(s['id']?.toString() ?? ''));

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        _selectedIds.clear();
      } else {
        for (final s in widget.submissions) {
          final id = s['id']?.toString() ?? '';
          if (id.isNotEmpty) _selectedIds.add(id);
        }
      }
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  int _countByStatus(String status) {
    return widget.submissions
        .where((s) => (s['status'] as String? ?? '') == status)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterChips(),
        if (_selectedIds.isNotEmpty) _buildBulkActionBar(),
        Expanded(
          child: widget.isLoading && widget.submissions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => widget.onRefresh?.call(),
                  child: _buildSubmissionList(),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildChip('PENDING', 'Pending', Colors.amber, _countByStatus('PENDING')),
          const SizedBox(width: 8),
          _buildChip('APPROVED', 'Approved', Colors.green, _countByStatus('APPROVED')),
          const SizedBox(width: 8),
          _buildChip('REJECTED', 'Rejected', Colors.red, _countByStatus('REJECTED')),
        ],
      ),
    );
  }

  Widget _buildChip(String value, String label, Color color, int count) {
    final isSelected = widget.currentFilter == value;
    return ChoiceChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : color.shade700,
        ),
      ),
      selected: isSelected,
      selectedColor: color.shade600,
      backgroundColor: color.shade50,
      side: BorderSide(color: isSelected ? color.shade600 : color.shade200),
      onSelected: (_) => widget.onFilterChange?.call(value),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1565C0).withValues(alpha: 0.08),
      child: Row(
        children: [
          Checkbox(
            value: _allSelected,
            onChanged: (_) => _toggleSelectAll(),
            activeColor: const Color(0xFF1565C0),
          ),
          Text(
            '${_selectedIds.length} selected',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              widget.onBulkApprove?.call(_selectedIds.toList());
              setState(() => _selectedIds.clear());
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Approve', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: () => _showBulkRejectDialog(),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Reject', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionList() {
    if (widget.submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No submissions found',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.submissions.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.submissions.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildSubmissionTile(widget.submissions[index]);
      },
    );
  }

  Widget _buildSubmissionTile(Map<String, dynamic> submission) {
    final id = submission['id']?.toString() ?? '';
    final name = submission['applicant_name'] as String? ?? 'Unknown';
    final nationalId = submission['national_id'] as String? ?? '-';
    final phone = submission['phone'] as String? ?? '-';
    final livenessPassed = submission['liveness_passed'] as bool? ?? false;
    final source = submission['submission_source'] as String? ?? '-';
    final status = submission['status'] as String? ?? 'PENDING';
    final submittedAt = submission['submitted_at'] as String?;
    final isSelected = _selectedIds.contains(id);

    return GestureDetector(
      onTap: () => _showDetailSheet(submission),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1565C0).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleSelection(id),
              activeColor: const Color(0xFF1565C0),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.badge_outlined,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(nationalId,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 12),
                      Icon(Icons.phone_outlined,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(phone,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildLivenessBadge(livenessPassed),
                      const SizedBox(width: 8),
                      Icon(Icons.source_outlined,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(source,
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500])),
                      const Spacer(),
                      if (submittedAt != null)
                        Text(
                          _formatTimestamp(submittedAt),
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivenessBadge(bool passed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: passed ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: passed ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 3),
          Text(
            passed ? 'Liveness OK' : 'Liveness Failed',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: passed ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'APPROVED':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'REJECTED':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return _dateFmt.format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  void _showDetailSheet(Map<String, dynamic> submission) {
    final id = submission['id']?.toString() ?? '';
    final name = submission['applicant_name'] as String? ?? 'Unknown';
    final nationalId = submission['national_id'] as String? ?? '-';
    final phone = submission['phone'] as String? ?? '-';
    final email = submission['email'] as String? ?? '-';
    final dob = submission['date_of_birth'] as String? ?? '-';
    final gender = submission['gender'] as String? ?? '-';
    final livenessPassed = submission['liveness_passed'] as bool? ?? false;
    final livenessResult =
        submission['liveness_result'] as Map<String, dynamic>? ?? {};
    final deviceMeta =
        submission['device_meta'] as Map<String, dynamic>? ?? {};
    final status = submission['status'] as String? ?? 'PENDING';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF1565C0),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            _buildStatusBadge(status),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailSection('Applicant Information', [
                    _buildDetailRow('Full Name', name),
                    _buildDetailRow('National ID', nationalId),
                    _buildDetailRow('Phone', phone),
                    _buildDetailRow('Email', email),
                    _buildDetailRow('Date of Birth', dob),
                    _buildDetailRow('Gender', gender),
                  ]),
                  const SizedBox(height: 16),
                  _buildDetailSection('Liveness Results', [
                    _buildDetailRow(
                        'Status', livenessPassed ? 'Passed' : 'Failed'),
                    ...livenessResult.entries.map(
                      (e) => _buildDetailRow(
                          _formatKey(e.key), e.value?.toString() ?? '-'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildDetailSection('Device Metadata', [
                    ...deviceMeta.entries.map(
                      (e) => _buildDetailRow(
                          _formatKey(e.key), e.value?.toString() ?? '-'),
                    ),
                    if (deviceMeta.isEmpty)
                      _buildDetailRow('Info', 'No device data available'),
                  ]),
                  const SizedBox(height: 24),
                  if (status == 'PENDING') _buildDetailActions(ctx, id),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailActions(BuildContext sheetContext, String id) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(sheetContext).pop();
              widget.onApprove?.call(id);
            },
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(sheetContext).pop();
              _showRejectDialog(id);
            },
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(String kycId) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Reject KYC Submission',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Enter the reason...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Reason is required';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogCtx).pop();
                  widget.onReject?.call(kycId, reasonController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _showBulkRejectDialog() {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Reject Selected Submissions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedIds.length} submissions will be rejected.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Reason for rejection',
                    hintText: 'Enter the reason...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Reason is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogCtx).pop();
                  widget.onBulkReject?.call(
                      _selectedIds.toList(), reasonController.text.trim());
                  setState(() => _selectedIds.clear());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject All'),
            ),
          ],
        );
      },
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}
