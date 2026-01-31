import '../database.dart';

class TasksTable extends SupabaseTable<TasksRow> {
  @override
  String get tableName => 'tasks';

  @override
  TasksRow createRow(Map<String, dynamic> data) => TasksRow(data);
}

class TasksRow extends SupabaseDataRow {
  TasksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TasksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get assignedTo => getField<String>('assigned_to')!;
  set assignedTo(String value) => setField<String>('assigned_to', value);

  String get assignedBy => getField<String>('assigned_by')!;
  set assignedBy(String value) => setField<String>('assigned_by', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get priority => getField<String>('priority')!;
  set priority(String value) => setField<String>('priority', value);

  String? get linkedRecordId => getField<String>('linked_record_id');
  set linkedRecordId(String? value) =>
      setField<String>('linked_record_id', value);

  String? get linkedRecordType => getField<String>('linked_record_type');
  set linkedRecordType(String? value) =>
      setField<String>('linked_record_type', value);

  DateTime? get dueDate => getField<DateTime>('due_date');
  set dueDate(DateTime? value) => setField<DateTime>('due_date', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
