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
import 'hr_dashboard_model.dart';
export 'hr_dashboard_model.dart';

/// HR Dashboard — Overview page with KPI cards, quick actions, and alerts.
///
/// HEADER: Greeting + notification bell (badge count)
/// KPI ROW: Headcount, Payroll Cost, Attendance Rate, Avg Performance
/// ALERTS: Expiring contracts, pending leaves, pending reviews
/// QUICK ACTIONS: 6-tile grid linking to HR sub-pages
/// Style: Blue primary (#1E3A8A), consistent with Homepagestaff
class HrDashboardWidget extends StatefulWidget {
  const HrDashboardWidget({super.key});

  static String routeName = 'HrDashboard';
  static String routePath = '/hrDashboard';

  @override
  State<HrDashboardWidget> createState() => _HrDashboardWidgetState();
}

class _HrDashboardWidgetState extends State<HrDashboardWidget> {
  late HrDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HrDashboardModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (currentUserUid == '') {
        context.pushNamed(LoginPageWidget.routeName);
        return;
      }
      await _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final uid = SupaFlow.client.auth.currentUser?.id ?? '';
      final now = DateTime.now();
      final todayStr = now.toIso8601String().split('T')[0];
      final monthStart = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
      final in30days = now.add(const Duration(days: 30)).toIso8601String().split('T')[0];

      // Run all queries in parallel
      final results = await Future.wait([
        SupaFlow.client.from('staff').select('id').eq('active', true),                           // 0: active staff
        SupaFlow.client.from('leave_requests_v2').select('id').eq('status', 'pending'),          // 1: pending leaves
        SupaFlow.client.from('attendance_v2_today').select('id'),                                // 2: today attendance
        SupaFlow.client.from('employees').select('id').gte('hire_date', monthStart),             // 3: new hires this month
        SupaFlow.client.from('leave_requests_v2').select('id')                                   // 4: on leave today
            .eq('status', 'approved').lte('start_date', todayStr).gte('end_date', todayStr),
        SupaFlow.client.from('salary_structures').select('gross_salary').eq('is_current', true), // 5: salaries
        SupaFlow.client.from('staff_performance_monthly').select('overall_score')                 // 6: performance scores
            .eq('year', now.year).eq('month', now.month),
        SupaFlow.client.from('employees').select('id')                                           // 7: expiring contracts
            .lte('contract_end_date', in30days).gte('contract_end_date', todayStr),
        HrService.instance.getUnreadNotificationCount(uid),                                      // 8: unread count
      ]);

      final activeStaff = (results[0] as List).length;
      final pendingLeaveCount = (results[1] as List).length;
      final todayAttCount = (results[2] as List).length;
      final newHires = (results[3] as List).length;
      final onLeaveToday = (results[4] as List).length;

      // Calculate payroll from salary_structures
      final salaries = results[5] as List;
      double totalCost = 0;
      for (final s in salaries) {
        totalCost += ((s as Map)['gross_salary'] as num?)?.toDouble() ?? 0;
      }
      final avgSalary = salaries.isNotEmpty ? totalCost / salaries.length : 0.0;

      // Calculate avg performance score
      final perfRecords = results[6] as List;
      double avgScore = 0;
      if (perfRecords.isNotEmpty) {
        double total = 0;
        int count = 0;
        for (final p in perfRecords) {
          final score = (p as Map)['overall_score'] as num?;
          if (score != null) { total += score; count++; }
        }
        if (count > 0) avgScore = total / count;
      }

      final expiringContracts = (results[7] as List).length;

      final kpis = <String, dynamic>{
        'headcount': {'active': activeStaff, 'new_hires_this_month': newHires},
        'attendance': {'rate_this_month': activeStaff > 0 ? todayAttCount * 100 ~/ activeStaff : 0},
        'leave': {'pending_requests': pendingLeaveCount, 'on_leave_today': onLeaveToday},
        'performance': {'avg_score': avgScore.round(), 'pending_reviews': 0},
        'payroll': {'monthly_cost': totalCost, 'avg_salary': avgSalary},
        'alerts': {'expiring_contracts': expiringContracts},
      };

