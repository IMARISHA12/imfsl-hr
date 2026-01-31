import '../database.dart';

class ZArchiveLeaveApprovalMatrixTable
    extends SupabaseTable<ZArchiveLeaveApprovalMatrixRow> {
  @override
  String get tableName => 'z_archive_leave_approval_matrix';

  @override
  ZArchiveLeaveApprovalMatrixRow createRow(Map<String, dynamic> data) =>
      ZArchiveLeaveApprovalMatrixRow(data);
}

class ZArchiveLeaveApprovalMatrixRow extends SupabaseDataRow {
  ZArchiveLeaveApprovalMatrixRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveLeaveApprovalMatrixTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get branchCode => getField<String>('branch_code')!;
  set branchCode(String value) => setField<String>('branch_code', value);

  String? get leaveTypeId => getField<String>('leave_type_id');
  set leaveTypeId(String? value) => setField<String>('leave_type_id', value);

  String get stage => getField<String>('stage')!;
  set stage(String value) => setField<String>('stage', value);

  List<String> get allowedRoles => getListField<String>('allowed_roles');
  set allowedRoles(List<String> value) =>
      setListField<String>('allowed_roles', value);

  List<String> get allowedEmails => getListField<String>('allowed_emails');
  set allowedEmails(List<String>? value) =>
      setListField<String>('allowed_emails', value);

  bool get enforceActorBranch => getField<bool>('enforce_actor_branch')!;
  set enforceActorBranch(bool value) =>
      setField<bool>('enforce_actor_branch', value);

  bool get active => getField<bool>('active')!;
  set active(bool value) => setField<bool>('active', value);
}
