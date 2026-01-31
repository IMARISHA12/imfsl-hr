import '../database.dart';

class AiDecisionStreamTable extends SupabaseTable<AiDecisionStreamRow> {
  @override
  String get tableName => 'ai_decision_stream';

  @override
  AiDecisionStreamRow createRow(Map<String, dynamic> data) =>
      AiDecisionStreamRow(data);
}

class AiDecisionStreamRow extends SupabaseDataRow {
  AiDecisionStreamRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AiDecisionStreamTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get decisionType => getField<String>('decision_type')!;
  set decisionType(String value) => setField<String>('decision_type', value);

  String get decisionResult => getField<String>('decision_result')!;
  set decisionResult(String value) =>
      setField<String>('decision_result', value);

  double? get confidenceScore => getField<double>('confidence_score');
  set confidenceScore(double? value) =>
      setField<double>('confidence_score', value);

  dynamic get inputData => getField<dynamic>('input_data');
  set inputData(dynamic value) => setField<dynamic>('input_data', value);

  String? get reasoning => getField<String>('reasoning');
  set reasoning(String? value) => setField<String>('reasoning', value);

  String? get affectedEntityType => getField<String>('affected_entity_type');
  set affectedEntityType(String? value) =>
      setField<String>('affected_entity_type', value);

  String? get affectedEntityId => getField<String>('affected_entity_id');
  set affectedEntityId(String? value) =>
      setField<String>('affected_entity_id', value);

  DateTime? get decidedAt => getField<DateTime>('decided_at');
  set decidedAt(DateTime? value) => setField<DateTime>('decided_at', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  String? get reviewStatus => getField<String>('review_status');
  set reviewStatus(String? value) => setField<String>('review_status', value);
}
