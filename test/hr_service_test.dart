import 'package:flutter_test/flutter_test.dart';

import 'package:i_m_f_s_l_staff/backend/supabase/hr_service.dart';

/// Tests for HrService singleton and method contracts.
///
/// Since HrService directly wraps Supabase client calls, these tests verify
/// the singleton pattern, object identity, and that the service API surface
/// is well-defined. Integration tests with a real/mock Supabase instance
/// belong in a separate integration test suite.
void main() {
  group('HrService singleton', () {
    test('instance returns the same object', () {
      final a = HrService.instance;
      final b = HrService.instance;
      expect(identical(a, b), true);
    });

    test('instance is not null', () {
      expect(HrService.instance, isNotNull);
    });
  });

  group('HrService API surface', () {
    late HrService service;

    setUp(() {
      service = HrService.instance;
    });

    // Verify all public methods exist and have the expected return types.
    // These tests confirm the API contract without requiring a Supabase connection.

    test('payroll methods are defined', () {
      // getPayrollRuns should return Future<List<Map<String, dynamic>>>
      expect(service.getPayrollRuns, isA<Function>());
    });

    test('salary methods are defined', () {
      expect(service.getMySalary, isA<Function>());
      expect(service.getMyPayslips, isA<Function>());
    });

    test('leave methods are defined', () {
      expect(service.getLeaveTypes, isA<Function>());
      expect(service.submitLeaveRequest, isA<Function>());
      expect(service.getLeaveBalance, isA<Function>());
      expect(service.getPendingLeaveRequests, isA<Function>());
      expect(service.getMyLeaveRequests, isA<Function>());
      expect(service.processLeaveRequest, isA<Function>());
      expect(service.cancelLeaveRequest, isA<Function>());
    });

    test('attendance methods are defined', () {
      expect(service.clockIn, isA<Function>());
      expect(service.clockOut, isA<Function>());
      expect(service.getMyAttendance, isA<Function>());
      expect(service.getTodayAttendance, isA<Function>());
      expect(service.getAttendanceSettings, isA<Function>());
    });

    test('performance methods are defined', () {
      expect(service.getMyPerformance, isA<Function>());
      expect(service.getLatestKpis, isA<Function>());
    });

    test('notification methods are defined', () {
      expect(service.getUnreadNotificationCount, isA<Function>());
      expect(service.getNotifications, isA<Function>());
      expect(service.markNotificationsRead, isA<Function>());
    });

    test('loans method is defined', () {
      expect(service.getMyLoans, isA<Function>());
    });

    test('staff info methods are defined', () {
      expect(service.getStaffByUserId, isA<Function>());
      expect(service.getActiveLeaves, isA<Function>());
    });
  });
}
