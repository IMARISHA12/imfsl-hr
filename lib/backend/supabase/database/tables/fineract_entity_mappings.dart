import '../database.dart';

class FineractEntityMappingsTable
    extends SupabaseTable<FineractEntityMappingsRow> {
  @override
  String get tableName => 'fineract_entity_mappings';

  @override
  FineractEntityMappingsRow createRow(Map<String, dynamic> data) =>
      FineractEntityMappingsRow(data);
}

class FineractEntityMappingsRow extends SupabaseDataRow {
  FineractEntityMappingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FineractEntityMappingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get integrationId => getField<String>('integration_id')!;
  set integrationId(String value) => setField<String>('integration_id', value);

  String get entityType => getField<String>('entity_type')!;
  set entityType(String value) => setField<String>('entity_type', value);

  String get fineractId => getField<String>('fineract_id')!;
  set fineractId(String value) => setField<String>('fineract_id', value);

  String get localId => getField<String>('local_id')!;
  set localId(String value) => setField<String>('local_id', value);

  String? get localTableName => getField<String>('local_table_name');
  set localTableName(String? value) =>
      setField<String>('local_table_name', value);

  DateTime? get lastSyncedAt => getField<DateTime>('last_synced_at');
  set lastSyncedAt(DateTime? value) =>
      setField<DateTime>('last_synced_at', value);

  String? get syncDirection => getField<String>('sync_direction');
  set syncDirection(String? value) =>
      setField<String>('sync_direction', value);

  dynamic get fineractData => getField<dynamic>('fineract_data');
  set fineractData(dynamic value) =>
      setField<dynamic>('fineract_data', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
