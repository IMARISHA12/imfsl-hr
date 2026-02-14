import '../database.dart';

class FineractSyncRunsTable extends SupabaseTable<FineractSyncRunsRow> {
  @override
  String get tableName => 'fineract_sync_runs';

  @override
  FineractSyncRunsRow createRow(Map<String, dynamic> data) =>
      FineractSyncRunsRow(data);
}

class FineractSyncRunsRow extends SupabaseDataRow {
  FineractSyncRunsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FineractSyncRunsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get integrationId => getField<String>('integration_id')!;
  set integrationId(String value) => setField<String>('integration_id', value);

  String get runType => getField<String>('run_type')!;
  set runType(String value) => setField<String>('run_type', value);

  DateTime get startedAt => getField<DateTime>('started_at')!;
  set startedAt(DateTime value) => setField<DateTime>('started_at', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  int? get recordsFetched => getField<int>('records_fetched');
  set recordsFetched(int? value) => setField<int>('records_fetched', value);

  int? get recordsCreated => getField<int>('records_created');
  set recordsCreated(int? value) => setField<int>('records_created', value);

  int? get recordsUpdated => getField<int>('records_updated');
  set recordsUpdated(int? value) => setField<int>('records_updated', value);

  int? get recordsSkipped => getField<int>('records_skipped');
  set recordsSkipped(int? value) => setField<int>('records_skipped', value);

  int? get recordsFailed => getField<int>('records_failed');
  set recordsFailed(int? value) => setField<int>('records_failed', value);

  DateTime? get syncFromDate => getField<DateTime>('sync_from_date');
  set syncFromDate(DateTime? value) =>
      setField<DateTime>('sync_from_date', value);

  DateTime? get syncToDate => getField<DateTime>('sync_to_date');
  set syncToDate(DateTime? value) => setField<DateTime>('sync_to_date', value);

  List<String> get entityTypes => getListField<String>('entity_types');
  set entityTypes(List<String>? value) =>
      setListField<String>('entity_types', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  dynamic get errorDetails => getField<dynamic>('error_details');
  set errorDetails(dynamic value) => setField<dynamic>('error_details', value);

  int? get retryCount => getField<int>('retry_count');
  set retryCount(int? value) => setField<int>('retry_count', value);

  String? get triggeredBy => getField<String>('triggered_by');
  set triggeredBy(String? value) => setField<String>('triggered_by', value);

  String? get lastProcessedId => getField<String>('last_processed_id');
  set lastProcessedId(String? value) =>
      setField<String>('last_processed_id', value);

  dynamic get checkpointData => getField<dynamic>('checkpoint_data');
  set checkpointData(dynamic value) =>
      setField<dynamic>('checkpoint_data', value);
}
