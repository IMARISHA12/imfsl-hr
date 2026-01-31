import '../database.dart';

class StaffPerformanceSnapshotsTable
    extends SupabaseTable<StaffPerformanceSnapshotsRow> {
  @override
  String get tableName => 'staff_performance_snapshots';

  @override
  StaffPerformanceSnapshotsRow createRow(Map<String, dynamic> data) =>
      StaffPerformanceSnapshotsRow(data);
}

class StaffPerformanceSnapshotsRow extends SupabaseDataRow {
  StaffPerformanceSnapshotsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffPerformanceSnapshotsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  DateTime get periodStart => getField<DateTime>('period_start')!;
  set periodStart(DateTime value) => setField<DateTime>('period_start', value);

  DateTime get periodEnd => getField<DateTime>('period_end')!;
  set periodEnd(DateTime value) => setField<DateTime>('period_end', value);

  double get portfolioQualityScore =>
      getField<double>('portfolio_quality_score')!;
  set portfolioQualityScore(double value) =>
      setField<double>('portfolio_quality_score', value);

  double get activityMetricsScore =>
      getField<double>('activity_metrics_score')!;
  set activityMetricsScore(double value) =>
      setField<double>('activity_metrics_score', value);

  double get processAdherenceScore =>
      getField<double>('process_adherence_score')!;
  set processAdherenceScore(double value) =>
      setField<double>('process_adherence_score', value);

  double get customerSatisfactionScore =>
      getField<double>('customer_satisfaction_score')!;
  set customerSatisfactionScore(double value) =>
      setField<double>('customer_satisfaction_score', value);

  double get compositeScore => getField<double>('composite_score')!;
  set compositeScore(double value) =>
      setField<double>('composite_score', value);

  dynamic get rawMetrics => getField<dynamic>('raw_metrics')!;
  set rawMetrics(dynamic value) => setField<dynamic>('raw_metrics', value);

  dynamic get flags => getField<dynamic>('flags')!;
  set flags(dynamic value) => setField<dynamic>('flags', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
