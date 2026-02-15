import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Model imports
import 'package:i_m_f_s_l_staff/hr_attendance/hr_attendance_model.dart';
import 'package:i_m_f_s_l_staff/hr_leave/hr_leave_model.dart';
import 'package:i_m_f_s_l_staff/hr_dashboard/hr_dashboard_model.dart';
import 'package:i_m_f_s_l_staff/hr_payslips/hr_payslips_model.dart';
import 'package:i_m_f_s_l_staff/hr_performance/hr_performance_model.dart';
import 'package:i_m_f_s_l_staff/hr_notifications/hr_notifications_model.dart';
import 'package:i_m_f_s_l_staff/hr_manager_approvals/hr_manager_approvals_model.dart';
import 'package:i_m_f_s_l_staff/hr_profile/hr_profile_model.dart';
import 'package:i_m_f_s_l_staff/homepagestaff/homepagestaff_model.dart';

void main() {
  group('HomepagestaffModel', () {
    late HomepagestaffModel model;

    setUp(() {
      model = HomepagestaffModel();
    });

    test('has correct default values', () {
      expect(model.currentStaffId, isNull);
      expect(model.currentStaffName, isNull);
      expect(model.isClockedIn, false);
      expect(model.clockInTime, isNull);
      expect(model.currentRealTime, isNull);
      expect(model.instantTimer, isNull);
    });

    test('can set staff identity', () {
      model.currentStaffId = 'staff-123';
      model.currentStaffName = 'John Doe';
      expect(model.currentStaffId, 'staff-123');
      expect(model.currentStaffName, 'John Doe');
    });

    test('can toggle clock-in state', () {
      expect(model.isClockedIn, false);
      model.isClockedIn = true;
      expect(model.isClockedIn, true);
    });

    test('can set clock-in time', () {
      final now = DateTime.now();
      model.clockInTime = now;
      expect(model.clockInTime, now);
    });

    test('dispose cancels timer', () {
      // Timer is null by default, dispose should not throw
      model.dispose();
    });
  });

  group('HrAttendanceModel', () {
    late HrAttendanceModel model;

    setUp(() {
      model = HrAttendanceModel();
    });

    test('has correct default values', () {
      expect(model.isClockedIn, false);
      expect(model.clockInTime, isNull);
      expect(model.records, isEmpty);
      expect(model.summary, isEmpty);
      expect(model.isLoading, true);
      expect(model.errorMessage, isNull);
      expect(model.isSubmitting, false);
    });

    testWidgets('initState creates report controller', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Builder(
        builder: (context) {
          model.initState(context);
          return const SizedBox();
        },
      )));
      expect(model.reportController, isNotNull);
      expect(model.reportController, isA<TextEditingController>());
    });

    test('can store attendance records', () {
      model.records = [
        {
          'id': '1',
          'staff_id': 'staff-1',
          'work_date': '2026-02-15',
          'clock_in_time': '2026-02-15T08:00:00',
          'clock_out_time': '2026-02-15T17:00:00',
          'work_minutes': 540,
          'status': 'present',
        },
        {
          'id': '2',
          'staff_id': 'staff-1',
          'work_date': '2026-02-14',
          'clock_in_time': '2026-02-14T08:30:00',
          'status': 'present',
        },
      ];
      expect(model.records.length, 2);
      expect(model.records[0]['work_minutes'], 540);
    });

    test('can store summary stats', () {
      model.summary = {
        'total_days': 20,
        'present_days': 18,
        'late_days': 2,
        'absent_days': 0,
      };
      expect(model.summary['total_days'], 20);
      expect(model.summary['present_days'], 18);
    });

    test('error state management', () {
      expect(model.errorMessage, isNull);
      model.errorMessage = 'Network error';
      expect(model.errorMessage, 'Network error');
      model.errorMessage = null;
      expect(model.errorMessage, isNull);
    });

    test('double-tap guard via isSubmitting', () {
      expect(model.isSubmitting, false);
      model.isSubmitting = true;
      expect(model.isSubmitting, true);
    });

    testWidgets('dispose cleans up report controller', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Builder(
        builder: (context) {
          model.initState(context);
          return const SizedBox();
        },
      )));
      expect(model.reportController, isNotNull);
      model.dispose();
      // After dispose, controller should have been disposed (no crash)
    });
  });

  group('HrLeaveModel', () {
    late HrLeaveModel model;

    setUp(() {
      model = HrLeaveModel();
    });

    test('has correct default values', () {
      expect(model.balances, isEmpty);
      expect(model.requests, isEmpty);
      expect(model.leaveTypes, isEmpty);
      expect(model.isLoading, true);
      expect(model.isSubmitting, false);
      expect(model.selectedLeaveTypeId, isNull);
      expect(model.startDate, isNull);
      expect(model.endDate, isNull);
    });

    testWidgets('initState creates reason controller', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Builder(
        builder: (context) {
          model.initState(context);
          return const SizedBox();
        },
      )));
      expect(model.reasonController, isNotNull);
      expect(model.reasonController, isA<TextEditingController>());
    });

    test('can store leave balances', () {
      model.balances = [
        {
          'id': '1',
          'leave_type_id': 'lt-1',
          'total_days': 21,
          'used_days': 5,
          'remaining_days': 16,
          'leave_types': {'name': 'Annual Leave', 'code': 'AL', 'days_allowed': 21},
        },
        {
          'id': '2',
          'leave_type_id': 'lt-2',
          'total_days': 10,
          'used_days': 0,
          'remaining_days': 10,
          'leave_types': {'name': 'Sick Leave', 'code': 'SL', 'days_allowed': 10},
        },
      ];
      expect(model.balances.length, 2);
      expect(model.balances[0]['leave_types']['name'], 'Annual Leave');
    });

    test('can store leave requests', () {
      model.requests = [
        {
          'id': 'req-1',
          'staff_id': 'staff-1',
          'leave_type': 'Annual Leave',
          'start_date': '2026-03-01',
          'end_date': '2026-03-05',
          'status': 'pending',
          'reason': 'Family vacation',
        },
      ];
      expect(model.requests.length, 1);
      expect(model.requests[0]['status'], 'pending');
    });

    test('can set form fields for leave request', () {
      model.selectedLeaveTypeId = 'lt-1';
      model.startDate = DateTime(2026, 3, 1);
      model.endDate = DateTime(2026, 3, 5);
      expect(model.selectedLeaveTypeId, 'lt-1');
      expect(model.startDate, DateTime(2026, 3, 1));
      expect(model.endDate, DateTime(2026, 3, 5));
    });

    test('can store leave types', () {
      model.leaveTypes = [
        {'id': 'lt-1', 'name': 'Annual Leave', 'code': 'AL', 'days_allowed': 21},
        {'id': 'lt-2', 'name': 'Sick Leave', 'code': 'SL', 'days_allowed': 10},
        {'id': 'lt-3', 'name': 'Maternity Leave', 'code': 'ML', 'days_allowed': 84},
      ];
      expect(model.leaveTypes.length, 3);
    });

    testWidgets('dispose cleans up reason controller', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Builder(
        builder: (context) {
          model.initState(context);
          return const SizedBox();
        },
      )));
      model.dispose();
      // No crash after dispose
    });
  });

  group('HrDashboardModel', () {
    late HrDashboardModel model;

    setUp(() {
      model = HrDashboardModel();
    });

    test('has correct default values', () {
      expect(model.kpiData, isNull);
      expect(model.isLoading, true);
      expect(model.errorMessage, isNull);
      expect(model.unreadCount, 0);
    });

    test('can store KPI data', () {
      model.kpiData = {
        'total_staff': 45,
        'present_today': 40,
        'on_leave': 3,
        'absent': 2,
        'attendance_rate': 0.89,
      };
      expect(model.kpiData!['total_staff'], 45);
      expect(model.kpiData!['attendance_rate'], 0.89);
    });

    test('can track unread notification count', () {
      model.unreadCount = 5;
      expect(model.unreadCount, 5);
    });

    test('loading and error states', () {
      expect(model.isLoading, true);
      model.isLoading = false;
      expect(model.isLoading, false);

      model.errorMessage = 'Failed to load dashboard';
      expect(model.errorMessage, 'Failed to load dashboard');
    });
  });

  group('HrPayslipsModel', () {
    late HrPayslipsModel model;

    setUp(() {
      model = HrPayslipsModel();
    });

    test('has correct default values', () {
      expect(model.currentSalary, isNull);
      expect(model.payslips, isEmpty);
      expect(model.loans, isEmpty);
      expect(model.isLoading, true);
      expect(model.errorMessage, isNull);
      expect(model.selectedPayslip, isNull);
    });

    test('can store current salary', () {
      model.currentSalary = {
        'id': 'sal-1',
        'employee_id': 'emp-1',
        'basic_salary': 2500000,
        'housing_allowance': 500000,
        'transport_allowance': 200000,
        'is_current': true,
      };
      expect(model.currentSalary!['basic_salary'], 2500000);
    });

    test('can store payslips with payroll run info', () {
      model.payslips = [
        {
          'id': 'ps-1',
          'employee_id': 'emp-1',
          'gross_pay': 3200000,
          'net_pay': 2800000,
          'payroll_runs': {
            'month': 'January',
            'run_period_year': 2026,
            'run_period_month': 1,
            'status': 'completed',
          },
        },
      ];
      expect(model.payslips.length, 1);
      expect(model.payslips[0]['payroll_runs']['run_period_month'], 1);
    });

    test('can select payslip for detail view', () {
      final payslip = {'id': 'ps-1', 'net_pay': 2800000};
      model.selectedPayslip = payslip;
      expect(model.selectedPayslip, payslip);
    });

    test('can store loans', () {
      model.loans = [
        {
          'id': 'loan-1',
          'employee_id': 'emp-1',
          'amount': 1000000,
          'balance': 500000,
          'monthly_deduction': 100000,
        },
      ];
      expect(model.loans.length, 1);
      expect(model.loans[0]['balance'], 500000);
    });
  });

  group('HrPerformanceModel', () {
    late HrPerformanceModel model;

    setUp(() {
      model = HrPerformanceModel();
    });

    test('has correct default values', () {
      expect(model.reviews, isEmpty);
      expect(model.isLoading, true);
    });

    test('can store monthly performance records', () {
      model.reviews = [
        {
          'id': '1',
          'staff_id': 'staff-1',
          'year': 2026,
          'month': 1,
          'attendance_score': 95.0,
          'task_completion_score': 88.0,
          'overall_score': 91.5,
        },
        {
          'id': '2',
          'staff_id': 'staff-1',
          'year': 2025,
          'month': 12,
          'attendance_score': 90.0,
          'task_completion_score': 85.0,
          'overall_score': 87.5,
        },
      ];
      expect(model.reviews.length, 2);
      expect(model.reviews[0]['overall_score'], 91.5);
    });
  });

  group('HrNotificationsModel', () {
    late HrNotificationsModel model;

    setUp(() {
      model = HrNotificationsModel();
    });

    test('has correct default values', () {
      expect(model.notifications, isEmpty);
      expect(model.isLoading, true);
      expect(model.unreadOnly, false);
    });

    test('can store notifications', () {
      model.notifications = [
        {
          'id': 'n-1',
          'user_id': 'user-1',
          'event_type': 'leave_approved',
          'body': 'Your leave request has been approved',
          'is_read': false,
          'created_at': '2026-02-15T10:00:00',
        },
        {
          'id': 'n-2',
          'user_id': 'user-1',
          'event_type': 'payslip_ready',
          'body': 'Your January payslip is ready',
          'is_read': true,
          'created_at': '2026-02-14T09:00:00',
        },
      ];
      expect(model.notifications.length, 2);
      expect(model.notifications[0]['is_read'], false);
    });

    test('can toggle unread filter', () {
      expect(model.unreadOnly, false);
      model.unreadOnly = true;
      expect(model.unreadOnly, true);
    });
  });

  group('HrManagerApprovalsModel', () {
    late HrManagerApprovalsModel model;

    setUp(() {
      model = HrManagerApprovalsModel();
    });

    test('has correct default values', () {
      expect(model.pendingLeaves, isEmpty);
      expect(model.isLoading, true);
      expect(model.isSubmitting, false);
    });

    testWidgets('initState creates comment controller', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Builder(
        builder: (context) {
          model.initState(context);
          return const SizedBox();
        },
      )));
      expect(model.commentController, isNotNull);
      expect(model.commentController, isA<TextEditingController>());
    });

    test('can store pending leave requests', () {
      model.pendingLeaves = [
        {
          'id': 'req-1',
          'staff_id': 'staff-2',
          'full_name': 'Jane Doe',
          'leave_type': 'Annual Leave',
          'start_date': '2026-03-01',
          'end_date': '2026-03-05',
          'status': 'pending',
          'reason': 'Family event',
        },
      ];
      expect(model.pendingLeaves.length, 1);
      expect(model.pendingLeaves[0]['full_name'], 'Jane Doe');
    });

    test('double-tap guard via isSubmitting', () {
      expect(model.isSubmitting, false);
      model.isSubmitting = true;
      expect(model.isSubmitting, true);
    });

    testWidgets('dispose cleans up comment controller', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Builder(
        builder: (context) {
          model.initState(context);
          return const SizedBox();
        },
      )));
      model.dispose();
    });
  });

  group('HrProfileModel', () {
    late HrProfileModel model;

    setUp(() {
      model = HrProfileModel();
    });

    test('has correct default values', () {
      expect(model.employee, isNull);
      expect(model.salary, isNull);
      expect(model.isLoading, true);
    });

    test('can store employee data', () {
      model.employee = {
        'id': 'emp-1',
        'full_name': 'John Doe',
        'email': 'john@imfsl.co.tz',
        'department': 'IT',
        'position': 'Software Developer',
        'hire_date': '2024-01-15',
        'phone': '+255712345678',
      };
      expect(model.employee!['full_name'], 'John Doe');
      expect(model.employee!['department'], 'IT');
    });

    test('can store salary data', () {
      model.salary = {
        'basic_salary': 2500000,
        'housing_allowance': 500000,
        'transport_allowance': 200000,
        'is_current': true,
      };
      expect(model.salary!['basic_salary'], 2500000);
      expect(model.salary!['is_current'], true);
    });
  });
}
