import '../database.dart';

class GovernanceRoleAuditTable extends SupabaseTable<GovernanceRoleAuditRow> {
  @override
  String get tableName => 'governance_role_audit';

  @override
  GovernanceRoleAuditRow createRow(Map<String, dynamic> data) =>
      GovernanceRoleAuditRow(data);
}

class GovernanceRoleAuditRow extends SupabaseDataRow {
  GovernanceRoleAuditRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GovernanceRoleAuditTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String? get grantedBy => getField<String>('granted_by');
  set grantedBy(String? value) => setField<String>('granted_by', value);

  DateTime? get oldExpiresAt => getField<DateTime>('old_expires_at');
  set oldExpiresAt(DateTime? value) =>
      setField<DateTime>('old_expires_at', value);

  DateTime? get newExpiresAt => getField<DateTime>('new_expires_at');
  set newExpiresAt(DateTime? value) =>
      setField<DateTime>('new_expires_at', value);

  bool? get isActiveBefore => getField<bool>('is_active_before');
  set isActiveBefore(bool? value) => setField<bool>('is_active_before', value);

  bool? get isActiveAfter => getField<bool>('is_active_after');
  set isActiveAfter(bool? value) => setField<bool>('is_active_after', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
