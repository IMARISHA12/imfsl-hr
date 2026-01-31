import '../database.dart';

class ClientBehavioralPatternsTable
    extends SupabaseTable<ClientBehavioralPatternsRow> {
  @override
  String get tableName => 'client_behavioral_patterns';

  @override
  ClientBehavioralPatternsRow createRow(Map<String, dynamic> data) =>
      ClientBehavioralPatternsRow(data);
}

class ClientBehavioralPatternsRow extends SupabaseDataRow {
  ClientBehavioralPatternsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ClientBehavioralPatternsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get clientId => getField<String>('client_id')!;
  set clientId(String value) => setField<String>('client_id', value);

  String get patternType => getField<String>('pattern_type')!;
  set patternType(String value) => setField<String>('pattern_type', value);

  dynamic get patternValue => getField<dynamic>('pattern_value')!;
  set patternValue(dynamic value) => setField<dynamic>('pattern_value', value);

  double? get strength => getField<double>('strength');
  set strength(double? value) => setField<double>('strength', value);

  DateTime get detectedAt => getField<DateTime>('detected_at')!;
  set detectedAt(DateTime value) => setField<DateTime>('detected_at', value);

  DateTime get lastObserved => getField<DateTime>('last_observed')!;
  set lastObserved(DateTime value) =>
      setField<DateTime>('last_observed', value);

  int? get observationCount => getField<int>('observation_count');
  set observationCount(int? value) => setField<int>('observation_count', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);
}
