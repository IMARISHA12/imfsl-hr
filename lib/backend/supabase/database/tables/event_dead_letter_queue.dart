import '../database.dart';

class EventDeadLetterQueueTable extends SupabaseTable<EventDeadLetterQueueRow> {
  @override
  String get tableName => 'event_dead_letter_queue';

  @override
  EventDeadLetterQueueRow createRow(Map<String, dynamic> data) =>
      EventDeadLetterQueueRow(data);
}

class EventDeadLetterQueueRow extends SupabaseDataRow {
  EventDeadLetterQueueRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EventDeadLetterQueueTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get originalEventId => getField<String>('original_event_id');
  set originalEventId(String? value) =>
      setField<String>('original_event_id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  dynamic get payload => getField<dynamic>('payload')!;
  set payload(dynamic value) => setField<dynamic>('payload', value);

  String get targetUrl => getField<String>('target_url')!;
  set targetUrl(String value) => setField<String>('target_url', value);

  String get failureReason => getField<String>('failure_reason')!;
  set failureReason(String value) => setField<String>('failure_reason', value);

  dynamic get attemptHistory => getField<dynamic>('attempt_history');
  set attemptHistory(dynamic value) =>
      setField<dynamic>('attempt_history', value);

  bool get resolved => getField<bool>('resolved')!;
  set resolved(bool value) => setField<bool>('resolved', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) => setField<DateTime>('resolved_at', value);

  String? get resolvedBy => getField<String>('resolved_by');
  set resolvedBy(String? value) => setField<String>('resolved_by', value);

  String? get resolutionNotes => getField<String>('resolution_notes');
  set resolutionNotes(String? value) =>
      setField<String>('resolution_notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
