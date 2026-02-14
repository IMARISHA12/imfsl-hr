import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/hr_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hr_notifications_model.dart';
export 'hr_notifications_model.dart';

/// Notifications — HR workflow notifications with read/unread state.
class HrNotificationsWidget extends StatefulWidget {
  const HrNotificationsWidget({super.key});

  static String routeName = 'HrNotifications';
  static String routePath = '/hrNotifications';

  @override
  State<HrNotificationsWidget> createState() => _HrNotificationsWidgetState();
}

class _HrNotificationsWidgetState extends State<HrNotificationsWidget> {
  late HrNotificationsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HrNotificationsModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    try {
      final result = await HrService.instance.getNotifications(
        limit: 50,
        unreadOnly: _model.unreadOnly,
      );
      _model.notifications = List<Map<String, dynamic>>.from(
          result['notifications'] ?? []);
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
            'Arifa',
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
          actions: [
            // Toggle unread only
            IconButton(
              icon: Icon(
                _model.unreadOnly
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                _model.unreadOnly = !_model.unreadOnly;
                _model.isLoading = true;
                safeSetState(() {});
                _loadNotifications();
              },
            ),
            // Mark all as read
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              onPressed: () async {
                final unreadIds = _model.notifications
                    .where((n) => n['is_read'] == false)
                    .map((n) => n['id'] as String)
                    .toList();
                if (unreadIds.isNotEmpty) {
                  await HrService.instance.markNotificationsRead(unreadIds);
                  await _loadNotifications();
                }
              },
            ),
          ],
        ),
        body: _model.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            : _model.notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_off_outlined,
                            size: 64.0, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 12.0),
                        Text(
                          'Hakuna arifa',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _model.notifications.length,
                      itemBuilder: (context, index) {
                        final n = _model.notifications[index];
                        return _buildNotificationTile(context, n);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, Map<String, dynamic> n) {
    final isRead = n['is_read'] == true;
    final eventType = n['event_type'] as String? ?? '';
    final title = n['title'] as String? ?? '';
    final body = n['body'] as String? ?? '';
    final createdAt = n['created_at'] as String? ?? '';

    final iconMap = {
      'leave_submitted': Icons.event_note,
      'leave_approved': Icons.check_circle,
      'leave_rejected': Icons.cancel,
      'payroll_approved': Icons.account_balance_wallet,
      'payroll_paid': Icons.paid,
      'salary_loan_approved': Icons.credit_card,
      'salary_loan_completed': Icons.credit_score,
    };
    final colorMap = {
      'leave_submitted': const Color(0xFFF59E0B),
      'leave_approved': const Color(0xFF059669),
      'leave_rejected': const Color(0xFFEF4444),
      'payroll_approved': const Color(0xFF3B82F6),
      'payroll_paid': const Color(0xFF059669),
      'salary_loan_approved': const Color(0xFF8B5CF6),
      'salary_loan_completed': const Color(0xFF059669),
    };

    final icon = iconMap[eventType] ?? Icons.notifications;
    final color = colorMap[eventType] ?? const Color(0xFF6B7280);

    return GestureDetector(
      onTap: () async {
        if (!isRead) {
          await HrService.instance.markNotificationsRead([n['id']]);
          n['is_read'] = true;
          safeSetState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isRead
              ? FlutterFlowTheme.of(context).secondaryBackground
              : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10.0),
          border: isRead
              ? null
              : Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18.0),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.w600),
                          letterSpacing: 0.0,
                        ),
                  ),
                  if (body.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        body,
                        style:
                            FlutterFlowTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _timeAgo(createdAt),
                      style: GoogleFonts.inter(
                          fontSize: 11.0, color: const Color(0xFF9CA3AF)),
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'sasa hivi';
      if (diff.inMinutes < 60) return 'dakika ${diff.inMinutes} zilizopita';
      if (diff.inHours < 24) return 'masaa ${diff.inHours} yaliyopita';
      if (diff.inDays < 7) return 'siku ${diff.inDays} zilizopita';
      return dateTimeFormat('yMMMd', dt);
    } catch (_) {
      return isoDate;
    }
  }
}
