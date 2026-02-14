import '/flutter_flow/flutter_flow_util.dart';
import 'hr_leave_widget.dart' show HrLeaveWidget;
import 'package:flutter/material.dart';

class HrLeaveModel extends FlutterFlowModel<HrLeaveWidget> {
  /// Leave balances for current year.
  List<Map<String, dynamic>> balances = [];

  /// My leave requests.
  List<Map<String, dynamic>> requests = [];

  /// Available leave types.
  List<Map<String, dynamic>> leaveTypes = [];

  /// Loading state.
  bool isLoading = true;

  /// Prevents double-tap on submit/cancel buttons.
  bool isSubmitting = false;

  /// New request form controllers.
  TextEditingController? reasonController;
  String? selectedLeaveTypeId;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState(BuildContext context) {
    reasonController = TextEditingController();
  }

  @override
  void dispose() {
    reasonController?.dispose();
  }
}
