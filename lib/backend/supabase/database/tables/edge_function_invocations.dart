import '../database.dart';

class EdgeFunctionInvocationsTable
    extends SupabaseTable<EdgeFunctionInvocationsRow> {
  @override
  String get tableName => 'edge_function_invocations';

  @override
  EdgeFunctionInvocationsRow createRow(Map<String, dynamic> data) =>
      EdgeFunctionInvocationsRow(data);
}

class EdgeFunctionInvocationsRow extends SupabaseDataRow {
  EdgeFunctionInvocationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EdgeFunctionInvocationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get functionName => getField<String>('function_name')!;
  set functionName(String value) => setField<String>('function_name', value);

  DateTime get invokedAt => getField<DateTime>('invoked_at')!;
  set invokedAt(DateTime value) => setField<DateTime>('invoked_at', value);

  double get durationMs => getField<double>('duration_ms')!;
  set durationMs(double value) => setField<double>('duration_ms', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  int? get requestSizeBytes => getField<int>('request_size_bytes');
  set requestSizeBytes(int? value) =>
      setField<int>('request_size_bytes', value);

  int? get responseSizeBytes => getField<int>('response_size_bytes');
  set responseSizeBytes(int? value) =>
      setField<int>('response_size_bytes', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);
}
