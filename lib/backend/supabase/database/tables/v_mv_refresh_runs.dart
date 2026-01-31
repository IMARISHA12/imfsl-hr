import '../database.dart';

class VMvRefreshRunsTable extends SupabaseTable<VMvRefreshRunsRow> {
  @override
  String get tableName => 'v_mv_refresh_runs';

  @override
  VMvRefreshRunsRow createRow(Map<String, dynamic> data) =>
      VMvRefreshRunsRow(data);
}

class VMvRefreshRunsRow extends SupabaseDataRow {
  VMvRefreshRunsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VMvRefreshRunsTable();

  DateTime? get runStartedAt => getField<DateTime>('run_started_at');
  set runStartedAt(DateTime? value) =>
      setField<DateTime>('run_started_at', value);

  int? get durationMs => getField<int>('duration_ms');
  set durationMs(int? value) => setField<int>('duration_ms', value);

  bool? get success => getField<bool>('success');
  set success(bool? value) => setField<bool>('success', value);

  String? get errorText => getField<String>('error_text');
  set errorText(String? value) => setField<String>('error_text', value);
}
