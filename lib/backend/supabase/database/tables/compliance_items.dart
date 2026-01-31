import '../database.dart';

class ComplianceItemsTable extends SupabaseTable<ComplianceItemsRow> {
  @override
  String get tableName => 'compliance_items';

  @override
  ComplianceItemsRow createRow(Map<String, dynamic> data) =>
      ComplianceItemsRow(data);
}

class ComplianceItemsRow extends SupabaseDataRow {
  ComplianceItemsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ComplianceItemsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime get dueDate => getField<DateTime>('due_date')!;
  set dueDate(DateTime value) => setField<DateTime>('due_date', value);

  int? get progress => getField<int>('progress');
  set progress(int? value) => setField<int>('progress', value);

  String get responsibleDepartment =>
      getField<String>('responsible_department')!;
  set responsibleDepartment(String value) =>
      setField<String>('responsible_department', value);

  DateTime? get lastReviewed => getField<DateTime>('last_reviewed');
  set lastReviewed(DateTime? value) =>
      setField<DateTime>('last_reviewed', value);

  DateTime? get nextReview => getField<DateTime>('next_review');
  set nextReview(DateTime? value) => setField<DateTime>('next_review', value);

  String? get riskLevel => getField<String>('risk_level');
  set riskLevel(String? value) => setField<String>('risk_level', value);

  int? get complianceScore => getField<int>('compliance_score');
  set complianceScore(int? value) => setField<int>('compliance_score', value);

  List<String> get evidenceFiles => getListField<String>('evidence_files');
  set evidenceFiles(List<String>? value) =>
      setListField<String>('evidence_files', value);

  int? get graceDays => getField<int>('grace_days');
  set graceDays(int? value) => setField<int>('grace_days', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
