import '../database.dart';

class ZArchiveEdgeFunctionMetricsTable
    extends SupabaseTable<ZArchiveEdgeFunctionMetricsRow> {
  @override
  String get tableName => 'z_archive_edge_function_metrics';

  @override
  ZArchiveEdgeFunctionMetricsRow createRow(Map<String, dynamic> data) =>
      ZArchiveEdgeFunctionMetricsRow(data);
}

class ZArchiveEdgeFunctionMetricsRow extends SupabaseDataRow {
  ZArchiveEdgeFunctionMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveEdgeFunctionMetricsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get functionName => getField<String>('function_name')!;
  set functionName(String value) => setField<String>('function_name', value);

  String get endpoint => getField<String>('endpoint')!;
  set endpoint(String value) => setField<String>('endpoint', value);

  String get method => getField<String>('method')!;
  set method(String value) => setField<String>('method', value);

  int get statusCode => getField<int>('status_code')!;
  set statusCode(int value) => setField<int>('status_code', value);

  int get durationMs => getField<int>('duration_ms')!;
  set durationMs(int value) => setField<int>('duration_ms', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get correlationId => getField<String>('correlation_id');
  set correlationId(String? value) => setField<String>('correlation_id', value);
}
