import '../database.dart';

class EssVerificationLogsTable extends SupabaseTable<EssVerificationLogsRow> {
  @override
  String get tableName => 'ess_verification_logs';

  @override
  EssVerificationLogsRow createRow(Map<String, dynamic> data) =>
      EssVerificationLogsRow(data);
}

class EssVerificationLogsRow extends SupabaseDataRow {
  EssVerificationLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EssVerificationLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get checkNumber => getField<String>('check_number')!;
  set checkNumber(String value) => setField<String>('check_number', value);

  String get queriedBy => getField<String>('queried_by')!;
  set queriedBy(String value) => setField<String>('queried_by', value);

  DateTime? get queriedAt => getField<DateTime>('queried_at');
  set queriedAt(DateTime? value) => setField<DateTime>('queried_at', value);

  String? get querySource => getField<String>('query_source');
  set querySource(String? value) => setField<String>('query_source', value);

  String? get queryPurpose => getField<String>('query_purpose');
  set queryPurpose(String? value) => setField<String>('query_purpose', value);

  bool get employeeFound => getField<bool>('employee_found')!;
  set employeeFound(bool value) => setField<bool>('employee_found', value);

  String? get employeeName => getField<String>('employee_name');
  set employeeName(String? value) => setField<String>('employee_name', value);

  String? get employer => getField<String>('employer');
  set employer(String? value) => setField<String>('employer', value);

  double? get basicSalary => getField<double>('basic_salary');
  set basicSalary(double? value) => setField<double>('basic_salary', value);

  String? get verificationStatus => getField<String>('verification_status');
  set verificationStatus(String? value) =>
      setField<String>('verification_status', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  String? get sessionId => getField<String>('session_id');
  set sessionId(String? value) => setField<String>('session_id', value);

  int? get responseTimeMs => getField<int>('response_time_ms');
  set responseTimeMs(int? value) => setField<int>('response_time_ms', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);
}
