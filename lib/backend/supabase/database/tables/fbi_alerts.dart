import '../database.dart';

class FbiAlertsTable extends SupabaseTable<FbiAlertsRow> {
  @override
  String get tableName => 'fbi_alerts';

  @override
  FbiAlertsRow createRow(Map<String, dynamic> data) => FbiAlertsRow(data);
}

class FbiAlertsRow extends SupabaseDataRow {
  FbiAlertsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FbiAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String? get source => getField<String>('source');
  set source(String? value) => setField<String>('source', value);

  String? get affectedUserId => getField<String>('affected_user_id');
  set affectedUserId(String? value) =>
      setField<String>('affected_user_id', value);

  String? get affectedResource => getField<String>('affected_resource');
  set affectedResource(String? value) =>
      setField<String>('affected_resource', value);

  String? get branch => getField<String>('branch');
  set branch(String? value) => setField<String>('branch', value);

  String? get locationHint => getField<String>('location_hint');
  set locationHint(String? value) => setField<String>('location_hint', value);

  DateTime get occurredAt => getField<DateTime>('occurred_at')!;
  set occurredAt(DateTime value) => setField<DateTime>('occurred_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
