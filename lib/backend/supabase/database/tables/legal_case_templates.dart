import '../database.dart';

class LegalCaseTemplatesTable extends SupabaseTable<LegalCaseTemplatesRow> {
  @override
  String get tableName => 'legal_case_templates';

  @override
  LegalCaseTemplatesRow createRow(Map<String, dynamic> data) =>
      LegalCaseTemplatesRow(data);
}

class LegalCaseTemplatesRow extends SupabaseDataRow {
  LegalCaseTemplatesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalCaseTemplatesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseType => getField<String>('case_type')!;
  set caseType(String value) => setField<String>('case_type', value);

  String? get subType => getField<String>('sub_type');
  set subType(String? value) => setField<String>('sub_type', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  dynamic get requiredDocuments => getField<dynamic>('required_documents')!;
  set requiredDocuments(dynamic value) =>
      setField<dynamic>('required_documents', value);

  dynamic get standardProcedures => getField<dynamic>('standard_procedures');
  set standardProcedures(dynamic value) =>
      setField<dynamic>('standard_procedures', value);

  int? get typicalDurationDays => getField<int>('typical_duration_days');
  set typicalDurationDays(int? value) =>
      setField<int>('typical_duration_days', value);

  dynamic get applicableLaws => getField<dynamic>('applicable_laws');
  set applicableLaws(dynamic value) =>
      setField<dynamic>('applicable_laws', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
