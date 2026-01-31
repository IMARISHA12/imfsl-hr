import '../database.dart';

class AlertMetricsHealthTable extends SupabaseTable<AlertMetricsHealthRow> {
  @override
  String get tableName => 'alert_metrics_health';

  @override
  AlertMetricsHealthRow createRow(Map<String, dynamic> data) =>
      AlertMetricsHealthRow(data);
}

class AlertMetricsHealthRow extends SupabaseDataRow {
  AlertMetricsHealthRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertMetricsHealthTable();

  int? get totalRecords => getField<int>('total_records');
  set totalRecords(int? value) => setField<int>('total_records', value);

  int? get uniqueServices => getField<int>('unique_services');
  set uniqueServices(int? value) => setField<int>('unique_services', value);

  int? get uniqueVendors => getField<int>('unique_vendors');
  set uniqueVendors(int? value) => setField<int>('unique_vendors', value);

  DateTime? get latestMetricHour => getField<DateTime>('latest_metric_hour');
  set latestMetricHour(DateTime? value) =>
      setField<DateTime>('latest_metric_hour', value);

  DateTime? get earliestMetricHour =>
      getField<DateTime>('earliest_metric_hour');
  set earliestMetricHour(DateTime? value) =>
      setField<DateTime>('earliest_metric_hour', value);

  int? get totalAlertsSent => getField<int>('total_alerts_sent');
  set totalAlertsSent(int? value) => setField<int>('total_alerts_sent', value);

  int? get totalAlertsSuppressed => getField<int>('total_alerts_suppressed');
  set totalAlertsSuppressed(int? value) =>
      setField<int>('total_alerts_suppressed', value);

  double? get suppressionRatePercent =>
      getField<double>('suppression_rate_percent');
  set suppressionRatePercent(double? value) =>
      setField<double>('suppression_rate_percent', value);
}
