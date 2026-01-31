import '../database.dart';

class ZArchivePerfMetricsTable extends SupabaseTable<ZArchivePerfMetricsRow> {
  @override
  String get tableName => 'z_archive_perf_metrics';

  @override
  ZArchivePerfMetricsRow createRow(Map<String, dynamic> data) =>
      ZArchivePerfMetricsRow(data);
}

class ZArchivePerfMetricsRow extends SupabaseDataRow {
  ZArchivePerfMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchivePerfMetricsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get metricName => getField<String>('metric_name')!;
  set metricName(String value) => setField<String>('metric_name', value);

  double get metricValue => getField<double>('metric_value')!;
  set metricValue(double value) => setField<double>('metric_value', value);

  String get metricUnit => getField<String>('metric_unit')!;
  set metricUnit(String value) => setField<String>('metric_unit', value);

  String? get nodeName => getField<String>('node_name');
  set nodeName(String? value) => setField<String>('node_name', value);

  DateTime get recordedAt => getField<DateTime>('recorded_at')!;
  set recordedAt(DateTime value) => setField<DateTime>('recorded_at', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
