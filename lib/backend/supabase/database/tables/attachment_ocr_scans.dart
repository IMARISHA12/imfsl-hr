import '../database.dart';

class AttachmentOcrScansTable
    extends SupabaseTable<AttachmentOcrScansRow> {
  @override
  String get tableName => 'attachment_ocr_scans';

  @override
  AttachmentOcrScansRow createRow(Map<String, dynamic> data) =>
      AttachmentOcrScansRow(data);
}

class AttachmentOcrScansRow extends SupabaseDataRow {
  AttachmentOcrScansRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AttachmentOcrScansTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get attachmentId => getField<String>('attachment_id')!;
  set attachmentId(String value) =>
      setField<String>('attachment_id', value);

  String get ocrEngine => getField<String>('ocr_engine')!;
  set ocrEngine(String value) => setField<String>('ocr_engine', value);

  String get ocrMode => getField<String>('ocr_mode')!;
  set ocrMode(String value) => setField<String>('ocr_mode', value);

  String? get rawText => getField<String>('raw_text');
  set rawText(String? value) => setField<String>('raw_text', value);

  String? get rawTextLanguage => getField<String>('raw_text_language');
  set rawTextLanguage(String? value) =>
      setField<String>('raw_text_language', value);

  int get wordCount => getField<int>('word_count') ?? 0;
  set wordCount(int value) => setField<int>('word_count', value);

  dynamic get extractedFields => getField<dynamic>('extracted_fields');
  set extractedFields(dynamic value) =>
      setField<dynamic>('extracted_fields', value);

  dynamic get extractedLineItems =>
      getField<dynamic>('extracted_line_items');
  set extractedLineItems(dynamic value) =>
      setField<dynamic>('extracted_line_items', value);

  dynamic get extractedDates => getField<dynamic>('extracted_dates');
  set extractedDates(dynamic value) =>
      setField<dynamic>('extracted_dates', value);

  dynamic get extractedAmounts =>
      getField<dynamic>('extracted_amounts');
  set extractedAmounts(dynamic value) =>
      setField<dynamic>('extracted_amounts', value);

  dynamic get extractedNames => getField<dynamic>('extracted_names');
  set extractedNames(dynamic value) =>
      setField<dynamic>('extracted_names', value);

  double get confidenceScore =>
      getField<double>('confidence_score') ?? 0;
  set confidenceScore(double value) =>
      setField<double>('confidence_score', value);

  double? get imageQualityScore =>
      getField<double>('image_quality_score');
  set imageQualityScore(double? value) =>
      setField<double>('image_quality_score', value);

  int get pageCount => getField<int>('page_count') ?? 1;
  set pageCount(int value) => setField<int>('page_count', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) =>
      setField<String>('error_message', value);

  int get retryCount => getField<int>('retry_count') ?? 0;
  set retryCount(int value) => setField<int>('retry_count', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) =>
      setField<DateTime>('created_at', value);
}
