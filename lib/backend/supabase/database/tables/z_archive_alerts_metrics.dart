import '../database.dart';

class ZArchiveAlertsMetricsTable
    extends SupabaseTable<ZArchiveAlertsMetricsRow> {
  @override
  String get tableName => 'z_archive_alerts_metrics';

  @override
  ZArchiveAlertsMetricsRow createRow(Map<String, dynamic> data) =>
      ZArchiveAlertsMetricsRow(data);
}

class ZArchiveAlertsMetricsRow extends SupabaseDataRow {
  ZArchiveAlertsMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveAlertsMetricsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get timestampHour => getField<DateTime>('timestamp_hour')!;
  set timestampHour(DateTime value) =>
      setField<DateTime>('timestamp_hour', value);

  String get source => getField<String>('source')!;
  set source(String value) => setField<String>('source', value);

  String get event => getField<String>('event')!;
  set event(String value) => setField<String>('event', value);

  int get count => getField<int>('count')!;
  set count(int value) => setField<int>('count', value);

  int get suppressedCount => getField<int>('suppressed_count')!;
  set suppressedCount(int value) => setField<int>('suppressed_count', value);

  double? get peakRate => getField<double>('peak_rate');
  set peakRate(double? value) => setField<double>('peak_rate', value);

  String? get correlationId => getField<String>('correlation_id');
  set correlationId(String? value) => setField<String>('correlation_id', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
