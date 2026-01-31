import '../database.dart';

class ZArchiveSystemEventsTable extends SupabaseTable<ZArchiveSystemEventsRow> {
  @override
  String get tableName => 'z_archive_system_events';

  @override
  ZArchiveSystemEventsRow createRow(Map<String, dynamic> data) =>
      ZArchiveSystemEventsRow(data);
}

class ZArchiveSystemEventsRow extends SupabaseDataRow {
  ZArchiveSystemEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveSystemEventsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get actorId => getField<String>('actor_id');
  set actorId(String? value) => setField<String>('actor_id', value);

  String get module => getField<String>('module')!;
  set module(String value) => setField<String>('module', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  dynamic get payloadJson => getField<dynamic>('payload_json');
  set payloadJson(dynamic value) => setField<dynamic>('payload_json', value);

  DateTime? get ts => getField<DateTime>('ts');
  set ts(DateTime? value) => setField<DateTime>('ts', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
