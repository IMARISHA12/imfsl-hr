import '../database.dart';

class EnterprisePermissionsTable
    extends SupabaseTable<EnterprisePermissionsRow> {
  @override
  String get tableName => 'enterprise_permissions';

  @override
  EnterprisePermissionsRow createRow(Map<String, dynamic> data) =>
      EnterprisePermissionsRow(data);
}

class EnterprisePermissionsRow extends SupabaseDataRow {
  EnterprisePermissionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EnterprisePermissionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  String get module => getField<String>('module')!;
  set module(String value) => setField<String>('module', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  bool? get isSensitive => getField<bool>('is_sensitive');
  set isSensitive(bool? value) => setField<bool>('is_sensitive', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
