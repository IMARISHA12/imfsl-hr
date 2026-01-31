import '../database.dart';

class EventEngineMetricsTable extends SupabaseTable<EventEngineMetricsRow> {
  @override
  String get tableName => 'event_engine_metrics';

  @override
  EventEngineMetricsRow createRow(Map<String, dynamic> data) =>
      EventEngineMetricsRow(data);
}

class EventEngineMetricsRow extends SupabaseDataRow {
  EventEngineMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EventEngineMetricsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get metricHour => getField<DateTime>('metric_hour')!;
  set metricHour(DateTime value) => setField<DateTime>('metric_hour', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  int get totalEvents => getField<int>('total_events')!;
  set totalEvents(int value) => setField<int>('total_events', value);

  int get deliveredCount => getField<int>('delivered_count')!;
  set deliveredCount(int value) => setField<int>('delivered_count', value);

  int get failedCount => getField<int>('failed_count')!;
  set failedCount(int value) => setField<int>('failed_count', value);

  int get retryCount => getField<int>('retry_count')!;
  set retryCount(int value) => setField<int>('retry_count', value);

  double? get avgDeliveryTimeMs => getField<double>('avg_delivery_time_ms');
  set avgDeliveryTimeMs(double? value) =>
      setField<double>('avg_delivery_time_ms', value);

  double? get p95DeliveryTimeMs => getField<double>('p95_delivery_time_ms');
  set p95DeliveryTimeMs(double? value) =>
      setField<double>('p95_delivery_time_ms', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
