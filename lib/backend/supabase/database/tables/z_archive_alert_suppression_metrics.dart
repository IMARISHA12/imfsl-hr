import '../database.dart';

class ZArchiveAlertSuppressionMetricsTable
    extends SupabaseTable<ZArchiveAlertSuppressionMetricsRow> {
  @override
  String get tableName => 'z_archive_alert_suppression_metrics';

  @override
  ZArchiveAlertSuppressionMetricsRow createRow(Map<String, dynamic> data) =>
      ZArchiveAlertSuppressionMetricsRow(data);
}

class ZArchiveAlertSuppressionMetricsRow extends SupabaseDataRow {
  ZArchiveAlertSuppressionMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveAlertSuppressionMetricsTable();

  DateTime get metricHour => getField<DateTime>('metric_hour')!;
  set metricHour(DateTime value) => setField<DateTime>('metric_hour', value);

  int get alertsSent => getField<int>('alerts_sent')!;
  set alertsSent(int value) => setField<int>('alerts_sent', value);

  int get alertsSuppressed => getField<int>('alerts_suppressed')!;
  set alertsSuppressed(int value) => setField<int>('alerts_suppressed', value);

  String get service => getField<String>('service')!;
  set service(String value) => setField<String>('service', value);

  String get vendorId => getField<String>('vendor_id')!;
  set vendorId(String value) => setField<String>('vendor_id', value);
}
