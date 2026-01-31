import '../database.dart';

class DuplicatePoliciesAnalysisTable
    extends SupabaseTable<DuplicatePoliciesAnalysisRow> {
  @override
  String get tableName => 'duplicate_policies_analysis';

  @override
  DuplicatePoliciesAnalysisRow createRow(Map<String, dynamic> data) =>
      DuplicatePoliciesAnalysisRow(data);
}

class DuplicatePoliciesAnalysisRow extends SupabaseDataRow {
  DuplicatePoliciesAnalysisRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DuplicatePoliciesAnalysisTable();

  String? get schemaName => getField<String>('schema_name');
  set schemaName(String? value) => setField<String>('schema_name', value);

  String? get tableNameField => getField<String>('table_name');
  set tableNameField(String? value) => setField<String>('table_name', value);

  String? get policyCmd => getField<String>('policy_cmd');
  set policyCmd(String? value) => setField<String>('policy_cmd', value);

  bool? get isPermissive => getField<bool>('is_permissive');
  set isPermissive(bool? value) => setField<bool>('is_permissive', value);

  int? get duplicateCount => getField<int>('duplicate_count');
  set duplicateCount(int? value) => setField<int>('duplicate_count', value);

  List<String> get policyNames => getListField<String>('policy_names');
  set policyNames(List<String>? value) =>
      setListField<String>('policy_names', value);

  String? get keepPolicy => getField<String>('keep_policy');
  set keepPolicy(String? value) => setField<String>('keep_policy', value);

  List<String> get dropPolicies => getListField<String>('drop_policies');
  set dropPolicies(List<String>? value) =>
      setListField<String>('drop_policies', value);

  String? get usingExpr => getField<String>('using_expr');
  set usingExpr(String? value) => setField<String>('using_expr', value);

  String? get withCheckExpr => getField<String>('with_check_expr');
  set withCheckExpr(String? value) =>
      setField<String>('with_check_expr', value);
}
