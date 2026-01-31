import '../database.dart';

class GovernanceRoleConflictsTable
    extends SupabaseTable<GovernanceRoleConflictsRow> {
  @override
  String get tableName => 'governance_role_conflicts';

  @override
  GovernanceRoleConflictsRow createRow(Map<String, dynamic> data) =>
      GovernanceRoleConflictsRow(data);
}

class GovernanceRoleConflictsRow extends SupabaseDataRow {
  GovernanceRoleConflictsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GovernanceRoleConflictsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get roleA => getField<String>('role_a')!;
  set roleA(String value) => setField<String>('role_a', value);

  String get roleB => getField<String>('role_b')!;
  set roleB(String value) => setField<String>('role_b', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
