import '../database.dart';

class AiSuggestionsTable extends SupabaseTable<AiSuggestionsRow> {
  @override
  String get tableName => 'ai_suggestions';

  @override
  AiSuggestionsRow createRow(Map<String, dynamic> data) =>
      AiSuggestionsRow(data);
}

class AiSuggestionsRow extends SupabaseDataRow {
  AiSuggestionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AiSuggestionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get module => getField<String>('module')!;
  set module(String value) => setField<String>('module', value);

  dynamic get contextJson => getField<dynamic>('context_json');
  set contextJson(dynamic value) => setField<dynamic>('context_json', value);

  String get suggestion => getField<String>('suggestion')!;
  set suggestion(String value) => setField<String>('suggestion', value);

  int? get impactScore => getField<int>('impact_score');
  set impactScore(int? value) => setField<int>('impact_score', value);

  bool? get accepted => getField<bool>('accepted');
  set accepted(bool? value) => setField<bool>('accepted', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get acceptedAt => getField<DateTime>('accepted_at');
  set acceptedAt(DateTime? value) => setField<DateTime>('accepted_at', value);

  String? get acceptedBy => getField<String>('accepted_by');
  set acceptedBy(String? value) => setField<String>('accepted_by', value);
}
