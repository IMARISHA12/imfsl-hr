import '../database.dart';

class StaffActionLogsTable extends SupabaseTable<StaffActionLogsRow> {
  @override
  String get tableName => 'staff_action_logs';

  @override
  StaffActionLogsRow createRow(Map<String, dynamic> data) =>
      StaffActionLogsRow(data);
}

class StaffActionLogsRow extends SupabaseDataRow {
  StaffActionLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffActionLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get occurredAt => getField<DateTime>('occurred_at')!;
  set occurredAt(DateTime value) => setField<DateTime>('occurred_at', value);

  String? get actorUserId => getField<String>('actor_user_id');
  set actorUserId(String? value) => setField<String>('actor_user_id', value);

  String get actorLabel => getField<String>('actor_label')!;
  set actorLabel(String value) => setField<String>('actor_label', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String get targetEmployeeId => getField<String>('target_employee_id')!;
  set targetEmployeeId(String value) =>
      setField<String>('target_employee_id', value);

  String? get beforeStatus => getField<String>('before_status');
  set beforeStatus(String? value) => setField<String>('before_status', value);

  String? get afterStatus => getField<String>('after_status');
  set afterStatus(String? value) => setField<String>('after_status', value);

  dynamic get context => getField<dynamic>('context');
  set context(dynamic value) => setField<dynamic>('context', value);
}
