import '../database.dart';

class ZArchivePiiFieldMappingsTable
    extends SupabaseTable<ZArchivePiiFieldMappingsRow> {
  @override
  String get tableName => 'z_archive_pii_field_mappings';

  @override
  ZArchivePiiFieldMappingsRow createRow(Map<String, dynamic> data) =>
      ZArchivePiiFieldMappingsRow(data);
}

class ZArchivePiiFieldMappingsRow extends SupabaseDataRow {
  ZArchivePiiFieldMappingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchivePiiFieldMappingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get integrationType => getField<String>('integration_type')!;
  set integrationType(String value) =>
      setField<String>('integration_type', value);

  String get entityType => getField<String>('entity_type')!;
  set entityType(String value) => setField<String>('entity_type', value);

  String get internalField => getField<String>('internal_field')!;
  set internalField(String value) => setField<String>('internal_field', value);

  String? get externalField => getField<String>('external_field');
  set externalField(String? value) => setField<String>('external_field', value);

  bool? get isPii => getField<bool>('is_pii');
  set isPii(bool? value) => setField<bool>('is_pii', value);

  bool? get isRequired => getField<bool>('is_required');
  set isRequired(bool? value) => setField<bool>('is_required', value);

  bool? get sendToExternal => getField<bool>('send_to_external');
  set sendToExternal(bool? value) => setField<bool>('send_to_external', value);

  String? get maskingRule => getField<String>('masking_rule');
  set maskingRule(String? value) => setField<String>('masking_rule', value);

  int? get retentionDays => getField<int>('retention_days');
  set retentionDays(int? value) => setField<int>('retention_days', value);

  String? get complianceNotes => getField<String>('compliance_notes');
  set complianceNotes(String? value) =>
      setField<String>('compliance_notes', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
