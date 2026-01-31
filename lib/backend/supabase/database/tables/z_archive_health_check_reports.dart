import '../database.dart';

class ZArchiveHealthCheckReportsTable
    extends SupabaseTable<ZArchiveHealthCheckReportsRow> {
  @override
  String get tableName => 'z_archive_health_check_reports';

  @override
  ZArchiveHealthCheckReportsRow createRow(Map<String, dynamic> data) =>
      ZArchiveHealthCheckReportsRow(data);
}

class ZArchiveHealthCheckReportsRow extends SupabaseDataRow {
  ZArchiveHealthCheckReportsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveHealthCheckReportsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get checkTimestamp => getField<DateTime>('check_timestamp')!;
  set checkTimestamp(DateTime value) =>
      setField<DateTime>('check_timestamp', value);

  String get overallStatus => getField<String>('overall_status')!;
  set overallStatus(String value) => setField<String>('overall_status', value);

  dynamic get checkResults => getField<dynamic>('check_results')!;
  set checkResults(dynamic value) => setField<dynamic>('check_results', value);

  int get issuesFound => getField<int>('issues_found')!;
  set issuesFound(int value) => setField<int>('issues_found', value);

  int get criticalIssues => getField<int>('critical_issues')!;
  set criticalIssues(int value) => setField<int>('critical_issues', value);

  int get warningIssues => getField<int>('warning_issues')!;
  set warningIssues(int value) => setField<int>('warning_issues', value);

  int? get executionTimeMs => getField<int>('execution_time_ms');
  set executionTimeMs(int? value) => setField<int>('execution_time_ms', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
