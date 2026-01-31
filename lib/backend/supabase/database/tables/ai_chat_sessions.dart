import '../database.dart';

class AiChatSessionsTable extends SupabaseTable<AiChatSessionsRow> {
  @override
  String get tableName => 'ai_chat_sessions';

  @override
  AiChatSessionsRow createRow(Map<String, dynamic> data) =>
      AiChatSessionsRow(data);
}

class AiChatSessionsRow extends SupabaseDataRow {
  AiChatSessionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AiChatSessionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get sessionType => getField<String>('session_type');
  set sessionType(String? value) => setField<String>('session_type', value);

  dynamic get messages => getField<dynamic>('messages')!;
  set messages(dynamic value) => setField<dynamic>('messages', value);

  dynamic get contextData => getField<dynamic>('context_data');
  set contextData(dynamic value) => setField<dynamic>('context_data', value);

  DateTime? get startedAt => getField<DateTime>('started_at');
  set startedAt(DateTime? value) => setField<DateTime>('started_at', value);

  DateTime? get endedAt => getField<DateTime>('ended_at');
  set endedAt(DateTime? value) => setField<DateTime>('ended_at', value);

  int? get totalMessages => getField<int>('total_messages');
  set totalMessages(int? value) => setField<int>('total_messages', value);

  String? get aiModelUsed => getField<String>('ai_model_used');
  set aiModelUsed(String? value) => setField<String>('ai_model_used', value);

  String? get sessionSummary => getField<String>('session_summary');
  set sessionSummary(String? value) =>
      setField<String>('session_summary', value);
}
