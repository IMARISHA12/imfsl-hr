import '../database.dart';

class ServiceRequestMessagesTable
    extends SupabaseTable<ServiceRequestMessagesRow> {
  @override
  String get tableName => 'service_request_messages';

  @override
  ServiceRequestMessagesRow createRow(Map<String, dynamic> data) =>
      ServiceRequestMessagesRow(data);
}

class ServiceRequestMessagesRow extends SupabaseDataRow {
  ServiceRequestMessagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ServiceRequestMessagesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get requestId => getField<String>('request_id')!;
  set requestId(String value) => setField<String>('request_id', value);

  String? get senderId => getField<String>('sender_id');
  set senderId(String? value) => setField<String>('sender_id', value);

  String get senderType => getField<String>('sender_type')!;
  set senderType(String value) => setField<String>('sender_type', value);

  String get message => getField<String>('message')!;
  set message(String value) => setField<String>('message', value);

  dynamic get attachments => getField<dynamic>('attachments');
  set attachments(dynamic value) => setField<dynamic>('attachments', value);

  bool? get isInternal => getField<bool>('is_internal');
  set isInternal(bool? value) => setField<bool>('is_internal', value);

  DateTime? get readAt => getField<DateTime>('read_at');
  set readAt(DateTime? value) => setField<DateTime>('read_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
