import '../database.dart';

class ZArchiveSecurityPlaybooksTable
    extends SupabaseTable<ZArchiveSecurityPlaybooksRow> {
  @override
  String get tableName => 'z_archive_security_playbooks';

  @override
  ZArchiveSecurityPlaybooksRow createRow(Map<String, dynamic> data) =>
      ZArchiveSecurityPlaybooksRow(data);
}

class ZArchiveSecurityPlaybooksRow extends SupabaseDataRow {
  ZArchiveSecurityPlaybooksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveSecurityPlaybooksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get playbookType => getField<String>('playbook_type')!;
  set playbookType(String value) => setField<String>('playbook_type', value);

  List<String> get severityTrigger => getListField<String>('severity_trigger');
  set severityTrigger(List<String>? value) =>
      setListField<String>('severity_trigger', value);

  bool? get automated => getField<bool>('automated');
  set automated(bool? value) => setField<bool>('automated', value);

  dynamic get steps => getField<dynamic>('steps')!;
  set steps(dynamic value) => setField<dynamic>('steps', value);

  List<String> get notificationRoles =>
      getListField<String>('notification_roles');
  set notificationRoles(List<String>? value) =>
      setListField<String>('notification_roles', value);

  bool? get enabled => getField<bool>('enabled');
  set enabled(bool? value) => setField<bool>('enabled', value);

  int? get executionCount => getField<int>('execution_count');
  set executionCount(int? value) => setField<int>('execution_count', value);

  DateTime? get lastExecutedAt => getField<DateTime>('last_executed_at');
  set lastExecutedAt(DateTime? value) =>
      setField<DateTime>('last_executed_at', value);

  int? get avgExecutionTimeMs => getField<int>('avg_execution_time_ms');
  set avgExecutionTimeMs(int? value) =>
      setField<int>('avg_execution_time_ms', value);

  double? get successRate => getField<double>('success_rate');
  set successRate(double? value) => setField<double>('success_rate', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
