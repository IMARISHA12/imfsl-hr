import '../database.dart';

class LiquidityPredictionsTable extends SupabaseTable<LiquidityPredictionsRow> {
  @override
  String get tableName => 'liquidity_predictions';

  @override
  LiquidityPredictionsRow createRow(Map<String, dynamic> data) =>
      LiquidityPredictionsRow(data);
}

class LiquidityPredictionsRow extends SupabaseDataRow {
  LiquidityPredictionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LiquidityPredictionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get predictionDate => getField<DateTime>('prediction_date')!;
  set predictionDate(DateTime value) =>
      setField<DateTime>('prediction_date', value);

  double? get predictedInflows => getField<double>('predicted_inflows');
  set predictedInflows(double? value) =>
      setField<double>('predicted_inflows', value);

  double? get predictedOutflows => getField<double>('predicted_outflows');
  set predictedOutflows(double? value) =>
      setField<double>('predicted_outflows', value);

  double? get netPosition => getField<double>('net_position');
  set netPosition(double? value) => setField<double>('net_position', value);

  double? get confidenceScore => getField<double>('confidence_score');
  set confidenceScore(double? value) =>
      setField<double>('confidence_score', value);

  String? get riskLevel => getField<String>('risk_level');
  set riskLevel(String? value) => setField<String>('risk_level', value);

  String? get aiRecommendation => getField<String>('ai_recommendation');
  set aiRecommendation(String? value) =>
      setField<String>('ai_recommendation', value);

  dynamic get factors => getField<dynamic>('factors');
  set factors(dynamic value) => setField<dynamic>('factors', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
