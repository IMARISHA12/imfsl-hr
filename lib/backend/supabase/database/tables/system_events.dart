import '../database.dart';

class SystemEventsTable extends SupabaseTable<SystemEventsRow> {
  @override
  String get tableName => 'system_events';

  @override
  SystemEventsRow createRow(Map<String, dynamic> data) => SystemEventsRow(data);
}

class SystemEventsRow extends SupabaseDataRow {
  SystemEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SystemEventsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  String? get module => getField<String>('module');
  set module(String? value) => setField<String>('module', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get action => getField<String>('action');
  set action(String? value) => setField<String>('action', value);
}
