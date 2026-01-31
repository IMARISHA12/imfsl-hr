import '../database.dart';

class DocumentOcrResultsTable extends SupabaseTable<DocumentOcrResultsRow> {
  @override
  String get tableName => 'document_ocr_results';

  @override
  DocumentOcrResultsRow createRow(Map<String, dynamic> data) =>
      DocumentOcrResultsRow(data);
}

class DocumentOcrResultsRow extends SupabaseDataRow {
  DocumentOcrResultsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DocumentOcrResultsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get documentId => getField<String>('document_id')!;
  set documentId(String value) => setField<String>('document_id', value);

  String get ocrEngine => getField<String>('ocr_engine')!;
  set ocrEngine(String value) => setField<String>('ocr_engine', value);

  String? get rawText => getField<String>('raw_text');
  set rawText(String? value) => setField<String>('raw_text', value);

  dynamic get extractedFields => getField<dynamic>('extracted_fields');
  set extractedFields(dynamic value) =>
      setField<dynamic>('extracted_fields', value);

  double? get confidenceScore => getField<double>('confidence_score');
  set confidenceScore(double? value) =>
      setField<double>('confidence_score', value);

  String get processingStatus => getField<String>('processing_status')!;
  set processingStatus(String value) =>
      setField<String>('processing_status', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  DateTime? get processingStartedAt =>
      getField<DateTime>('processing_started_at');
  set processingStartedAt(DateTime? value) =>
      setField<DateTime>('processing_started_at', value);

  DateTime? get processingCompletedAt =>
      getField<DateTime>('processing_completed_at');
  set processingCompletedAt(DateTime? value) =>
      setField<DateTime>('processing_completed_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
