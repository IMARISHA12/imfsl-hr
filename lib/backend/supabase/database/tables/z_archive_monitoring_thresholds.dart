import '../database.dart';

class ZArchiveMonitoringThresholdsTable
    extends SupabaseTable<ZArchiveMonitoringThresholdsRow> {
  @override
  String get tableName => 'z_archive_monitoring_thresholds';

  @override
  ZArchiveMonitoringThresholdsRow createRow(Map<String, dynamic> data) =>
      ZArchiveMonitoringThresholdsRow(data);
}

class ZArchiveMonitoringThresholdsRow extends SupabaseDataRow {
  ZArchiveMonitoringThresholdsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveMonitoringThresholdsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get service => getField<String>('service')!;
  set service(String value) => setField<String>('service', value);

  String? get functionName => getField<String>('function_name');
  set functionName(String? value) => setField<String>('function_name', value);

  int? get p90LatencyMsThreshold => getField<int>('p90_latency_ms_threshold');
  set p90LatencyMsThreshold(int? value) =>
      setField<int>('p90_latency_ms_threshold', value);

  int? get p99LatencyMsThreshold => getField<int>('p99_latency_ms_threshold');
  set p99LatencyMsThreshold(int? value) =>
      setField<int>('p99_latency_ms_threshold', value);

  double? get errorRatePctThreshold =>
      getField<double>('error_rate_pct_threshold');
  set errorRatePctThreshold(double? value) =>
      setField<double>('error_rate_pct_threshold', value);

  int? get minRequestsForAlert => getField<int>('min_requests_for_alert');
  set minRequestsForAlert(int? value) =>
      setField<int>('min_requests_for_alert', value);

  bool? get enabled => getField<bool>('enabled');
  set enabled(bool? value) => setField<bool>('enabled', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
