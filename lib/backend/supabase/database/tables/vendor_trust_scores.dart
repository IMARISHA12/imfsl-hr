import '../database.dart';

class VendorTrustScoresTable extends SupabaseTable<VendorTrustScoresRow> {
  @override
  String get tableName => 'vendor_trust_scores';

  @override
  VendorTrustScoresRow createRow(Map<String, dynamic> data) =>
      VendorTrustScoresRow(data);
}

class VendorTrustScoresRow extends SupabaseDataRow {
  VendorTrustScoresRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VendorTrustScoresTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get vendorId => getField<String>('vendor_id')!;
  set vendorId(String value) => setField<String>('vendor_id', value);

  double? get trustScore => getField<double>('trust_score');
  set trustScore(double? value) => setField<double>('trust_score', value);

  double? get deliveryScore => getField<double>('delivery_score');
  set deliveryScore(double? value) => setField<double>('delivery_score', value);

  double? get qualityScore => getField<double>('quality_score');
  set qualityScore(double? value) => setField<double>('quality_score', value);

  double? get priceCompetitivenessScore =>
      getField<double>('price_competitiveness_score');
  set priceCompetitivenessScore(double? value) =>
      setField<double>('price_competitiveness_score', value);

  double? get communicationScore => getField<double>('communication_score');
  set communicationScore(double? value) =>
      setField<double>('communication_score', value);

  double? get complianceScore => getField<double>('compliance_score');
  set complianceScore(double? value) =>
      setField<double>('compliance_score', value);

  String? get riskLevel => getField<String>('risk_level');
  set riskLevel(String? value) => setField<String>('risk_level', value);

  dynamic get factors => getField<dynamic>('factors');
  set factors(dynamic value) => setField<dynamic>('factors', value);

  DateTime? get lastEvaluationDate =>
      getField<DateTime>('last_evaluation_date');
  set lastEvaluationDate(DateTime? value) =>
      setField<DateTime>('last_evaluation_date', value);

  DateTime? get nextReviewDate => getField<DateTime>('next_review_date');
  set nextReviewDate(DateTime? value) =>
      setField<DateTime>('next_review_date', value);

  String? get evaluatorId => getField<String>('evaluator_id');
  set evaluatorId(String? value) => setField<String>('evaluator_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
