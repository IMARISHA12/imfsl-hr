import '../database.dart';

class AiStrategicInsightsTable extends SupabaseTable<AiStrategicInsightsRow> {
  @override
  String get tableName => 'ai_strategic_insights';

  @override
  AiStrategicInsightsRow createRow(Map<String, dynamic> data) =>
      AiStrategicInsightsRow(data);
}

class AiStrategicInsightsRow extends SupabaseDataRow {
  AiStrategicInsightsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AiStrategicInsightsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get reportDate => getField<DateTime>('report_date')!;
  set reportDate(DateTime value) => setField<DateTime>('report_date', value);

  String? get insightArea => getField<String>('insight_area');
  set insightArea(String? value) => setField<String>('insight_area', value);

  String? get summary => getField<String>('summary');
  set summary(String? value) => setField<String>('summary', value);

  dynamic get recommendations => getField<dynamic>('recommendations');
  set recommendations(dynamic value) =>
      setField<dynamic>('recommendations', value);

  String? get generatedBy => getField<String>('generated_by');
  set generatedBy(String? value) => setField<String>('generated_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
