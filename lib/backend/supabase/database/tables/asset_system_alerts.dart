import '../database.dart';

class AssetSystemAlertsTable
    extends SupabaseTable<AssetSystemAlertsRow> {
  @override
  String get tableName => 'asset_system_alerts';

  @override
  AssetSystemAlertsRow createRow(Map<String, dynamic> data) =>
      AssetSystemAlertsRow(data);
}

class AssetSystemAlertsRow extends SupabaseDataRow {
  AssetSystemAlertsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AssetSystemAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get alertSource => getField<String>('alert_source')!;
  set alertSource(String value) =>
      setField<String>('alert_source', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get message => getField<String>('message')!;
  set message(String value) => setField<String>('message', value);

  String? get entityType => getField<String>('entity_type');
  set entityType(String? value) =>
      setField<String>('entity_type', value);

  String? get entityId => getField<String>('entity_id');
  set entityId(String? value) => setField<String>('entity_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get acknowledgedBy => getField<String>('acknowledged_by');
  set acknowledgedBy(String? value) =>
      setField<String>('acknowledged_by', value);

  DateTime? get acknowledgedAt =>
      getField<DateTime>('acknowledged_at');
  set acknowledgedAt(DateTime? value) =>
      setField<DateTime>('acknowledged_at', value);

  String? get resolvedBy => getField<String>('resolved_by');
  set resolvedBy(String? value) =>
      setField<String>('resolved_by', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) =>
      setField<DateTime>('resolved_at', value);

  String? get resolutionNotes =>
      getField<String>('resolution_notes');
  set resolutionNotes(String? value) =>
      setField<String>('resolution_notes', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) =>
      setField<DateTime>('created_at', value);
}
