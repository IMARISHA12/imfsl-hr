import '../database.dart';

class StaffTable extends SupabaseTable<StaffRow> {
  @override
  String get tableName => 'staff';

  @override
  StaffRow createRow(Map<String, dynamic> data) => StaffRow(data);
}

class StaffRow extends SupabaseDataRow {
  StaffRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  bool get active => getField<bool>('active')!;
  set active(bool value) => setField<bool>('active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);

  String? get profilePhotoUrl => getField<String>('profile_photo_url');
  set profilePhotoUrl(String? value) =>
      setField<String>('profile_photo_url', value);

  String? get phone => getField<String>('phone');
  set phone(String? value) => setField<String>('phone', value);

  String? get address => getField<String>('address');
  set address(String? value) => setField<String>('address', value);

  DateTime? get dateOfBirth => getField<DateTime>('date_of_birth');
  set dateOfBirth(DateTime? value) =>
      setField<DateTime>('date_of_birth', value);

  String? get gender => getField<String>('gender');
  set gender(String? value) => setField<String>('gender', value);

  String? get nationalId => getField<String>('national_id');
  set nationalId(String? value) => setField<String>('national_id', value);

  String? get position => getField<String>('position');
  set position(String? value) => setField<String>('position', value);

  String? get department => getField<String>('department');
  set department(String? value) => setField<String>('department', value);

  String? get branch => getField<String>('branch');
  set branch(String? value) => setField<String>('branch', value);

  DateTime? get hireDate => getField<DateTime>('hire_date');
  set hireDate(DateTime? value) => setField<DateTime>('hire_date', value);

  String? get contractType => getField<String>('contract_type');
  set contractType(String? value) => setField<String>('contract_type', value);

  String? get employmentStatus => getField<String>('employment_status');
  set employmentStatus(String? value) =>
      setField<String>('employment_status', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  bool? get onboardingComplete => getField<bool>('onboarding_complete');
  set onboardingComplete(bool? value) =>
      setField<bool>('onboarding_complete', value);

  String? get maritalStatus => getField<String>('marital_status');
  set maritalStatus(String? value) => setField<String>('marital_status', value);

  String? get nationality => getField<String>('nationality');
  set nationality(String? value) => setField<String>('nationality', value);

  String? get tinNumber => getField<String>('tin_number');
  set tinNumber(String? value) => setField<String>('tin_number', value);

  String? get nssfNumber => getField<String>('nssf_number');
  set nssfNumber(String? value) => setField<String>('nssf_number', value);

  String? get nhifNumber => getField<String>('nhif_number');
  set nhifNumber(String? value) => setField<String>('nhif_number', value);

  String? get driversLicense => getField<String>('drivers_license');
  set driversLicense(String? value) =>
      setField<String>('drivers_license', value);

  String? get homeDistrict => getField<String>('home_district');
  set homeDistrict(String? value) => setField<String>('home_district', value);

  String? get homeRegion => getField<String>('home_region');
  set homeRegion(String? value) => setField<String>('home_region', value);

  String? get nokFullName => getField<String>('nok_full_name');
  set nokFullName(String? value) => setField<String>('nok_full_name', value);

  String? get nokRelationship => getField<String>('nok_relationship');
  set nokRelationship(String? value) =>
      setField<String>('nok_relationship', value);

  String? get nokPhone => getField<String>('nok_phone');
  set nokPhone(String? value) => setField<String>('nok_phone', value);

  String? get nokAddress => getField<String>('nok_address');
  set nokAddress(String? value) => setField<String>('nok_address', value);

  String? get nokNationalId => getField<String>('nok_national_id');
  set nokNationalId(String? value) =>
      setField<String>('nok_national_id', value);

  String? get emergencyName => getField<String>('emergency_name');
  set emergencyName(String? value) => setField<String>('emergency_name', value);

  String? get emergencyPhone => getField<String>('emergency_phone');
  set emergencyPhone(String? value) =>
      setField<String>('emergency_phone', value);

  String? get emergencyRelationship =>
      getField<String>('emergency_relationship');
  set emergencyRelationship(String? value) =>
      setField<String>('emergency_relationship', value);

  String? get bankName => getField<String>('bank_name');
  set bankName(String? value) => setField<String>('bank_name', value);

  String? get bankAccountNumber => getField<String>('bank_account_number');
  set bankAccountNumber(String? value) =>
      setField<String>('bank_account_number', value);

  String? get bankBranch => getField<String>('bank_branch');
  set bankBranch(String? value) => setField<String>('bank_branch', value);

  String? get mobileMoneyProvider => getField<String>('mobile_money_provider');
  set mobileMoneyProvider(String? value) =>
      setField<String>('mobile_money_provider', value);

  String? get mobileMoneyNumber => getField<String>('mobile_money_number');
  set mobileMoneyNumber(String? value) =>
      setField<String>('mobile_money_number', value);

  String? get salaryGrade => getField<String>('salary_grade');
  set salaryGrade(String? value) => setField<String>('salary_grade', value);

  double? get basicSalary => getField<double>('basic_salary');
  set basicSalary(double? value) => setField<double>('basic_salary', value);

  DateTime? get contractEndDate => getField<DateTime>('contract_end_date');
  set contractEndDate(DateTime? value) =>
      setField<DateTime>('contract_end_date', value);

  DateTime? get probationEndDate => getField<DateTime>('probation_end_date');
  set probationEndDate(DateTime? value) =>
      setField<DateTime>('probation_end_date', value);

  String? get supervisorId => getField<String>('supervisor_id');
  set supervisorId(String? value) => setField<String>('supervisor_id', value);

  String? get jobDescription => getField<String>('job_description');
  set jobDescription(String? value) =>
      setField<String>('job_description', value);

  String? get backgroundCheckStatus =>
      getField<String>('background_check_status');
  set backgroundCheckStatus(String? value) =>
      setField<String>('background_check_status', value);

  DateTime? get backgroundCheckDate =>
      getField<DateTime>('background_check_date');
  set backgroundCheckDate(DateTime? value) =>
      setField<DateTime>('background_check_date', value);

  String? get referee1Name => getField<String>('referee_1_name');
  set referee1Name(String? value) => setField<String>('referee_1_name', value);

  String? get referee1Phone => getField<String>('referee_1_phone');
  set referee1Phone(String? value) =>
      setField<String>('referee_1_phone', value);

  String? get referee1Organization =>
      getField<String>('referee_1_organization');
  set referee1Organization(String? value) =>
      setField<String>('referee_1_organization', value);

  String? get referee2Name => getField<String>('referee_2_name');
  set referee2Name(String? value) => setField<String>('referee_2_name', value);

  String? get referee2Phone => getField<String>('referee_2_phone');
  set referee2Phone(String? value) =>
      setField<String>('referee_2_phone', value);

  String? get referee2Organization =>
      getField<String>('referee_2_organization');
  set referee2Organization(String? value) =>
      setField<String>('referee_2_organization', value);

  double? get homeGpsLat => getField<double>('home_gps_lat');
  set homeGpsLat(double? value) => setField<double>('home_gps_lat', value);

  double? get homeGpsLng => getField<double>('home_gps_lng');
  set homeGpsLng(double? value) => setField<double>('home_gps_lng', value);

  String? get assignedArea => getField<String>('assigned_area');
  set assignedArea(String? value) => setField<String>('assigned_area', value);
}
