import '../database.dart';

class AiDecisionsTable extends SupabaseTable<AiDecisionsRow> {
  @override
  String get tableName => 'ai_decisions';

  @override
  AiDecisionsRow createRow(Map<String, dynamic> data) => AiDecisionsRow(data);
}

class AiDecisionsRow extends SupabaseDataRow {
  AiDecisionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AiDecisionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get decisionType => getField<String>('decision_type')!;
  set decisionType(String value) => setField<String>('decision_type', value);

  String get entityType => getField<String>('entity_type')!;
  set entityType(String value) => setField<String>('entity_type', value);

  String get entityId => getField<String>('entity_id')!;
  set entityId(String value) => setField<String>('entity_id', value);

  dynamic get inputData => getField<dynamic>('input_data')!;
  set inputData(dynamic value) => setField<dynamic>('input_data', value);

  String get outputRecommendation => getField<String>('output_recommendation')!;
  set outputRecommendation(String value) =>
      setField<String>('output_recommendation', value);

  String? get reasoning => getField<String>('reasoning');
  set reasoning(String? value) => setField<String>('reasoning', value);

  double? get confidenceScore => getField<double>('confidence_score');
  set confidenceScore(double? value) =>
      setField<double>('confidence_score', value);

  String? get severity => getField<String>('severity');
  set severity(String? value) => setField<String>('severity', value);

  String? get autoActionTaken => getField<String>('auto_action_taken');
  set autoActionTaken(String? value) =>
      setField<String>('auto_action_taken', value);

  DateTime? get autoActionAt => getField<DateTime>('auto_action_at');
  set autoActionAt(DateTime? value) =>
      setField<DateTime>('auto_action_at', value);

  bool? get humanOverride => getField<bool>('human_override');
  set humanOverride(bool? value) => setField<bool>('human_override', value);

  String? get overrideBy => getField<String>('override_by');
  set overrideBy(String? value) => setField<String>('override_by', value);

  String? get overrideReason => getField<String>('override_reason');
  set overrideReason(String? value) =>
      setField<String>('override_reason', value);

  DateTime? get overrideAt => getField<DateTime>('override_at');
  set overrideAt(DateTime? value) => setField<DateTime>('override_at', value);

  String? get outcome => getField<String>('outcome');
  set outcome(String? value) => setField<String>('outcome', value);

  String? get outcomeNotes => getField<String>('outcome_notes');
  set outcomeNotes(String? value) => setField<String>('outcome_notes', value);

  String? get outcomeRecordedBy => getField<String>('outcome_recorded_by');
  set outcomeRecordedBy(String? value) =>
      setField<String>('outcome_recorded_by', value);

  DateTime? get outcomeRecordedAt => getField<DateTime>('outcome_recorded_at');
  set outcomeRecordedAt(DateTime? value) =>
      setField<DateTime>('outcome_recorded_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) => setField<DateTime>('resolved_at', value);
}
