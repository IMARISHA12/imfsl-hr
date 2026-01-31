import '../database.dart';

class CompanyLicensesTable extends SupabaseTable<CompanyLicensesRow> {
  @override
  String get tableName => 'company_licenses';

  @override
  CompanyLicensesRow createRow(Map<String, dynamic> data) =>
      CompanyLicensesRow(data);
}

class CompanyLicensesRow extends SupabaseDataRow {
  CompanyLicensesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CompanyLicensesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get licenseTypeId => getField<String>('license_type_id');
  set licenseTypeId(String? value) =>
      setField<String>('license_type_id', value);

  String get licenseNumber => getField<String>('license_number')!;
  set licenseNumber(String value) => setField<String>('license_number', value);

  String get licenseName => getField<String>('license_name')!;
  set licenseName(String value) => setField<String>('license_name', value);

  String get issuingAuthority => getField<String>('issuing_authority')!;
  set issuingAuthority(String value) =>
      setField<String>('issuing_authority', value);

  DateTime get issueDate => getField<DateTime>('issue_date')!;
  set issueDate(DateTime value) => setField<DateTime>('issue_date', value);

  DateTime get expiryDate => getField<DateTime>('expiry_date')!;
  set expiryDate(DateTime value) => setField<DateTime>('expiry_date', value);

  DateTime? get renewalDate => getField<DateTime>('renewal_date');
  set renewalDate(DateTime? value) => setField<DateTime>('renewal_date', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  String? get responsibleRole => getField<String>('responsible_role');
  set responsibleRole(String? value) =>
      setField<String>('responsible_role', value);

  String? get responsibleUserId => getField<String>('responsible_user_id');
  set responsibleUserId(String? value) =>
      setField<String>('responsible_user_id', value);

  List<String> get documentIds => getListField<String>('document_ids');
  set documentIds(List<String>? value) =>
      setListField<String>('document_ids', value);

  double? get renewalCost => getField<double>('renewal_cost');
  set renewalCost(double? value) => setField<double>('renewal_cost', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime? get lastReminderSentAt =>
      getField<DateTime>('last_reminder_sent_at');
  set lastReminderSentAt(DateTime? value) =>
      setField<DateTime>('last_reminder_sent_at', value);

  int? get escalationLevel => getField<int>('escalation_level');
  set escalationLevel(int? value) => setField<int>('escalation_level', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
