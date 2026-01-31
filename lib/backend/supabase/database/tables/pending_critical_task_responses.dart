import '../database.dart';

class PendingCriticalTaskResponsesTable
    extends SupabaseTable<PendingCriticalTaskResponsesRow> {
  @override
  String get tableName => 'pending_critical_task_responses';

  @override
  PendingCriticalTaskResponsesRow createRow(Map<String, dynamic> data) =>
      PendingCriticalTaskResponsesRow(data);
}

class PendingCriticalTaskResponsesRow extends SupabaseDataRow {
  PendingCriticalTaskResponsesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PendingCriticalTaskResponsesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get taskId => getField<String>('task_id')!;
  set taskId(String value) => setField<String>('task_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get explanation => getField<String>('explanation')!;
  set explanation(String value) => setField<String>('explanation', value);

  DateTime get submittedAt => getField<DateTime>('submitted_at')!;
  set submittedAt(DateTime value) => setField<DateTime>('submitted_at', value);
}
