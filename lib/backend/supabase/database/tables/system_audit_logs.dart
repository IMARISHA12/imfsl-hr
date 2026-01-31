import '../database.dart';

class SystemAuditLogsTable extends SupabaseTable<SystemAuditLogsRow> {
  @override
  String get tableName => 'system_audit_logs';

  @override
  SystemAuditLogsRow createRow(Map<String, dynamic> data) =>
      SystemAuditLogsRow(data);
}

class SystemAuditLogsRow extends SupabaseDataRow {
  SystemAuditLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SystemAuditLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get timestamp => getField<DateTime>('timestamp')!;
  set timestamp(DateTime value) => setField<DateTime>('timestamp', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String get module => getField<String>('module')!;
  set module(String value) => setField<String>('module', value);

  String? get resourceType => getField<String>('resource_type');
  set resourceType(String? value) => setField<String>('resource_type', value);

  String? get resourceId => getField<String>('resource_id');
  set resourceId(String? value) => setField<String>('resource_id', value);

  dynamic get oldValues => getField<dynamic>('old_values');
  set oldValues(dynamic value) => setField<dynamic>('old_values', value);

  dynamic get newValues => getField<dynamic>('new_values');
  set newValues(dynamic value) => setField<dynamic>('new_values', value);

  dynamic get details => getField<dynamic>('details');
  set details(dynamic value) => setField<dynamic>('details', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  String? get sessionId => getField<String>('session_id');
  set sessionId(String? value) => setField<String>('session_id', value);
}
