import '../database.dart';

class AccessLogsTable extends SupabaseTable<AccessLogsRow> {
  @override
  String get tableName => 'access_logs';

  @override
  AccessLogsRow createRow(Map<String, dynamic> data) => AccessLogsRow(data);
}

class AccessLogsRow extends SupabaseDataRow {
  AccessLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AccessLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String get resource => getField<String>('resource')!;
  set resource(String value) => setField<String>('resource', value);

  String? get resourceId => getField<String>('resource_id');
  set resourceId(String? value) => setField<String>('resource_id', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  bool get granted => getField<bool>('granted')!;
  set granted(bool value) => setField<bool>('granted', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  DateTime? get timestamp => getField<DateTime>('timestamp');
  set timestamp(DateTime? value) => setField<DateTime>('timestamp', value);
}
