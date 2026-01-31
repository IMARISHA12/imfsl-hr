import '../database.dart';

class LegalChatMessagesTable extends SupabaseTable<LegalChatMessagesRow> {
  @override
  String get tableName => 'legal_chat_messages';

  @override
  LegalChatMessagesRow createRow(Map<String, dynamic> data) =>
      LegalChatMessagesRow(data);
}

class LegalChatMessagesRow extends SupabaseDataRow {
  LegalChatMessagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalChatMessagesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get conversationId => getField<String>('conversation_id')!;
  set conversationId(String value) =>
      setField<String>('conversation_id', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
