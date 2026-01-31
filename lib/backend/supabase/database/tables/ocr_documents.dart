import '../database.dart';

class OcrDocumentsTable extends SupabaseTable<OcrDocumentsRow> {
  @override
  String get tableName => 'ocr_documents';

  @override
  OcrDocumentsRow createRow(Map<String, dynamic> data) => OcrDocumentsRow(data);
}

class OcrDocumentsRow extends SupabaseDataRow {
  OcrDocumentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OcrDocumentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get documentType => getField<String>('document_type')!;
  set documentType(String value) => setField<String>('document_type', value);

  String? get originalFilename => getField<String>('original_filename');
  set originalFilename(String? value) =>
      setField<String>('original_filename', value);

  String get storagePath => getField<String>('storage_path')!;
  set storagePath(String value) => setField<String>('storage_path', value);

  String? get entityType => getField<String>('entity_type');
  set entityType(String? value) => setField<String>('entity_type', value);

  String? get entityId => getField<String>('entity_id');
  set entityId(String? value) => setField<String>('entity_id', value);

  String get ocrStatus => getField<String>('ocr_status')!;
  set ocrStatus(String value) => setField<String>('ocr_status', value);

  String? get ocrProvider => getField<String>('ocr_provider');
  set ocrProvider(String? value) => setField<String>('ocr_provider', value);

  DateTime? get ocrProcessedAt => getField<DateTime>('ocr_processed_at');
  set ocrProcessedAt(DateTime? value) =>
      setField<DateTime>('ocr_processed_at', value);

  double? get ocrConfidence => getField<double>('ocr_confidence');
  set ocrConfidence(double? value) => setField<double>('ocr_confidence', value);

  dynamic get extractedData => getField<dynamic>('extracted_data');
  set extractedData(dynamic value) =>
      setField<dynamic>('extracted_data', value);

  String? get verificationStatus => getField<String>('verification_status');
  set verificationStatus(String? value) =>
      setField<String>('verification_status', value);

  String? get verificationNotes => getField<String>('verification_notes');
  set verificationNotes(String? value) =>
      setField<String>('verification_notes', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) => setField<String>('verified_by', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  bool? get hasWarnings => getField<bool>('has_warnings');
  set hasWarnings(bool? value) => setField<bool>('has_warnings', value);

  dynamic get warnings => getField<dynamic>('warnings');
  set warnings(dynamic value) => setField<dynamic>('warnings', value);

  String? get uploadedBy => getField<String>('uploaded_by');
  set uploadedBy(String? value) => setField<String>('uploaded_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
