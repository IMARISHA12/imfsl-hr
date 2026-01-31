import '../database.dart';

class EdgeMetricsRefreshStatusTable
    extends SupabaseTable<EdgeMetricsRefreshStatusRow> {
  @override
  String get tableName => 'edge_metrics_refresh_status';

  @override
  EdgeMetricsRefreshStatusRow createRow(Map<String, dynamic> data) =>
      EdgeMetricsRefreshStatusRow(data);
}

class EdgeMetricsRefreshStatusRow extends SupabaseDataRow {
  EdgeMetricsRefreshStatusRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EdgeMetricsRefreshStatusTable();

  DateTime? get lastSuccessfulRefresh =>
      getField<DateTime>('last_successful_refresh');
  set lastSuccessfulRefresh(DateTime? value) =>
      setField<DateTime>('last_successful_refresh', value);

  int? get stalenessSeconds => getField<int>('staleness_seconds');
  set stalenessSeconds(int? value) => setField<int>('staleness_seconds', value);

  int? get successfulRunsLastHour => getField<int>('successful_runs_last_hour');
  set successfulRunsLastHour(int? value) =>
      setField<int>('successful_runs_last_hour', value);

  int? get failedRunsLastHour => getField<int>('failed_runs_last_hour');
  set failedRunsLastHour(int? value) =>
      setField<int>('failed_runs_last_hour', value);

  double? get avgDurationMs24h => getField<double>('avg_duration_ms_24h');
  set avgDurationMs24h(double? value) =>
      setField<double>('avg_duration_ms_24h', value);

  int? get maxDurationMs24h => getField<int>('max_duration_ms_24h');
  set maxDurationMs24h(int? value) =>
      setField<int>('max_duration_ms_24h', value);
}
