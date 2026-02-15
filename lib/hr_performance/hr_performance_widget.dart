import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/backend/supabase/hr_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hr_performance_model.dart';
export 'hr_performance_model.dart';

/// Performance — Monthly KPI scores and history from staff_performance_monthly.
///
/// TAB 1 (Tathmini): Latest month's KPI breakdown
/// TAB 2 (Historia): Monthly performance history with grades
class HrPerformanceWidget extends StatefulWidget {
  const HrPerformanceWidget({super.key});

  static String routeName = 'HrPerformance';
  static String routePath = '/hrPerformance';

  @override
  State<HrPerformanceWidget> createState() => _HrPerformanceWidgetState();
}

class _HrPerformanceWidgetState extends State<HrPerformanceWidget>
    with SingleTickerProviderStateMixin {
  late HrPerformanceModel _model;
  late TabController _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HrPerformanceModel());
    _tabController = TabController(length: 2, vsync: this);

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final records =
          await HrService.instance.getMyPerformance(currentUserUid);
      _model.reviews = records;
      _model.isLoading = false;
    } catch (e) {
      _model.isLoading = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hitilafu kupakia data: $e')),
        );
      }
    }
    safeSetState(() {});
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A),
          title: Text(
            'Utendaji',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  letterSpacing: 0.0,
                ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0x99FFFFFF),
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Tathmini'),
              Tab(text: 'Historia'),
            ],
          ),
        ),
        body: _model.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildLatestTab(context),
                  _buildHistoryTab(context),
                ],
              ),
      ),
    );
  }

  // ── TAB 1: Latest Month KPI Breakdown ──────────────────────────────

  Widget _buildLatestTab(BuildContext context) {
    if (_model.reviews.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bar_chart,
                        size: 64.0, color: Color(0xFF9CA3AF)),
                    const SizedBox(height: 12.0),
                    Text(
                      'Hakuna data ya utendaji',
                      style: FlutterFlowTheme.of(context).bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final latest = _model.reviews.first;
    final grade = latest['grade'] as String? ?? '-';
    final overallScore = latest['overall_score'] as num? ?? 0;
    final monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = (latest['month'] as int?) ?? 0;
    final year = (latest['year'] as int?) ?? 0;
    final periodLabel =
        '${month > 0 && month <= 12 ? monthNames[month] : month} $year';

    final gradeColors = {
      'A': const Color(0xFF059669),
      'B': const Color(0xFF3B82F6),
      'C': const Color(0xFFF59E0B),
      'D': const Color(0xFFEF4444),
      'F': const Color(0xFF991B1B),
    };
    final gradeColor = gradeColors[grade] ?? const Color(0xFF6B7280);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Grade header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradeColor, gradeColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  Text(
                    periodLabel,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: const Color(0xCCFFFFFF),
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    grade,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 56.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Alama: ${overallScore.toStringAsFixed(1)}',
                    style: GoogleFonts.inter(
                      color: const Color(0xCCFFFFFF),
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            // KPI breakdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vipimo vya Utendaji',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w600),
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 14.0),
                  _kpiBar('Mahudhurio',
                      latest['attendance_score'] as num? ?? 0, 100),
                  _kpiBar('Ukusanyaji',
                      latest['collection_score'] as num? ?? 0, 100),
                  _kpiBar('Huduma kwa Wateja',
                      latest['customer_satisfaction_score'] as num? ?? 0, 100),
                  _kpiBar('Kufuata Sheria',
                      latest['compliance_score'] as num? ?? 0, 100),
                ],
              ),
            ),
            const SizedBox(height: 14.0),
            // Attendance details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maelezo ya Mahudhurio',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w600),
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statBadge('Siku Kazini',
                          '${latest['days_worked'] ?? 0}',
                          const Color(0xFF059669)),
                      _statBadge('Kuchelewa',
                          '${latest['days_late'] ?? 0}',
                          const Color(0xFFF59E0B)),
                      _statBadge('Kutokuwepo',
                          '${latest['days_absent'] ?? 0}',
                          const Color(0xFFEF4444)),
                    ],
                  ),
                ],
              ),
            ),
            if (latest['recommendation'] != null) ...[
              const SizedBox(height: 14.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0x1A3B82F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mapendekezo',
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w600),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      latest['recommendation'] as String? ?? '',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            letterSpacing: 0.0,
                          ),
                    ),
                    if (latest['recommendation_reason'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          latest['recommendation_reason'] as String,
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(
                                        fontStyle: FontStyle.italic),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kpiBar(String label, num score, num maxScore) {
    final progress = maxScore > 0 ? (score / maxScore).clamp(0.0, 1.0) : 0.0;
    final color = progress >= 0.8
        ? const Color(0xFF059669)
        : progress >= 0.6
            ? const Color(0xFF3B82F6)
            : progress >= 0.4
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13.0, fontWeight: FontWeight.w500)),
              Text('${score.toStringAsFixed(1)}',
                  style: GoogleFonts.inter(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
          const SizedBox(height: 6.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.interTight(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11.0, color: const Color(0xFF9CA3AF))),
      ],
    );
  }

  // ── TAB 2: History ───────────────────────────────────────────────────

  Widget _buildHistoryTab(BuildContext context) {
    if (_model.reviews.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Text(
                  'Hakuna rekodi za utendaji',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        itemCount: _model.reviews.length,
        itemBuilder: (context, index) {
          final record = _model.reviews[index];
          final grade = record['grade'] as String? ?? '-';
          final score = record['overall_score'] as num?;
          final month = (record['month'] as int?) ?? 0;
          final year = (record['year'] as int?) ?? 0;
          final periodLabel =
              '${month > 0 && month <= 12 ? monthNames[month] : month} $year';

          final gradeColors = {
            'A': const Color(0xFF059669),
            'B': const Color(0xFF3B82F6),
            'C': const Color(0xFFF59E0B),
            'D': const Color(0xFFEF4444),
            'F': const Color(0xFF991B1B),
          };

          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color:
                        (gradeColors[grade] ?? const Color(0xFF6B7280))
                            .withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      grade,
                      style: GoogleFonts.interTight(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: gradeColors[grade] ??
                            const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        periodLabel,
                        style: FlutterFlowTheme.of(context)
                            .bodyLarge
                            .override(
                              font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600),
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        'Siku ${record['days_worked'] ?? 0} kazini, ${record['days_late'] ?? 0} kuchelewa',
                        style: FlutterFlowTheme.of(context)
                            .bodySmall
                            .override(
                              font: GoogleFonts.inter(),
                              color: FlutterFlowTheme.of(context)
                                  .secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ),
                if (score != null)
                  Text(
                    '${score.toStringAsFixed(1)}',
                    style: GoogleFonts.interTight(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: gradeColors[grade] ??
                            const Color(0xFF6B7280)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
