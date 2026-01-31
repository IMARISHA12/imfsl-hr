import '../database.dart';

class EdgeRecentFailures24hTable
    extends SupabaseTable<EdgeRecentFailures24hRow> {
  @override
  String get tableName => 'edge_recent_failures_24h';

  @override
  EdgeRecentFailures24hRow createRow(Map<String, dynamic> data) =>
      EdgeRecentFailures24hRow(data);
}

class EdgeRecentFailures24hRow extends SupabaseDataRow {
  EdgeRecentFailures24hRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EdgeRecentFailures24hTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get functionName => getField<String>('function_name');
  set functionName(String? value) => setField<String>('function_name', value);

  String? get endpoint => getField<String>('endpoint');
  set endpoint(String? value) => setField<String>('endpoint', value);

  String? get method => getField<String>('method');
  set method(String? value) => setField<String>('method', value);

  int? get statusCode => getField<int>('status_code');
  set statusCode(int? value) => setField<int>('status_code', value);

  int? get durationMs => getField<int>('duration_ms');
  set durationMs(int? value) => setField<int>('duration_ms', value);

  String? get correlationId => getField<String>('correlation_id');
  set correlationId(String? value) => setField<String>('correlation_id', value);

  String? get errorSnippet => getField<String>('error_snippet');
  set errorSnippet(String? value) => setField<String>('error_snippet', value);
}
