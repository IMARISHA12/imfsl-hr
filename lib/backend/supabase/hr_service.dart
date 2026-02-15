import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'supabase.dart';

/// Central service for all HR operations.
///
/// Uses REAL Supabase tables (from FlutterFlow schema):
///   Attendance:  staff_attendance_v3, attendance_v2_today, attendance_settings
///   Leave:       leave_requests_v2, leave_requests_v2_enriched, leave_types, leave_balances
///   Payroll:     payroll_runs, salary_structures, payslips
///   Performance: staff_performance_monthly, staff_performance
///   Loans:       staff_loans, staff_salary_loans
///   Notifications: notifications
class HrService {
  HrService._();
  static final instance = HrService._();

  SupabaseClient get _client => SupaFlow.client;

  // ──────────────────────────────────────────────
  //  PAYROLL
  // ──────────────────────────────────────────────

  /// Get all payroll runs sorted by most recent.
  Future<List<Map<String, dynamic>>> getPayrollRuns() async {
    final res = await _client
        .from('payroll_runs')
        .select()
        .order('run_period_year', ascending: false)
        .order('run_period_month', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(res);
  }

  // ──────────────────────────────────────────────
  //  SALARY & PAYSLIPS (uses salary_structures, payslips)
  // ──────────────────────────────────────────────

  /// Get current salary structure for an employee.
  Future<Map<String, dynamic>?> getMySalary(String employeeId) async {
    final res = await _client
        .from('salary_structures')
        .select()
        .eq('employee_id', employeeId)
        .eq('is_current', true)
        .maybeSingle();
    return res;
  }

  /// Get payslips for an employee with payroll run info.
  Future<List<Map<String, dynamic>>> getMyPayslips(String employeeId) async {
    final res = await _client
        .from('payslips')
        .select('*, payroll_runs(month, run_period_year, run_period_month, status)')
        .eq('employee_id', employeeId)
        .order('created_at', ascending: false)
        .limit(24);
    return List<Map<String, dynamic>>.from(res);
  }

  // ──────────────────────────────────────────────
  //  LEAVE MANAGEMENT
  // ──────────────────────────────────────────────

  /// Get leave types (existing table).
  Future<List<Map<String, dynamic>>> getLeaveTypes() async {
    final res = await _client
        .from('leave_types')
        .select()
        .order('name');
    return List<Map<String, dynamic>>.from(res);
  }

  /// Submit a new leave request directly to leave_requests_v2.
  Future<Map<String, dynamic>> submitLeaveRequest({
    required String staffId,
    required String leaveType,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    final res = await _client
        .from('leave_requests_v2')
        .insert({
          'staff_id': staffId,
          'leave_type': leaveType,
          'start_date': startDate,
          'end_date': endDate,
          if (reason != null) 'reason': reason,
          'status': 'pending',
        })
        .select()
        .single();
    return Map<String, dynamic>.from(res);
  }

  /// Get leave balance for a user from leave_balances table.
  Future<List<Map<String, dynamic>>> getLeaveBalance(
    String userId, {
    int? year,
  }) async {
    var query = _client
        .from('leave_balances')
        .select('*, leave_types!inner(name, code, days_allowed)')
        .eq('user_id', userId);
    if (year != null) {
      query = query.eq('year', year);
    }
    final res = await query;
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get all pending leave requests (for managers).
  /// Uses leave_requests_v2_enriched VIEW which includes staff name.
  Future<List<Map<String, dynamic>>> getPendingLeaveRequests() async {
    final res = await _client
        .from('leave_requests_v2_enriched')
        .select()
        .eq('status', 'pending')
        .order('start_date', ascending: false)
        .limit(100);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get my leave requests from leave_requests_v2.
  Future<List<Map<String, dynamic>>> getMyLeaveRequests(String staffId) async {
    final res = await _client
        .from('leave_requests_v2')
        .select()
        .eq('staff_id', staffId)
        .order('start_date', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Approve/reject a leave request.
  Future<void> processLeaveRequest({
    required String requestId,
    required String action,
    required String approvedBy,
  }) async {
    await _client
        .from('leave_requests_v2')
        .update({
          'status': action, // 'approved' or 'rejected'
          'approved_by': approvedBy,
        })
        .eq('id', requestId);
  }

  /// Cancel a leave request.
  Future<void> cancelLeaveRequest(String requestId) async {
    await _client
        .from('leave_requests_v2')
        .update({'status': 'cancelled'})
        .eq('id', requestId);
  }

  // ──────────────────────────────────────────────
  //  ATTENDANCE (uses staff_attendance_v3)
  // ──────────────────────────────────────────────

  /// Clock in — insert row into staff_attendance_v3.
  Future<Map<String, dynamic>> clockIn(
    String staffId, {
    double? latitude,
    double? longitude,
    String? geofenceId,
    String? deviceId,
    String? photoPath,
  }) async {
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final res = await _client
        .from('staff_attendance_v3')
        .upsert({
          'staff_id': staffId,
          'work_date': today,
          'clock_in_time': now.toIso8601String(),
          if (latitude != null) 'clock_in_latitude': latitude,
          if (longitude != null) 'clock_in_longitude': longitude,
          if (geofenceId != null) 'clock_in_geofence_id': geofenceId,
          if (deviceId != null) 'clock_in_device_id': deviceId,
          if (photoPath != null) 'clock_in_photo_path': photoPath,
          'status': 'present',
        }, onConflict: 'staff_id,work_date')
        .select()
        .single();
    return Map<String, dynamic>.from(res);
  }

  /// Clock out — update existing row in staff_attendance_v3.
  Future<Map<String, dynamic>> clockOut(
    String staffId, {
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final res = await _client
        .from('staff_attendance_v3')
        .update({
          'clock_out_time': now.toIso8601String(),
          if (latitude != null) 'clock_out_latitude': latitude,
          if (longitude != null) 'clock_out_longitude': longitude,
          if (notes != null) 'notes': notes,
        })
        .eq('staff_id', staffId)
        .eq('work_date', today)
        .select()
        .single();
    return Map<String, dynamic>.from(res);
  }

  /// Get my attendance records for a month from staff_attendance_v3.
  Future<List<Map<String, dynamic>>> getMyAttendance(
    String staffId, {
    int? month,
    int? year,
  }) async {
    final now = DateTime.now();
    final m = month ?? now.month;
    final y = year ?? now.year;
    final startDate = '$y-${m.toString().padLeft(2, '0')}-01';
    final endDate = m == 12
        ? '${y + 1}-01-01'
        : '$y-${(m + 1).toString().padLeft(2, '0')}-01';

    final res = await _client
        .from('staff_attendance_v3')
        .select()
        .eq('staff_id', staffId)
        .gte('work_date', startDate)
        .lt('work_date', endDate)
        .order('work_date', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get today's attendance for all staff (manager view).
  /// Uses existing attendance_v2_today VIEW.
  Future<List<Map<String, dynamic>>> getTodayAttendance() async {
    final res = await _client
        .from('attendance_v2_today')
        .select()
        .order('full_name');
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get attendance settings.
  Future<Map<String, dynamic>?> getAttendanceSettings() async {
    final res = await _client
        .from('attendance_settings')
        .select()
        .limit(1)
        .maybeSingle();
    return res;
  }

  // ──────────────────────────────────────────────
  //  PERFORMANCE (uses staff_performance_monthly)
  // ──────────────────────────────────────────────

  /// Get my monthly performance records.
  Future<List<Map<String, dynamic>>> getMyPerformance(String staffId) async {
    final res = await _client
        .from('staff_performance_monthly')
        .select()
        .eq('staff_id', staffId)
        .order('year', ascending: false)
        .order('month', ascending: false)
        .limit(12);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Get KPI data from staff_performance table.
  Future<Map<String, dynamic>?> getLatestKpis(String staffId) async {
    final res = await _client
        .from('staff_performance')
        .select()
        .eq('staff_id', staffId)
        .order('calculated_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return res;
  }

  // ──────────────────────────────────────────────
  //  NOTIFICATIONS (uses existing notifications table)
  // ──────────────────────────────────────────────

  /// Get unread notification count.
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final res = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false);
      return (res as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// Get notifications for a user.
  Future<List<Map<String, dynamic>>> getNotifications(
    String userId, {
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    var query = _client
        .from('notifications')
        .select()
        .eq('user_id', userId);
    if (unreadOnly) {
      query = query.eq('is_read', false);
    }
    final res = await query
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Mark notifications as read.
  Future<void> markNotificationsRead(List<String> notificationIds) async {
    await _client
        .from('notifications')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        })
        .inFilter('id', notificationIds);
  }

  // ──────────────────────────────────────────────
  //  STAFF LOANS (uses existing staff_loans table)
  // ──────────────────────────────────────────────

  /// Get staff loans for an employee.
  Future<List<Map<String, dynamic>>> getMyLoans(String employeeId) async {
    final res = await _client
        .from('staff_loans')
        .select()
        .eq('employee_id', employeeId)
        .order('created_at', ascending: false)
        .limit(20);
    return List<Map<String, dynamic>>.from(res);
  }

  // ──────────────────────────────────────────────
  //  STAFF INFO
  // ──────────────────────────────────────────────

  /// Get staff record by user_id.
  Future<Map<String, dynamic>?> getStaffByUserId(String userId) async {
    final res = await _client
        .from('staff')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return res;
  }

  /// Get active leave (currently on leave) from the enriched view.
  Future<List<Map<String, dynamic>>> getActiveLeaves() async {
    final res = await _client
        .from('leave_requests_v2_enriched')
        .select()
        .eq('is_active_now', true)
        .limit(50);
    return List<Map<String, dynamic>>.from(res);
  }

  // ──────────────────────────────────────────────
  //  INTERNAL — Edge Function Caller (for complex operations)
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
      String errorMsg = 'Edge function error ($functionName)';
      try {
        final error = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        if (error is Map) {
          errorMsg = (error['error'] as String?) ?? errorMsg;
        }
      } catch (_) {
        // Non-JSON error response — use default message
      }
      throw Exception(errorMsg);
    }

    final decoded = response.data is String
        ? jsonDecode(response.data)
        : response.data;
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return {'data': decoded};
  }
}
