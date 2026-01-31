import '../database.dart';

class AlertsMetricsTable extends SupabaseTable<AlertsMetricsRow> {
  @override
  String get tableName => 'alerts_metrics';

  @override
  AlertsMetricsRow createRow(Map<String, dynamic> data) =>
      AlertsMetricsRow(data);
}

class AlertsMetricsRow extends SupabaseDataRow {
  AlertsMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertsMetricsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  int? get totalAlerts => getField<int>('total_alerts');
  set totalAlerts(int? value) => setField<int>('total_alerts', value);

  int? get criticalAlerts => getField<int>('critical_alerts');
  set criticalAlerts(int? value) => setField<int>('critical_alerts', value);

  int? get resolvedAlerts => getField<int>('resolved_alerts');
  set resolvedAlerts(int? value) => setField<int>('resolved_alerts', value);

  DateTime? get recordedAt => getField<DateTime>('recorded_at');
  set recordedAt(DateTime? value) => setField<DateTime>('recorded_at', value);

  DateTime get timestampHour => getField<DateTime>('timestamp_hour')!;
  set timestampHour(DateTime value) =>
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
}
