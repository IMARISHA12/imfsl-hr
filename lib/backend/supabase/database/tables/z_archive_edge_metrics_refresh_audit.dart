import '../database.dart';

class ZArchiveEdgeMetricsRefreshAuditTable
    extends SupabaseTable<ZArchiveEdgeMetricsRefreshAuditRow> {
  @override
  String get tableName => 'z_archive_edge_metrics_refresh_audit';

  @override
  ZArchiveEdgeMetricsRefreshAuditRow createRow(Map<String, dynamic> data) =>
      ZArchiveEdgeMetricsRefreshAuditRow(data);
}

class ZArchiveEdgeMetricsRefreshAuditRow extends SupabaseDataRow {
  ZArchiveEdgeMetricsRefreshAuditRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveEdgeMetricsRefreshAuditTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get runStartedAt => getField<DateTime>('run_started_at')!;
  set runStartedAt(DateTime value) =>
      setField<DateTime>('run_started_at', value);

  DateTime? get runFinishedAt => getField<DateTime>('run_finished_at');
  set runFinishedAt(DateTime? value) =>
      setField<DateTime>('run_finished_at', value);

  int? get durationMs => getField<int>('duration_ms');
  set durationMs(int? value) => setField<int>('duration_ms', value);

  bool get success => getField<bool>('success')!;
  set success(bool value) => setField<bool>('success', value);

  String? get errorText => getField<String>('error_text');
  set errorText(String? value) => setField<String>('error_text', value);

  int? get recentFailuresRows => getField<int>('recent_failures_rows');
  set recentFailuresRows(int? value) =>
      setField<int>('recent_failures_rows', value);

  int? get latencyPctsRows => getField<int>('latency_pcts_rows');
  set latencyPctsRows(int? value) => setField<int>('latency_pcts_rows', value);

  int? get errorRatesRows => getField<int>('error_rates_rows');
  set errorRatesRows(int? value) => setField<int>('error_rates_rows', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
