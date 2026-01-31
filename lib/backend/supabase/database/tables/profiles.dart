import '../database.dart';

class ProfilesTable extends SupabaseTable<ProfilesRow> {
  @override
  String get tableName => 'profiles';

  @override
  ProfilesRow createRow(Map<String, dynamic> data) => ProfilesRow(data);
}

class ProfilesRow extends SupabaseDataRow {
  ProfilesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProfilesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get employeeId => getField<String>('employee_id');
  set employeeId(String? value) => setField<String>('employee_id', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get departmentId => getField<String>('department_id');
  set departmentId(String? value) => setField<String>('department_id', value);

  String? get positionId => getField<String>('position_id');
  set positionId(String? value) => setField<String>('position_id', value);

  String? get managerId => getField<String>('manager_id');
  set managerId(String? value) => setField<String>('manager_id', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get employeeCode => getField<String>('employee_code');
  set employeeCode(String? value) => setField<String>('employee_code', value);

  String? get department => getField<String>('department');
  set department(String? value) => setField<String>('department', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get orgId => getField<String>('org_id');
  set orgId(String? value) => setField<String>('org_id', value);

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  String? get language => getField<String>('language');
  set language(String? value) => setField<String>('language', value);

  bool? get smsNotificationsEnabled =>
      getField<bool>('sms_notifications_enabled');
  set smsNotificationsEnabled(bool? value) =>
      setField<bool>('sms_notifications_enabled', value);

  PostgresTime? get quietHoursStart =>
      getField<PostgresTime>('quiet_hours_start');
  set quietHoursStart(PostgresTime? value) =>
      setField<PostgresTime>('quiet_hours_start', value);

  PostgresTime? get quietHoursEnd => getField<PostgresTime>('quiet_hours_end');
  set quietHoursEnd(PostgresTime? value) =>
      setField<PostgresTime>('quiet_hours_end', value);

  String? get timezone => getField<String>('timezone');
  set timezone(String? value) => setField<String>('timezone', value);

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);

  String? get jobTitle => getField<String>('job_title');
  set jobTitle(String? value) => setField<String>('job_title', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  String? get employmentType => getField<String>('employment_type');
  set employmentType(String? value) =>
      setField<String>('employment_type', value);

  DateTime? get joiningDate => getField<DateTime>('joining_date');
  set joiningDate(DateTime? value) => setField<DateTime>('joining_date', value);

  String? get profileStatus => getField<String>('profile_status');
  set profileStatus(String? value) => setField<String>('profile_status', value);

  bool? get onboardingCompleted => getField<bool>('onboarding_completed');
  set onboardingCompleted(bool? value) =>
      setField<bool>('onboarding_completed', value);

  bool? get identityVerified => getField<bool>('identity_verified');
  set identityVerified(bool? value) =>
      setField<bool>('identity_verified', value);

  String? get nidaNumber => getField<String>('nida_number');
  set nidaNumber(String? value) => setField<String>('nida_number', value);

  String? get tinNumber => getField<String>('tin_number');
  set tinNumber(String? value) => setField<String>('tin_number', value);

  String? get nextOfKinName => getField<String>('next_of_kin_name');
  set nextOfKinName(String? value) =>
      setField<String>('next_of_kin_name', value);

  String? get nextOfKinRelationship =>
      getField<String>('next_of_kin_relationship');
  set nextOfKinRelationship(String? value) =>
      setField<String>('next_of_kin_relationship', value);

  String? get nextOfKinContact => getField<String>('next_of_kin_contact');
  set nextOfKinContact(String? value) =>
      setField<String>('next_of_kin_contact', value);

  String? get nextOfKinAddress => getField<String>('next_of_kin_address');
  set nextOfKinAddress(String? value) =>
      setField<String>('next_of_kin_address', value);

  String? get bankName => getField<String>('bank_name');
  set bankName(String? value) => setField<String>('bank_name', value);

  String? get bankAccountNumber => getField<String>('bank_account_number');
  set bankAccountNumber(String? value) =>
      setField<String>('bank_account_number', value);

  String? get mobileNetwork => getField<String>('mobile_network');
  set mobileNetwork(String? value) => setField<String>('mobile_network', value);

  String? get mobilePaymentNumber => getField<String>('mobile_payment_number');
  set mobilePaymentNumber(String? value) =>
      setField<String>('mobile_payment_number', value);

  String? get employmentContractUrl =>
      getField<String>('employment_contract_url');
  set employmentContractUrl(String? value) =>
      setField<String>('employment_contract_url', value);

  String? get cvDocumentUrl => getField<String>('cv_document_url');
  set cvDocumentUrl(String? value) =>
      setField<String>('cv_document_url', value);
}
