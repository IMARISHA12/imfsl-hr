import '../database.dart';

class AccessControlChangesTable extends SupabaseTable<AccessControlChangesRow> {
  @override
  String get tableName => 'access_control_changes';

  @override
  AccessControlChangesRow createRow(Map<String, dynamic> data) =>
      AccessControlChangesRow(data);
}

class AccessControlChangesRow extends SupabaseDataRow {
  AccessControlChangesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AccessControlChangesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get changeType => getField<String>('change_type')!;
  set changeType(String value) => setField<String>('change_type', value);

  String get targetUserId => getField<String>('target_user_id')!;
  set targetUserId(String value) => setField<String>('target_user_id', value);

  String? get oldRole => getField<String>('old_role');
  set oldRole(String? value) => setField<String>('old_role', value);

  String? get newRole => getField<String>('new_role');
  set newRole(String? value) => setField<String>('new_role', value);

  dynamic get oldPermissions => getField<dynamic>('old_permissions');
  set oldPermissions(dynamic value) =>
      setField<dynamic>('old_permissions', value);

  dynamic get newPermissions => getField<dynamic>('new_permissions');
  set newPermissions(dynamic value) =>
      setField<dynamic>('new_permissions', value);

  String get changedBy => getField<String>('changed_by')!;
  set changedBy(String value) => setField<String>('changed_by', value);

  String? get changeReason => getField<String>('change_reason');
  set changeReason(String? value) => setField<String>('change_reason', value);

  bool? get requiresApproval => getField<bool>('requires_approval');
  set requiresApproval(bool? value) =>
      setField<bool>('requires_approval', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  DateTime? get occurredAt => getField<DateTime>('occurred_at');
  set occurredAt(DateTime? value) => setField<DateTime>('occurred_at', value);
}
