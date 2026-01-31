import '../database.dart';

class FeatureDefinitionsTable extends SupabaseTable<FeatureDefinitionsRow> {
  @override
  String get tableName => 'feature_definitions';

  @override
  FeatureDefinitionsRow createRow(Map<String, dynamic> data) =>
      FeatureDefinitionsRow(data);
}

class FeatureDefinitionsRow extends SupabaseDataRow {
  FeatureDefinitionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FeatureDefinitionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get featureName => getField<String>('feature_name')!;
  set featureName(String value) => setField<String>('feature_name', value);

  String get sourceTable => getField<String>('source_table')!;
  set sourceTable(String value) => setField<String>('source_table', value);

  String get sourceColumn => getField<String>('source_column')!;
  set sourceColumn(String value) => setField<String>('source_column', value);

  String? get transform => getField<String>('transform');
  set transform(String? value) => setField<String>('transform', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String? get freshness => getField<String>('freshness');
  set freshness(String? value) => setField<String>('freshness', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  String get tenantId => getField<String>('tenant_id')!;
  set tenantId(String value) => setField<String>('tenant_id', value);
}
