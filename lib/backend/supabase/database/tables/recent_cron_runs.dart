import '../database.dart';

class RecentCronRunsTable extends SupabaseTable<RecentCronRunsRow> {
  @override
  String get tableName => 'recent_cron_runs';

  @override
  RecentCronRunsRow createRow(Map<String, dynamic> data) =>
      RecentCronRunsRow(data);
}

class RecentCronRunsRow extends SupabaseDataRow {
  RecentCronRunsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RecentCronRunsTable();

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

  int? get durationSeconds => getField<int>('duration_seconds');
  set durationSeconds(int? value) => setField<int>('duration_seconds', value);

  String? get statusDisplay => getField<String>('status_display');
  set statusDisplay(String? value) => setField<String>('status_display', value);
}
