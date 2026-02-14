import '/flutter_flow/flutter_flow_util.dart';
import 'hr_manager_approvals_widget.dart' show HrManagerApprovalsWidget;
import 'package:flutter/material.dart';

class HrManagerApprovalsModel
    extends FlutterFlowModel<HrManagerApprovalsWidget> {
  /// Pending leave requests for approval.
  List<Map<String, dynamic>> pendingLeaves = [];

  /// Loading state.
  bool isLoading = true;

  /// Comment controller for approval/rejection.
  TextEditingController? commentController;

  @override
  void initState(BuildContext context) {
    commentController = TextEditingController();
  }

  @override
  void dispose() {
    commentController?.dispose();
  }
}
