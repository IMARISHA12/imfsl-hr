import '../database.dart';

class VGovernanceSummaryTable extends SupabaseTable<VGovernanceSummaryRow> {
  @override
  String get tableName => 'v_governance_summary';

  @override
  VGovernanceSummaryRow createRow(Map<String, dynamic> data) =>
      VGovernanceSummaryRow(data);
}

class VGovernanceSummaryRow extends SupabaseDataRow {
  VGovernanceSummaryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VGovernanceSummaryTable();

  int? get usersWithActiveRoles => getField<int>('users_with_active_roles');
  set usersWithActiveRoles(int? value) =>
      setField<int>('users_with_active_roles', value);

  int? get activeRoleAssignments => getField<int>('active_role_assignments');
  set activeRoleAssignments(int? value) =>
      setField<int>('active_role_assignments', value);

  int? get totalRevokedAssignments =>
      getField<int>('total_revoked_assignments');
  set totalRevokedAssignments(int? value) =>
      setField<int>('total_revoked_assignments', value);

  int? get uniqueRolesInUse => getField<int>('unique_roles_in_use');
  set uniqueRolesInUse(int? value) =>
      setField<int>('unique_roles_in_use', value);

  int? get grantsLast7d => getField<int>('grants_last_7d');
  set grantsLast7d(int? value) => setField<int>('grants_last_7d', value);

  int? get grantsLast30d => getField<int>('grants_last_30d');
  set grantsLast30d(int? value) => setField<int>('grants_last_30d', value);
}
