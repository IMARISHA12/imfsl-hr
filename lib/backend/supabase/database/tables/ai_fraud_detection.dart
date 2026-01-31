import '../database.dart';

class AiFraudDetectionTable extends SupabaseTable<AiFraudDetectionRow> {
  @override
  String get tableName => 'ai_fraud_detection';

  @override
  AiFraudDetectionRow createRow(Map<String, dynamic> data) =>
      AiFraudDetectionRow(data);
}

class AiFraudDetectionRow extends SupabaseDataRow {
  AiFraudDetectionRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AiFraudDetectionTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get transactionId => getField<String>('transaction_id')!;
  set transactionId(String value) => setField<String>('transaction_id', value);

  String get transactionType => getField<String>('transaction_type')!;
  set transactionType(String value) =>
      setField<String>('transaction_type', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  int get riskScore => getField<int>('risk_score')!;
  set riskScore(int value) => setField<int>('risk_score', value);

  dynamic get riskFactors => getField<dynamic>('risk_factors');
  set riskFactors(dynamic value) => setField<dynamic>('risk_factors', value);

  String? get aiModelVersion => getField<String>('ai_model_version');
  set aiModelVersion(String? value) =>
      setField<String>('ai_model_version', value);

  DateTime? get detectionTimestamp => getField<DateTime>('detection_timestamp');
  set detectionTimestamp(DateTime? value) =>
      setField<DateTime>('detection_timestamp', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  String? get reviewNotes => getField<String>('review_notes');
  set reviewNotes(String? value) => setField<String>('review_notes', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  List<String> get redFlags => getListField<String>('red_flags');
  set redFlags(List<String>? value) => setListField<String>('red_flags', value);
}
