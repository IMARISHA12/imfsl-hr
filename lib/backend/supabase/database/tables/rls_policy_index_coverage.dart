import '../database.dart';

class RlsPolicyIndexCoverageTable
    extends SupabaseTable<RlsPolicyIndexCoverageRow> {
  @override
  String get tableName => 'rls_policy_index_coverage';

  @override
  RlsPolicyIndexCoverageRow createRow(Map<String, dynamic> data) =>
      RlsPolicyIndexCoverageRow(data);
}

class RlsPolicyIndexCoverageRow extends SupabaseDataRow {
  RlsPolicyIndexCoverageRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RlsPolicyIndexCoverageTable();

  String? get schemaName => getField<String>('schema_name');
  set schemaName(String? value) => setField<String>('schema_name', value);

  String? get tableNameField => getField<String>('table_name');
  set tableNameField(String? value) => setField<String>('table_name', value);

  String? get columnName => getField<String>('column_name');
  set columnName(String? value) => setField<String>('column_name', value);

  String? get indexStatus => getField<String>('index_status');
  set indexStatus(String? value) => setField<String>('index_status', value);

  String? get suggestedIndexName => getField<String>('suggested_index_name');
  set suggestedIndexName(String? value) =>
      setField<String>('suggested_index_name', value);

  int? get sortPriority => getField<int>('sort_priority');
  set sortPriority(int? value) => setField<int>('sort_priority', value);
}
