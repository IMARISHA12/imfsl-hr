import '../database.dart';

class ZArchiveEmployeeOnboardingStatusTable
    extends SupabaseTable<ZArchiveEmployeeOnboardingStatusRow> {
  @override
  String get tableName => 'z_archive_employee_onboarding_status';

  @override
  ZArchiveEmployeeOnboardingStatusRow createRow(Map<String, dynamic> data) =>
      ZArchiveEmployeeOnboardingStatusRow(data);
}

class ZArchiveEmployeeOnboardingStatusRow extends SupabaseDataRow {
  ZArchiveEmployeeOnboardingStatusRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveEmployeeOnboardingStatusTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get employeeId => getField<String>('employee_id');
  set employeeId(String? value) => setField<String>('employee_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get invitedAt => getField<DateTime>('invited_at');
  set invitedAt(DateTime? value) => setField<DateTime>('invited_at', value);

  String? get invitedBy => getField<String>('invited_by');
  set invitedBy(String? value) => setField<String>('invited_by', value);

  DateTime? get registeredAt => getField<DateTime>('registered_at');
  set registeredAt(DateTime? value) =>
      setField<DateTime>('registered_at', value);

  DateTime? get profileCompletedAt =>
      getField<DateTime>('profile_completed_at');
  set profileCompletedAt(DateTime? value) =>
      setField<DateTime>('profile_completed_at', value);

  DateTime? get documentsSubmittedAt =>
      getField<DateTime>('documents_submitted_at');
  set documentsSubmittedAt(DateTime? value) =>
      setField<DateTime>('documents_submitted_at', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) => setField<String>('verified_by', value);

  DateTime? get rejectedAt => getField<DateTime>('rejected_at');
  set rejectedAt(DateTime? value) => setField<DateTime>('rejected_at', value);

  String? get rejectedBy => getField<String>('rejected_by');
  set rejectedBy(String? value) => setField<String>('rejected_by', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  List<String> get requiredDocuments =>
      getListField<String>('required_documents');
  set requiredDocuments(List<String>? value) =>
      setListField<String>('required_documents', value);

  List<String> get submittedDocuments =>
      getListField<String>('submitted_documents');
  set submittedDocuments(List<String>? value) =>
      setListField<String>('submitted_documents', value);

  int? get completionPercentage => getField<int>('completion_percentage');
  set completionPercentage(int? value) =>
      setField<int>('completion_percentage', value);

  bool? get identityVerified => getField<bool>('identity_verified');
  set identityVerified(bool? value) =>
      setField<bool>('identity_verified', value);

  bool? get nidaVerified => getField<bool>('nida_verified');
  set nidaVerified(bool? value) => setField<bool>('nida_verified', value);

  bool? get tinVerified => getField<bool>('tin_verified');
  set tinVerified(bool? value) => setField<bool>('tin_verified', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  DateTime? get linkOpenedAt => getField<DateTime>('link_opened_at');
  set linkOpenedAt(DateTime? value) =>
      setField<DateTime>('link_opened_at', value);
}
