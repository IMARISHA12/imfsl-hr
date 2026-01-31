import '../database.dart';

class ZArchivePerfThresholdsTable
    extends SupabaseTable<ZArchivePerfThresholdsRow> {
  @override
  String get tableName => 'z_archive_perf_thresholds';

  @override
  ZArchivePerfThresholdsRow createRow(Map<String, dynamic> data) =>
      ZArchivePerfThresholdsRow(data);
}

class ZArchivePerfThresholdsRow extends SupabaseDataRow {
  ZArchivePerfThresholdsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchivePerfThresholdsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get metricName => getField<String>('metric_name')!;
  set metricName(String value) => setField<String>('metric_name', value);

  double get warningThreshold => getField<double>('warning_threshold')!;
  set warningThreshold(double value) =>
      setField<double>('warning_threshold', value);

  double get errorThreshold => getField<double>('error_threshold')!;
  set errorThreshold(double value) =>
      setField<double>('error_threshold', value);

  String get metricUnit => getField<String>('metric_unit')!;
  set metricUnit(String value) => setField<String>('metric_unit', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  bool? get enabled => getField<bool>('enabled');
  set enabled(bool? value) => setField<bool>('enabled', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
