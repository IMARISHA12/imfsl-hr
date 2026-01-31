import '../database.dart';

class ZArchiveDocumentAccessLogsTable
    extends SupabaseTable<ZArchiveDocumentAccessLogsRow> {
  @override
  String get tableName => 'z_archive_document_access_logs';

  @override
  ZArchiveDocumentAccessLogsRow createRow(Map<String, dynamic> data) =>
      ZArchiveDocumentAccessLogsRow(data);
}

class ZArchiveDocumentAccessLogsRow extends SupabaseDataRow {
  ZArchiveDocumentAccessLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveDocumentAccessLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get documentId => getField<String>('document_id')!;
  set documentId(String value) => setField<String>('document_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  DateTime? get accessedAt => getField<DateTime>('accessed_at');
  set accessedAt(DateTime? value) => setField<DateTime>('accessed_at', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);
}
