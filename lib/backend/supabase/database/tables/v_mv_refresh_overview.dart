import '../database.dart';

class VMvRefreshOverviewTable extends SupabaseTable<VMvRefreshOverviewRow> {
  @override
  String get tableName => 'v_mv_refresh_overview';

  @override
  VMvRefreshOverviewRow createRow(Map<String, dynamic> data) =>
      VMvRefreshOverviewRow(data);
}

class VMvRefreshOverviewRow extends SupabaseDataRow {
  VMvRefreshOverviewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VMvRefreshOverviewTable();

  int? get failingMvs => getField<int>('failing_mvs');
  set failingMvs(int? value) => setField<int>('failing_mvs', value);

  int? get totalMvs => getField<int>('total_mvs');
  set totalMvs(int? value) => setField<int>('total_mvs', value);

  int? get avgRefreshMs => getField<int>('avg_refresh_ms');
  set avgRefreshMs(int? value) => setField<int>('avg_refresh_ms', value);

  DateTime? get lastRunAt => getField<DateTime>('last_run_at');
  set lastRunAt(DateTime? value) => setField<DateTime>('last_run_at', value);

  bool? get lastRunSuccess => getField<bool>('last_run_success');
  set lastRunSuccess(bool? value) => setField<bool>('last_run_success', value);
}
