import '../database.dart';

class MyTenantsTable extends SupabaseTable<MyTenantsRow> {
  @override
  String get tableName => 'my_tenants';

  @override
  MyTenantsRow createRow(Map<String, dynamic> data) => MyTenantsRow(data);
}

class MyTenantsRow extends SupabaseDataRow {
  MyTenantsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MyTenantsTable();

  String? get tenantId => getField<String>('tenant_id');
  set tenantId(String? value) => setField<String>('tenant_id', value);

  String? get tenantName => getField<String>('tenant_name');
  set tenantName(String? value) => setField<String>('tenant_name', value);

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);

  DateTime? get memberSince => getField<DateTime>('member_since');
  set memberSince(DateTime? value) => setField<DateTime>('member_since', value);
}
