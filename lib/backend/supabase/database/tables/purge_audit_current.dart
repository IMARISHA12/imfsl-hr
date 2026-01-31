import '../database.dart';

class PurgeAuditCurrentTable extends SupabaseTable<PurgeAuditCurrentRow> {
  @override
  String get tableName => 'purge_audit_current';

  @override
  PurgeAuditCurrentRow createRow(Map<String, dynamic> data) =>
      PurgeAuditCurrentRow(data);
}

class PurgeAuditCurrentRow extends SupabaseDataRow {
  PurgeAuditCurrentRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PurgeAuditCurrentTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  DateTime? get purgeDate => getField<DateTime>('purge_date');
  set purgeDate(DateTime? value) => setField<DateTime>('purge_date', value);

  DateTime? get ranAt => getField<DateTime>('ran_at');
  set ranAt(DateTime? value) => setField<DateTime>('ran_at', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  int? get rowsDeleted => getField<int>('rows_deleted');
  set rowsDeleted(int? value) => setField<int>('rows_deleted', value);

  int? get executionTimeMs => getField<int>('execution_time_ms');
  set executionTimeMs(int? value) => setField<int>('execution_time_ms', value);

  String? get error => getField<String>('error');
  set error(String? value) => setField<String>('error', value);

  int? get retentionDays => getField<int>('retention_days');
  set retentionDays(int? value) => setField<int>('retention_days', value);
}
