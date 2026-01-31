import '../database.dart';

class AiDocumentAnalysisLogsTable
    extends SupabaseTable<AiDocumentAnalysisLogsRow> {
  @override
  String get tableName => 'ai_document_analysis_logs';

  @override
  AiDocumentAnalysisLogsRow createRow(Map<String, dynamic> data) =>
      AiDocumentAnalysisLogsRow(data);
}

class AiDocumentAnalysisLogsRow extends SupabaseDataRow {
  AiDocumentAnalysisLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AiDocumentAnalysisLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get documentType => getField<String>('document_type')!;
  set documentType(String value) => setField<String>('document_type', value);

  String? get fileName => getField<String>('file_name');
  set fileName(String? value) => setField<String>('file_name', value);

  String get analyzer => getField<String>('analyzer')!;
  set analyzer(String value) => setField<String>('analyzer', value);

  dynamic get analysisResult => getField<dynamic>('analysis_result')!;
  set analysisResult(dynamic value) =>
      setField<dynamic>('analysis_result', value);

  double? get sentimentScore => getField<double>('sentiment_score');
  set sentimentScore(double? value) =>
      setField<double>('sentiment_score', value);

  double? get complianceScore => getField<double>('compliance_score');
  set complianceScore(double? value) =>
      setField<double>('compliance_score', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
