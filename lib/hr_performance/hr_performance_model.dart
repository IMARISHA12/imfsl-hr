import '/flutter_flow/flutter_flow_util.dart';
import 'hr_performance_widget.dart' show HrPerformanceWidget;
import 'package:flutter/material.dart';

class HrPerformanceModel extends FlutterFlowModel<HrPerformanceWidget> {
  /// My pending/active reviews.
  List<Map<String, dynamic>> reviews = [];

  /// Performance history from dashboard view.
  List<Map<String, dynamic>> history = [];

  /// Loading state.
  bool isLoading = true;

  /// Prevents double-tap on submit button.
  bool isSubmitting = false;

  /// Currently selected review for self-assessment form.
  Map<String, dynamic>? activeReview;

  /// Self-assessment score controllers.
  double quality = 3;
  double productivity = 3;
  double teamwork = 3;
  double initiative = 3;
  double attendance = 3;
  TextEditingController? commentsController;

  @override
  void initState(BuildContext context) {
    commentsController = TextEditingController();
  }

  @override
  void dispose() {
    commentsController?.dispose();
  }
}
