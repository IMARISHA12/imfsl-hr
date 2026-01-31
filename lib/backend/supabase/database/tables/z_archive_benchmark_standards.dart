import '../database.dart';

class ZArchiveBenchmarkStandardsTable
    extends SupabaseTable<ZArchiveBenchmarkStandardsRow> {
  @override
  String get tableName => 'z_archive_benchmark_standards';

  @override
  ZArchiveBenchmarkStandardsRow createRow(Map<String, dynamic> data) =>
      ZArchiveBenchmarkStandardsRow(data);
}

class ZArchiveBenchmarkStandardsRow extends SupabaseDataRow {
  ZArchiveBenchmarkStandardsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveBenchmarkStandardsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get metricName => getField<String>('metric_name')!;
  set metricName(String value) => setField<String>('metric_name', value);

  String get benchmarkType => getField<String>('benchmark_type')!;
  set benchmarkType(String value) => setField<String>('benchmark_type', value);

  double get metricValue => getField<double>('metric_value')!;
  set metricValue(double value) => setField<double>('metric_value', value);

  double? get percentile90 => getField<double>('percentile_90');
  set percentile90(double? value) => setField<double>('percentile_90', value);

  double? get percentile75 => getField<double>('percentile_75');
  set percentile75(double? value) => setField<double>('percentile_75', value);

  double? get percentile50 => getField<double>('percentile_50');
  set percentile50(double? value) => setField<double>('percentile_50', value);

  double? get percentile25 => getField<double>('percentile_25');
  set percentile25(double? value) => setField<double>('percentile_25', value);

  String? get industrySector => getField<String>('industry_sector');
  set industrySector(String? value) =>
      setField<String>('industry_sector', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
