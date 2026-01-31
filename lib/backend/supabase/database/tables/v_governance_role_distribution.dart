import '../database.dart';

class VGovernanceRoleDistributionTable
    extends SupabaseTable<VGovernanceRoleDistributionRow> {
  @override
  String get tableName => 'v_governance_role_distribution';

  @override
  VGovernanceRoleDistributionRow createRow(Map<String, dynamic> data) =>
      VGovernanceRoleDistributionRow(data);
}

class VGovernanceRoleDistributionRow extends SupabaseDataRow {
  VGovernanceRoleDistributionRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VGovernanceRoleDistributionTable();

  String? get governanceRole => getField<String>('governance_role');
  set governanceRole(String? value) =>
      setField<String>('governance_role', value);

  int? get activeUsers => getField<int>('active_users');
  set activeUsers(int? value) => setField<int>('active_users', value);

  int? get totalAssignments => getField<int>('total_assignments');
  set totalAssignments(int? value) => setField<int>('total_assignments', value);

  int? get inactiveCount => getField<int>('inactive_count');
  set inactiveCount(int? value) => setField<int>('inactive_count', value);
}
