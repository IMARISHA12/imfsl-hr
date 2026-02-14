import '../database.dart';

class ScheduledTaskRunsTable extends SupabaseTable<ScheduledTaskRunsRow> {
  @override
  String get tableName => 'scheduled_task_runs';

  @override
  ScheduledTaskRunsRow createRow(Map<String, dynamic> data) =>
      ScheduledTaskRunsRow(data);
}

class ScheduledTaskRunsRow extends SupabaseDataRow {
  ScheduledTaskRunsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ScheduledTaskRunsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get taskName => getField<String>('task_name')!;
  set taskName(String value) => setField<String>('task_name', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get startedAt => getField<DateTime>('started_at')!;
  set startedAt(DateTime value) => setField<DateTime>('started_at', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) =>
      setField<DateTime>('completed_at', value);

  dynamic get result => getField<dynamic>('result');
  set result(dynamic value) => setField<dynamic>('result', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) =>
      setField<String>('error_message', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
