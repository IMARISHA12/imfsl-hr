import '../database.dart';

class FineractIntegrationsTable
    extends SupabaseTable<FineractIntegrationsRow> {
  @override
  String get tableName => 'fineract_integrations';

  @override
  FineractIntegrationsRow createRow(Map<String, dynamic> data) =>
      FineractIntegrationsRow(data);
}

class FineractIntegrationsRow extends SupabaseDataRow {
  FineractIntegrationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FineractIntegrationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get integrationName => getField<String>('integration_name')!;
  set integrationName(String value) =>
      setField<String>('integration_name', value);

  String get environment => getField<String>('environment')!;
  set environment(String value) => setField<String>('environment', value);

  String? get baseUrl => getField<String>('base_url');
  set baseUrl(String? value) => setField<String>('base_url', value);

  String? get tenantId => getField<String>('tenant_id');
  set tenantId(String? value) => setField<String>('tenant_id', value);

  String? get authUsername => getField<String>('auth_username');
  set authUsername(String? value) => setField<String>('auth_username', value);

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

  bool? get syncClients => getField<bool>('sync_clients');
  set syncClients(bool? value) => setField<bool>('sync_clients', value);

  bool? get syncLoans => getField<bool>('sync_loans');
  set syncLoans(bool? value) => setField<bool>('sync_loans', value);

  bool? get syncRepayments => getField<bool>('sync_repayments');
  set syncRepayments(bool? value) => setField<bool>('sync_repayments', value);

  bool? get syncSavingsAccounts => getField<bool>('sync_savings_accounts');
  set syncSavingsAccounts(bool? value) =>
      setField<bool>('sync_savings_accounts', value);

  bool? get syncOffices => getField<bool>('sync_offices');
  set syncOffices(bool? value) => setField<bool>('sync_offices', value);

  bool? get syncStaff => getField<bool>('sync_staff');
  set syncStaff(bool? value) => setField<bool>('sync_staff', value);

  bool? get syncCharges => getField<bool>('sync_charges');
  set syncCharges(bool? value) => setField<bool>('sync_charges', value);

  bool? get syncJournalEntries => getField<bool>('sync_journal_entries');
  set syncJournalEntries(bool? value) =>
      setField<bool>('sync_journal_entries', value);

  String? get fineractVersion => getField<String>('fineract_version');
  set fineractVersion(String? value) =>
      setField<String>('fineract_version', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get updatedBy => getField<String>('updated_by');
  set updatedBy(String? value) => setField<String>('updated_by', value);
}
