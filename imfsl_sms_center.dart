import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// IMFSL SMS Management Center.
///
/// Dashboard for managing SMS templates, sending individual and bulk messages,
/// viewing message logs, and tracking delivery metrics.
class ImfslSmsCenter extends StatefulWidget {
  final Map<String, dynamic> smsData;
  final List<dynamic> templates;
  final bool isLoading;
  final Function(Map<String, dynamic>)? onSendBulk;
  final VoidCallback? onRefresh;

  const ImfslSmsCenter({
    super.key,
    this.smsData = const {},
    this.templates = const [],
    this.isLoading = false,
    this.onSendBulk,
    this.onRefresh,
  });

  @override
  State<ImfslSmsCenter> createState() => _ImfslSmsCenterState();
}

class _ImfslSmsCenterState extends State<ImfslSmsCenter>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF1565C0);

  final NumberFormat _numFmt = NumberFormat('#,##0');
  final DateFormat _dateTimeFmt = DateFormat('dd MMM yyyy HH:mm');

  late TabController _tabController;

  // Template manager state
  int _selectedTemplateIndex = -1;
  bool _templateEditing = false;
  String _editLang = 'en';
  final TextEditingController _templateEnCtrl = TextEditingController();
  final TextEditingController _templateSwCtrl = TextEditingController();

  // Send SMS state
  int _sendTemplateIndex = -1;
  final TextEditingController _customerSearchCtrl = TextEditingController();
  final List<Map<String, dynamic>> _selectedCustomers = [];
  final Map<String, String> _variableValues = {};
  String _smsPreview = '';

  // Bulk send state
  String _bulkFilter = 'overdue';
  int _bulkTemplateIndex = -1;
  bool _bulkConfirmVisible = false;

  // Message log state
  String _logStatusFilter = 'ALL';

  static const Map<String, Color> _statusColors = {
    'SENT': Color(0xFF43A047),
    'FAILED': Color(0xFFE53935),
    'PENDING': Color(0xFFFF8F00),
    'RETRYING': Color(0xFF1565C0),
  };

  static const Map<String, IconData> _statusIcons = {
    'SENT': Icons.check_circle,
    'FAILED': Icons.error,
    'PENDING': Icons.schedule,
    'RETRYING': Icons.replay,
  };

  static const Map<String, Color> _categoryColors = {
    'REMINDER': Color(0xFF1565C0),
    'ALERT': Color(0xFFE53935),
    'MARKETING': Color(0xFF7B1FA2),
    'TRANSACTIONAL': Color(0xFF00897B),
    'COLLECTION': Color(0xFFFF8F00),
    'ONBOARDING': Color(0xFF43A047),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _templateEnCtrl.dispose();
    _templateSwCtrl.dispose();
    _customerSearchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> get _kpi =>
      widget.smsData['kpi'] as Map<String, dynamic>? ?? {};

  List<Map<String, dynamic>> get _typedTemplates =>
      widget.templates.cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> get _messageLog {
    final raw =
        (widget.smsData['message_log'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];
    if (_logStatusFilter == 'ALL') return raw;
    return raw
        .where((m) => m['status']?.toString() == _logStatusFilter)
        .toList();
  }

  List<Map<String, dynamic>> get _searchableCustomers =>
      (widget.smsData['customers'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  List<String> _templateVariables(Map<String, dynamic> tpl) {
    final text = tpl['text_en']?.toString() ?? '';
    final regex = RegExp(r'\{\{(\w+)\}\}');
    return regex.allMatches(text).map((m) => m.group(1)!).toSet().toList();
  }

  String _renderPreview(Map<String, dynamic> tpl) {
    var text = tpl['text_${_editLang}']?.toString() ??
        tpl['text_en']?.toString() ??
        '';
    for (final entry in _variableValues.entries) {
      text = text.replaceAll('{{${entry.key}}}', entry.value);
    }
    return text;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('SMS Center'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.isLoading ? null : widget.onRefresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard, size: 18)),
            Tab(text: 'Templates', icon: Icon(Icons.description, size: 18)),
            Tab(text: 'Send SMS', icon: Icon(Icons.send, size: 18)),
            Tab(text: 'Message Log', icon: Icon(Icons.history, size: 18)),
          ],
        ),
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildTemplatesTab(),
                _buildSendTab(),
                _buildLogTab(),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Dashboard
  // ---------------------------------------------------------------------------

  Widget _buildDashboardTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildKPICards(),
        const SizedBox(height: 16),
        _sectionHeader('Delivery Overview'),
        const SizedBox(height: 8),
        _buildDeliveryChart(),
        const SizedBox(height: 16),
        _sectionHeader('Quick Actions'),
        const SizedBox(height: 8),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildKPICards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: [
        _kpiCard('Sent Today', _numFmt.format(_kpi['sent_today'] ?? 0),
            Icons.today, _primary),
        _kpiCard('Sent This Week',
            _numFmt.format(_kpi['sent_week'] ?? 0), Icons.date_range,
            const Color(0xFF00897B)),
        _kpiCard(
            'Delivery Rate',
            '${((_kpi['delivery_rate'] as num?)?.toDouble() ?? 0).toStringAsFixed(1)}%',
            Icons.verified,
            const Color(0xFF43A047)),
        _kpiCard('Queue Pending',
            _numFmt.format(_kpi['queue_pending'] ?? 0), Icons.queue,
            const Color(0xFFFF8F00)),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
            ]),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryChart() {
    final daily = (widget.smsData['daily_stats'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];
    if (daily.isEmpty) return _emptyState('No delivery data');

    final maxCount = daily.fold<int>(
        1, (m, d) => ((d['count'] as int?) ?? 0) > m ? (d['count'] as int) : m);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Messages / Day (Last 7 days)',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: daily.map((d) {
                  final count = (d['count'] as int?) ?? 0;
                  final fraction =
                      maxCount > 0 ? count / maxCount : 0.0;
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('$count',
                              style: const TextStyle(fontSize: 9)),
                          const SizedBox(height: 2),
                          Container(
                            height: (fraction * 90).clamp(4, 90),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            d['label']?.toString() ?? '',
                            style: const TextStyle(fontSize: 9),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickActionCard(
              'Send Reminder', Icons.notifications_active, () {
            _tabController.animateTo(2);
          }),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _quickActionCard(
              'Bulk Send', Icons.group, () {
            _tabController.animateTo(2);
          }),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _quickActionCard(
              'View Log', Icons.history, () {
            _tabController.animateTo(3);
          }),
        ),
      ],
    );
  }

  Widget _quickActionCard(
      String label, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: _primary, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Templates
  // ---------------------------------------------------------------------------

  Widget _buildTemplatesTab() {
    final templates = _typedTemplates;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('SMS Templates (${templates.length})'),
        const SizedBox(height: 8),
        ...templates.asMap().entries.map((entry) =>
            _buildTemplateCard(entry.key, entry.value)),
        if (templates.isEmpty) _emptyState('No templates configured'),
      ],
    );
  }

  Widget _buildTemplateCard(int index, Map<String, dynamic> tpl) {
    final selected = _selectedTemplateIndex == index;
    final category = tpl['category']?.toString() ?? 'TRANSACTIONAL';
    final catColor = _categoryColors[category] ?? Colors.grey;
    final variables = _templateVariables(tpl);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() {
          _selectedTemplateIndex = selected ? -1 : index;
          _templateEditing = false;
          if (!selected) {
            _templateEnCtrl.text = tpl['text_en']?.toString() ?? '';
            _templateSwCtrl.text = tpl['text_sw']?.toString() ?? '';
          }
        }),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(category,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: catColor)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        tpl['name']?.toString() ?? 'Untitled',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  Icon(selected
                      ? Icons.expand_less
                      : Icons.expand_more),
                ],
              ),
              if (variables.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: variables
                      .map((v) => Chip(
                            label: Text('{{$v}}',
                                style: const TextStyle(fontSize: 10)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Colors.grey.shade100,
                          ))
                      .toList(),
                ),
              ],
              if (selected) ...[
                const Divider(height: 16),
                _buildTemplateDetail(tpl),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateDetail(Map<String, dynamic> tpl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'sw', label: Text('Swahili')),
              ],
              selected: {_editLang},
              onSelectionChanged: (s) =>
                  setState(() => _editLang = s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: _primary,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const Spacer(),
            if (!_templateEditing)
              TextButton.icon(
                onPressed: () =>
                    setState(() => _templateEditing = true),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_templateEditing) ...[
          TextField(
            controller:
                _editLang == 'en' ? _templateEnCtrl : _templateSwCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              labelText:
                  _editLang == 'en' ? 'English Text' : 'Swahili Text',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () =>
                      setState(() => _templateEditing = false),
                  child: const Text('Cancel')),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  setState(() => _templateEditing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Template saved'),
                        backgroundColor: Color(0xFF43A047)),
                  );
                },
                style:
                    FilledButton.styleFrom(backgroundColor: _primary),
                child: const Text('Save'),
              ),
            ],
          ),
        ] else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              tpl['text_${_editLang}']?.toString() ??
                  tpl['text_en']?.toString() ??
                  'No content',
              style: const TextStyle(fontSize: 13),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Send SMS
  // ---------------------------------------------------------------------------

  Widget _buildSendTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('Send Individual SMS'),
        const SizedBox(height: 8),
        _buildSendIndividual(),
        const SizedBox(height: 24),
        _sectionHeader('Bulk SMS'),
        const SizedBox(height: 8),
        _buildBulkSend(),
      ],
    );
  }

  Widget _buildSendIndividual() {
    final templates = _typedTemplates;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template selector
            const Text('1. Select Template',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _sendTemplateIndex >= 0 ? _sendTemplateIndex : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintText: 'Choose a template',
                isDense: true,
              ),
              items: templates.asMap().entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value['name']?.toString() ?? 'Template ${e.key}',
                      style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _sendTemplateIndex = v;
                    _variableValues.clear();
                    _smsPreview = '';
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Customer search
            const Text('2. Select Recipients',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _customerSearchCtrl,
              decoration: InputDecoration(
                hintText: 'Search customer by name or phone...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                isDense: true,
                suffixIcon: _customerSearchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _customerSearchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_customerSearchCtrl.text.isNotEmpty)
              _buildCustomerSearchResults(),
            if (_selectedCustomers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _selectedCustomers.map((c) {
                  return Chip(
                    label: Text(
                        c['name']?.toString() ?? 'Unknown',
                        style: const TextStyle(fontSize: 11)),
                    deleteIcon:
                        const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(
                        () => _selectedCustomers.remove(c)),
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),

            // Variable fill
            if (_sendTemplateIndex >= 0 &&
                _sendTemplateIndex < templates.length) ...[
              const Text('3. Fill Variables',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              ..._templateVariables(templates[_sendTemplateIndex])
                  .map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: v,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                          onChanged: (val) {
                            _variableValues[v] = val;
                            setState(() {
                              _smsPreview = _renderPreview(
                                  templates[_sendTemplateIndex]);
                            });
                          },
                        ),
                      )),
              const SizedBox(height: 8),

              // Preview
              const Text('4. Preview',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sms, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text('SMS Preview',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _smsPreview.isNotEmpty
                          ? _smsPreview
                          : _renderPreview(
                              templates[_sendTemplateIndex]),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedCustomers.isEmpty
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'SMS sent to ${_selectedCustomers.length} recipient(s)'),
                              backgroundColor: const Color(0xFF43A047),
                            ),
                          );
                        },
                  icon: const Icon(Icons.send, size: 18),
                  label: Text(
                      'Send to ${_selectedCustomers.length} recipient(s)'),
                  style: FilledButton.styleFrom(
                      backgroundColor: _primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSearchResults() {
    final query = _customerSearchCtrl.text.toLowerCase();
    final results = _searchableCustomers
        .where((c) {
          final name = (c['name']?.toString() ?? '').toLowerCase();
          final phone = (c['phone']?.toString() ?? '').toLowerCase();
          return name.contains(query) || phone.contains(query);
        })
        .take(5)
        .toList();

    if (results.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: results.map((c) {
          final alreadySelected = _selectedCustomers.any(
              (s) => s['id'] == c['id']);
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: _primary.withOpacity(0.1),
              child: Icon(Icons.person, size: 16, color: _primary),
            ),
            title: Text(c['name']?.toString() ?? '',
                style: const TextStyle(fontSize: 12)),
            subtitle: Text(c['phone']?.toString() ?? '',
                style: const TextStyle(fontSize: 11)),
            trailing: alreadySelected
                ? const Icon(Icons.check, color: Color(0xFF43A047),
                    size: 18)
                : const Icon(Icons.add, size: 18),
            onTap: alreadySelected
                ? null
                : () => setState(() {
                      _selectedCustomers.add(c);
                      _customerSearchCtrl.clear();
                    }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBulkSend() {
    final templates = _typedTemplates;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group, size: 20, color: _primary),
                const SizedBox(width: 8),
                const Text('Bulk Message',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const Divider(height: 20),

            // Filter
            const Text('Filter Customers',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _bulkFilterChip('Overdue Loans', 'overdue',
                    Icons.warning_amber),
                _bulkFilterChip('Savings Milestone', 'savings_milestone',
                    Icons.savings),
                _bulkFilterChip('All Customers', 'all',
                    Icons.people),
              ],
            ),
            const SizedBox(height: 12),

            // Template
            const Text('Template',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _bulkTemplateIndex >= 0 ? _bulkTemplateIndex : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintText: 'Choose template',
                isDense: true,
              ),
              items: templates.asMap().entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(
                      e.value['name']?.toString() ?? 'Template ${e.key}',
                      style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _bulkTemplateIndex = v);
              },
            ),
            const SizedBox(height: 12),

            if (!_bulkConfirmVisible)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _bulkTemplateIndex < 0
                      ? null
                      : () => setState(
                          () => _bulkConfirmVisible = true),
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Prepare Bulk Send'),
                ),
              )
            else
              _buildBulkConfirm(),
          ],
        ),
      ),
    );
  }

  Widget _bulkFilterChip(String label, String key, IconData icon) {
    final selected = _bulkFilter == key;
    return FilterChip(
      avatar: Icon(icon, size: 16,
          color: selected ? Colors.white : _primary),
      label: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: selected ? Colors.white : Colors.black87)),
      selected: selected,
      selectedColor: _primary,
      checkmarkColor: Colors.white,
      onSelected: (_) => setState(() => _bulkFilter = key),
    );
  }

  Widget _buildBulkConfirm() {
    final count = widget.smsData['bulk_count_$_bulkFilter'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber,
                  color: Color(0xFFFF8F00), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This will send SMS to $count customers matching "$_bulkFilter" filter.',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () =>
                    setState(() => _bulkConfirmVisible = false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  widget.onSendBulk?.call({
                    'filter': _bulkFilter,
                    'template_index': _bulkTemplateIndex,
                  });
                  setState(() => _bulkConfirmVisible = false);
                },
                style:
                    FilledButton.styleFrom(backgroundColor: _primary),
                child: Text('Confirm Send ($count)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4: Message Log
  // ---------------------------------------------------------------------------

  Widget _buildLogTab() {
    final log = _messageLog;

    return Column(
      children: [
        _buildLogStatusFilter(),
        Expanded(
          child: log.isEmpty
              ? _emptyState('No messages found')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: log.length,
                  itemBuilder: (ctx, i) => _buildLogEntry(log[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildLogStatusFilter() {
    const statuses = ['ALL', 'SENT', 'FAILED', 'PENDING', 'RETRYING'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses.map((s) {
            final selected = _logStatusFilter == s;
            final color = s == 'ALL' ? _primary : (_statusColors[s] ?? Colors.grey);
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(s,
                    style: TextStyle(
                        fontSize: 11,
                        color: selected ? Colors.white : Colors.black87)),
                selected: selected,
                selectedColor: color,
                checkmarkColor: Colors.white,
                onSelected: (_) =>
                    setState(() => _logStatusFilter = s),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogEntry(Map<String, dynamic> msg) {
    final status = msg['status']?.toString() ?? 'PENDING';
    final color = _statusColors[status] ?? Colors.grey;
    final icon = _statusIcons[status] ?? Icons.help;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(msg['recipient']?.toString() ?? 'Unknown',
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg['message']?.toString() ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(msg['sent_at']?.toString()),
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
          child: Text(status,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ),
        isThreeLine: true,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      return _dateTimeFmt.format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}
