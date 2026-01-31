import '../database.dart';

class BranchMembersTable extends SupabaseTable<BranchMembersRow> {
  @override
  String get tableName => 'branch_members';

  @override
  BranchMembersRow createRow(Map<String, dynamic> data) =>
      BranchMembersRow(data);
}

class BranchMembersRow extends SupabaseDataRow {
  BranchMembersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BranchMembersTable();

  String get branchId => getField<String>('branch_id')!;
  set branchId(String value) => setField<String>('branch_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
