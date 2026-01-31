import '../database.dart';

class PolicyCatalogTable extends SupabaseTable<PolicyCatalogRow> {
  @override
  String get tableName => 'policy_catalog';

  @override
  PolicyCatalogRow createRow(Map<String, dynamic> data) =>
      PolicyCatalogRow(data);
}

class PolicyCatalogRow extends SupabaseDataRow {
  PolicyCatalogRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PolicyCatalogTable();

  String? get schemaname => getField<String>('schemaname');
  set schemaname(String? value) => setField<String>('schemaname', value);

  String? get tablename => getField<String>('tablename');
  set tablename(String? value) => setField<String>('tablename', value);

  bool? get rlsEnabled => getField<bool>('rls_enabled');
  set rlsEnabled(bool? value) => setField<bool>('rls_enabled', value);

  int? get policyCount => getField<int>('policy_count');
  set policyCount(int? value) => setField<int>('policy_count', value);

  List<dynamic> get policies => getListField<dynamic>('policies');
  set policies(List<dynamic>? value) =>
      setListField<dynamic>('policies', value);
}
