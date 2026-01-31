import '../database.dart';

class VGovernanceTopUsersTable extends SupabaseTable<VGovernanceTopUsersRow> {
  @override
  String get tableName => 'v_governance_top_users';

  @override
  VGovernanceTopUsersRow createRow(Map<String, dynamic> data) =>
      VGovernanceTopUsersRow(data);
}

class VGovernanceTopUsersRow extends SupabaseDataRow {
  VGovernanceTopUsersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VGovernanceTopUsersTable();

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  int? get activeRolesCount => getField<int>('active_roles_count');
  set activeRolesCount(int? value) =>
      setField<int>('active_roles_count', value);

  List<String> get roles => getListField<String>('roles');
  set roles(List<String>? value) => setListField<String>('roles', value);

  DateTime? get firstRoleGranted => getField<DateTime>('first_role_granted');
  set firstRoleGranted(DateTime? value) =>
      setField<DateTime>('first_role_granted', value);

  DateTime? get latestRoleGranted => getField<DateTime>('latest_role_granted');
  set latestRoleGranted(DateTime? value) =>
      setField<DateTime>('latest_role_granted', value);
}
