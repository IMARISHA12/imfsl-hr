import '../database.dart';

class OrganizationMembersTable extends SupabaseTable<OrganizationMembersRow> {
  @override
  String get tableName => 'organization_members';

  @override
  OrganizationMembersRow createRow(Map<String, dynamic> data) =>
      OrganizationMembersRow(data);
}

class OrganizationMembersRow extends SupabaseDataRow {
  OrganizationMembersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OrganizationMembersTable();

  String get organizationId => getField<String>('organization_id')!;
  set organizationId(String value) =>
      setField<String>('organization_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
