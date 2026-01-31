import '../database.dart';

class AiServiceLogsTable extends SupabaseTable<AiServiceLogsRow> {
  @override
  String get tableName => 'ai_service_logs';

  @override
  AiServiceLogsRow createRow(Map<String, dynamic> data) =>
      AiServiceLogsRow(data);
}

class AiServiceLogsRow extends SupabaseDataRow {
  AiServiceLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AiServiceLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get serviceName => getField<String>('service_name')!;
  set serviceName(String value) => setField<String>('service_name', value);

  String get requestType => getField<String>('request_type')!;
  set requestType(String value) => setField<String>('request_type', value);

  dynamic get requestPayload => getField<dynamic>('request_payload');
  set requestPayload(dynamic value) =>
      setField<dynamic>('request_payload', value);

  dynamic get responsePayload => getField<dynamic>('response_payload');
  set responsePayload(dynamic value) =>
      setField<dynamic>('response_payload', value);

  int? get latencyMs => getField<int>('latency_ms');
  set latencyMs(int? value) => setField<int>('latency_ms', value);

  int? get tokensUsed => getField<int>('tokens_used');
  set tokensUsed(int? value) => setField<int>('tokens_used', value);

  double? get costEstimate => getField<double>('cost_estimate');
  set costEstimate(double? value) => setField<double>('cost_estimate', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
