import '../database.dart';

class ZArchiveIntegrationLogsTable
    extends SupabaseTable<ZArchiveIntegrationLogsRow> {
  @override
  String get tableName => 'z_archive_integration_logs';

  @override
  ZArchiveIntegrationLogsRow createRow(Map<String, dynamic> data) =>
      ZArchiveIntegrationLogsRow(data);
}

class ZArchiveIntegrationLogsRow extends SupabaseDataRow {
  ZArchiveIntegrationLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveIntegrationLogsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get systemName => getField<String>('system_name')!;
  set systemName(String value) => setField<String>('system_name', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  dynamic get payload => getField<dynamic>('payload');
  set payload(dynamic value) => setField<dynamic>('payload', value);

  dynamic get response => getField<dynamic>('response');
  set response(dynamic value) => setField<dynamic>('response', value);

  DateTime? get logTime => getField<DateTime>('log_time');
  set logTime(DateTime? value) => setField<DateTime>('log_time', value);
}
