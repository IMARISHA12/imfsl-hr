import '../database.dart';

class FineractSyncItemsTable extends SupabaseTable<FineractSyncItemsRow> {
  @override
  String get tableName => 'fineract_sync_items';

  @override
  FineractSyncItemsRow createRow(Map<String, dynamic> data) =>
      FineractSyncItemsRow(data);
}

class FineractSyncItemsRow extends SupabaseDataRow {
  FineractSyncItemsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FineractSyncItemsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get syncRunId => getField<String>('sync_run_id')!;
  set syncRunId(String value) => setField<String>('sync_run_id', value);

  String get entityType => getField<String>('entity_type')!;
  set entityType(String value) => setField<String>('entity_type', value);

  String get externalId => getField<String>('external_id')!;
  set externalId(String value) => setField<String>('external_id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String? get localId => getField<String>('local_id');
  set localId(String? value) => setField<String>('local_id', value);

  dynamic get sourceData => getField<dynamic>('source_data');
  set sourceData(dynamic value) => setField<dynamic>('source_data', value);

  dynamic get transformedData => getField<dynamic>('transformed_data');
  set transformedData(dynamic value) =>
      setField<dynamic>('transformed_data', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  DateTime get syncedAt => getField<DateTime>('synced_at')!;
  set syncedAt(DateTime value) => setField<DateTime>('synced_at', value);
}
