import '../database.dart';

class AlertSuppressionOverviewTable
    extends SupabaseTable<AlertSuppressionOverviewRow> {
  @override
  String get tableName => 'alert_suppression_overview';

  @override
  AlertSuppressionOverviewRow createRow(Map<String, dynamic> data) =>
      AlertSuppressionOverviewRow(data);
}

class AlertSuppressionOverviewRow extends SupabaseDataRow {
  AlertSuppressionOverviewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertSuppressionOverviewTable();

  DateTime? get metricHour => getField<DateTime>('metric_hour');
  set metricHour(DateTime? value) => setField<DateTime>('metric_hour', value);

  String? get service => getField<String>('service');
  set service(String? value) => setField<String>('service', value);

  String? get vendorId => getField<String>('vendor_id');
  set vendorId(String? value) => setField<String>('vendor_id', value);

  int? get alertsSent => getField<int>('alerts_sent');
  set alertsSent(int? value) => setField<int>('alerts_sent', value);

  int? get alertsSuppressed => getField<int>('alerts_suppressed');
  set alertsSuppressed(int? value) => setField<int>('alerts_suppressed', value);

  double? get suppressionRate => getField<double>('suppression_rate');
  set suppressionRate(double? value) =>
      setField<double>('suppression_rate', value);

  double? get p95 => getField<double>('p95');
  set p95(double? value) => setField<double>('p95', value);

  bool? get isAnomaly => getField<bool>('is_anomaly');
  set isAnomaly(bool? value) => setField<bool>('is_anomaly', value);
}
