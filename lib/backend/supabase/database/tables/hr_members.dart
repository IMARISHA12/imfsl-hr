import '../database.dart';

class HrMembersTable extends SupabaseTable<HrMembersRow> {
  @override
  String get tableName => 'hr_members';

  @override
  HrMembersRow createRow(Map<String, dynamic> data) => HrMembersRow(data);
}

class HrMembersRow extends SupabaseDataRow {
  HrMembersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => HrMembersTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);
}
