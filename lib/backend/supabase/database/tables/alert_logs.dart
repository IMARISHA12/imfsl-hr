import '../database.dart';

class AlertLogsTable extends SupabaseTable<AlertLogsRow> {
  @override
  String get tableName => 'alert_logs';

  @override
  AlertLogsRow createRow(Map<String, dynamic> data) => AlertLogsRow(data);
}

class AlertLogsRow extends SupabaseDataRow {
  AlertLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  String get message => getField<String>('message')!;
  set message(String value) => setField<String>('message', value);

  String? get source => getField<String>('source');
  set source(String? value) => setField<String>('source', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) => setField<DateTime>('resolved_at', value);

  String? get alertType => getField<String>('alert_type');
  set alertType(String? value) => setField<String>('alert_type', value);

  dynamic get alertData => getField<dynamic>('alert_data');
  set alertData(dynamic value) => setField<dynamic>('alert_data', value);

  DateTime? get triggeredAt => getField<DateTime>('triggered_at');
  set triggeredAt(DateTime? value) => setField<DateTime>('triggered_at', value);
}
