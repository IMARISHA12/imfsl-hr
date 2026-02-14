import '../database.dart';

class HrNotificationsTable extends SupabaseTable<HrNotificationsRow> {
  @override
  String get tableName => 'hr_notifications';

  @override
  HrNotificationsRow createRow(Map<String, dynamic> data) =>
      HrNotificationsRow(data);
}

class HrNotificationsRow extends SupabaseDataRow {
  HrNotificationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => HrNotificationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get recipientUserId => getField<String>('recipient_user_id');
  set recipientUserId(String? value) =>
      setField<String>('recipient_user_id', value);

  String? get recipientRole => getField<String>('recipient_role');
  set recipientRole(String? value) =>
      setField<String>('recipient_role', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get body => getField<String>('body');
  set body(String? value) => setField<String>('body', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  bool get isRead => getField<bool>('is_read')!;
  set isRead(bool value) => setField<bool>('is_read', value);

  DateTime? get readAt => getField<DateTime>('read_at');
  set readAt(DateTime? value) => setField<DateTime>('read_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
