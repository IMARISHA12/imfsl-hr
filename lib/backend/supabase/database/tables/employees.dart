import '../database.dart';

class EmployeesTable extends SupabaseTable<EmployeesRow> {
  @override
  String get tableName => 'employees';

  @override
  EmployeesRow createRow(Map<String, dynamic> data) => EmployeesRow(data);
}

class EmployeesRow extends SupabaseDataRow {
  EmployeesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmployeesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get employeeCode => getField<String>('employee_code')!;
  set employeeCode(String value) => setField<String>('employee_code', value);

  String get fullName => getField<String>('full_name')!;
  set fullName(String value) => setField<String>('full_name', value);

  String get email => getField<String>('email')!;
  set email(String value) => setField<String>('email', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  String get dept => getField<String>('dept')!;
  set dept(String value) => setField<String>('dept', value);

  String get branch => getField<String>('branch')!;
  set branch(String value) => setField<String>('branch', value);

  String? get position => getField<String>('position');
  set position(String? value) => setField<String>('position', value);

  String? get managerEmail => getField<String>('manager_email');
  set managerEmail(String? value) => setField<String>('manager_email', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get hireDate => getField<DateTime>('hire_date');
  set hireDate(DateTime? value) => setField<DateTime>('hire_date', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get educationLevel => getField<String>('education_level');
  set educationLevel(String? value) =>
      setField<String>('education_level', value);

  String? get nationalId => getField<String>('national_id');
  set nationalId(String? value) => setField<String>('national_id', value);

  String? get nextOfKinName => getField<String>('next_of_kin_name');
  set nextOfKinName(String? value) =>
      setField<String>('next_of_kin_name', value);

  String? get nextOfKinPhone => getField<String>('next_of_kin_phone');
  set nextOfKinPhone(String? value) =>
      setField<String>('next_of_kin_phone', value);

  String? get cvUrl => getField<String>('cv_url');
  set cvUrl(String? value) => setField<String>('cv_url', value);

  String? get idScanUrl => getField<String>('id_scan_url');
  set idScanUrl(String? value) => setField<String>('id_scan_url', value);

  String? get phone => getField<String>('phone');
  set phone(String? value) => setField<String>('phone', value);

  DateTime? get dateOfBirth => getField<DateTime>('date_of_birth');
  set dateOfBirth(DateTime? value) =>
      setField<DateTime>('date_of_birth', value);

  String? get gender => getField<String>('gender');
  set gender(String? value) => setField<String>('gender', value);

  String? get maritalStatus => getField<String>('marital_status');
  set maritalStatus(String? value) => setField<String>('marital_status', value);

  String? get nationality => getField<String>('nationality');
  set nationality(String? value) => setField<String>('nationality', value);

  double? get salary => getField<double>('salary');
  set salary(double? value) => setField<double>('salary', value);

  String? get bankAccount => getField<String>('bank_account');
  set bankAccount(String? value) => setField<String>('bank_account', value);

  String? get bankName => getField<String>('bank_name');
  set bankName(String? value) => setField<String>('bank_name', value);

  String? get address => getField<String>('address');
  set address(String? value) => setField<String>('address', value);

  String? get emergencyContact => getField<String>('emergency_contact');
  set emergencyContact(String? value) =>
      setField<String>('emergency_contact', value);

  String? get emergencyPhone => getField<String>('emergency_phone');
  set emergencyPhone(String? value) =>
      setField<String>('emergency_phone', value);

  String? get jobPosition => getField<String>('job_position');
  set jobPosition(String? value) => setField<String>('job_position', value);

  String? get tinNo => getField<String>('tin_no');
  set tinNo(String? value) => setField<String>('tin_no', value);

  String get profileStatus => getField<String>('profile_status')!;
  set profileStatus(String value) => setField<String>('profile_status', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get tinNumber => getField<String>('tin_number');
  set tinNumber(String? value) => setField<String>('tin_number', value);

  String? get tin => getField<String>('tin');
  set tin(String? value) => setField<String>('tin', value);

  DateTime? get contractStartDate => getField<DateTime>('contract_start_date');
  set contractStartDate(DateTime? value) =>
      setField<DateTime>('contract_start_date', value);

  DateTime? get contractEndDate => getField<DateTime>('contract_end_date');
  set contractEndDate(DateTime? value) =>
      setField<DateTime>('contract_end_date', value);

  String? get nidaNumber => getField<String>('nida_number');
  set nidaNumber(String? value) => setField<String>('nida_number', value);

  String? get bankAccountNumber => getField<String>('bank_account_number');
  set bankAccountNumber(String? value) =>
      setField<String>('bank_account_number', value);

  String? get contractUrl => getField<String>('contract_url');
  set contractUrl(String? value) => setField<String>('contract_url', value);

  DateTime? get contractUploadDate =>
      getField<DateTime>('contract_upload_date');
  set contractUploadDate(DateTime? value) =>
      setField<DateTime>('contract_upload_date', value);

  DateTime? get contractExpiryDate =>
      getField<DateTime>('contract_expiry_date');
  set contractExpiryDate(DateTime? value) =>
      setField<DateTime>('contract_expiry_date', value);

  String? get bankAccountName => getField<String>('bank_account_name');
  set bankAccountName(String? value) =>
      setField<String>('bank_account_name', value);

  String? get idVerificationStatus =>
      getField<String>('id_verification_status');
  set idVerificationStatus(String? value) =>
      setField<String>('id_verification_status', value);

  DateTime? get idVerificationDate =>
      getField<DateTime>('id_verification_date');
  set idVerificationDate(DateTime? value) =>
      setField<DateTime>('id_verification_date', value);

  String? get idVerificationNotes => getField<String>('id_verification_notes');
  set idVerificationNotes(String? value) =>
      setField<String>('id_verification_notes', value);

  String? get nextOfKinRelationship =>
      getField<String>('next_of_kin_relationship');
  set nextOfKinRelationship(String? value) =>
      setField<String>('next_of_kin_relationship', value);

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

  int? get numberOfDependents => getField<int>('number_of_dependents');
  set numberOfDependents(int? value) =>
      setField<int>('number_of_dependents', value);

  int? get numberOfChildren => getField<int>('number_of_children');
  set numberOfChildren(int? value) =>
      setField<int>('number_of_children', value);

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

  int? get dependentsCount => getField<int>('dependents_count');
  set dependentsCount(int? value) => setField<int>('dependents_count', value);

  String get employmentStatus => getField<String>('employment_status')!;
  set employmentStatus(String value) =>
      setField<String>('employment_status', value);
}
