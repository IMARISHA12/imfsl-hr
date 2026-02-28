// IMFSL Audit Log Viewer - FlutterFlow Custom Widget
// ===================================================
// Full audit trail viewer with filtering, search, and detail view.
// - Search bar with free-text search
// - Filter row with event type, date range, actor search
// - Severity filter chips (INFO, WARNING, ERROR, CRITICAL)
// - Paginated log list with severity icons
// - Detail bottom sheet with JSON diff view
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslAuditLogViewer extends StatefulWidget {
  const ImfslAuditLogViewer({
    super.key,
    this.entries = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.eventTypes = const [
      'STAFF_ROLE_CHANGED',
      'STAFF_ACTIVATED',
      'STAFF_DEACTIVATED',
      'STAFF_ONBOARDED',
      'KYC_APPROVED',
      'KYC_REJECTED',
      'LOAN_APPROVED',
      'LOAN_REJECTED',
    ],
    this.onSearch,
    this.onLoadMore,
    this.onRefresh,
  });

  final List<Map<String, dynamic>> entries;
  final int totalCount;
  final bool isLoading;
  final List<String> eventTypes;
  final Function(Map<String, dynamic> filters)? onSearch;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;

  @override
  State<ImfslAuditLogViewer> createState() => _ImfslAuditLogViewerState();
}

class _ImfslAuditLogViewerState extends State<ImfslAuditLogViewer> {
  static const Color _primaryColor = Color(0xFF1565C0);

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _actorController = TextEditingController();
  final DateFormat _timestampFmt = DateFormat('dd MMM yyyy HH:mm:ss');
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');
  final JsonEncoder _jsonEncoder = const JsonEncoder.withIndent('  ');

  String? _selectedEventType;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  final Set<String> _selectedSeverities = {};

