import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'leavepage_widget.dart' show LeavepageWidget;
import 'package:flutter/material.dart';

class LeavepageModel extends FlutterFlowModel<LeavepageWidget> {
  ///  Local state fields for this page.

  DateTime? startDate;

  DateTime? endDate;

  String? selectedLeaveType;

  String? uploadedDocUrl;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for DefineOption widget.
  String? defineOptionValue;
  FormFieldController<String>? defineOptionValueController;
  DateTime? datePicked1;
  DateTime? datePicked2;
  DateTime? datePicked3;
  DateTime? datePicked4;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  bool isDataUploading_uploadedMedia = false;
  FFUploadedFile uploadedLocalFile_uploadedMedia =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadedMedia = '';

  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<StaffRow>? staffIDtoLeave;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
