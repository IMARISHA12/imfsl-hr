import '../database.dart';

class ComplianceReportsTable extends SupabaseTable<ComplianceReportsRow> {
  @override
  String get tableName => 'compliance_reports';

  @override
  ComplianceReportsRow createRow(Map<String, dynamic> data) =>
      ComplianceReportsRow(data);
}

class ComplianceReportsRow extends SupabaseDataRow {
  ComplianceReportsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ComplianceReportsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get reportCode => getField<String>('report_code')!;
  set reportCode(String value) => setField<String>('report_code', value);

  String get reportType => getField<String>('report_type')!;
  set reportType(String value) => setField<String>('report_type', value);

  DateTime get periodStart => getField<DateTime>('period_start')!;
  set periodStart(DateTime value) => setField<DateTime>('period_start', value);

  DateTime get periodEnd => getField<DateTime>('period_end')!;
  set periodEnd(DateTime value) => setField<DateTime>('period_end', value);

  int get fiscalYear => getField<int>('fiscal_year')!;
  set fiscalYear(int value) => setField<int>('fiscal_year', value);

  dynamic get reportData => getField<dynamic>('report_data');
  set reportData(dynamic value) => setField<dynamic>('report_data', value);

  DateTime? get generatedAt => getField<DateTime>('generated_at');
  set generatedAt(DateTime? value) => setField<DateTime>('generated_at', value);

  DateTime? get submittedAt => getField<DateTime>('submitted_at');
  set submittedAt(DateTime? value) => setField<DateTime>('submitted_at', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get fileUrl => getField<String>('file_url');
  set fileUrl(String? value) => setField<String>('file_url', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get submittedBy => getField<String>('submitted_by');
  set submittedBy(String? value) => setField<String>('submitted_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
