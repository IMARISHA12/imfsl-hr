import '../database.dart';

class LoandiskAccessLogTable extends SupabaseTable<LoandiskAccessLogRow> {
  @override
  String get tableName => 'loandisk_access_log';

  @override
  LoandiskAccessLogRow createRow(Map<String, dynamic> data) =>
      LoandiskAccessLogRow(data);
}

class LoandiskAccessLogRow extends SupabaseDataRow {
  LoandiskAccessLogRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoandiskAccessLogTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get userEmail => getField<String>('user_email');
  set userEmail(String? value) => setField<String>('user_email', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String? get resource => getField<String>('resource');
  set resource(String? value) => setField<String>('resource', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  DateTime get accessedAt => getField<DateTime>('accessed_at')!;
  set accessedAt(DateTime value) => setField<DateTime>('accessed_at', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);
}