      _model.kpiData = kpis;
      _model.unreadCount = results[8] as int;
      _model.isLoading = false;
      _model.errorMessage = null;
    } catch (e) {
      _model.isLoading = false;
      _model.errorMessage = e.toString();
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
        body: SafeArea(
          top: true,
          child: _model.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                )
              : _model.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off,
                                size: 64.0, color: Color(0xFF9CA3AF)),
                            const SizedBox(height: 16.0),
                            Text(
                              'Hitilafu kupakia data',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w600),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              _model.errorMessage!,
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            const SizedBox(height: 24.0),
                            FFButtonWidget(
                              onPressed: () {
                                _model.isLoading = true;
                                _model.errorMessage = null;
                                safeSetState(() {});
                                _loadDashboardData();
                              },
                              text: 'Jaribu tena',
                              options: FFButtonOptions(
                                height: 44.0,
                                color: const Color(0xFF1E3A8A),
                                textStyle: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDashboardData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context),
                              const SizedBox(height: 20.0),
                              _buildKpiCards(context),
                              const SizedBox(height: 20.0),
                              _buildAlerts(context),
                              const SizedBox(height: 20.0),
                              _buildQuickActions(context),
                            ],
                          ),
                        ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: AlignmentDirectional(1.0, 1.0),
          end: AlignmentDirectional(-1.0, -1.0),
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HR Dashboard',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                      color: Colors.white,
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(height: 4.0),
              Text(
                dateTimeFormat('yMMMd', DateTime.now()),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: const Color(0xCCFFFFFF),
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.pushNamed(HrNotificationsWidget.routeName),
            child: Stack(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: const BoxDecoration(
                    color: Color(0x33FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
                if (_model.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_model.unreadCount > 9 ? "9+" : _model.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCards(BuildContext context) {
    final headcount = _model.kpiData?['headcount'] as Map<String, dynamic>? ?? {};
    final payroll = _model.kpiData?['payroll'] as Map<String, dynamic>? ?? {};
    final attendance = _model.kpiData?['attendance'] as Map<String, dynamic>? ?? {};
    final performance = _model.kpiData?['performance'] as Map<String, dynamic>? ?? {};

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.0,
      mainAxisSpacing: 12.0,
      childAspectRatio: 1.6,
      children: [
        _kpiCard(
          context,
          icon: Icons.people_outline,
          label: 'Wafanyakazi',
          value: '${headcount['active'] ?? 0}',
          subtitle: '${headcount['new_hires_this_month'] ?? 0} wapya mwezi huu',
          color: const Color(0xFF1E3A8A),
        ),
        _kpiCard(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Mishahara',
          value: _formatCurrency(payroll['monthly_cost']),
          subtitle: 'Wastani: ${_formatCurrency(payroll['avg_salary'])}',
          color: const Color(0xFF059669),
        ),
        _kpiCard(
          context,
          icon: Icons.access_time_filled,
          label: 'Mahudhurio',
          value: '${attendance['rate_this_month'] ?? 0}%',
          subtitle: 'Mwezi huu',
          color: const Color(0xFFF59E0B),
        ),
        _kpiCard(
          context,
          icon: Icons.trending_up,
          label: 'Utendaji',
          value: '${performance['avg_score'] ?? 0}',
          subtitle: '${performance['pending_reviews'] ?? 0} tathmini zinasubiri',
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _kpiCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20.0),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  label,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: color,
                  letterSpacing: 0.0,
                ),
          ),
          Text(
            subtitle,
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts(BuildContext context) {
    final alerts = _model.kpiData?['alerts'] as Map<String, dynamic>? ?? {};
    final leave = _model.kpiData?['leave'] as Map<String, dynamic>? ?? {};
    final performance = _model.kpiData?['performance'] as Map<String, dynamic>? ?? {};

    final items = <_AlertItem>[];
    if ((alerts['expiring_contracts'] ?? 0) > 0) {
      items.add(_AlertItem(
        Icons.warning_amber_rounded,
        '${alerts['expiring_contracts']} mikataba inaisha siku 30',
        const Color(0xFFEF4444),
      ));
    }
    if ((leave['pending_requests'] ?? 0) > 0) {
      items.add(_AlertItem(
        Icons.event_note,
        '${leave['pending_requests']} maombi ya likizo yanasubiri',
        const Color(0xFFF59E0B),
      ));
    }
    if ((performance['pending_reviews'] ?? 0) > 0) {
      items.add(_AlertItem(
        Icons.rate_review_outlined,
        '${performance['pending_reviews']} tathmini hazijakamilika',
        const Color(0xFF8B5CF6),
      ));
    }
    if ((leave['on_leave_today'] ?? 0) > 0) {
      items.add(_AlertItem(
        Icons.beach_access,
        '${leave['on_leave_today']} wafanyakazi likizoni leo',
        const Color(0xFF3B82F6),
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tahadhari',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                letterSpacing: 0.0,
              ),
        ),
        const SizedBox(height: 8.0),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: item.color.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, color: item.color, size: 20.0),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        item.message,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              color: item.color,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vitendo Vya Haraka',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                letterSpacing: 0.0,
              ),
        ),
        const SizedBox(height: 12.0),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.0,
          children: [
            _actionTile(
              context,
              icon: Icons.receipt_long,
              label: 'Mishahara',
              color: const Color(0xFF059669),
              onTap: () => context.pushNamed(HrPayslipsWidget.routeName),
            ),
            _actionTile(
              context,
              icon: Icons.event_available,
              label: 'Likizo',
              color: const Color(0xFF3B82F6),
              onTap: () => context.pushNamed(HrLeaveWidget.routeName),
            ),
            _actionTile(
              context,
              icon: Icons.fingerprint,
              label: 'Mahudhurio',
              color: const Color(0xFFF59E0B),
              onTap: () => context.pushNamed(HrAttendanceWidget.routeName),
            ),
            _actionTile(
              context,
              icon: Icons.star_outline,
              label: 'Utendaji',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.pushNamed(HrPerformanceWidget.routeName),
            ),
            _actionTile(
              context,
              icon: Icons.notifications_none,
              label: 'Arifa',
              color: const Color(0xFFEF4444),
              onTap: () => context.pushNamed(HrNotificationsWidget.routeName),
            ),
            _actionTile(
              context,
              icon: Icons.person_outline,
              label: 'Wasifu',
              color: const Color(0xFF1E3A8A),
              onTap: () => context.pushNamed(HrProfileWidget.routeName),
            ),
            _actionTile(
              context,
              icon: Icons.approval,
              label: 'Idhini',
              color: const Color(0xFF059669),
              onTap: () => context.pushNamed(HrManagerApprovalsWidget.routeName),
            ),
            _actionTile(
              context,
              icon: Icons.home_outlined,
              label: 'Nyumbani',
              color: const Color(0xFF6B7280),
              onTap: () => context.pushNamed(HomepagestaffWidget.routeName),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    letterSpacing: 0.0,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    final value = (amount is num) ? amount.toDouble() : 0.0;
    if (value >= 1000000) {
      return 'TZS ${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return 'TZS ${(value / 1000).toStringAsFixed(0)}K';
    }
    return 'TZS ${value.toStringAsFixed(0)}';
  }
}

class _AlertItem {
  final IconData icon;
  final String message;
  final Color color;
  const _AlertItem(this.icon, this.message, this.color);
}
