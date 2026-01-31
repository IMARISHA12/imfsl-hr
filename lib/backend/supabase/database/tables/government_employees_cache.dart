import '../database.dart';

class GovernmentEmployeesCacheTable
    extends SupabaseTable<GovernmentEmployeesCacheRow> {
  @override
  String get tableName => 'government_employees_cache';

  @override
  GovernmentEmployeesCacheRow createRow(Map<String, dynamic> data) =>
      GovernmentEmployeesCacheRow(data);
}

class GovernmentEmployeesCacheRow extends SupabaseDataRow {
  GovernmentEmployeesCacheRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GovernmentEmployeesCacheTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get checkNumber => getField<String>('check_number')!;
  set checkNumber(String value) => setField<String>('check_number', value);

  String? get nidaNumber => getField<String>('nida_number');
  set nidaNumber(String? value) => setField<String>('nida_number', value);

  String get fullName => getField<String>('full_name')!;
  set fullName(String value) => setField<String>('full_name', value);

  String get employer => getField<String>('employer')!;
  set employer(String value) => setField<String>('employer', value);

  String? get department => getField<String>('department');
  set department(String? value) => setField<String>('department', value);

  String? get jobTitle => getField<String>('job_title');
  set jobTitle(String? value) => setField<String>('job_title', value);

  double get basicSalary => getField<double>('basic_salary')!;
  set basicSalary(double value) => setField<double>('basic_salary', value);

  double? get grossSalary => getField<double>('gross_salary');
  set grossSalary(double? value) => setField<double>('gross_salary', value);

  double get netSalary => getField<double>('net_salary')!;
  set netSalary(double value) => setField<double>('net_salary', value);

  double? get currentDeductions => getField<double>('current_deductions');
  set currentDeductions(double? value) =>
      setField<double>('current_deductions', value);

  DateTime? get retirementDate => getField<DateTime>('retirement_date');
  set retirementDate(DateTime? value) =>
      setField<DateTime>('retirement_date', value);

  DateTime? get employmentStartDate =>
      getField<DateTime>('employment_start_date');
  set employmentStartDate(DateTime? value) =>
      setField<DateTime>('employment_start_date', value);

  String? get verificationStatus => getField<String>('verification_status');
  set verificationStatus(String? value) =>
      setField<String>('verification_status', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) => setField<String>('verified_by', value);

  String? get essReference => getField<String>('ess_reference');
  set essReference(String? value) => setField<String>('ess_reference', value);

  dynamic get essResponseJson => getField<dynamic>('ess_response_json');
  set essResponseJson(dynamic value) =>
      setField<dynamic>('ess_response_json', value);

  DateTime? get cacheExpiresAt => getField<DateTime>('cache_expires_at');
  set cacheExpiresAt(DateTime? value) =>
      setField<DateTime>('cache_expires_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
