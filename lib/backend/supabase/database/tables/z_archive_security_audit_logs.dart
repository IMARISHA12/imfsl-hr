import '../database.dart';

class ZArchiveSecurityAuditLogsTable
    extends SupabaseTable<ZArchiveSecurityAuditLogsRow> {
  @override
  String get tableName => 'z_archive_security_audit_logs';

  @override
  ZArchiveSecurityAuditLogsRow createRow(Map<String, dynamic> data) =>
      ZArchiveSecurityAuditLogsRow(data);
}

class ZArchiveSecurityAuditLogsRow extends SupabaseDataRow {
  ZArchiveSecurityAuditLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveSecurityAuditLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get recordId => getField<String>('record_id');
  set recordId(String? value) => setField<String>('record_id', value);

  String get tableNameField => getField<String>('table_name')!;
  set tableNameField(String value) => setField<String>('table_name', value);

  String get operation => getField<String>('operation')!;
  set operation(String value) => setField<String>('operation', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  DateTime? get timestamp => getField<DateTime>('timestamp');
  set timestamp(DateTime? value) => setField<DateTime>('timestamp', value);

  dynamic get dataBefore => getField<dynamic>('data_before');
  set dataBefore(dynamic value) => setField<dynamic>('data_before', value);

  dynamic get dataAfter => getField<dynamic>('data_after');
  set dataAfter(dynamic value) => setField<dynamic>('data_after', value);

  String? get riskLevel => getField<String>('risk_level');
  set riskLevel(String? value) => setField<String>('risk_level', value);

  String? get dataClassification => getField<String>('data_classification');
  set dataClassification(String? value) =>
      setField<String>('data_classification', value);

  bool? get sensitiveDataAccessed => getField<bool>('sensitive_data_accessed');
  set sensitiveDataAccessed(bool? value) =>
      setField<bool>('sensitive_data_accessed', value);

  DateTime? get accessTime => getField<DateTime>('access_time');
  set accessTime(DateTime? value) => setField<DateTime>('access_time', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
