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
import 'hr_manager_approvals_model.dart';
export 'hr_manager_approvals_model.dart';

/// Manager Approvals — Leave request approval/rejection queue.
///
/// LIST: Pending leave requests with employee name, dates, type
/// ACTIONS: Approve (green) or Reject (red) with optional comment
class HrManagerApprovalsWidget extends StatefulWidget {
  const HrManagerApprovalsWidget({super.key});

  static String routeName = 'HrManagerApprovals';
  static String routePath = '/hrManagerApprovals';

  @override
  State<HrManagerApprovalsWidget> createState() =>
      _HrManagerApprovalsWidgetState();
}

class _HrManagerApprovalsWidgetState extends State<HrManagerApprovalsWidget> {
  late HrManagerApprovalsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HrManagerApprovalsModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadPendingRequests();
    });
  }

  Future<void> _loadPendingRequests() async {
    try {
      final pending = await HrService.instance.getPendingLeaveRequests();
      _model.pendingLeaves = pending;
      _model.isLoading = false;
    } catch (e) {
      _model.isLoading = false;
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
            'Idhini za Likizo',
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
            : _model.pendingLeaves.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 64.0, color: Color(0xFF059669)),
                        const SizedBox(height: 12.0),
                        Text(
                          'Hakuna maombi yanayosubiri idhini',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPendingRequests,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _model.pendingLeaves.length,
                      itemBuilder: (context, index) {
                        final req = _model.pendingLeaves[index];
                        return _buildRequestCard(context, req);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> req) {
    final leaveType = req['leave_type'] ?? '';
    final employeeName = req['employee_name'] ?? 'N/A';
    final startDate = req['start_date'] ?? '';
    final endDate = req['end_date'] ?? '';
    final days = req['days_count'] ?? '';
    final reason = req['reason'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0x1AF59E0B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  employeeName,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: const Color(0x1A3B82F6),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  leaveType,
                  style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 14.0, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 6.0),
              Text(
                '$startDate - $endDate',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(width: 12.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                decoration: BoxDecoration(
                  color: const Color(0x1AF59E0B),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  'siku $days',
                  style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (reason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '"$reason"',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(fontStyle: FontStyle.italic),
                      letterSpacing: 0.0,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              Expanded(
                child: FFButtonWidget(
                  onPressed: () => _showApprovalDialog(context, req, 'reject'),
                  text: 'Kataa',
                  options: FFButtonOptions(
                    height: 38.0,
                    color: const Color(0xFFEF4444),
                    textStyle: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: FFButtonWidget(
                  onPressed: () => _showApprovalDialog(context, req, 'approve'),
                  text: 'Idhinisha',
                  options: FFButtonOptions(
                    height: 38.0,
                    color: const Color(0xFF059669),
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
        ],
      ),
    );
  }

  void _showApprovalDialog(
      BuildContext context, Map<String, dynamic> req, String action) {
    _model.commentController?.clear();
    final isReject = action == 'reject';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isReject ? 'Kataa Ombi' : 'Idhinisha Ombi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isReject
                ? 'Tafadhali toa sababu ya kukataa:'
                : 'Ongeza maoni (si lazima):'),
            const SizedBox(height: 10.0),
            TextField(
              controller: _model.commentController,
              decoration: InputDecoration(
                hintText: isReject ? 'Sababu...' : 'Maoni...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isReject ? const Color(0xFFEF4444) : const Color(0xFF059669),
            ),
            onPressed: () async {
              if (isReject &&
                  (_model.commentController?.text.isEmpty ?? true)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sababu inahitajika kwa kukataa')),
                );
                return;
              }
              Navigator.pop(ctx);

              try {
                final edgeFnBody = {
                  'operation': action,
                  'request_id': req['request_id'],
                  'manager_comment': _model.commentController?.text ?? '',
                  'processed_by': currentUserEmail,
                };
                await SupaFlow.client.functions.invoke(
                  'hr-leave-workflow',
                  body: edgeFnBody,
                );
                await _loadPendingRequests();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isReject
                          ? 'Ombi limekataliwa'
                          : 'Ombi limeidhinishwa!'),
                      backgroundColor: isReject
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF059669),
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
            child: Text(isReject ? 'Kataa' : 'Idhinisha',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
