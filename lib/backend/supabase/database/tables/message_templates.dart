import '../database.dart';

class MessageTemplatesTable extends SupabaseTable<MessageTemplatesRow> {
  @override
  String get tableName => 'message_templates';

  @override
  MessageTemplatesRow createRow(Map<String, dynamic> data) =>
      MessageTemplatesRow(data);
}

class MessageTemplatesRow extends SupabaseDataRow {
  MessageTemplatesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MessageTemplatesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get channel => getField<String>('channel')!;
  set channel(String value) => setField<String>('channel', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String? get subject => getField<String>('subject');
  set subject(String? value) => setField<String>('subject', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  List<String> get variables => getListField<String>('variables');
  set variables(List<String>? value) =>
      setListField<String>('variables', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  bool get isSystem => getField<bool>('is_system')!;
  set isSystem(bool value) => setField<bool>('is_system', value);

  int get usageCount => getField<int>('usage_count')!;
  set usageCount(int value) => setField<int>('usage_count', value);

  DateTime? get lastUsedAt => getField<DateTime>('last_used_at');
  set lastUsedAt(DateTime? value) => setField<DateTime>('last_used_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
