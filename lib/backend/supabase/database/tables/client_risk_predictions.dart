import '../database.dart';

class ClientRiskPredictionsTable
    extends SupabaseTable<ClientRiskPredictionsRow> {
  @override
  String get tableName => 'client_risk_predictions';

  @override
  ClientRiskPredictionsRow createRow(Map<String, dynamic> data) =>
      ClientRiskPredictionsRow(data);
}

class ClientRiskPredictionsRow extends SupabaseDataRow {
  ClientRiskPredictionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ClientRiskPredictionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get clientId => getField<String>('client_id')!;
  set clientId(String value) => setField<String>('client_id', value);

  DateTime get predictionDate => getField<DateTime>('prediction_date')!;
  set predictionDate(DateTime value) =>
      setField<DateTime>('prediction_date', value);

  int get riskScore => getField<int>('risk_score')!;
  set riskScore(int value) => setField<int>('risk_score', value);

  String get riskLevel => getField<String>('risk_level')!;
  set riskLevel(String value) => setField<String>('risk_level', value);

  double? get defaultProbability => getField<double>('default_probability');
  set defaultProbability(double? value) =>
      setField<double>('default_probability', value);

  double? get predictionConfidence => getField<double>('prediction_confidence');
  set predictionConfidence(double? value) =>
      setField<double>('prediction_confidence', value);

  dynamic get behavioralFactors => getField<dynamic>('behavioral_factors');
  set behavioralFactors(dynamic value) =>
      setField<dynamic>('behavioral_factors', value);

  List<String> get riskDrivers => getListField<String>('risk_drivers');
  set riskDrivers(List<String>? value) =>
      setListField<String>('risk_drivers', value);

  List<String> get recommendedActions =>
      getListField<String>('recommended_actions');
  set recommendedActions(List<String>? value) =>
      setListField<String>('recommended_actions', value);

  String? get modelVersion => getField<String>('model_version');
  set modelVersion(String? value) => setField<String>('model_version', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
