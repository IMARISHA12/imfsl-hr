import '../database.dart';

class WebhookEventsTable extends SupabaseTable<WebhookEventsRow> {
  @override
  String get tableName => 'webhook_events';

  @override
  WebhookEventsRow createRow(Map<String, dynamic> data) =>
      WebhookEventsRow(data);
}

class WebhookEventsRow extends SupabaseDataRow {
  WebhookEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => WebhookEventsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get provider => getField<String>('provider')!;
  set provider(String value) => setField<String>('provider', value);

  String get eventKey => getField<String>('event_key')!;
  set eventKey(String value) => setField<String>('event_key', value);

  DateTime get receivedAt => getField<DateTime>('received_at')!;
  set receivedAt(DateTime value) => setField<DateTime>('received_at', value);

  dynamic get payload => getField<dynamic>('payload')!;
  set payload(dynamic value) => setField<dynamic>('payload', value);

  DateTime? get processedAt => getField<DateTime>('processed_at');
  set processedAt(DateTime? value) => setField<DateTime>('processed_at', value);

  dynamic get processResult => getField<dynamic>('process_result');
  set processResult(dynamic value) =>
      setField<dynamic>('process_result', value);
}
