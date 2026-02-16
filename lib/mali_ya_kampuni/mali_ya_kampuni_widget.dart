import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'mali_ya_kampuni_model.dart';
export 'mali_ya_kampuni_model.dart';

/// Mali ya Kampuni — Company Assets & Technology Monitoring
///
/// Full-featured asset management page with:
/// - KPI Cards: Total Asset Value, Depreciation, Maintenance Due, Fraud Alerts
/// - Tab sections: Assets, OCR Scanner, Fraud Detection, Technology Monitoring, Alerts
/// - Live OCR scanning with camera/scanner
/// - AI fraud detection with auto-quarantine
/// - Technology health monitoring dashboard
/// - Real-time system alerts
///
/// Style: Blue primary (#1E3A8A), consistent with HR Dashboard
class MaliYaKampuniWidget extends StatefulWidget {
  const MaliYaKampuniWidget({super.key});

  static String routeName = 'MaliYaKampuni';
  static String routePath = '/maliYaKampuni';

  @override
  State<MaliYaKampuniWidget> createState() => _MaliYaKampuniWidgetState();
}

class _MaliYaKampuniWidgetState extends State<MaliYaKampuniWidget>
    with SingleTickerProviderStateMixin {
  late MaliYaKampuniModel _model;
  late TabController _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MaliYaKampuniModel());
    _tabController = TabController(length: 5, vsync: this);

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (currentUserUid == '') {
        context.pushNamed(LoginPageWidget.routeName);
        return;
      }
      await _loadAllData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // DATA LOADING
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadAllData() async {
    try {
      setState(() => _model.isLoading = true);

      final results = await Future.wait([
        // 0: Asset category summary view
        SupaFlow.client.from('v_company_asset_summary').select(),
        // 1: All assets
        SupaFlow.client.from('company_assets').select().eq('status', 'active').order('created_at', ascending: false).limit(100),
        // 2: Maintenance due
        SupaFlow.client.from('v_maintenance_due').select().limit(50),
        // 3: Fraud alerts dashboard
        SupaFlow.client.from('v_fraud_alerts_dashboard').select().limit(50),
        // 4: System alerts (open)
        SupaFlow.client.from('asset_system_alerts').select().eq('status', 'open').order('created_at', ascending: false).limit(50),
        // 5: Technology health
        SupaFlow.client.from('v_tech_system_health').select(),
        // 6: Recent attachments
        SupaFlow.client.from('asset_attachments').select().order('created_at', ascending: false).limit(20),
        // 7: Quarantined documents
        SupaFlow.client.from('asset_attachments').select('id').eq('status', 'quarantined'),
        // 8: Expiring insurance
        SupaFlow.client.from('v_asset_insurance_expiring').select().limit(20),
      ]);

      if (!mounted) return;

      final categoryStats = (results[0] is List) ? (results[0] as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      final assets = (results[1] is List) ? (results[1] as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      final maintenanceList = (results[2] is List) ? (results[2] as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      final fraudAlertsList = (results[3] is List) ? (results[3] as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      final systemAlerts = (results[4] is List) ? (results[4] as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      final techHealth = (results[5] is List) ? (results[5] as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      final recentAttachments = (results[6] is List) ? (results[6] as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      final quarantined = (results[7] is List) ? (results[7] as List) : [];
      final expiringInsurance = (results[8] is List) ? (results[8] as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];

      // Calculate KPIs
      double totalValue = 0;
      double totalDepr = 0;
      for (final cat in categoryStats) {
        totalValue += (cat['total_purchase_value'] as num?)?.toDouble() ?? 0;
        totalDepr += (cat['total_depreciation'] as num?)?.toDouble() ?? 0;
      }

      setState(() {
        _model.categoryStats = categoryStats;
        _model.assets = assets;
        _model.maintenanceList = maintenanceList;
        _model.fraudAlertsList = fraudAlertsList;
        _model.systemAlerts = systemAlerts;
        _model.techHealth = techHealth;
        _model.recentAttachments = recentAttachments;
        _model.expiringInsurance = expiringInsurance;
        _model.totalAssets = assets.length;
        _model.totalAssetValue = totalValue;
        _model.totalDepreciation = totalDepr;
        _model.maintenanceDue = maintenanceList.length;
        _model.fraudAlerts = fraudAlertsList.length;
        _model.quarantinedDocs = quarantined.length;
        _model.isLoading = false;
        _model.errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _model.isLoading = false;
          _model.errorMessage = 'Imeshindwa kupakia data: ${e.toString()}';
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1E3A8A);
    const cardRadius = 16.0;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text(
          'Mali ya Kampuni',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          // Fraud alert badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.security, color: Colors.white),
                onPressed: () => _tabController.animateTo(2),
              ),
              if (_model.fraudAlerts > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_model.fraudAlerts}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2, size: 18), text: 'Mali'),
            Tab(icon: Icon(Icons.document_scanner, size: 18), text: 'OCR'),
            Tab(icon: Icon(Icons.shield, size: 18), text: 'Udanganyifu'),
            Tab(icon: Icon(Icons.monitor_heart, size: 18), text: 'Teknolojia'),
            Tab(icon: Icon(Icons.warning_amber, size: 18), text: 'Tahadhari'),
          ],
        ),
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : _model.errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    // KPI Row (always visible)
                    _buildKpiRow(primaryBlue),
                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAssetsTab(primaryBlue, cardRadius),
                          _buildOcrTab(primaryBlue, cardRadius),
                          _buildFraudTab(primaryBlue, cardRadius),
                          _buildTechTab(primaryBlue, cardRadius),
                          _buildAlertsTab(primaryBlue, cardRadius),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryBlue,
        onPressed: _showAddAssetDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ongeza Mali', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // KPI ROW
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildKpiRow(Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _kpiCard(
              'Thamani ya Mali',
              _formatCurrency(_model.totalAssetValue),
              Icons.account_balance_wallet,
              const Color(0xFF059669),
            ),
            const SizedBox(width: 8),
            _kpiCard(
              'Kushuka Thamani',
              _formatCurrency(_model.totalDepreciation),
              Icons.trending_down,
              const Color(0xFFDC2626),
            ),
            const SizedBox(width: 8),
            _kpiCard(
              'Matengenezo',
              '${_model.maintenanceDue}',
              Icons.build_circle,
              const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 8),
            _kpiCard(
              'Udanganyifu',
              '${_model.fraudAlerts}',
              Icons.warning,
              _model.fraudAlerts > 0 ? Colors.red : const Color(0xFF059669),
            ),
            const SizedBox(width: 8),
            _kpiCard(
              'Karantini',
              '${_model.quarantinedDocs}',
              Icons.block,
              _model.quarantinedDocs > 0 ? const Color(0xFFDC2626) : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TAB 1: ASSETS (Mali)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildAssetsTab(Color primary, double radius) {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Category breakdown
          _sectionTitle('Muhtasari wa Kategoria', Icons.pie_chart),
          const SizedBox(height: 8),
          ..._model.categoryStats.map((cat) => _categoryRow(cat)),

          const SizedBox(height: 16),

          // Insurance expiring
          if (_model.expiringInsurance.isNotEmpty) ...[
            _sectionTitle('Bima Zinazoisha', Icons.health_and_safety),
            const SizedBox(height: 8),
            ..._model.expiringInsurance.map((ins) => _insuranceRow(ins)),
            const SizedBox(height: 16),
          ],

          // Maintenance due
          if (_model.maintenanceList.isNotEmpty) ...[
            _sectionTitle('Matengenezo Yanayosubiri', Icons.build),
            const SizedBox(height: 8),
            ..._model.maintenanceList.take(5).map((m) => _maintenanceRow(m)),
            const SizedBox(height: 16),
          ],

          // Asset list
          _sectionTitle('Mali Zote (${_model.totalAssets})', Icons.inventory_2),
          const SizedBox(height: 8),
          ..._model.assets.map((asset) => _assetRow(asset)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _categoryRow(Map<String, dynamic> cat) {
    final category = (cat['asset_category'] ?? 'N/A').toString();
    final total = (cat['total_assets'] as num?)?.toInt() ?? 0;
    final active = (cat['active_assets'] as num?)?.toInt() ?? 0;
    final value = (cat['total_purchase_value'] as num?)?.toDouble() ?? 0;
    final deprPct = (cat['depreciation_pct'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
          child: Icon(_categoryIcon(category), color: const Color(0xFF1E3A8A), size: 20),
        ),
        title: Text(_categoryLabel(category), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('$active hai / $total jumla | Kupungua: ${deprPct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
        trailing: Text(_formatCurrency(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF059669))),
      ),
    );
  }

  Widget _assetRow(Map<String, dynamic> asset) {
    final name = asset['asset_name']?.toString() ?? 'N/A';
    final code = asset['asset_code']?.toString() ?? '';
    final category = asset['asset_category']?.toString() ?? '';
    final condition = asset['condition']?.toString() ?? '';
    final value = (asset['current_book_value'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: _conditionColor(condition).withOpacity(0.15),
          child: Icon(_categoryIcon(category), size: 16, color: _conditionColor(condition)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text('$code | ${_categoryLabel(category)} | $condition', style: const TextStyle(fontSize: 11)),
        trailing: Text(_formatCurrency(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _maintenanceRow(Map<String, dynamic> m) {
    final title = m['title']?.toString() ?? 'N/A';
    final assetName = m['asset_name']?.toString() ?? '';
    final priority = m['priority']?.toString() ?? 'medium';
    final urgency = m['urgency']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      color: urgency == 'overdue' ? const Color(0xFFFEE2E2) : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.build_circle,
          color: priority == 'critical' ? Colors.red : priority == 'high' ? Colors.orange : Colors.amber,
          size: 24,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text('$assetName | $urgency', style: const TextStyle(fontSize: 11)),
        trailing: _priorityBadge(priority),
      ),
    );
  }

  Widget _insuranceRow(Map<String, dynamic> ins) {
    final name = ins['asset_name']?.toString() ?? 'N/A';
    final status = ins['insurance_status']?.toString() ?? '';
    final days = (ins['days_until_expiry'] as num?)?.toInt() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      color: status == 'expired' ? const Color(0xFFFEE2E2) : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.health_and_safety,
          color: status == 'expired' ? Colors.red : status == 'expiring_soon' ? Colors.orange : Colors.green,
          size: 20,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(status == 'expired' ? 'IMEISHA' : 'Siku $days zilizobaki', style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TAB 2: OCR SCANNER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildOcrTab(Color primary, double radius) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // OCR Action Cards
        _sectionTitle('Changanua Hati (OCR)', Icons.document_scanner),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _ocrActionCard('Piga Picha', Icons.camera_alt, 'camera_live', primary)),
            const SizedBox(width: 8),
            Expanded(child: _ocrActionCard('Scanner', Icons.scanner, 'scanner', primary)),
            const SizedBox(width: 8),
            Expanded(child: _ocrActionCard('Pakia Faili', Icons.upload_file, 'upload', primary)),
          ],
        ),
        const SizedBox(height: 16),

        // Processing status
        if (_model.isProcessingOcr)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primary)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Inachakata OCR na AI Fraud Detection...',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Recent attachments with OCR status
        _sectionTitle('Viambatisho vya Hivi Karibuni', Icons.attach_file),
        const SizedBox(height: 8),
        ..._model.recentAttachments.map((att) => _attachmentRow(att)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _ocrActionCard(String label, IconData icon, String method, Color primary) {
    return InkWell(
      onTap: () => _handleOcrCapture(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: primary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _attachmentRow(Map<String, dynamic> att) {
    final fileName = att['file_name']?.toString() ?? 'N/A';
    final ocrStatus = att['ocr_status']?.toString() ?? 'pending';
    final fraudStatus = att['fraud_check_status']?.toString() ?? 'pending';
    final riskScore = (att['fraud_risk_score'] as num?)?.toInt() ?? 0;
    final captureMethod = att['capture_method']?.toString() ?? 'upload';

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      color: fraudStatus == 'fraudulent' ? const Color(0xFFFEE2E2) :
             fraudStatus == 'suspicious' ? const Color(0xFFFEF3C7) : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          _captureIcon(captureMethod),
          color: _fraudStatusColor(fraudStatus),
          size: 20,
        ),
        title: Text(fileName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            _statusChip('OCR: $ocrStatus', _ocrStatusColor(ocrStatus)),
            const SizedBox(width: 4),
            _statusChip('Risk: $riskScore', _riskColor(riskScore)),
          ],
        ),
        trailing: fraudStatus == 'fraudulent'
          ? const Icon(Icons.dangerous, color: Colors.red, size: 20)
          : fraudStatus == 'suspicious'
            ? const Icon(Icons.warning, color: Colors.orange, size: 20)
            : const Icon(Icons.check_circle, color: Colors.green, size: 20),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TAB 3: FRAUD DETECTION (Udanganyifu)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildFraudTab(Color primary, double radius) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Fraud summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _model.fraudAlerts > 0
                ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
                : [const Color(0xFF059669), const Color(0xFF10B981)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _model.fraudAlerts > 0 ? Icons.shield : Icons.verified_user,
                color: Colors.white, size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _model.fraudAlerts > 0
                        ? 'TAHADHARI: Hati ${_model.fraudAlerts} zenye mashaka!'
                        : 'Hali Salama — Hakuna udanganyifu',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Karantini: ${_model.quarantinedDocs} | AI inaendelea kufuatilia',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fraud alerts list
        _sectionTitle('Maonyo ya Udanganyifu', Icons.shield),
        const SizedBox(height: 8),
        if (_model.fraudAlertsList.isEmpty)
          _emptyState('Hakuna maonyo ya udanganyifu', Icons.check_circle_outline)
        else
          ..._model.fraudAlertsList.map((alert) => _fraudAlertRow(alert)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _fraudAlertRow(Map<String, dynamic> alert) {
    final fileName = alert['file_name']?.toString() ?? 'N/A';
    final riskScore = (alert['risk_score'] as num?)?.toInt() ?? 0;
    final riskLevel = alert['risk_level']?.toString() ?? 'low';
    final verdict = alert['verdict']?.toString() ?? 'pending';
    final reasoning = alert['ai_reasoning']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: riskLevel == 'critical' ? const Color(0xFFFEE2E2) :
             riskLevel == 'high' ? const Color(0xFFFEF3C7) : null,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _riskColor(riskScore),
          radius: 18,
          child: Text('$riskScore', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        title: Text(fileName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Row(
          children: [
            _statusChip(riskLevel.toUpperCase(), _riskLevelColor(riskLevel)),
            const SizedBox(width: 4),
            _statusChip(verdict, _verdictColor(verdict)),
          ],
        ),
        children: [
          if (reasoning.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Uchambuzi:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(reasoning, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleFraudVerdict(alert, 'confirmed_authentic'),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Halali', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleFraudVerdict(alert, 'confirmed_fraud'),
                            icon: const Icon(Icons.dangerous, size: 16),
                            label: const Text('Udanganyifu', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TAB 4: TECHNOLOGY MONITORING (Teknolojia)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTechTab(Color primary, double radius) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionTitle('Afya ya Mfumo', Icons.monitor_heart),
        const SizedBox(height: 8),
        if (_model.techHealth.isEmpty)
          _emptyState('Hakuna data ya ufuatiliaji', Icons.monitor_heart)
        else
          ..._model.techHealth.map((sys) => _techHealthRow(sys)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _techHealthRow(Map<String, dynamic> sys) {
    final name = sys['system_name']?.toString() ?? 'N/A';
    final type = sys['system_type']?.toString() ?? '';
    final status = sys['status']?.toString() ?? 'unknown';
    final responseMs = (sys['response_time_ms'] as num?)?.toInt();
    final uptimePct = (sys['uptime_pct'] as num?)?.toDouble();
    final statusColor = sys['status_color']?.toString() ?? 'gray';

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _techStatusBgColor(statusColor),
          radius: 20,
          child: Icon(_techTypeIcon(type), color: _techStatusFgColor(statusColor), size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '${status.toUpperCase()}${responseMs != null ? ' | ${responseMs}ms' : ''}${uptimePct != null ? ' | ${uptimePct.toStringAsFixed(1)}%' : ''}',
          style: TextStyle(fontSize: 12, color: _techStatusFgColor(statusColor)),
        ),
        trailing: Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: _techStatusFgColor(statusColor),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TAB 5: SYSTEM ALERTS (Tahadhari)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildAlertsTab(Color primary, double radius) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionTitle('Tahadhari za Mfumo (${_model.systemAlerts.length})', Icons.warning_amber),
        const SizedBox(height: 8),
        if (_model.systemAlerts.isEmpty)
          _emptyState('Hakuna tahadhari', Icons.notifications_off)
        else
          ..._model.systemAlerts.map((alert) => _systemAlertRow(alert)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _systemAlertRow(Map<String, dynamic> alert) {
    final title = alert['title']?.toString() ?? 'N/A';
    final message = alert['message']?.toString() ?? '';
    final severity = alert['severity']?.toString() ?? 'info';
    final source = alert['alert_source']?.toString() ?? '';
    final createdAt = alert['created_at']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      color: severity == 'critical' ? const Color(0xFFFEE2E2) :
             severity == 'error' ? const Color(0xFFFEF3C7) : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          _severityIcon(severity),
          color: _severityColor(severity),
          size: 22,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2),
        subtitle: Text('$source | $createdAt', style: const TextStyle(fontSize: 11)),
        trailing: _statusChip(severity.toUpperCase(), _severityColor(severity)),
        onTap: () => _showAlertDetail(alert),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _priorityBadge(String priority) {
    final color = priority == 'critical' ? Colors.red : priority == 'high' ? Colors.orange : Colors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(priority.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 48, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
            const SizedBox(height: 12),
            Text(_model.errorMessage ?? 'Hitilafu', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh),
              label: const Text('Jaribu Tena'),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════

  String _formatCurrency(double amount) {
    if (amount >= 1e9) return 'TZS ${(amount / 1e9).toStringAsFixed(1)}B';
    if (amount >= 1e6) return 'TZS ${(amount / 1e6).toStringAsFixed(1)}M';
    if (amount >= 1e3) return 'TZS ${(amount / 1e3).toStringAsFixed(0)}K';
    return 'TZS ${amount.toStringAsFixed(0)}';
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'vehicle': return Icons.directions_car;
      case 'it_equipment': return Icons.computer;
      case 'office_furniture': return Icons.chair;
      case 'office_equipment': return Icons.print;
      case 'machinery': return Icons.precision_manufacturing;
      case 'building': return Icons.business;
      case 'land': return Icons.landscape;
      case 'software_license': return Icons.code;
      case 'infrastructure': return Icons.router;
      default: return Icons.inventory_2;
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'vehicle': return 'Magari';
      case 'it_equipment': return 'Vifaa vya IT';
      case 'office_furniture': return 'Samani za Ofisi';
      case 'office_equipment': return 'Vifaa vya Ofisi';
      case 'machinery': return 'Mashine';
      case 'building': return 'Majengo';
      case 'land': return 'Ardhi';
      case 'software_license': return 'Leseni za Software';
      case 'infrastructure': return 'Miundombinu';
      default: return 'Nyingine';
    }
  }

  Color _conditionColor(String condition) {
    switch (condition) {
      case 'new': return const Color(0xFF059669);
      case 'good': return const Color(0xFF2563EB);
      case 'fair': return const Color(0xFFF59E0B);
      case 'poor': return const Color(0xFFDC2626);
      case 'damaged': return Colors.red;
      default: return const Color(0xFF6B7280);
    }
  }

  IconData _captureIcon(String method) {
    switch (method) {
      case 'camera_capture': case 'camera_live': return Icons.camera_alt;
      case 'scanner': case 'ocr_scanner': return Icons.scanner;
      case 'email': return Icons.email;
      case 'whatsapp': return Icons.message;
      default: return Icons.upload_file;
    }
  }

  Color _ocrStatusColor(String status) {
    switch (status) {
      case 'completed': return const Color(0xFF059669);
      case 'processing': return const Color(0xFF2563EB);
      case 'failed': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _fraudStatusColor(String status) {
    switch (status) {
      case 'clean': return const Color(0xFF059669);
      case 'suspicious': return const Color(0xFFF59E0B);
      case 'fraudulent': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _riskColor(int score) {
    if (score >= 75) return const Color(0xFFDC2626);
    if (score >= 50) return const Color(0xFFF59E0B);
    if (score >= 25) return const Color(0xFFE97E10);
    return const Color(0xFF059669);
  }

  Color _riskLevelColor(String level) {
    switch (level) {
      case 'critical': return const Color(0xFFDC2626);
      case 'high': return const Color(0xFFEA580C);
      case 'medium': return const Color(0xFFF59E0B);
      case 'low': return const Color(0xFF059669);
      default: return const Color(0xFF059669);
    }
  }

  Color _verdictColor(String verdict) {
    switch (verdict) {
      case 'authentic': return const Color(0xFF059669);
      case 'suspicious': return const Color(0xFFF59E0B);
      case 'fraudulent': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical': return const Color(0xFFDC2626);
      case 'error': return const Color(0xFFEA580C);
      case 'warning': return const Color(0xFFF59E0B);
      default: return const Color(0xFF2563EB);
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'critical': return Icons.error;
      case 'error': return Icons.warning;
      case 'warning': return Icons.warning_amber;
      default: return Icons.info_outline;
    }
  }

  IconData _techTypeIcon(String type) {
    switch (type) {
      case 'database': return Icons.storage;
      case 'edge_function': return Icons.functions;
      case 'storage': return Icons.cloud;
      case 'auth': return Icons.lock;
      case 'network': return Icons.wifi;
      case 'api': return Icons.api;
      case 'cron': return Icons.schedule;
      default: return Icons.devices;
    }
  }

  Color _techStatusBgColor(String color) {
    switch (color) {
      case 'green': return const Color(0xFFDCFCE7);
      case 'yellow': return const Color(0xFFFEF9C3);
      case 'red': return const Color(0xFFFEE2E2);
      default: return const Color(0xFFF1F5F9);
    }
  }

  Color _techStatusFgColor(String color) {
    switch (color) {
      case 'green': return const Color(0xFF059669);
      case 'yellow': return const Color(0xFFF59E0B);
      case 'red': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7280);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════

  void _handleOcrCapture(String method) {
    // In production, this would launch camera/scanner/file picker
    // then upload to Supabase Storage and trigger the OCR + fraud pipeline
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OCR $method — Inaendelea kutengenezwa'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }

  Future<void> _handleFraudVerdict(Map<String, dynamic> alert, String verdict) async {
    try {
      final checkId = alert['fraud_check_id']?.toString();
      if (checkId == null) return;

      await SupaFlow.client.from('attachment_fraud_checks').update({
        'reviewed_by': currentUserUid,
        'reviewed_at': DateTime.now().toIso8601String(),
        'review_verdict': verdict,
      }).eq('id', checkId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verdict == 'confirmed_authentic' ? 'Imethibitishwa kuwa halali' : 'Imethibitishwa kuwa udanganyifu'),
            backgroundColor: verdict == 'confirmed_authentic' ? Colors.green : Colors.red,
          ),
        );
        await _loadAllData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hitilafu: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAlertDetail(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(alert['title']?.toString() ?? 'Tahadhari', style: const TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: Text(alert['message']?.toString() ?? '', style: const TextStyle(fontSize: 13)),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await SupaFlow.client.from('asset_system_alerts').update({
                  'status': 'acknowledged',
                  'acknowledged_by': currentUserUid,
                  'acknowledged_at': DateTime.now().toIso8601String(),
                }).eq('id', alert['id']);
                await _loadAllData();
              } catch (_) {}
            },
            child: const Text('Kubali'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Funga'),
          ),
        ],
      ),
    );
  }

  void _showAddAssetDialog() {
    // Add asset dialog — full form in production
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ongeza Mali Mpya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Fomu ya kuongeza mali mpya ya kampuni itakuwa hapa.\n\n'
                'Vipengele:\n'
                '- Kategoria (Gari, IT, Ofisi, n.k.)\n'
                '- Taarifa za mali (jina, serial, thamani)\n'
                '- Picha na hati (OCR + AI Fraud Check)\n'
                '- Eneo la GPS\n'
                '- Bima na dhamana',
                style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Funga', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
