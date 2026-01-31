import '../database.dart';

class DocumentShareLinksTable extends SupabaseTable<DocumentShareLinksRow> {
  @override
  String get tableName => 'document_share_links';

  @override
  DocumentShareLinksRow createRow(Map<String, dynamic> data) =>
      DocumentShareLinksRow(data);
}

class DocumentShareLinksRow extends SupabaseDataRow {
  DocumentShareLinksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DocumentShareLinksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get documentId => getField<String>('document_id')!;
  set documentId(String value) => setField<String>('document_id', value);

  String get accessToken => getField<String>('access_token')!;
  set accessToken(String value) => setField<String>('access_token', value);

  DateTime get expiresAt => getField<DateTime>('expires_at')!;
  set expiresAt(DateTime value) => setField<DateTime>('expires_at', value);

  int? get maxDownloads => getField<int>('max_downloads');
  set maxDownloads(int? value) => setField<int>('max_downloads', value);

  int? get downloadCount => getField<int>('download_count');
  set downloadCount(int? value) => setField<int>('download_count', value);

  String? get recipientEmail => getField<String>('recipient_email');
  set recipientEmail(String? value) =>
      setField<String>('recipient_email', value);

  String? get recipientName => getField<String>('recipient_name');
  set recipientName(String? value) => setField<String>('recipient_name', value);

  String? get purpose => getField<String>('purpose');
  set purpose(String? value) => setField<String>('purpose', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get accessedAt => getField<DateTime>('accessed_at');
  set accessedAt(DateTime? value) => setField<DateTime>('accessed_at', value);
}
