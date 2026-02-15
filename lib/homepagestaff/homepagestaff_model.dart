import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'homepagestaff_widget.dart' show HomepagestaffWidget;
import 'package:flutter/material.dart';

class HomepagestaffModel extends FlutterFlowModel<HomepagestaffWidget> {
  ///  Local state fields for this page.

  String? currentStaffId;

  String? currentStaffName;

  bool isClockedIn = true;

  DateTime? clockInTime;

  DateTime? currentRealTime;

  int? totalWorkDays = 0;

  int? lateDays = 0;

  int? remainingLeave = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in Homepagestaff widget.
  List<StaffRow>? currentStaff;
  // Stores action output result for [Backend Call - Query Rows] action in Homepagestaff widget.
  List<AttendanceRecordsRow>? todayAttendance;
  // Stores action output result for [Backend Call - Query Rows] action in Homepagestaff widget.
  List<AttendanceRecordsRow>? allAttendance;
  // Stores action output result for [Backend Call - Query Rows] action in Homepagestaff widget.
  List<AttendanceRecordsRow>? lateAttendance;
  // Stores action output result for [Backend Call - Query Rows] action in Homepagestaff widget.
  List<LeaveBalancesRow>? leaveBalance;
  InstantTimer? instantTimer;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }
}
