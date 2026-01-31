import '../database.dart';

class PurgeAudit7dTable extends SupabaseTable<PurgeAudit7dRow> {
  @override
  String get tableName => 'purge_audit_7d';

  @override
  PurgeAudit7dRow createRow(Map<String, dynamic> data) => PurgeAudit7dRow(data);
}

class PurgeAudit7dRow extends SupabaseDataRow {
  PurgeAudit7dRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PurgeAudit7dTable();

  DateTime? get purgeDate => getField<DateTime>('purge_date');
  set purgeDate(DateTime? value) => setField<DateTime>('purge_date', value);

  int? get totalRuns => getField<int>('total_runs');
  set totalRuns(int? value) => setField<int>('total_runs', value);

  int? get successfulRuns => getField<int>('successful_runs');
  set successfulRuns(int? value) => setField<int>('successful_runs', value);

  int? get failedRuns => getField<int>('failed_runs');
  set failedRuns(int? value) => setField<int>('failed_runs', value);

  double? get totalRowsDeleted => getField<double>('total_rows_deleted');
  set totalRowsDeleted(double? value) =>
      setField<double>('total_rows_deleted', value);

  double? get avgRowsDeleted => getField<double>('avg_rows_deleted');
  set avgRowsDeleted(double? value) =>
      setField<double>('avg_rows_deleted', value);

  int? get maxRowsDeleted => getField<int>('max_rows_deleted');
  set maxRowsDeleted(int? value) => setField<int>('max_rows_deleted', value);

  double? get avgExecutionTimeMs => getField<double>('avg_execution_time_ms');
  set avgExecutionTimeMs(double? value) =>
      setField<double>('avg_execution_time_ms', value);

  int? get maxExecutionTimeMs => getField<int>('max_execution_time_ms');
  set maxExecutionTimeMs(int? value) =>
      setField<int>('max_execution_time_ms', value);
}
