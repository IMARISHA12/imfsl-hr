import '../database.dart';

class LicenseTypesTable extends SupabaseTable<LicenseTypesRow> {
  @override
  String get tableName => 'license_types';

  @override
  LicenseTypesRow createRow(Map<String, dynamic> data) => LicenseTypesRow(data);
}

class LicenseTypesRow extends SupabaseDataRow {
  LicenseTypesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LicenseTypesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String? get issuingAuthority => getField<String>('issuing_authority');
  set issuingAuthority(String? value) =>
      setField<String>('issuing_authority', value);

  int? get renewalCycleMonths => getField<int>('renewal_cycle_months');
  set renewalCycleMonths(int? value) =>
      setField<int>('renewal_cycle_months', value);

  List<int> get advanceWarningDays => getListField<int>('advance_warning_days');
  set advanceWarningDays(List<int>? value) =>
      setListField<int>('advance_warning_days', value);

  double? get latePenaltyRate => getField<double>('late_penalty_rate');
  set latePenaltyRate(double? value) =>
      setField<double>('late_penalty_rate', value);

  List<String> get requiredDocuments =>
      getListField<String>('required_documents');
  set requiredDocuments(List<String>? value) =>
      setListField<String>('required_documents', value);

  bool? get complianceCritical => getField<bool>('compliance_critical');
  set complianceCritical(bool? value) =>
      setField<bool>('compliance_critical', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
