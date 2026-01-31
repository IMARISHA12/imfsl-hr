import '../database.dart';

class SystemPulseMetricsTable extends SupabaseTable<SystemPulseMetricsRow> {
  @override
  String get tableName => 'system_pulse_metrics';

  @override
  SystemPulseMetricsRow createRow(Map<String, dynamic> data) =>
      SystemPulseMetricsRow(data);
}

class SystemPulseMetricsRow extends SupabaseDataRow {
  SystemPulseMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SystemPulseMetricsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get metricType => getField<String>('metric_type')!;
  set metricType(String value) => setField<String>('metric_type', value);

  double get metricValue => getField<double>('metric_value')!;
  set metricValue(double value) => setField<double>('metric_value', value);

  String? get metricUnit => getField<String>('metric_unit');
  set metricUnit(String? value) => setField<String>('metric_unit', value);

  DateTime? get recordedAt => getField<DateTime>('recorded_at');
  set recordedAt(DateTime? value) => setField<DateTime>('recorded_at', value);

  String? get sourceModule => getField<String>('source_module');
  set sourceModule(String? value) => setField<String>('source_module', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);
}
