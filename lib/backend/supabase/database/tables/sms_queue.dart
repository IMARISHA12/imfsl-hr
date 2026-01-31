import '../database.dart';

class SmsQueueTable extends SupabaseTable<SmsQueueRow> {
  @override
  String get tableName => 'sms_queue';

  @override
  SmsQueueRow createRow(Map<String, dynamic> data) => SmsQueueRow(data);
}

class SmsQueueRow extends SupabaseDataRow {
  SmsQueueRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SmsQueueTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get recipientPhone => getField<String>('recipient_phone')!;
  set recipientPhone(String value) =>
      setField<String>('recipient_phone', value);

  String? get recipientName => getField<String>('recipient_name');
  set recipientName(String? value) => setField<String>('recipient_name', value);

  String get message => getField<String>('message')!;
  set message(String value) => setField<String>('message', value);

  String get messageType => getField<String>('message_type')!;
  set messageType(String value) => setField<String>('message_type', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  int get priority => getField<int>('priority')!;
  set priority(int value) => setField<int>('priority', value);

  DateTime get scheduledAt => getField<DateTime>('scheduled_at')!;
  set scheduledAt(DateTime value) => setField<DateTime>('scheduled_at', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  int get retryCount => getField<int>('retry_count')!;
  set retryCount(int value) => setField<int>('retry_count', value);

  int get maxRetries => getField<int>('max_retries')!;
  set maxRetries(int value) => setField<int>('max_retries', value);

  String? get entityType => getField<String>('entity_type');
  set entityType(String? value) => setField<String>('entity_type', value);

  String? get entityId => getField<String>('entity_id');
  set entityId(String? value) => setField<String>('entity_id', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
