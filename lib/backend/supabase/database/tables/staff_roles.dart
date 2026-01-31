import '../database.dart';

class StaffRolesTable extends SupabaseTable<StaffRolesRow> {
  @override
  String get tableName => 'staff_roles';

  @override
  StaffRolesRow createRow(Map<String, dynamic> data) => StaffRolesRow(data);
}

class StaffRolesRow extends SupabaseDataRow {
  StaffRolesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffRolesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  String get roleId => getField<String>('role_id')!;
  set roleId(String value) => setField<String>('role_id', value);

  DateTime get assignedAt => getField<DateTime>('assigned_at')!;
  set assignedAt(DateTime value) => setField<DateTime>('assigned_at', value);

  String? get assignedBy => getField<String>('assigned_by');
  set assignedBy(String? value) => setField<String>('assigned_by', value);
}
