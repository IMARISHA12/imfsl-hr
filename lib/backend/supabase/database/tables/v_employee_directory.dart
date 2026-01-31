import '../database.dart';

class VEmployeeDirectoryTable extends SupabaseTable<VEmployeeDirectoryRow> {
  @override
  String get tableName => 'v_employee_directory';

  @override
  VEmployeeDirectoryRow createRow(Map<String, dynamic> data) =>
      VEmployeeDirectoryRow(data);
}

class VEmployeeDirectoryRow extends SupabaseDataRow {
  VEmployeeDirectoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VEmployeeDirectoryTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get employeeCode => getField<String>('employee_code');
  set employeeCode(String? value) => setField<String>('employee_code', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get position => getField<String>('position');
  set position(String? value) => setField<String>('position', value);

  String? get dept => getField<String>('dept');
  set dept(String? value) => setField<String>('dept', value);

  String? get branch => getField<String>('branch');
  set branch(String? value) => setField<String>('branch', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get hireDate => getField<DateTime>('hire_date');
  set hireDate(DateTime? value) => setField<DateTime>('hire_date', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);
}
