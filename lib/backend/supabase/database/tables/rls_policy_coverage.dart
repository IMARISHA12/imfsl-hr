import '../database.dart';

class RlsPolicyCoverageTable extends SupabaseTable<RlsPolicyCoverageRow> {
  @override
  String get tableName => 'rls_policy_coverage';

  @override
  RlsPolicyCoverageRow createRow(Map<String, dynamic> data) =>
      RlsPolicyCoverageRow(data);
}

class RlsPolicyCoverageRow extends SupabaseDataRow {
  RlsPolicyCoverageRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RlsPolicyCoverageTable();

  String? get schemaName => getField<String>('schema_name');
  set schemaName(String? value) => setField<String>('schema_name', value);

  String? get tableNameField => getField<String>('table_name');
  set tableNameField(String? value) => setField<String>('table_name', value);

  bool? get rlsEnabled => getField<bool>('rls_enabled');
  set rlsEnabled(bool? value) => setField<bool>('rls_enabled', value);

  bool? get rlsForced => getField<bool>('rls_forced');
  set rlsForced(bool? value) => setField<bool>('rls_forced', value);

  int? get policyCount => getField<int>('policy_count');
  set policyCount(int? value) => setField<int>('policy_count', value);

  List<String> get commandsCovered => getListField<String>('commands_covered');
  set commandsCovered(List<String>? value) =>
      setListField<String>('commands_covered', value);

  List<String> get missingOperations =>
      getListField<String>('missing_operations');
  set missingOperations(List<String>? value) =>
      setListField<String>('missing_operations', value);

  String? get securityStatus => getField<String>('security_status');
  set securityStatus(String? value) =>
      setField<String>('security_status', value);

  int? get priorityScore => getField<int>('priority_score');
  set priorityScore(int? value) => setField<int>('priority_score', value);
}
