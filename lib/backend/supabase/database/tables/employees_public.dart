import '../database.dart';

class EmployeesPublicTable extends SupabaseTable<EmployeesPublicRow> {
  @override
  String get tableName => 'employees_public';

  @override
  EmployeesPublicRow createRow(Map<String, dynamic> data) =>
      EmployeesPublicRow(data);
}

class EmployeesPublicRow extends SupabaseDataRow {
  EmployeesPublicRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmployeesPublicTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get employeeCode => getField<String>('employee_code');
  set employeeCode(String? value) => setField<String>('employee_code', value);

  String? get dept => getField<String>('dept');
  set dept(String? value) => setField<String>('dept', value);

  String? get position => getField<String>('position');
  set position(String? value) => setField<String>('position', value);

  String? get branch => getField<String>('branch');
  set branch(String? value) => setField<String>('branch', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get hireDate => getField<DateTime>('hire_date');
  set hireDate(DateTime? value) => setField<DateTime>('hire_date', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
