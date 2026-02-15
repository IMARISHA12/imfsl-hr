import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'usajili_widget.dart' show UsajiliWidget;
import 'package:flutter/material.dart';

class UsajiliModel extends FlutterFlowModel<UsajiliWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey3 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  // State field(s) for fullNameField widget.
  FocusNode? fullNameFieldFocusNode;
  TextEditingController? fullNameFieldTextController;
  String? Function(BuildContext, String?)? fullNameFieldTextControllerValidator;
  // State field(s) for genderDropdown widget.
  String? genderDropdownValue;
  FormFieldController<String>? genderDropdownValueController;
  // State field(s) for nidaField widget.
  FocusNode? nidaFieldFocusNode;
  TextEditingController? nidaFieldTextController;
  String? Function(BuildContext, String?)? nidaFieldTextControllerValidator;
  // State field(s) for phoneField widget.
  FocusNode? phoneFieldFocusNode;
  TextEditingController? phoneFieldTextController;
  String? Function(BuildContext, String?)? phoneFieldTextControllerValidator;
  // State field(s) for addressField widget.
  FocusNode? addressFieldFocusNode;
  TextEditingController? addressFieldTextController;
  String? Function(BuildContext, String?)? addressFieldTextControllerValidator;
  // State field(s) for departmentDropdown widget.
  String? departmentDropdownValue;
  FormFieldController<String>? departmentDropdownValueController;
  // State field(s) for branchDropdown widget.
  String? branchDropdownValue;
  FormFieldController<String>? branchDropdownValueController;
  // State field(s) for positionField widget.
  FocusNode? positionFieldFocusNode;
  TextEditingController? positionFieldTextController;
  String? Function(BuildContext, String?)? positionFieldTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    fullNameFieldFocusNode?.dispose();
    fullNameFieldTextController?.dispose();

    nidaFieldFocusNode?.dispose();
    nidaFieldTextController?.dispose();

    phoneFieldFocusNode?.dispose();
    phoneFieldTextController?.dispose();

    addressFieldFocusNode?.dispose();
    addressFieldTextController?.dispose();

    positionFieldFocusNode?.dispose();
    positionFieldTextController?.dispose();
  }
}