  @override
  void dispose() {
    _searchController.dispose();
    _actorController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      filters['search'] = searchText;
    }
    if (_selectedEventType != null) {
      filters['event_type'] = _selectedEventType;
    }
    if (_dateFrom != null) {
      filters['date_from'] = _dateFrom!.toIso8601String();
    }
    if (_dateTo != null) {
      filters['date_to'] = _dateTo!.toIso8601String();
    }
    final actorText = _actorController.text.trim();
    if (actorText.isNotEmpty) {
      filters['actor_id'] = actorText;
    }
    if (_selectedSeverities.isNotEmpty) {
      filters['severity'] = _selectedSeverities.toList();
    }
    widget.onSearch?.call(filters);
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom ? (_dateFrom ?? now) : (_dateTo ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
      _applyFilters();
    }
  }

  IconData _severityIcon(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'INFO':
        return Icons.info_outline;
      case 'WARNING':
        return Icons.warning_amber;
      case 'ERROR':
        return Icons.error_outline;
      case 'CRITICAL':
        return Icons.dangerous;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _severityColor(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'INFO':
        return Colors.blue;
      case 'WARNING':
        return Colors.amber.shade700;
      case 'ERROR':
        return Colors.orange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is DateTime) {
      return _timestampFmt.format(timestamp);
    }
    if (timestamp is String) {
      final parsed = DateTime.tryParse(timestamp);
      if (parsed != null) {
        return _timestampFmt.format(parsed);
      }
      return timestamp;
    }
    return timestamp.toString();
  }

  String _prettyJson(dynamic data) {
    if (data == null) return 'null';
    if (data is String) {
      try {
        final decoded = json.decode(data);
        return _jsonEncoder.convert(decoded);
      } catch (_) {
        return data;
      }
    }
    try {
      return _jsonEncoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  void _showDetailSheet(Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildSheetHeader(entry),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      children: [
                        _buildActorSection(entry),
                        const SizedBox(height: 16),
                        _buildEntitySection(entry),
                        const SizedBox(height: 16),
                        _buildDescriptionSection(entry),
                        const SizedBox(height: 16),
                        _buildJsonDiffSection(entry),
                        const SizedBox(height: 16),
                        _buildMetadataSection(entry),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        const SizedBox(height: 12),
        _buildFilterRow(),
        const SizedBox(height: 12),
        _buildSeverityChips(),
        const SizedBox(height: 12),
        _buildResultsCount(),
        const SizedBox(height: 8),
        Expanded(
          child: _buildLogList(),
        ),
      ],
    );
  }

  // -- Search Bar --

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search audit logs...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon:
                      const Icon(Icons.clear, color: Colors.grey, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            borderSide: const BorderSide(color: _primaryColor, width: 1.5),
          ),
        ),
        onSubmitted: (_) => _applyFilters(),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // -- Filter Row --

  Widget _buildFilterRow() {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildEventTypeDropdown(),
            const SizedBox(width: 8),
            _buildDateButton(
              label: _dateFrom != null ? _dateFmt.format(_dateFrom!) : 'From',
              icon: Icons.calendar_today,
              isActive: _dateFrom != null,
              onTap: () => _pickDate(isFrom: true),
              onClear: _dateFrom != null
                  ? () {
                      setState(() => _dateFrom = null);
                      _applyFilters();
                    }
                  : null,
            ),
            const SizedBox(width: 8),
            _buildDateButton(
              label: _dateTo != null ? _dateFmt.format(_dateTo!) : 'To',
              icon: Icons.calendar_today,
              isActive: _dateTo != null,
              onTap: () => _pickDate(isFrom: false),
              onClear: _dateTo != null
                  ? () {
                      setState(() => _dateTo = null);
                      _applyFilters();
                    }
                  : null,
            ),
            const SizedBox(width: 8),
            _buildActorSearchField(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _selectedEventType != null
            ? _primaryColor.withValues(alpha: 0.08)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _selectedEventType != null
              ? _primaryColor.withValues(alpha: 0.4)
              : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEventType,
          hint: const Text('Event Type',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Events',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
            ...widget.eventTypes.map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 13),
                  ),
                )),
          ],
          onChanged: (value) {
            setState(() => _selectedEventType = value);
            _applyFilters();
          },
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? _primaryColor.withValues(alpha: 0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? _primaryColor.withValues(alpha: 0.4)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isActive ? _primaryColor : Colors.grey),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? _primaryColor : Colors.grey[600],
                )),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close,
                    size: 16,
                    color: isActive ? _primaryColor : Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActorSearchField() {
    return SizedBox(
      width: 160,
      child: TextField(
        controller: _actorController,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Actor name/ID',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon:
              const Icon(Icons.person_outline, color: Colors.grey, size: 18),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primaryColor, width: 1.5),
          ),
        ),
        onSubmitted: (_) => _applyFilters(),
      ),
    );
  }

  // -- Severity Filter Chips --

  Widget _buildSeverityChips() {
    const severities = [
      _SeverityChipData('INFO', Colors.blue),
      _SeverityChipData('WARNING', Color(0xFFF9A825)),
      _SeverityChipData('ERROR', Colors.orange),
      _SeverityChipData('CRITICAL', Colors.red),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: severities.map((s) {
          final isSelected = _selectedSeverities.contains(s.label);
          return FilterChip(
            label: Text(s.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : s.color,
                )),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedSeverities.add(s.label);
                } else {
                  _selectedSeverities.remove(s.label);
                }
              });
              _applyFilters();
            },
            selectedColor: s.color,
            backgroundColor: s.color.withValues(alpha: 0.1),
            checkmarkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected
                    ? s.color
                    : s.color.withValues(alpha: 0.4),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        }).toList(),
      ),
    );
  }

  // -- Results Count --

  Widget _buildResultsCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Showing ${widget.entries.length} of ${widget.totalCount} entries',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  // -- Log List --

  Widget _buildLogList() {
    if (widget.isLoading && widget.entries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    if (widget.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No audit log entries found',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }

    final hasMore = widget.entries.length < widget.totalCount;

    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: () async {
        widget.onRefresh?.call();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.entries.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.entries.length) {
            return _buildLoadMoreButton();
          }
          return _buildLogEntry(widget.entries[index]);
        },
      ),
    );
  }

  Widget _buildLogEntry(Map<String, dynamic> entry) {
    final severity = entry['severity'] as String?;
    final eventType = entry['event_type'] as String? ?? 'UNKNOWN';
    final actorName = entry['actor_name'] as String? ?? '';
    final actorRole = entry['actor_role'] as String? ?? '';
    final entityType = entry['entity_type'] as String? ?? '';
    final tableName = entry['table_name'] as String? ?? '';
    final timestamp = entry['created_at'] ?? entry['timestamp'];

    final sevColor = _severityColor(severity);
    final sevIcon = _severityIcon(severity);

    return GestureDetector(
      onTap: () => _showDetailSheet(entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: sevColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(sevIcon, color: sevColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventType.replaceAll('_', ' '),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (actorName.isNotEmpty || actorRole.isNotEmpty)
                    Text(
                      [actorName, if (actorRole.isNotEmpty) actorRole]
                          .join(' - '),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (entityType.isNotEmpty || tableName.isNotEmpty)
                    Text(
                      [entityType, if (tableName.isNotEmpty) tableName]
                          .join(' / '),
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 3),
                  Text(
                    _formatTimestamp(timestamp),
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: widget.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: _primaryColor),
              )
            : OutlinedButton.icon(
                onPressed: widget.onLoadMore,
                icon: const Icon(Icons.expand_more, size: 18),
                label: const Text('Load More', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: const BorderSide(color: _primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
              ),
      ),
    );
  }

  // -- Detail Bottom Sheet Parts --

  Widget _buildSheetHeader(Map<String, dynamic> entry) {
    final severity = entry['severity'] as String?;
    final eventType = entry['event_type'] as String? ?? 'UNKNOWN';
    final timestamp = entry['created_at'] ?? entry['timestamp'];
    final sevColor = _severityColor(severity);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  eventType.replaceAll('_', ' '),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              if (severity != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sevColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sevColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(timestamp),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildActorSection(Map<String, dynamic> entry) {
    final actorName = entry['actor_name'] as String? ?? '-';
    final actorRole = entry['actor_role'] as String? ?? '-';
    final ipAddress = entry['ip_address'] as String? ?? '-';
    final userAgent = entry['user_agent'] as String? ?? '-';

    return _buildDetailCard(
      title: 'Actor',
      icon: Icons.person_outline,
      children: [
        _buildDetailRow('Name', actorName),
        _buildDetailRow('Role', actorRole),
        _buildDetailRow('IP Address', ipAddress),
        _buildDetailRow('User Agent', userAgent),
      ],
    );
  }

  Widget _buildEntitySection(Map<String, dynamic> entry) {
    final entityType = entry['entity_type'] as String? ?? '-';
    final tableName = entry['table_name'] as String? ?? '-';
    final recordId = entry['record_id']?.toString() ?? '-';

    return _buildDetailCard(
      title: 'Entity',
      icon: Icons.description_outlined,
      children: [
        _buildDetailRow('Entity Type', entityType),
        _buildDetailRow('Table Name', tableName),
        _buildDetailRow('Record ID', recordId),
      ],
    );
  }

  Widget _buildDescriptionSection(Map<String, dynamic> entry) {
    final description = entry['action_description'] as String?;
    final businessContext = entry['business_context'] as String?;

    if (description == null && businessContext == null) {
      return const SizedBox.shrink();
    }

    return _buildDetailCard(
      title: 'Description',
      icon: Icons.notes,
      children: [
        if (description != null) ...[
          Text(description,
              style: const TextStyle(fontSize: 13, height: 1.5)),
          const SizedBox(height: 8),
        ],
        if (businessContext != null) ...[
          Text('Business Context',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(businessContext,
              style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ],
    );
  }

  Widget _buildJsonDiffSection(Map<String, dynamic> entry) {
    final oldData = entry['old_data'];
    final newData = entry['new_data'];
    final changedFields = entry['changed_fields'];

    if (oldData == null && newData == null) {
      return const SizedBox.shrink();
    }

    return _buildDetailCard(
      title: 'Data Changes',
      icon: Icons.compare_arrows,
      children: [
        if (changedFields != null && changedFields is List) ...[
          Text('Changed Fields',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600])),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (changedFields as List).map<Widget>((field) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: _primaryColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  field.toString(),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _primaryColor),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (oldData != null) ...[
          _buildJsonBlock('Before', _prettyJson(oldData)),
          const SizedBox(height: 10),
        ],
        if (newData != null) ...[
          _buildJsonBlock('After', _prettyJson(newData)),
        ],
      ],
    );
  }

  Widget _buildJsonBlock(String label, String jsonText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600])),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              jsonText,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection(Map<String, dynamic> entry) {
    final correlationId = entry['correlation_id']?.toString();
    final sourceSystem = entry['source_system']?.toString();
    final sequenceNumber = entry['sequence_number']?.toString();

    if (correlationId == null &&
        sourceSystem == null &&
        sequenceNumber == null) {
      return const SizedBox.shrink();
    }

    return _buildDetailCard(
      title: 'Metadata',
      icon: Icons.info_outline,
      children: [
        if (correlationId != null)
          _buildDetailRow('Correlation ID', correlationId),
        if (sourceSystem != null)
          _buildDetailRow('Source System', sourceSystem),
        if (sequenceNumber != null)
          _buildDetailRow('Sequence Number', sequenceNumber),
      ],
    );
  }

  // -- Shared Detail Helpers --

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _primaryColor),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SeverityChipData {
  final String label;
  final Color color;
  const _SeverityChipData(this.label, this.color);
}
