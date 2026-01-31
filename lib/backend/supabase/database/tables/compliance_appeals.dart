import '../database.dart';

class ComplianceAppealsTable extends SupabaseTable<ComplianceAppealsRow> {
  @override
  String get tableName => 'compliance_appeals';

  @override
  ComplianceAppealsRow createRow(Map<String, dynamic> data) =>
      ComplianceAppealsRow(data);
}

class ComplianceAppealsRow extends SupabaseDataRow {
  ComplianceAppealsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ComplianceAppealsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get taskId => getField<String>('task_id');
  set taskId(String? value) => setField<String>('task_id', value);

  String get reasonText => getField<String>('reason_text')!;
  set reasonText(String value) => setField<String>('reason_text', value);

  String? get attachmentPath => getField<String>('attachment_path');
  set attachmentPath(String? value) =>
      setField<String>('attachment_path', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
