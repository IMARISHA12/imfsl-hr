import '../database.dart';

class VUnifiedNotificationsTable
    extends SupabaseTable<VUnifiedNotificationsRow> {
  @override
  String get tableName => 'v_unified_notifications';

  @override
  VUnifiedNotificationsRow createRow(Map<String, dynamic> data) =>
      VUnifiedNotificationsRow(data);
}

class VUnifiedNotificationsRow extends SupabaseDataRow {
  VUnifiedNotificationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VUnifiedNotificationsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get sourceType => getField<String>('source_type');
  set sourceType(String? value) => setField<String>('source_type', value);

  String? get sourceId => getField<String>('source_id');
  set sourceId(String? value) => setField<String>('source_id', value);

  String? get channel => getField<String>('channel');
  set channel(String? value) => setField<String>('channel', value);

  String? get message => getField<String>('message');
  set message(String? value) => setField<String>('message', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get externalId => getField<String>('external_id');
  set externalId(String? value) => setField<String>('external_id', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  int? get retryCount => getField<int>('retry_count');
  set retryCount(int? value) => setField<int>('retry_count', value);

  int? get maxRetries => getField<int>('max_retries');
  set maxRetries(int? value) => setField<int>('max_retries', value);

  DateTime? get nextRetryAt => getField<DateTime>('next_retry_at');
  set nextRetryAt(DateTime? value) =>
      setField<DateTime>('next_retry_at', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
