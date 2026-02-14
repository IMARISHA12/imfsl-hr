import '/flutter_flow/flutter_flow_util.dart';
import 'hr_notifications_widget.dart' show HrNotificationsWidget;
import 'package:flutter/material.dart';

class HrNotificationsModel extends FlutterFlowModel<HrNotificationsWidget> {
  /// Notifications list.
  List<Map<String, dynamic>> notifications = [];

  /// Loading state.
  bool isLoading = true;

  /// Show only unread.
  bool unreadOnly = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
