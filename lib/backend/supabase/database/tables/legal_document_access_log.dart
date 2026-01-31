import '../database.dart';

class LegalDocumentAccessLogTable
    extends SupabaseTable<LegalDocumentAccessLogRow> {
  @override
  String get tableName => 'legal_document_access_log';

  @override
  LegalDocumentAccessLogRow createRow(Map<String, dynamic> data) =>
      LegalDocumentAccessLogRow(data);
}

class LegalDocumentAccessLogRow extends SupabaseDataRow {
  LegalDocumentAccessLogRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalDocumentAccessLogTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get documentId => getField<String>('document_id')!;
  set documentId(String value) => setField<String>('document_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
