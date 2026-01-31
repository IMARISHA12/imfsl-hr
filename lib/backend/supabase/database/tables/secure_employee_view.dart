import '../database.dart';

class SecureEmployeeViewTable extends SupabaseTable<SecureEmployeeViewRow> {
  @override
  String get tableName => 'secure_employee_view';

  @override
  SecureEmployeeViewRow createRow(Map<String, dynamic> data) =>
      SecureEmployeeViewRow(data);
}

class SecureEmployeeViewRow extends SupabaseDataRow {
  SecureEmployeeViewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SecureEmployeeViewTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get employeeId => getField<String>('employee_id');
  set employeeId(String? value) => setField<String>('employee_id', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get jobTitle => getField<String>('job_title');
  set jobTitle(String? value) => setField<String>('job_title', value);

  String? get department => getField<String>('department');
  set department(String? value) => setField<String>('department', value);

  String? get departmentId => getField<String>('department_id');
  set departmentId(String? value) => setField<String>('department_id', value);

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  String? get employmentType => getField<String>('employment_type');
  set employmentType(String? value) =>
      setField<String>('employment_type', value);

  String? get profileStatus => getField<String>('profile_status');
  set profileStatus(String? value) => setField<String>('profile_status', value);

  DateTime? get joiningDate => getField<DateTime>('joining_date');
  set joiningDate(DateTime? value) => setField<DateTime>('joining_date', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  String? get nidaNumber => getField<String>('nida_number');
  set nidaNumber(String? value) => setField<String>('nida_number', value);

  String? get tinNumber => getField<String>('tin_number');
  set tinNumber(String? value) => setField<String>('tin_number', value);

  String? get bankAccountNumber => getField<String>('bank_account_number');
  set bankAccountNumber(String? value) =>
      setField<String>('bank_account_number', value);

  String? get nextOfKinName => getField<String>('next_of_kin_name');
  set nextOfKinName(String? value) =>
      setField<String>('next_of_kin_name', value);

  String? get nextOfKinContact => getField<String>('next_of_kin_contact');
  set nextOfKinContact(String? value) =>
      setField<String>('next_of_kin_contact', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
