import '../database.dart';

class TechMonitoringChecksTable
    extends SupabaseTable<TechMonitoringChecksRow> {
  @override
  String get tableName => 'tech_monitoring_checks';

  @override
  TechMonitoringChecksRow createRow(Map<String, dynamic> data) =>
      TechMonitoringChecksRow(data);
}

class TechMonitoringChecksRow extends SupabaseDataRow {
  TechMonitoringChecksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TechMonitoringChecksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get systemName => getField<String>('system_name')!;
  set systemName(String value) =>
      setField<String>('system_name', value);

  String get systemType => getField<String>('system_type')!;
  set systemType(String value) =>
      setField<String>('system_type', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  int? get responseTimeMs => getField<int>('response_time_ms');
  set responseTimeMs(int? value) =>
      setField<int>('response_time_ms', value);

  double? get uptimePct => getField<double>('uptime_pct');
  set uptimePct(double? value) =>
      setField<double>('uptime_pct', value);

  dynamic get metrics => getField<dynamic>('metrics');
  set metrics(dynamic value) => setField<dynamic>('metrics', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) =>
      setField<String>('error_message', value);

  String? get checkSource => getField<String>('check_source');
  set checkSource(String? value) =>
      setField<String>('check_source', value);

  DateTime get checkedAt => getField<DateTime>('checked_at')!;
  set checkedAt(DateTime value) =>
      setField<DateTime>('checked_at', value);
}
