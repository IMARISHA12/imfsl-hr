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
import 'hr_leave_model.dart';
export 'hr_leave_model.dart';

/// Leave Management — Request leave, view balances, track history.
///
/// TAB 1 (Salio): Leave balance cards per type
/// TAB 2 (Maombi): My leave request history + status
/// TAB 3 (Omba): New leave request form
class HrLeaveWidget extends StatefulWidget {
  const HrLeaveWidget({super.key});

  static String routeName = 'HrLeave';
  static String routePath = '/hrLeave';

  @override
  State<HrLeaveWidget> createState() => _HrLeaveWidgetState();
}

class _HrLeaveWidgetState extends State<HrLeaveWidget>
    with SingleTickerProviderStateMixin {
  late HrLeaveModel _model;
  late TabController _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HrLeaveModel());
    _tabController = TabController(length: 3, vsync: this);

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final balanceResp =
          await HrService.instance.getLeaveBalance(currentUserUid);
      final myRequests =
          await HrService.instance.getMyLeaveRequests(currentUserUid);

      // Load leave types for the request form
      final types = await SupaFlow.client
          .from('leave_types')
          .select('id, leave_type, max_days_per_year')
          .eq('is_active', true)
          .order('leave_type');

      _model.balances =
          List<Map<String, dynamic>>.from(balanceResp['balances'] ?? []);
      _model.requests = myRequests;
      _model.leaveTypes = List<Map<String, dynamic>>.from(types);
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
            'Likizo',
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
              Tab(text: 'Salio'),
              Tab(text: 'Maombi'),
              Tab(text: 'Omba'),
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
                  _buildBalancesTab(context),
                  _buildRequestsTab(context),
                  _buildNewRequestTab(context),
                ],
              ),
      ),
    );
  }

  // ── TAB 1: Balances ──────────────────────────────────────────────────

  Widget _buildBalancesTab(BuildContext context) {
    if (_model.balances.isEmpty) {
      return Center(
        child: Text(
          'Hakuna salio la likizo lililopatikana',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _model.balances.length,
      itemBuilder: (context, index) {
        final b = _model.balances[index];
        final leaveType =
            (b['leave_types'] as Map<String, dynamic>?)?['leave_type'] ?? 'N/A';
        final total = (b['annual_entitlement'] as num?) ?? 0;
        final used = (b['used_days'] as num?) ?? 0;
        final remaining = (b['remaining_days'] as num?) ?? 0;
        final progress = total > 0 ? used / total : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leaveType,
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _balanceStat('Jumla', '$total', const Color(0xFF3B82F6)),
                  _balanceStat(
                      'Imetumika', '$used', const Color(0xFFF59E0B)),
                  _balanceStat(
                      'Iliyobaki', '$remaining', const Color(0xFF059669)),
                ],
              ),
              const SizedBox(height: 10.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.8
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3B82F6),
                  ),
                  minHeight: 6.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _balanceStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.interTight(
                fontSize: 22.0, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11.0, color: const Color(0xFF9CA3AF))),
      ],
    );
  }

  // ── TAB 2: My Requests ───────────────────────────────────────────────

  Widget _buildRequestsTab(BuildContext context) {
    if (_model.requests.isEmpty) {
      return Center(
        child: Text(
          'Hakuna maombi ya likizo',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _model.requests.length,
      itemBuilder: (context, index) {
        final r = _model.requests[index];
        final leaveType =
            (r['leave_types'] as Map<String, dynamic>?)?['leave_type'] ?? '';
        final status = r['status'] ?? 'pending';
        final statusColors = {
          'pending': const Color(0xFFF59E0B),
          'approved': const Color(0xFF059669),
          'rejected': const Color(0xFFEF4444),
          'cancelled': const Color(0xFF6B7280),
        };
        final statusLabels = {
          'pending': 'Inasubiri',
          'approved': 'Imeidhinishwa',
          'rejected': 'Imekataliwa',
          'cancelled': 'Imefutwa',
        };
        final color = statusColors[status] ?? const Color(0xFF6B7280);

        return Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    leaveType,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font:
                              GoogleFonts.inter(fontWeight: FontWeight.w600),
                          letterSpacing: 0.0,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      statusLabels[status] ?? status,
                      style: TextStyle(
                          color: color,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Text(
                '${r['start_date'] ?? ''} - ${r['end_date'] ?? ''} (siku ${r['days_count'] ?? ''})',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              if (r['reason'] != null && (r['reason'] as String).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    r['reason'],
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          letterSpacing: 0.0,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (status == 'pending')
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      await HrService.instance
                          .cancelLeaveRequest(r['id'], currentUserUid);
                      await _loadData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Ombi limefutwa')),
                        );
                      }
                    },
                    child: Text(
                      'Futa',
                      style: GoogleFonts.inter(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── TAB 3: New Leave Request ─────────────────────────────────────────

  Widget _buildNewRequestTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Omba Likizo',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 16.0),
          // Leave type dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Aina ya Likizo',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            value: _model.selectedLeaveTypeId,
            items: _model.leaveTypes
                .map((lt) => DropdownMenuItem<String>(
                      value: lt['id'] as String,
                      child: Text(lt['leave_type'] as String),
                    ))
                .toList(),
            onChanged: (val) {
              _model.selectedLeaveTypeId = val;
              safeSetState(() {});
            },
          ),
          const SizedBox(height: 14.0),
          // Start date
          _datePicker(
            context,
            label: 'Tarehe ya Kuanza',
            value: _model.startDate,
            onPick: (d) {
              _model.startDate = d;
              safeSetState(() {});
            },
          ),
          const SizedBox(height: 14.0),
          // End date
          _datePicker(
            context,
            label: 'Tarehe ya Mwisho',
            value: _model.endDate,
            onPick: (d) {
              _model.endDate = d;
              safeSetState(() {});
            },
          ),
          const SizedBox(height: 14.0),
          // Reason
          TextFormField(
            controller: _model.reasonController,
            decoration: InputDecoration(
              labelText: 'Sababu (si lazima)',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20.0),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: FFButtonWidget(
              onPressed: () async {
                if (_model.selectedLeaveTypeId == null ||
                    _model.startDate == null ||
                    _model.endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Tafadhali jaza sehemu zote')),
                  );
                  return;
                }

                try {
                  await HrService.instance.submitLeaveRequest(
                    userId: currentUserUid,
                    leaveTypeId: _model.selectedLeaveTypeId!,
                    startDate: _model.startDate!.toIso8601String().split('T')[0],
                    endDate: _model.endDate!.toIso8601String().split('T')[0],
                    reason: _model.reasonController?.text,
                  );

                  // Reset form
                  _model.selectedLeaveTypeId = null;
                  _model.startDate = null;
                  _model.endDate = null;
                  _model.reasonController?.clear();

                  await _loadData();
                  _tabController.animateTo(1); // switch to requests tab

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ombi limetumwa!'),
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
              text: 'Tuma Ombi',
              options: FFButtonOptions(
                height: 50.0,
                color: const Color(0xFF1E3A8A),
                textStyle: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w600),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePicker(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPick,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          suffixIcon: const Icon(Icons.calendar_today, size: 18.0),
        ),
        child: Text(
          value != null ? dateTimeFormat('yMMMd', value) : 'Chagua tarehe',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: value != null
                    ? FlutterFlowTheme.of(context).primaryText
                    : FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
        ),
      ),
    );
  }
}
