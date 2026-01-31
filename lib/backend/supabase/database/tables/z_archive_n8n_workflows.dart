import '../database.dart';

class ZArchiveN8nWorkflowsTable extends SupabaseTable<ZArchiveN8nWorkflowsRow> {
  @override
  String get tableName => 'z_archive_n8n_workflows';

  @override
  ZArchiveN8nWorkflowsRow createRow(Map<String, dynamic> data) =>
      ZArchiveN8nWorkflowsRow(data);
}

class ZArchiveN8nWorkflowsRow extends SupabaseDataRow {
  ZArchiveN8nWorkflowsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveN8nWorkflowsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get webhookUrl => getField<String>('webhook_url')!;
  set webhookUrl(String value) => setField<String>('webhook_url', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  dynamic get triggerConditions => getField<dynamic>('trigger_conditions');
  set triggerConditions(dynamic value) =>
      setField<dynamic>('trigger_conditions', value);

  DateTime? get lastExecution => getField<DateTime>('last_execution');
  set lastExecution(DateTime? value) =>
      setField<DateTime>('last_execution', value);

  int? get successCount => getField<int>('success_count');
  set successCount(int? value) => setField<int>('success_count', value);

  int? get errorCount => getField<int>('error_count');
  set errorCount(int? value) => setField<int>('error_count', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
