import '../database.dart';

class LoandiskIntegrationsTable extends SupabaseTable<LoandiskIntegrationsRow> {
  @override
  String get tableName => 'loandisk_integrations';

  @override
  LoandiskIntegrationsRow createRow(Map<String, dynamic> data) =>
      LoandiskIntegrationsRow(data);
}

class LoandiskIntegrationsRow extends SupabaseDataRow {
  LoandiskIntegrationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoandiskIntegrationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get integrationName => getField<String>('integration_name')!;
  set integrationName(String value) =>
      setField<String>('integration_name', value);

  String get environment => getField<String>('environment')!;
  set environment(String value) => setField<String>('environment', value);

  String? get baseUrl => getField<String>('base_url');
  set baseUrl(String? value) => setField<String>('base_url', value);

  List<String> get allowedIpRanges => getListField<String>('allowed_ip_ranges');
  set allowedIpRanges(List<String>? value) =>
      setListField<String>('allowed_ip_ranges', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  bool get syncEnabled => getField<bool>('sync_enabled')!;
  set syncEnabled(bool value) => setField<bool>('sync_enabled', value);

  int? get syncIntervalMinutes => getField<int>('sync_interval_minutes');
  set syncIntervalMinutes(int? value) =>
      setField<int>('sync_interval_minutes', value);

  DateTime? get lastSyncAt => getField<DateTime>('last_sync_at');
  set lastSyncAt(DateTime? value) => setField<DateTime>('last_sync_at', value);

  String? get lastSyncStatus => getField<String>('last_sync_status');
  set lastSyncStatus(String? value) =>
      setField<String>('last_sync_status', value);

  bool? get syncLoans => getField<bool>('sync_loans');
  set syncLoans(bool? value) => setField<bool>('sync_loans', value);

  bool? get syncRepayments => getField<bool>('sync_repayments');
  set syncRepayments(bool? value) => setField<bool>('sync_repayments', value);

  bool? get syncCustomers => getField<bool>('sync_customers');
  set syncCustomers(bool? value) => setField<bool>('sync_customers', value);

  bool? get syncBranches => getField<bool>('sync_branches');
  set syncBranches(bool? value) => setField<bool>('sync_branches', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get updatedBy => getField<String>('updated_by');
  set updatedBy(String? value) => setField<String>('updated_by', value);
}
