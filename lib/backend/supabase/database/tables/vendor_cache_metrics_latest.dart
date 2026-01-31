import '../database.dart';

class VendorCacheMetricsLatestTable
    extends SupabaseTable<VendorCacheMetricsLatestRow> {
  @override
  String get tableName => 'vendor_cache_metrics_latest';

  @override
  VendorCacheMetricsLatestRow createRow(Map<String, dynamic> data) =>
      VendorCacheMetricsLatestRow(data);
}

class VendorCacheMetricsLatestRow extends SupabaseDataRow {
  VendorCacheMetricsLatestRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VendorCacheMetricsLatestTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  DateTime? get runStartedAt => getField<DateTime>('run_started_at');
  set runStartedAt(DateTime? value) =>
      setField<DateTime>('run_started_at', value);

  DateTime? get runFinishedAt => getField<DateTime>('run_finished_at');
  set runFinishedAt(DateTime? value) =>
      setField<DateTime>('run_finished_at', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  double? get durationMs => getField<double>('duration_ms');
  set durationMs(double? value) => setField<double>('duration_ms', value);

  bool? get slaBreached => getField<bool>('sla_breached');
  set slaBreached(bool? value) => setField<bool>('sla_breached', value);

  DateTime? get runAt => getField<DateTime>('run_at');
  set runAt(DateTime? value) => setField<DateTime>('run_at', value);
}
