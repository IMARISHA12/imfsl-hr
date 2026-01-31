import '../database.dart';

class ZArchiveMvRefreshStatusTable
    extends SupabaseTable<ZArchiveMvRefreshStatusRow> {
  @override
  String get tableName => 'z_archive_mv_refresh_status';

  @override
  ZArchiveMvRefreshStatusRow createRow(Map<String, dynamic> data) =>
      ZArchiveMvRefreshStatusRow(data);
}

class ZArchiveMvRefreshStatusRow extends SupabaseDataRow {
  ZArchiveMvRefreshStatusRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveMvRefreshStatusTable();

  String get mvName => getField<String>('mv_name')!;
  set mvName(String value) => setField<String>('mv_name', value);

  DateTime? get lastRefreshedAt => getField<DateTime>('last_refreshed_at');
  set lastRefreshedAt(DateTime? value) =>
      setField<DateTime>('last_refreshed_at', value);

  int? get lastDurationMs => getField<int>('last_duration_ms');
  set lastDurationMs(int? value) => setField<int>('last_duration_ms', value);

  int? get lastRowcount => getField<int>('last_rowcount');
  set lastRowcount(int? value) => setField<int>('last_rowcount', value);

  bool? get lastSuccess => getField<bool>('last_success');
  set lastSuccess(bool? value) => setField<bool>('last_success', value);

  String? get lastError => getField<String>('last_error');
  set lastError(String? value) => setField<String>('last_error', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  DateTime? get refreshStartedAt => getField<DateTime>('refresh_started_at');
  set refreshStartedAt(DateTime? value) =>
      setField<DateTime>('refresh_started_at', value);

  int? get errorCount => getField<int>('error_count');
  set errorCount(int? value) => setField<int>('error_count', value);
}
