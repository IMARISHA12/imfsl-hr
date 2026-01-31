import '../database.dart';

class AlertsMetrics7dTable extends SupabaseTable<AlertsMetrics7dRow> {
  @override
  String get tableName => 'alerts_metrics_7d';

  @override
  AlertsMetrics7dRow createRow(Map<String, dynamic> data) =>
      AlertsMetrics7dRow(data);
}

class AlertsMetrics7dRow extends SupabaseDataRow {
  AlertsMetrics7dRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertsMetrics7dTable();

  DateTime? get timestampHour => getField<DateTime>('timestamp_hour');
  set timestampHour(DateTime? value) =>
      setField<DateTime>('timestamp_hour', value);

  String? get source => getField<String>('source');
  set source(String? value) => setField<String>('source', value);

  String? get event => getField<String>('event');
  set event(String? value) => setField<String>('event', value);

  int? get count => getField<int>('count');
  set count(int? value) => setField<int>('count', value);

  int? get suppressedCount => getField<int>('suppressed_count');
  set suppressedCount(int? value) => setField<int>('suppressed_count', value);

  double? get peakRate => getField<double>('peak_rate');
  set peakRate(double? value) => setField<double>('peak_rate', value);

  String? get correlationId => getField<String>('correlation_id');
  set correlationId(String? value) => setField<String>('correlation_id', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  double? get suppressionRatePercent =>
      getField<double>('suppression_rate_percent');
  set suppressionRatePercent(double? value) =>
      setField<double>('suppression_rate_percent', value);
}
