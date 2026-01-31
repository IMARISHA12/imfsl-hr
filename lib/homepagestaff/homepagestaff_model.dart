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

  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }
}
