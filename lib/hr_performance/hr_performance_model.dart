import '/flutter_flow/flutter_flow_util.dart';
import 'hr_performance_widget.dart' show HrPerformanceWidget;
import 'package:flutter/material.dart';

class HrPerformanceModel extends FlutterFlowModel<HrPerformanceWidget> {
  /// Monthly performance records from staff_performance_monthly.
  List<Map<String, dynamic>> reviews = [];

  /// Loading state.
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
