import '../database.dart';

class ZArchiveTokenAuditLogsTable
    extends SupabaseTable<ZArchiveTokenAuditLogsRow> {
  @override
  String get tableName => 'z_archive_token_audit_logs';

  @override
  ZArchiveTokenAuditLogsRow createRow(Map<String, dynamic> data) =>
      ZArchiveTokenAuditLogsRow(data);
}

class ZArchiveTokenAuditLogsRow extends SupabaseDataRow {
  ZArchiveTokenAuditLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveTokenAuditLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get tokenName => getField<String>('token_name')!;
  set tokenName(String value) => setField<String>('token_name', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  dynamic get eventDetails => getField<dynamic>('event_details');
  set eventDetails(dynamic value) => setField<dynamic>('event_details', value);

  String? get performedBy => getField<String>('performed_by');
  set performedBy(String? value) => setField<String>('performed_by', value);

  String? get performedByEmail => getField<String>('performed_by_email');
  set performedByEmail(String? value) =>
      setField<String>('performed_by_email', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  String? get sessionId => getField<String>('session_id');
  set sessionId(String? value) => setField<String>('session_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
