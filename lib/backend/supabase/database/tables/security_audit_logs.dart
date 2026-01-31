import '../database.dart';

class SecurityAuditLogsTable extends SupabaseTable<SecurityAuditLogsRow> {
  @override
  String get tableName => 'security_audit_logs';

  @override
  SecurityAuditLogsRow createRow(Map<String, dynamic> data) =>
      SecurityAuditLogsRow(data);
}

class SecurityAuditLogsRow extends SupabaseDataRow {
  SecurityAuditLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SecurityAuditLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get tableNameField => getField<String>('table_name')!;
  set tableNameField(String value) => setField<String>('table_name', value);

  String get operation => getField<String>('operation')!;
  set operation(String value) => setField<String>('operation', value);

  String get riskLevel => getField<String>('risk_level')!;
  set riskLevel(String value) => setField<String>('risk_level', value);

  String get dataClassification => getField<String>('data_classification')!;
  set dataClassification(String value) =>
      setField<String>('data_classification', value);

  bool get sensitiveDataAccessed => getField<bool>('sensitive_data_accessed')!;
  set sensitiveDataAccessed(bool value) =>
      setField<bool>('sensitive_data_accessed', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
