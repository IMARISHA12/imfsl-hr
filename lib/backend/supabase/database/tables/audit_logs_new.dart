import '../database.dart';

class AuditLogsNewTable extends SupabaseTable<AuditLogsNewRow> {
  @override
  String get tableName => 'audit_logs_new';

  @override
  AuditLogsNewRow createRow(Map<String, dynamic> data) => AuditLogsNewRow(data);
}

class AuditLogsNewRow extends SupabaseDataRow {
  AuditLogsNewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AuditLogsNewTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get tableNameField => getField<String>('table_name')!;
  set tableNameField(String value) => setField<String>('table_name', value);

  String get recordId => getField<String>('record_id')!;
  set recordId(String value) => setField<String>('record_id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String? get changedBy => getField<String>('changed_by');
  set changedBy(String? value) => setField<String>('changed_by', value);

  dynamic get oldData => getField<dynamic>('old_data');
  set oldData(dynamic value) => setField<dynamic>('old_data', value);

  dynamic get newData => getField<dynamic>('new_data');
  set newData(dynamic value) => setField<dynamic>('new_data', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  DateTime? get timestamp => getField<DateTime>('timestamp');
  set timestamp(DateTime? value) => setField<DateTime>('timestamp', value);
}
