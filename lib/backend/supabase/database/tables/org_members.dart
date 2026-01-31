import '../database.dart';

class OrgMembersTable extends SupabaseTable<OrgMembersRow> {
  @override
  String get tableName => 'org_members';

  @override
  OrgMembersRow createRow(Map<String, dynamic> data) => OrgMembersRow(data);
}

class OrgMembersRow extends SupabaseDataRow {
  OrgMembersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OrgMembersTable();

  String get orgId => getField<String>('org_id')!;
  set orgId(String value) => setField<String>('org_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
