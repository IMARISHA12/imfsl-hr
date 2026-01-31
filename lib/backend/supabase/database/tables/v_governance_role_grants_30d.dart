import '../database.dart';

class VGovernanceRoleGrants30dTable
    extends SupabaseTable<VGovernanceRoleGrants30dRow> {
  @override
  String get tableName => 'v_governance_role_grants_30d';

  @override
  VGovernanceRoleGrants30dRow createRow(Map<String, dynamic> data) =>
      VGovernanceRoleGrants30dRow(data);
}

class VGovernanceRoleGrants30dRow extends SupabaseDataRow {
  VGovernanceRoleGrants30dRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VGovernanceRoleGrants30dTable();

  String? get governanceRole => getField<String>('governance_role');
  set governanceRole(String? value) =>
      setField<String>('governance_role', value);

  DateTime? get grantDate => getField<DateTime>('grant_date');
  set grantDate(DateTime? value) => setField<DateTime>('grant_date', value);

  int? get grantsCount => getField<int>('grants_count');
  set grantsCount(int? value) => setField<int>('grants_count', value);
}
