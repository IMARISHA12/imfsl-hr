import '../database.dart';

class HrAuditLogTable extends SupabaseTable<HrAuditLogRow> {
  @override
  String get tableName => 'hr_audit_log';

  @override
  HrAuditLogRow createRow(Map<String, dynamic> data) => HrAuditLogRow(data);
}

class HrAuditLogRow extends SupabaseDataRow {
  HrAuditLogRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => HrAuditLogTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get tableName_ => getField<String>('table_name')!;
  set tableName_(String value) => setField<String>('table_name', value);

  String? get recordId => getField<String>('record_id');
  set recordId(String? value) => setField<String>('record_id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  dynamic get oldValues => getField<dynamic>('old_values');
  set oldValues(dynamic value) => setField<dynamic>('old_values', value);

  dynamic get newValues => getField<dynamic>('new_values');
  set newValues(dynamic value) => setField<dynamic>('new_values', value);

  List<String> get changedFields =>
      getListField<String>('changed_fields');
  set changedFields(List<String>? value) =>
      setListField<String>('changed_fields', value);

  String? get performedBy => getField<String>('performed_by');
  set performedBy(String? value) => setField<String>('performed_by', value);

  DateTime get performedAt => getField<DateTime>('performed_at')!;
  set performedAt(DateTime value) =>
      setField<DateTime>('performed_at', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);
}
