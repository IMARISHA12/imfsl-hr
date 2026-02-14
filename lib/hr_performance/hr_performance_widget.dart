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

/// Performance Reviews — View pending reviews, submit self-assessment, history.
///
/// TAB 1 (Tathmini): Active reviews requiring self-assessment
/// TAB 2 (Historia): Past review results with grades
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
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HrPerformanceModel());
    _tabController = TabController(length: 2, vsync: this);

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _resolveEmployeeId();
      await _loadData();
    });
  }

  Future<void> _resolveEmployeeId() async {
    final rows = await EmployeesTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', currentUserUid).limit(1),
    );
    if (rows.isNotEmpty) {
      _employeeId = rows.first.id;
    }
  }

  Future<void> _loadData() async {
    if (_employeeId == null) {
      _model.isLoading = false;
      safeSetState(() {});
      return;
    }
    try {
      final reviews = await HrService.instance.getMyReviews(_employeeId!);
      _model.reviews = reviews;
      _model.isLoading = false;
    } catch (e) {
      _model.isLoading = false;
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
                  _buildPendingTab(context),
                  _buildHistoryTab(context),
                ],
              ),
      ),
    );
  }

  // ── TAB 1: Pending Reviews ───────────────────────────────────────────

  Widget _buildPendingTab(BuildContext context) {
    final pending = _model.reviews
        .where((r) =>
            r['status'] == 'pending' || r['status'] == 'self_review')
        .toList();

    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 64.0, color: Color(0xFF059669)),
            const SizedBox(height: 12.0),
            Text(
              'Hakuna tathmini zinazosubiri',
              style: FlutterFlowTheme.of(context).bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final review = pending[index];
        final cycle =
            review['performance_review_cycles'] as Map<String, dynamic>? ?? {};
        final cycleName = cycle['cycle_name'] ?? 'Review';
        final status = review['status'] ?? 'pending';

        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0x1A3B82F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cycleName,
                      style:
                          FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600),
                                letterSpacing: 0.0,
                              ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: const Color(0x1AF59E0B),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      status == 'pending'
                          ? 'Inasubiri'
                          : 'Tathmini Binafsi',
                      style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (cycle['period_start'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${cycle['period_start']} - ${cycle['period_end']}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color:
                              FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              const SizedBox(height: 12.0),
              SizedBox(
                width: double.infinity,
                child: FFButtonWidget(
                  onPressed: () => _showSelfReviewForm(context, review),
                  text: 'Jaza Tathmini Binafsi',
                  options: FFButtonOptions(
                    height: 40.0,
                    color: const Color(0xFF1E3A8A),
                    textStyle: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSelfReviewForm(
      BuildContext context, Map<String, dynamic> review) {
    // Reset scores
    _model.quality = 3;
    _model.productivity = 3;
    _model.teamwork = 3;
    _model.initiative = 3;
    _model.attendance = 3;
    _model.commentsController?.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollCtrl) => SingleChildScrollView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Tathmini Binafsi',
                  style:
                      FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold),
                            letterSpacing: 0.0,
                          ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Jikadirie 1-5 kwa kila eneo',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        color:
                            FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 20.0),
                _scoreSlider('Ubora wa Kazi', _model.quality,
                    (v) => setSheetState(() => _model.quality = v)),
                _scoreSlider('Tija', _model.productivity,
                    (v) => setSheetState(() => _model.productivity = v)),
                _scoreSlider('Ushirikiano', _model.teamwork,
                    (v) => setSheetState(() => _model.teamwork = v)),
                _scoreSlider('Ubunifu', _model.initiative,
                    (v) => setSheetState(() => _model.initiative = v)),
                _scoreSlider('Mahudhurio', _model.attendance,
                    (v) => setSheetState(() => _model.attendance = v)),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _model.commentsController,
                  decoration: InputDecoration(
                    labelText: 'Maoni (si lazima)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  child: FFButtonWidget(
                    onPressed: () async {
                      try {
                        await HrService.instance.submitSelfReview(
                          reviewId: review['id'],
                          quality: _model.quality.round(),
                          productivity: _model.productivity.round(),
                          teamwork: _model.teamwork.round(),
                          initiative: _model.initiative.round(),
                          attendance: _model.attendance.round(),
                          comments: _model.commentsController?.text,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (!mounted) return;
                        await _loadData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Tathmini binafsi imetumwa!'),
                              backgroundColor: Color(0xFF059669),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Kosa: $e')),
                          );
                        }
                      }
                    },
                    text: 'Tuma Tathmini',
                    options: FFButtonOptions(
                      height: 50.0,
                      color: const Color(0xFF1E3A8A),
                      textStyle: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreSlider(
      String label, double value, ValueChanged<double> onChanged) {
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFFFBBF24),
      const Color(0xFF34D399),
      const Color(0xFF059669),
    ];
    final labels = ['Dhaifu', 'Wastani-', 'Wastani', 'Nzuri', 'Bora'];
    final idx = (value.round() - 1).clamp(0, 4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 14.0)),
              Text('${value.round()}/5 — ${labels[idx]}',
                  style: GoogleFonts.inter(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: colors[idx])),
            ],
          ),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: colors[idx],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ── TAB 2: History ───────────────────────────────────────────────────

  Widget _buildHistoryTab(BuildContext context) {
    final completed =
        _model.reviews.where((r) => r['status'] == 'completed').toList();

    if (completed.isEmpty) {
      return Center(
        child: Text(
          'Hakuna tathmini zilizokamilika',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: completed.length,
      itemBuilder: (context, index) {
        final review = completed[index];
        final cycle =
            review['performance_review_cycles'] as Map<String, dynamic>? ?? {};
        final grade = review['overall_grade'] ?? '-';
        final score = review['overall_score'];

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
                  color: (gradeColors[grade] ?? const Color(0xFF6B7280))
                      .withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    grade,
                    style: GoogleFonts.interTight(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color:
                          gradeColors[grade] ?? const Color(0xFF6B7280),
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
                      cycle['cycle_name'] ?? 'Review',
                      style: FlutterFlowTheme.of(context)
                          .bodyLarge
                          .override(
                            font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600),
                            letterSpacing: 0.0,
                          ),
                    ),
                    if (cycle['period_start'] != null)
                      Text(
                        '${cycle['period_start']} - ${cycle['period_end']}',
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
                  '${(score as num).toStringAsFixed(1)}%',
                  style: GoogleFonts.interTight(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color:
                          gradeColors[grade] ?? const Color(0xFF6B7280)),
                ),
            ],
          ),
        );
      },
    );
  }
}
