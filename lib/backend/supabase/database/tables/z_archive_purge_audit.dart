import '../database.dart';

class ZArchivePurgeAuditTable extends SupabaseTable<ZArchivePurgeAuditRow> {
  @override
  String get tableName => 'z_archive_purge_audit';

  @override
  ZArchivePurgeAuditRow createRow(Map<String, dynamic> data) =>
      ZArchivePurgeAuditRow(data);
}

class ZArchivePurgeAuditRow extends SupabaseDataRow {
  ZArchivePurgeAuditRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchivePurgeAuditTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get ranAt => getField<DateTime>('ran_at')!;
  set ranAt(DateTime value) => setField<DateTime>('ran_at', value);

  int get retentionDays => getField<int>('retention_days')!;
  set retentionDays(int value) => setField<int>('retention_days', value);

  int get rowsDeleted => getField<int>('rows_deleted')!;
  set rowsDeleted(int value) => setField<int>('rows_deleted', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get error => getField<String>('error');
  set error(String? value) => setField<String>('error', value);

  int? get executionTimeMs => getField<int>('execution_time_ms');
  set executionTimeMs(int? value) => setField<int>('execution_time_ms', value);

  DateTime? get purgeDate => getField<DateTime>('purge_date');
  set purgeDate(DateTime? value) => setField<DateTime>('purge_date', value);
}
