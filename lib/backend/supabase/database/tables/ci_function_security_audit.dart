import '../database.dart';

class CiFunctionSecurityAuditTable
    extends SupabaseTable<CiFunctionSecurityAuditRow> {
  @override
  String get tableName => 'ci_function_security_audit';

  @override
  CiFunctionSecurityAuditRow createRow(Map<String, dynamic> data) =>
      CiFunctionSecurityAuditRow(data);
}

class CiFunctionSecurityAuditRow extends SupabaseDataRow {
  CiFunctionSecurityAuditRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CiFunctionSecurityAuditTable();

  String? get functionName => getField<String>('function_name');
  set functionName(String? value) => setField<String>('function_name', value);

  String? get schemaName => getField<String>('schema_name');
  set schemaName(String? value) => setField<String>('schema_name', value);

  String? get arguments => getField<String>('arguments');
  set arguments(String? value) => setField<String>('arguments', value);

  String? get volatility => getField<String>('volatility');
  set volatility(String? value) => setField<String>('volatility', value);

  String? get securityMode => getField<String>('security_mode');
  set securityMode(String? value) => setField<String>('security_mode', value);

  String? get searchPathConfig => getField<String>('search_path_config');
  set searchPathConfig(String? value) =>
      setField<String>('search_path_config', value);

  List<String> get grantedTo => getListField<String>('granted_to');
  set grantedTo(List<String>? value) =>
      setListField<String>('granted_to', value);

  String? get allowlistStatus => getField<String>('allowlist_status');
  set allowlistStatus(String? value) =>
      setField<String>('allowlist_status', value);

  List<String> get securityIssues => getListField<String>('security_issues');
  set securityIssues(List<String>? value) =>
      setListField<String>('security_issues', value);
}
