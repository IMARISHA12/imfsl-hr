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
import 'hr_attendance_model.dart';
export 'hr_attendance_model.dart';

/// Attendance Tracker — Clock in/out with GPS, monthly records, summary.
///
/// MAIN CARD: Clock status, large action button
/// SUMMARY: Days worked, late, absent, overtime, avg rating
/// HISTORY: Monthly record list with color-coded status
class HrAttendanceWidget extends StatefulWidget {
  const HrAttendanceWidget({super.key});

  static String routeName = 'HrAttendance';
  static String routePath = '/hrAttendance';

  @override
  State<HrAttendanceWidget> createState() => _HrAttendanceWidgetState();
}

class _HrAttendanceWidgetState extends State<HrAttendanceWidget> {
  late HrAttendanceModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? _staffId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HrAttendanceModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _resolveStaffId();
      await _loadData();
    });
  }

  Future<void> _resolveStaffId() async {
    // Try staff table first, then employees table
    final staffRows = await StaffTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', currentUserUid).limit(1),
    );
    if (staffRows.isNotEmpty) {
      _staffId = staffRows.first.id;
      return;
    }
    final empRows = await EmployeesTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', currentUserUid).limit(1),
    );
    if (empRows.isNotEmpty) {
      _staffId = empRows.first.id;
    }
  }

  Future<void> _loadData() async {
    if (_staffId == null) {
      _model.isLoading = false;
      safeSetState(() {});
      return;
    }
    try {
      final records = await HrService.instance.getMyAttendance(_staffId!);

      // Compute summary from records
      int daysPresent = records.length;
      int daysLate = records.where((r) => r['is_late'] == true).length;
      int totalMinutes = 0;
      for (final r in records) {
        totalMinutes += (r['work_minutes'] as int?) ?? 0;
      }
      final summary = <String, dynamic>{
        'days_present': daysPresent,
        'days_late': daysLate,
        'total_hours': totalMinutes / 60.0,
      };

      _model.records = records;
      _model.summary = summary;

      // Check if clocked in today
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayRecord = records.firstWhere(
        (r) => r['work_date'] == today,
        orElse: () => <String, dynamic>{},
      );
      _model.isClockedIn =
          todayRecord['clock_in_time'] != null && todayRecord['clock_out_time'] == null;
      _model.clockInTime = todayRecord['clock_in_time'] as String?;
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
            'Mahudhurio',
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
        ),
        body: _model.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildClockCard(context),
                      const SizedBox(height: 20.0),
                      _buildSummaryRow(context),
                      const SizedBox(height: 20.0),
                      _buildRecordsList(context),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildClockCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _model.isClockedIn
              ? [const Color(0xFF059669), const Color(0xFF34D399)]
              : [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Icon(
            _model.isClockedIn
                ? Icons.check_circle_outline
                : Icons.access_time_rounded,
            color: Colors.white,
            size: 48.0,
          ),
          const SizedBox(height: 8.0),
          Text(
            _model.isClockedIn ? 'Umeingia Kazini' : 'Hujaingia Kazini',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                  color: Colors.white,
                  letterSpacing: 0.0,
                ),
          ),
          if (_model.clockInTime != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Umeingia: ${_model.clockInTime}',
                style: GoogleFonts.inter(
                    color: const Color(0xCCFFFFFF), fontSize: 13.0),
              ),
            ),
          const SizedBox(height: 16.0),
          if (_model.isClockedIn) ...[
            // Show daily report input + clock-out button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _model.reportController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                decoration: InputDecoration(
                  hintText: 'Ripoti ya siku (si lazima)...',
                  hintStyle: GoogleFonts.inter(
                      color: const Color(0x99FFFFFF), fontSize: 14.0),
                  border: InputBorder.none,
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: FFButtonWidget(
                onPressed: _handleClockOut,
                text: 'TOKA KAZINI',
                options: FFButtonOptions(
                  height: 44.0,
                  color: const Color(0xFFEF4444),
                  textStyle: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: FFButtonWidget(
                onPressed: _handleClockIn,
                text: 'INGIA KAZINI',
                options: FFButtonOptions(
                  height: 44.0,
                  color: const Color(0xFF059669),
                  textStyle: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    return Row(
      children: [
        _summaryCard(context, 'Siku', '${_model.summary['days_present'] ?? 0}',
            Icons.calendar_today, const Color(0xFF3B82F6)),
        const SizedBox(width: 8.0),
        _summaryCard(context, 'Kuchelewa', '${_model.summary['days_late'] ?? 0}',
            Icons.warning_amber_rounded, const Color(0xFFF59E0B)),
        const SizedBox(width: 8.0),
        _summaryCard(
            context,
            'Masaa',
            '${(_model.summary['total_hours'] as num?)?.toStringAsFixed(0) ?? '0'}',
            Icons.schedule,
            const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _summaryCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.0),
            const SizedBox(height: 4.0),
            Text(value,
                style: GoogleFonts.interTight(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11.0, color: const Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context) {
    if (_model.records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Hakuna rekodi za mwezi huu',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rekodi za Mwezi',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                letterSpacing: 0.0,
              ),
        ),
        const SizedBox(height: 8.0),
        ...(_model.records.map((r) {
          final isLate = r['is_late'] == true;
          final workMins = r['work_minutes'] as int?;
          final hours = workMins != null ? (workMins / 60).toStringAsFixed(1) : '-';
          final clockIn = r['clock_in_time'] ?? '-';
          final clockOut = r['clock_out_time'] ?? '-';

          return Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isLate
                    ? const Color(0x33F59E0B)
                    : const Color(0x1A000000),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLate
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    _formatDate(r['work_date']),
                    style: GoogleFonts.inter(
                        fontSize: 13.0, fontWeight: FontWeight.w500),
                  ),
                ),
                Text('$clockIn - $clockOut',
                    style: GoogleFonts.inter(
                        fontSize: 12.0, color: const Color(0xFF6B7280))),
                const SizedBox(width: 8.0),
                Text('${hours}h',
                    style: GoogleFonts.inter(
                        fontSize: 12.0, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        })),
      ],
    );
  }

  Future<void> _handleClockIn() async {
    if (_staffId == null || _model.isSubmitting) return;
    _model.isSubmitting = true;
    safeSetState(() {});
    try {
      await HrService.instance.clockIn(_staffId!);
      await _loadData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Umeingia kazini!'),
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
    } finally {
      _model.isSubmitting = false;
      safeSetState(() {});
    }
  }

  Future<void> _handleClockOut() async {
    if (_staffId == null || _model.isSubmitting) return;
    _model.isSubmitting = true;
    safeSetState(() {});
    try {
      await HrService.instance.clockOut(
        _staffId!,
        notes: _model.reportController?.text,
      );
      _model.reportController?.clear();
      await _loadData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Umetoka kazini!'),
            backgroundColor: Color(0xFF3B82F6),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kosa: $e')),
        );
      }
    } finally {
      _model.isSubmitting = false;
      safeSetState(() {});
    }
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '-';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return raw.toString();
    return dateTimeFormat('yMMMd', dt);
  }
}
