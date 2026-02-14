import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'supabase.dart';

/// Central service for all HR operations.
///
/// Wraps Supabase edge function calls and direct table/RPC queries
/// used by the Flutter app for payroll, leave, attendance, performance,
/// and notifications.
class HrService {
  HrService._();
  static final instance = HrService._();

  SupabaseClient get _client => SupaFlow.client;

  /// Derive edge-function base URL from the project URL used by SupaFlow.
  static String get _functionsBase {
    final projectUrl = SupaFlow.client.rest.url.replaceAll('/rest/v1', '');
    return '$projectUrl/functions/v1';
  }

  // ──────────────────────────────────────────────
  //  PAYROLL
  // ──────────────────────────────────────────────

  /// Get all payroll runs sorted by most recent.
  Future<List<Map<String, dynamic>>> getPayrollRuns() async {
    final res = await _client
        .from('payroll_runs')
        .select()
        .order('run_period_year', ascending: false)
        .order('run_period_month', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get payslips for a given payroll run.
  Future<List<Map<String, dynamic>>> getPayslips(String payrollRunId) async {
    final res = await _client
        .from('payslips')
        .select()
        .eq('payroll_run_id', payrollRunId)
        .order('department')
        .order('employee_name');
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get current user's payslips.
  Future<List<Map<String, dynamic>>> getMyPayslips(String employeeId) async {
    final res = await _client
        .from('payslips')
        .select('*, payroll_runs!inner(month, status)')
        .eq('employee_id', employeeId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get current user's salary structure.
  Future<Map<String, dynamic>?> getMySalary(String employeeId) async {
    final res = await _client
        .from('salary_structures')
        .select()
        .eq('employee_id', employeeId)
        .eq('is_current', true)
        .maybeSingle();
    return res;
  }

  // ──────────────────────────────────────────────
  //  LEAVE MANAGEMENT
  // ──────────────────────────────────────────────

  /// Submit a new leave request via edge function.
  Future<Map<String, dynamic>> submitLeaveRequest({
    required String userId,
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    return _callFunction('hr-leave-workflow', {
      'operation': 'submit',
      'user_id': userId,
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      if (reason != null) 'reason': reason,
    });
  }

  /// Get leave balance for a user.
  Future<Map<String, dynamic>> getLeaveBalance(
    String userId, {
    int? year,
  }) async {
    return _callFunction('hr-leave-workflow', {
      'operation': 'balance',
      'user_id': userId,
      if (year != null) 'year': year,
    });
  }

  /// Get all pending leave requests (for managers).
  Future<List<Map<String, dynamic>>> getPendingLeaveRequests() async {
    final res = await _client
        .from('leave_requests')
        .select('*, leave_types!inner(leave_type)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get my leave requests.
  Future<List<Map<String, dynamic>>> getMyLeaveRequests(String userId) async {
    final res = await _client
        .from('leave_requests')
        .select('*, leave_types!inner(leave_type)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Cancel a leave request.
  Future<Map<String, dynamic>> cancelLeaveRequest(
    String requestId,
    String userId,
  ) async {
    return _callFunction('hr-leave-workflow', {
      'operation': 'cancel',
      'request_id': requestId,
      'user_id': userId,
    });
  }

  // ──────────────────────────────────────────────
  //  ATTENDANCE
  // ──────────────────────────────────────────────

  /// Clock in with optional GPS coordinates.
  Future<Map<String, dynamic>> clockIn(
    String staffId, {
    double? latitude,
    double? longitude,
  }) async {
    return _callFunction('hr-attendance', {
      'operation': 'clock_in',
      'staff_id': staffId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
  }

  /// Clock out with optional daily report.
  Future<Map<String, dynamic>> clockOut(
    String staffId, {
    String? dailyReport,
  }) async {
    return _callFunction('hr-attendance', {
      'operation': 'clock_out',
      'staff_id': staffId,
      if (dailyReport != null) 'daily_report': dailyReport,
    });
  }

  /// Get my attendance records for a month.
  Future<Map<String, dynamic>> getMyAttendance(
    String staffId, {
    int? month,
    int? year,
  }) async {
    return _callFunction('hr-attendance', {
      'operation': 'my_records',
      'staff_id': staffId,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    });
  }

  /// Get today's attendance for all staff (manager view).
  Future<Map<String, dynamic>> getTodayAttendance({
    String? department,
  }) async {
    return _callFunction('hr-attendance', {
      'operation': 'today',
      if (department != null) 'department': department,
    });
  }

  // ──────────────────────────────────────────────
  //  PERFORMANCE REVIEWS
  // ──────────────────────────────────────────────

  /// Get active review cycles.
  Future<List<Map<String, dynamic>>> getReviewCycles() async {
    final res = await _client
        .from('performance_review_cycles')
        .select()
        .order('period_start', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get my pending reviews.
  Future<List<Map<String, dynamic>>> getMyReviews(String employeeId) async {
    final res = await _client
        .from('performance_reviews')
        .select('*, performance_review_cycles!inner(cycle_name, period_start, period_end)')
        .eq('employee_id', employeeId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Submit self-review scores.
  Future<Map<String, dynamic>> submitSelfReview({
    required String reviewId,
    required int quality,
    required int productivity,
    required int teamwork,
    required int initiative,
    required int attendance,
    String? comments,
  }) async {
    return _callFunction('hr-performance-review', {
      'operation': 'self_review',
      'review_id': reviewId,
      'quality': quality,
      'productivity': productivity,
      'teamwork': teamwork,
      'initiative': initiative,
      'attendance': attendance,
      if (comments != null) 'comments': comments,
    });
  }

  /// Get performance history for an employee.
  Future<Map<String, dynamic>> getPerformanceHistory(
      String employeeId) async {
    return _callFunction('hr-performance-review', {
      'operation': 'employee_history',
      'employee_id': employeeId,
    });
  }

  // ──────────────────────────────────────────────
  //  NOTIFICATIONS
  // ──────────────────────────────────────────────

  /// Get unread notification count.
  Future<int> getUnreadNotificationCount() async {
    final res = await _client.rpc('rpc_unread_notification_count');
    return (res as Map<String, dynamic>?)?['count'] ?? 0;
  }

  /// Get notifications with pagination.
  Future<Map<String, dynamic>> getNotifications({
    int limit = 20,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    final res = await _client.rpc('rpc_get_notifications', params: {
      'p_limit': limit,
      'p_offset': offset,
      'p_unread_only': unreadOnly,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  /// Mark notifications as read.
  Future<void> markNotificationsRead(List<String> notificationIds) async {
    await _client.rpc('rpc_mark_notifications_read', params: {
      'p_notification_ids': notificationIds,
    });
  }

  // ──────────────────────────────────────────────
  //  DASHBOARD / KPIs
  // ──────────────────────────────────────────────

  /// Get HR dashboard KPIs (headcount, payroll, leave, attendance, performance).
  Future<Map<String, dynamic>> getDashboardKpis() async {
    final res = await _client.rpc('rpc_hr_dashboard_kpis');
    return Map<String, dynamic>.from(res as Map);
  }

  /// Get staff salary loans for an employee.
  Future<List<Map<String, dynamic>>> getMyLoans(String employeeId) async {
    final res = await _client
        .from('staff_salary_loans')
        .select()
        .eq('employee_id', employeeId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ──────────────────────────────────────────────
  //  INTERNAL — Edge Function Caller
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> _callFunction(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.functions.invoke(
      functionName,
      body: body,
    );

    if (response.status >= 400) {
      final error = jsonDecode(response.data);
      throw Exception(error['error'] ?? 'Edge function error ($functionName)');
    }

    final decoded = response.data is String
        ? jsonDecode(response.data)
        : response.data;
    return Map<String, dynamic>.from(decoded as Map);
  }
}
