import '../database.dart';

class DocumentOcrLogsTable extends SupabaseTable<DocumentOcrLogsRow> {
  @override
  String get tableName => 'document_ocr_logs';

  @override
  DocumentOcrLogsRow createRow(Map<String, dynamic> data) =>
      DocumentOcrLogsRow(data);
}

class DocumentOcrLogsRow extends SupabaseDataRow {
  DocumentOcrLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DocumentOcrLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get storagePath => getField<String>('storage_path')!;
  set storagePath(String value) => setField<String>('storage_path', value);

  String? get documentType => getField<String>('document_type');
  set documentType(String? value) => setField<String>('document_type', value);

  dynamic get extractedData => getField<dynamic>('extracted_data');
  set extractedData(dynamic value) =>
      setField<dynamic>('extracted_data', value);

  double? get confidenceScore => getField<double>('confidence_score');
  set confidenceScore(double? value) =>
      setField<double>('confidence_score', value);

  int? get processingTimeMs => getField<int>('processing_time_ms');
  set processingTimeMs(int? value) =>
      setField<int>('processing_time_ms', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
