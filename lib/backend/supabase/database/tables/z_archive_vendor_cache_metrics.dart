import '../database.dart';

class ZArchiveVendorCacheMetricsTable
    extends SupabaseTable<ZArchiveVendorCacheMetricsRow> {
  @override
  String get tableName => 'z_archive_vendor_cache_metrics';

  @override
  ZArchiveVendorCacheMetricsRow createRow(Map<String, dynamic> data) =>
      ZArchiveVendorCacheMetricsRow(data);
}

class ZArchiveVendorCacheMetricsRow extends SupabaseDataRow {
  ZArchiveVendorCacheMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveVendorCacheMetricsTable();

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

  int? get warmedCount => getField<int>('warmed_count');
  set warmedCount(int? value) => setField<int>('warmed_count', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  String? get cronJob => getField<String>('cron_job');
  set cronJob(String? value) => setField<String>('cron_job', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  bool? get testFlag => getField<bool>('test_flag');
  set testFlag(bool? value) => setField<bool>('test_flag', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  DateTime? get refreshTime => getField<DateTime>('refresh_time');
  set refreshTime(DateTime? value) => setField<DateTime>('refresh_time', value);
}
