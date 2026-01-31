import '../database.dart';

class LegalChatConversationsTable
    extends SupabaseTable<LegalChatConversationsRow> {
  @override
  String get tableName => 'legal_chat_conversations';

  @override
  LegalChatConversationsRow createRow(Map<String, dynamic> data) =>
      LegalChatConversationsRow(data);
}

class LegalChatConversationsRow extends SupabaseDataRow {
  LegalChatConversationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalChatConversationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
