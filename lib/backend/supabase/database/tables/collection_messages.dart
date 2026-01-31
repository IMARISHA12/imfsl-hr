import '../database.dart';

class CollectionMessagesTable extends SupabaseTable<CollectionMessagesRow> {
  @override
  String get tableName => 'collection_messages';

  @override
  CollectionMessagesRow createRow(Map<String, dynamic> data) =>
      CollectionMessagesRow(data);
}

class CollectionMessagesRow extends SupabaseDataRow {
  CollectionMessagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollectionMessagesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  String? get templateId => getField<String>('template_id');
  set templateId(String? value) => setField<String>('template_id', value);

  String get channel => getField<String>('channel')!;
  set channel(String value) => setField<String>('channel', value);

  String get direction => getField<String>('direction')!;
  set direction(String value) => setField<String>('direction', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  String? get contentLanguage => getField<String>('content_language');
  set contentLanguage(String? value) =>
      setField<String>('content_language', value);

  String? get externalId => getField<String>('external_id');
  set externalId(String? value) => setField<String>('external_id', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  DateTime? get deliveredAt => getField<DateTime>('delivered_at');
  set deliveredAt(DateTime? value) => setField<DateTime>('delivered_at', value);

  DateTime? get readAt => getField<DateTime>('read_at');
  set readAt(DateTime? value) => setField<DateTime>('read_at', value);

  String? get failureReason => getField<String>('failure_reason');
  set failureReason(String? value) => setField<String>('failure_reason', value);

  String? get sentBy => getField<String>('sent_by');
  set sentBy(String? value) => setField<String>('sent_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  int? get retryCount => getField<int>('retry_count');
  set retryCount(int? value) => setField<int>('retry_count', value);

  int? get maxRetries => getField<int>('max_retries');
  set maxRetries(int? value) => setField<int>('max_retries', value);

  DateTime? get nextRetryAt => getField<DateTime>('next_retry_at');
  set nextRetryAt(DateTime? value) =>
      setField<DateTime>('next_retry_at', value);

  String? get lastError => getField<String>('last_error');
  set lastError(String? value) => setField<String>('last_error', value);
}
