import '../database.dart';

class AiInsightsTable extends SupabaseTable<AiInsightsRow> {
  @override
  String get tableName => 'ai_insights';

  @override
  AiInsightsRow createRow(Map<String, dynamic> data) => AiInsightsRow(data);
}

class AiInsightsRow extends SupabaseDataRow {
  AiInsightsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AiInsightsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  double get confidenceScore => getField<double>('confidence_score')!;
  set confidenceScore(double value) =>
      setField<double>('confidence_score', value);

  String get impactLevel => getField<String>('impact_level')!;
  set impactLevel(String value) => setField<String>('impact_level', value);

  List<String> get recommendations => getListField<String>('recommendations');
  set recommendations(List<String>? value) =>
      setListField<String>('recommendations', value);

  List<String> get dataSources => getListField<String>('data_sources');
  set dataSources(List<String>? value) =>
      setListField<String>('data_sources', value);

  DateTime? get generatedAt => getField<DateTime>('generated_at');
  set generatedAt(DateTime? value) => setField<DateTime>('generated_at', value);

  bool? get isDismissed => getField<bool>('is_dismissed');
  set isDismissed(bool? value) => setField<bool>('is_dismissed', value);

  String? get userFeedback => getField<String>('user_feedback');
  set userFeedback(String? value) => setField<String>('user_feedback', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
