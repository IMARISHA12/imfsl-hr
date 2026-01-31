import '../database.dart';

class CronFailureAlertsTable extends SupabaseTable<CronFailureAlertsRow> {
  @override
  String get tableName => 'cron_failure_alerts';

  @override
  CronFailureAlertsRow createRow(Map<String, dynamic> data) =>
      CronFailureAlertsRow(data);
}

class CronFailureAlertsRow extends SupabaseDataRow {
  CronFailureAlertsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CronFailureAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get jobName => getField<String>('job_name')!;
  set jobName(String value) => setField<String>('job_name', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  DateTime? get failedAt => getField<DateTime>('failed_at');
  set failedAt(DateTime? value) => setField<DateTime>('failed_at', value);

  bool? get acknowledged => getField<bool>('acknowledged');
  set acknowledged(bool? value) => setField<bool>('acknowledged', value);

  String? get acknowledgedBy => getField<String>('acknowledged_by');
  set acknowledgedBy(String? value) =>
      setField<String>('acknowledged_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
