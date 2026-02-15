import '/flutter_flow/flutter_flow_util.dart';
import 'hr_attendance_widget.dart' show HrAttendanceWidget;
import 'package:flutter/material.dart';

class HrAttendanceModel extends FlutterFlowModel<HrAttendanceWidget> {
  /// Whether user is clocked in today.
  bool isClockedIn = false;

  /// Clock-in time for today.
  String? clockInTime;

  /// Monthly attendance records.
  List<Map<String, dynamic>> records = [];

  /// Summary stats.
  Map<String, dynamic> summary = {};

  /// Loading state.
  bool isLoading = true;

  /// Error message to display.
  String? errorMessage;

  /// Prevents double-tap on clock in/out buttons.
  bool isSubmitting = false;

  /// Daily report text controller (for clock-out).
  TextEditingController? reportController;

  @override
  void initState(BuildContext context) {
    reportController = TextEditingController();
  }

  @override
  void dispose() {
    reportController?.dispose();
  }
}
