import '../database.dart';

class PerformanceGoalsTable extends SupabaseTable<PerformanceGoalsRow> {
  @override
  String get tableName => 'performance_goals';

  @override
  PerformanceGoalsRow createRow(Map<String, dynamic> data) =>
      PerformanceGoalsRow(data);
}

class PerformanceGoalsRow extends SupabaseDataRow {
  PerformanceGoalsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PerformanceGoalsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get reviewId => getField<String>('review_id')!;
  set reviewId(String value) => setField<String>('review_id', value);

  String get goalTitle => getField<String>('goal_title')!;
  set goalTitle(String value) => setField<String>('goal_title', value);

  String? get goalDescription => getField<String>('goal_description');
  set goalDescription(String? value) =>
      setField<String>('goal_description', value);

  String? get targetMetric => getField<String>('target_metric');
  set targetMetric(String? value) =>
      setField<String>('target_metric', value);

  String? get actualMetric => getField<String>('actual_metric');
  set actualMetric(String? value) =>
      setField<String>('actual_metric', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  int? get weightPercent => getField<int>('weight_percent');
  set weightPercent(int? value) => setField<int>('weight_percent', value);

  int? get achievementPercent => getField<int>('achievement_percent');
  set achievementPercent(int? value) =>
      setField<int>('achievement_percent', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
