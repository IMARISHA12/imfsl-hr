import '/flutter_flow/flutter_flow_util.dart';
import 'hr_profile_widget.dart' show HrProfileWidget;
import 'package:flutter/material.dart';

class HrProfileModel extends FlutterFlowModel<HrProfileWidget> {
  /// Employee record.
  Map<String, dynamic>? employee;

  /// Current salary structure.
  Map<String, dynamic>? salary;

  /// Loading state.
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
