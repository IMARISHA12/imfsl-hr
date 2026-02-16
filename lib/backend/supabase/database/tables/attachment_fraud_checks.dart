import '../database.dart';

class AttachmentFraudChecksTable
    extends SupabaseTable<AttachmentFraudChecksRow> {
  @override
  String get tableName => 'attachment_fraud_checks';

  @override
  AttachmentFraudChecksRow createRow(Map<String, dynamic> data) =>
      AttachmentFraudChecksRow(data);
}

class AttachmentFraudChecksRow extends SupabaseDataRow {
  AttachmentFraudChecksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AttachmentFraudChecksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get attachmentId => getField<String>('attachment_id')!;
  set attachmentId(String value) =>
      setField<String>('attachment_id', value);

  String get checkType => getField<String>('check_type')!;
  set checkType(String value) => setField<String>('check_type', value);

  int get riskScore => getField<int>('risk_score')!;
  set riskScore(int value) => setField<int>('risk_score', value);

  String get riskLevel => getField<String>('risk_level')!;
  set riskLevel(String value) => setField<String>('risk_level', value);

  String get verdict => getField<String>('verdict')!;
  set verdict(String value) => setField<String>('verdict', value);

  dynamic get fraudFlags => getField<dynamic>('fraud_flags');
  set fraudFlags(dynamic value) =>
      setField<dynamic>('fraud_flags', value);

  double? get elaScore => getField<double>('ela_score');
  set elaScore(double? value) => setField<double>('ela_score', value);

  double? get templateMatchScore =>
      getField<double>('template_match_score');
  set templateMatchScore(double? value) =>
      setField<double>('template_match_score', value);

  double? get fontConsistencyScore =>
      getField<double>('font_consistency_score');
  set fontConsistencyScore(double? value) =>
      setField<double>('font_consistency_score', value);

  double? get similarityScore =>
      getField<double>('similarity_score');
  set similarityScore(double? value) =>
      setField<double>('similarity_score', value);

  double? get declaredAmount => getField<double>('declared_amount');
  set declaredAmount(double? value) =>
      setField<double>('declared_amount', value);

  double? get ocrExtractedAmount =>
      getField<double>('ocr_extracted_amount');
  set ocrExtractedAmount(double? value) =>
      setField<double>('ocr_extracted_amount', value);

  bool get amountDiscrepancy =>
      getField<bool>('amount_discrepancy') ?? false;
  set amountDiscrepancy(bool value) =>
      setField<bool>('amount_discrepancy', value);

  String? get aiModelUsed => getField<String>('ai_model_used');
  set aiModelUsed(String? value) =>
      setField<String>('ai_model_used', value);

  String? get aiReasoning => getField<String>('ai_reasoning');
  set aiReasoning(String? value) =>
      setField<String>('ai_reasoning', value);

  double? get aiConfidence => getField<double>('ai_confidence');
  set aiConfidence(double? value) =>
      setField<double>('ai_confidence', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) =>
      setField<String>('reviewed_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) =>
      setField<DateTime>('reviewed_at', value);

  String? get reviewVerdict => getField<String>('review_verdict');
  set reviewVerdict(String? value) =>
      setField<String>('review_verdict', value);

  String? get reviewNotes => getField<String>('review_notes');
  set reviewNotes(String? value) =>
      setField<String>('review_notes', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) =>
      setField<DateTime>('created_at', value);
}
