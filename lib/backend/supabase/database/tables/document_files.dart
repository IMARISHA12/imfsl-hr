import '../database.dart';

class DocumentFilesTable extends SupabaseTable<DocumentFilesRow> {
  @override
  String get tableName => 'document_files';

  @override
  DocumentFilesRow createRow(Map<String, dynamic> data) =>
      DocumentFilesRow(data);
}

class DocumentFilesRow extends SupabaseDataRow {
  DocumentFilesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DocumentFilesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get documentId => getField<String>('document_id')!;
  set documentId(String value) => setField<String>('document_id', value);

  String get storagePath => getField<String>('storage_path')!;
  set storagePath(String value) => setField<String>('storage_path', value);

  String get originalFilename => getField<String>('original_filename')!;
  set originalFilename(String value) =>
      setField<String>('original_filename', value);

  String get mimeType => getField<String>('mime_type')!;
  set mimeType(String value) => setField<String>('mime_type', value);

  int? get pageNumber => getField<int>('page_number');
  set pageNumber(int? value) => setField<int>('page_number', value);

  int get fileSizeBytes => getField<int>('file_size_bytes')!;
  set fileSizeBytes(int value) => setField<int>('file_size_bytes', value);

  String get sha256Hash => getField<String>('sha256_hash')!;
  set sha256Hash(String value) => setField<String>('sha256_hash', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
