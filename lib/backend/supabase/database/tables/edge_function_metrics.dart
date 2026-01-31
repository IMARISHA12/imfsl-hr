import '../database.dart';

class EdgeFunctionMetricsTable extends SupabaseTable<EdgeFunctionMetricsRow> {
  @override
  String get tableName => 'edge_function_metrics';

  @override
  EdgeFunctionMetricsRow createRow(Map<String, dynamic> data) =>
      EdgeFunctionMetricsRow(data);
}

class EdgeFunctionMetricsRow extends SupabaseDataRow {
  EdgeFunctionMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EdgeFunctionMetricsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get functionName => getField<String>('function_name')!;
  set functionName(String value) => setField<String>('function_name', value);

  int? get totalInvocations => getField<int>('total_invocations');
  set totalInvocations(int? value) => setField<int>('total_invocations', value);

  int? get errorCount => getField<int>('error_count');
  set errorCount(int? value) => setField<int>('error_count', value);

  int? get avgLatencyMs => getField<int>('avg_latency_ms');
  set avgLatencyMs(int? value) => setField<int>('avg_latency_ms', value);

  DateTime? get lastInvokedAt => getField<DateTime>('last_invoked_at');
  set lastInvokedAt(DateTime? value) =>
      setField<DateTime>('last_invoked_at', value);

  DateTime? get lastErrorAt => getField<DateTime>('last_error_at');
  set lastErrorAt(DateTime? value) =>
      setField<DateTime>('last_error_at', value);

  String? get lastErrorMessage => getField<String>('last_error_message');
  set lastErrorMessage(String? value) =>
      setField<String>('last_error_message', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  int get successCount => getField<int>('success_count')!;
  set successCount(int value) => setField<int>('success_count', value);

  double? get minLatencyMs => getField<double>('min_latency_ms');
  set minLatencyMs(double? value) => setField<double>('min_latency_ms', value);

  double? get maxLatencyMs => getField<double>('max_latency_ms');
  set maxLatencyMs(double? value) => setField<double>('max_latency_ms', value);
}
