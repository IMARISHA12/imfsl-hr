import '../database.dart';

class RoomMessagesTable extends SupabaseTable<RoomMessagesRow> {
  @override
  String get tableName => 'room_messages';

  @override
  RoomMessagesRow createRow(Map<String, dynamic> data) => RoomMessagesRow(data);
}

class RoomMessagesRow extends SupabaseDataRow {
  RoomMessagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RoomMessagesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get topic => getField<String>('topic')!;
  set topic(String value) => setField<String>('topic', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
