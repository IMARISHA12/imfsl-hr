import '../database.dart';

class UserGovernanceRolesTable extends SupabaseTable<UserGovernanceRolesRow> {
  @override
  String get tableName => 'user_governance_roles';

  @override
  UserGovernanceRolesRow createRow(Map<String, dynamic> data) =>
      UserGovernanceRolesRow(data);
}

class UserGovernanceRolesRow extends SupabaseDataRow {
  UserGovernanceRolesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserGovernanceRolesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  String? get grantedBy => getField<String>('granted_by');
  set grantedBy(String? value) => setField<String>('granted_by', value);

  DateTime? get grantedAt => getField<DateTime>('granted_at');
  set grantedAt(DateTime? value) => setField<DateTime>('granted_at', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get revokedAt => getField<DateTime>('revoked_at');
  set revokedAt(DateTime? value) => setField<DateTime>('revoked_at', value);

  String? get revokedBy => getField<String>('revoked_by');
  set revokedBy(String? value) => setField<String>('revoked_by', value);

  String? get assignedBy => getField<String>('assigned_by');
  set assignedBy(String? value) => setField<String>('assigned_by', value);
}
