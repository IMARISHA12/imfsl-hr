import '../database.dart';

class EventDeliveryLogTable extends SupabaseTable<EventDeliveryLogRow> {
  @override
  String get tableName => 'event_delivery_log';

  @override
  EventDeliveryLogRow createRow(Map<String, dynamic> data) =>
      EventDeliveryLogRow(data);
}

class EventDeliveryLogRow extends SupabaseDataRow {
  EventDeliveryLogRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EventDeliveryLogTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  dynamic get payload => getField<dynamic>('payload')!;
  set payload(dynamic value) => setField<dynamic>('payload', value);

  String get targetUrl => getField<String>('target_url')!;
  set targetUrl(String value) => setField<String>('target_url', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  int get attemptCount => getField<int>('attempt_count')!;
  set attemptCount(int value) => setField<int>('attempt_count', value);

  int get maxAttempts => getField<int>('max_attempts')!;
  set maxAttempts(int value) => setField<int>('max_attempts', value);

  DateTime? get lastAttemptAt => getField<DateTime>('last_attempt_at');
  set lastAttemptAt(DateTime? value) =>
      setField<DateTime>('last_attempt_at', value);

  DateTime? get nextRetryAt => getField<DateTime>('next_retry_at');
  set nextRetryAt(DateTime? value) =>
      setField<DateTime>('next_retry_at', value);

  int? get responseStatus => getField<int>('response_status');
  set responseStatus(int? value) => setField<int>('response_status', value);

  String? get responseBody => getField<String>('response_body');
  set responseBody(String? value) => setField<String>('response_body', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  String? get correlationId => getField<String>('correlation_id');
  set correlationId(String? value) => setField<String>('correlation_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
