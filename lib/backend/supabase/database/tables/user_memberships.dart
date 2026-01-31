import '../database.dart';

class UserMembershipsTable extends SupabaseTable<UserMembershipsRow> {
  @override
  String get tableName => 'user_memberships';

  @override
  UserMembershipsRow createRow(Map<String, dynamic> data) =>
      UserMembershipsRow(data);
}

class UserMembershipsRow extends SupabaseDataRow {
  UserMembershipsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserMembershipsTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get organizationId => getField<String>('organization_id')!;
  set organizationId(String value) =>
      setField<String>('organization_id', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
