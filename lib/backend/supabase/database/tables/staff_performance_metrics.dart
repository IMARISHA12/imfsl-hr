import '../database.dart';

class StaffPerformanceMetricsTable
    extends SupabaseTable<StaffPerformanceMetricsRow> {
  @override
  String get tableName => 'staff_performance_metrics';

  @override
  StaffPerformanceMetricsRow createRow(Map<String, dynamic> data) =>
      StaffPerformanceMetricsRow(data);
}

class StaffPerformanceMetricsRow extends SupabaseDataRow {
  StaffPerformanceMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffPerformanceMetricsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  int get tasksCompleted => getField<int>('tasks_completed')!;
  set tasksCompleted(int value) => setField<int>('tasks_completed', value);

  double get revenueGenerated => getField<double>('revenue_generated')!;
  set revenueGenerated(double value) =>
      setField<double>('revenue_generated', value);

  double get salaryCost => getField<double>('salary_cost')!;
  set salaryCost(double value) => setField<double>('salary_cost', value);

  double? get roiScore => getField<double>('roi_score');
  set roiScore(double? value) => setField<double>('roi_score', value);

  DateTime get month => getField<DateTime>('month')!;
  set month(DateTime value) => setField<DateTime>('month', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
