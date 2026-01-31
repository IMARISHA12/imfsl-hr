import '../database.dart';

class AlertsMetricsDailyTable extends SupabaseTable<AlertsMetricsDailyRow> {
  @override
  String get tableName => 'alerts_metrics_daily';

  @override
  AlertsMetricsDailyRow createRow(Map<String, dynamic> data) =>
      AlertsMetricsDailyRow(data);
}

class AlertsMetricsDailyRow extends SupabaseDataRow {
  AlertsMetricsDailyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertsMetricsDailyTable();

  DateTime? get metricDate => getField<DateTime>('metric_date');
  set metricDate(DateTime? value) => setField<DateTime>('metric_date', value);

  String? get source => getField<String>('source');
  set source(String? value) => setField<String>('source', value);

  String? get event => getField<String>('event');
  set event(String? value) => setField<String>('event', value);

  int? get totalCount => getField<int>('total_count');
  set totalCount(int? value) => setField<int>('total_count', value);

  int? get totalSuppressed => getField<int>('total_suppressed');
  set totalSuppressed(int? value) => setField<int>('total_suppressed', value);

  double? get maxPeakRate => getField<double>('max_peak_rate');
  set maxPeakRate(double? value) => setField<double>('max_peak_rate', value);

  int? get uniqueCorrelations => getField<int>('unique_correlations');
  set uniqueCorrelations(int? value) =>
      setField<int>('unique_correlations', value);

  dynamic get allMetadata => getField<dynamic>('all_metadata');
  set allMetadata(dynamic value) => setField<dynamic>('all_metadata', value);
}
