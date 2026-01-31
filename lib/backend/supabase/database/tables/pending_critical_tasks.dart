import '../database.dart';

class PendingCriticalTasksTable extends SupabaseTable<PendingCriticalTasksRow> {
  @override
  String get tableName => 'pending_critical_tasks';

  @override
  PendingCriticalTasksRow createRow(Map<String, dynamic> data) =>
      PendingCriticalTasksRow(data);
}

class PendingCriticalTasksRow extends SupabaseDataRow {
  PendingCriticalTasksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PendingCriticalTasksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get blockingLevel => getField<String>('blocking_level')!;
  set blockingLevel(String value) => setField<String>('blocking_level', value);

  DateTime? get dueAt => getField<DateTime>('due_at');
  set dueAt(DateTime? value) => setField<DateTime>('due_at', value);

  String? get formKey => getField<String>('form_key');
  set formKey(String? value) => setField<String>('form_key', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
