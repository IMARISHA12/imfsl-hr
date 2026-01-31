import '../database.dart';

class OcrResultsTable extends SupabaseTable<OcrResultsRow> {
  @override
  String get tableName => 'ocr_results';

  @override
  OcrResultsRow createRow(Map<String, dynamic> data) => OcrResultsRow(data);
}

class OcrResultsRow extends SupabaseDataRow {
  OcrResultsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OcrResultsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get documentId => getField<String>('document_id')!;
  set documentId(String value) => setField<String>('document_id', value);

  String get ocrJobId => getField<String>('ocr_job_id')!;
  set ocrJobId(String value) => setField<String>('ocr_job_id', value);

  String? get fullText => getField<String>('full_text');
  set fullText(String? value) => setField<String>('full_text', value);

  double? get confidenceScore => getField<double>('confidence_score');
  set confidenceScore(double? value) =>
      setField<double>('confidence_score', value);

  dynamic get extractedFields => getField<dynamic>('extracted_fields');
  set extractedFields(dynamic value) =>
      setField<dynamic>('extracted_fields', value);

  String? get detectedLanguage => getField<String>('detected_language');
  set detectedLanguage(String? value) =>
      setField<String>('detected_language', value);

  int? get wordCount => getField<int>('word_count');
  set wordCount(int? value) => setField<int>('word_count', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get providerUsed => getField<String>('provider_used');
  set providerUsed(String? value) => setField<String>('provider_used', value);

  bool? get localOcrAttempted => getField<bool>('local_ocr_attempted');
  set localOcrAttempted(bool? value) =>
      setField<bool>('local_ocr_attempted', value);

  double? get localOcrConfidence => getField<double>('local_ocr_confidence');
  set localOcrConfidence(double? value) =>
      setField<double>('local_ocr_confidence', value);

  bool? get geminiFallbackUsed => getField<bool>('gemini_fallback_used');
  set geminiFallbackUsed(bool? value) =>
      setField<bool>('gemini_fallback_used', value);

  String? get evidenceHash => getField<String>('evidence_hash');
  set evidenceHash(String? value) => setField<String>('evidence_hash', value);

  String? get hashAlgorithm => getField<String>('hash_algorithm');
  set hashAlgorithm(String? value) => setField<String>('hash_algorithm', value);
}
