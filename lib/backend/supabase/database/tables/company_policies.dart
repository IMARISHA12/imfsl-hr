import '../database.dart';

class CompanyPoliciesTable extends SupabaseTable<CompanyPoliciesRow> {
  @override
  String get tableName => 'company_policies';

  @override
  CompanyPoliciesRow createRow(Map<String, dynamic> data) =>
      CompanyPoliciesRow(data);
}

class CompanyPoliciesRow extends SupabaseDataRow {
  CompanyPoliciesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CompanyPoliciesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  int get version => getField<int>('version')!;
  set version(int value) => setField<int>('version', value);

  bool get requiredAcknowledgment => getField<bool>('required_acknowledgment')!;
  set requiredAcknowledgment(bool value) =>
      setField<bool>('required_acknowledgment', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
