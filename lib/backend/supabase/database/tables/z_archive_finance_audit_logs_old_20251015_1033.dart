import '../database.dart';

class ZArchiveFinanceAuditLogsOld202510151033Table
    extends SupabaseTable<ZArchiveFinanceAuditLogsOld202510151033Row> {
  @override
  String get tableName => 'z_archive_finance_audit_logs_old_20251015_1033';

  @override
  ZArchiveFinanceAuditLogsOld202510151033Row createRow(
          Map<String, dynamic> data) =>
      ZArchiveFinanceAuditLogsOld202510151033Row(data);
}

class ZArchiveFinanceAuditLogsOld202510151033Row extends SupabaseDataRow {
  ZArchiveFinanceAuditLogsOld202510151033Row(Map<String, dynamic> data)
      : super(data);

  @override
  SupabaseTable get table => ZArchiveFinanceAuditLogsOld202510151033Table();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get tableNameField => getField<String>('table_name')!;
  set tableNameField(String value) => setField<String>('table_name', value);

  String get recordId => getField<String>('record_id')!;
  set recordId(String value) => setField<String>('record_id', value);

  String get operationType => getField<String>('operation_type')!;
  set operationType(String value) => setField<String>('operation_type', value);

  dynamic get oldValues => getField<dynamic>('old_values');
  set oldValues(dynamic value) => setField<dynamic>('old_values', value);

  dynamic get newValues => getField<dynamic>('new_values');
  set newValues(dynamic value) => setField<dynamic>('new_values', value);

  List<String> get changedFields => getListField<String>('changed_fields');
  set changedFields(List<String>? value) =>
      setListField<String>('changed_fields', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get userRole => getField<String>('user_role');
  set userRole(String? value) => setField<String>('user_role', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  String? get sessionId => getField<String>('session_id');
  set sessionId(String? value) => setField<String>('session_id', value);

  DateTime get timestamp => getField<DateTime>('timestamp')!;
  set timestamp(DateTime value) => setField<DateTime>('timestamp', value);

  int? get transactionId => getField<int>('transaction_id');
  set transactionId(int? value) => setField<int>('transaction_id', value);

  int? get riskScore => getField<int>('risk_score');
  set riskScore(int? value) => setField<int>('risk_score', value);

  bool? get isSensitiveOperation => getField<bool>('is_sensitive_operation');
  set isSensitiveOperation(bool? value) =>
      setField<bool>('is_sensitive_operation', value);

  List<String> get userPermissions => getListField<String>('user_permissions');
  set userPermissions(List<String>? value) =>
      setListField<String>('user_permissions', value);

  String? get requestPath => getField<String>('request_path');
  set requestPath(String? value) => setField<String>('request_path', value);

  String? get prevHash => getField<String>('prev_hash');
  set prevHash(String? value) => setField<String>('prev_hash', value);

  String? get rowHash => getField<String>('row_hash');
  set rowHash(String? value) => setField<String>('row_hash', value);
}
