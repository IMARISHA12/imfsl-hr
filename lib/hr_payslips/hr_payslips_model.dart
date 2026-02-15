import '/flutter_flow/flutter_flow_util.dart';
import 'hr_payslips_widget.dart' show HrPayslipsWidget;
import 'package:flutter/material.dart';

class HrPayslipsModel extends FlutterFlowModel<HrPayslipsWidget> {
  /// Current salary structure.
  Map<String, dynamic>? currentSalary;

  /// Payslip history.
  List<Map<String, dynamic>> payslips = [];

  /// Staff salary loans.
  List<Map<String, dynamic>> loans = [];

  /// Loading state.
  bool isLoading = true;

  /// Error message to display.
  String? errorMessage;

  /// Selected payslip for detail view.
  Map<String, dynamic>? selectedPayslip;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
