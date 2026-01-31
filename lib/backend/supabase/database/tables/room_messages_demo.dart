import '../database.dart';

class RoomMessagesDemoTable extends SupabaseTable<RoomMessagesDemoRow> {
  @override
  String get tableName => 'room_messages_demo';

  @override
  RoomMessagesDemoRow createRow(Map<String, dynamic> data) =>
      RoomMessagesDemoRow(data);
}

class RoomMessagesDemoRow extends SupabaseDataRow {
  RoomMessagesDemoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RoomMessagesDemoTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get topic => getField<String>('topic')!;
  set topic(String value) => setField<String>('topic', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
