import '/flutter_flow/flutter_flow_util.dart';
import 'hr_dashboard_widget.dart' show HrDashboardWidget;
import 'package:flutter/material.dart';

class HrDashboardModel extends FlutterFlowModel<HrDashboardWidget> {
  /// Dashboard KPI data loaded from rpc_hr_dashboard_kpis.
  Map<String, dynamic>? kpiData;

  /// Loading state.
  bool isLoading = true;

  /// Error message if load fails.
  String? errorMessage;

  /// Unread notification count.
  int unreadCount = 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
