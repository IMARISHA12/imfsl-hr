import '../database.dart';

class EmployeesSecureTable extends SupabaseTable<EmployeesSecureRow> {
  @override
  String get tableName => 'employees_secure';

  @override
  EmployeesSecureRow createRow(Map<String, dynamic> data) =>
      EmployeesSecureRow(data);
}

class EmployeesSecureRow extends SupabaseDataRow {
  EmployeesSecureRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmployeesSecureTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get employeeCode => getField<String>('employee_code');
  set employeeCode(String? value) => setField<String>('employee_code', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get phone => getField<String>('phone');
  set phone(String? value) => setField<String>('phone', value);

  String? get nationalId => getField<String>('national_id');
  set nationalId(String? value) => setField<String>('national_id', value);

  String? get bankAccount => getField<String>('bank_account');
  set bankAccount(String? value) => setField<String>('bank_account', value);

  String? get dept => getField<String>('dept');
  set dept(String? value) => setField<String>('dept', value);

  String? get position => getField<String>('position');
  set position(String? value) => setField<String>('position', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get hireDate => getField<DateTime>('hire_date');
  set hireDate(DateTime? value) => setField<DateTime>('hire_date', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get nidaNumber => getField<String>('nida_number');
  set nidaNumber(String? value) => setField<String>('nida_number', value);

  String? get maritalStatus => getField<String>('marital_status');
  set maritalStatus(String? value) => setField<String>('marital_status', value);

  int? get numberOfChildren => getField<int>('number_of_children');
  set numberOfChildren(int? value) =>
      setField<int>('number_of_children', value);

  int? get numberOfDependents => getField<int>('number_of_dependents');
  set numberOfDependents(int? value) =>
      setField<int>('number_of_dependents', value);

  String? get nextOfKinName => getField<String>('next_of_kin_name');
  set nextOfKinName(String? value) =>
      setField<String>('next_of_kin_name', value);

  String? get nextOfKinRelationship =>
      getField<String>('next_of_kin_relationship');
  set nextOfKinRelationship(String? value) =>
      setField<String>('next_of_kin_relationship', value);

  String? get nextOfKinPhone => getField<String>('next_of_kin_phone');
  set nextOfKinPhone(String? value) =>
      setField<String>('next_of_kin_phone', value);

  String? get nextOfKinAddress => getField<String>('next_of_kin_address');
  set nextOfKinAddress(String? value) =>
      setField<String>('next_of_kin_address', value);

  String? get healthInsuranceProvider =>
      getField<String>('health_insurance_provider');
  set healthInsuranceProvider(String? value) =>
      setField<String>('health_insurance_provider', value);

  String? get healthInsuranceCardNumber =>
      getField<String>('health_insurance_card_number');
  set healthInsuranceCardNumber(String? value) =>
      setField<String>('health_insurance_card_number', value);

  String? get preferredHospital => getField<String>('preferred_hospital');
  set preferredHospital(String? value) =>
      setField<String>('preferred_hospital', value);

  String? get bloodGroup => getField<String>('blood_group');
  set bloodGroup(String? value) => setField<String>('blood_group', value);

  int? get dependentsCount => getField<int>('dependents_count');
  set dependentsCount(int? value) => setField<int>('dependents_count', value);

  String? get nextOfKinRelation => getField<String>('next_of_kin_relation');
  set nextOfKinRelation(String? value) =>
      setField<String>('next_of_kin_relation', value);

  String? get medicalInsuranceProvider =>
      getField<String>('medical_insurance_provider');
  set medicalInsuranceProvider(String? value) =>
      setField<String>('medical_insurance_provider', value);

  String? get medicalCardNumber => getField<String>('medical_card_number');
  set medicalCardNumber(String? value) =>
      setField<String>('medical_card_number', value);
}
