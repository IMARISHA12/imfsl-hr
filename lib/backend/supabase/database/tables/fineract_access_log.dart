import '../database.dart';

class FineractAccessLogTable extends SupabaseTable<FineractAccessLogRow> {
  @override
  String get tableName => 'fineract_access_log';

  @override
  FineractAccessLogRow createRow(Map<String, dynamic> data) =>
      FineractAccessLogRow(data);
}

class FineractAccessLogRow extends SupabaseDataRow {
  FineractAccessLogRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FineractAccessLogTable();

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

  String? get endpoint => getField<String>('endpoint');
  set endpoint(String? value) => setField<String>('endpoint', value);

  String? get httpMethod => getField<String>('http_method');
  set httpMethod(String? value) => setField<String>('http_method', value);

  int? get httpStatusCode => getField<int>('http_status_code');
  set httpStatusCode(int? value) => setField<int>('http_status_code', value);

  int? get responseTimeMs => getField<int>('response_time_ms');
  set responseTimeMs(int? value) => setField<int>('response_time_ms', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  DateTime get accessedAt => getField<DateTime>('accessed_at')!;
  set accessedAt(DateTime value) => setField<DateTime>('accessed_at', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);
}
