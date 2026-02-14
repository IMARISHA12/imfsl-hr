/// Client-side configuration for the Apache Fineract integration.
///
/// Loaded from the `fineract_integrations` Supabase table at runtime.
/// Credentials (username/password) are stored server-side only —
/// they live in the Firestore `config/fineract` document and are
/// never sent to the Flutter client.
class FineractConfig {
  final String baseUrl;
  final String tenantId;
  final String environment;
  final String? fineractVersion;
  final bool syncEnabled;
  final int syncIntervalMinutes;
  final bool syncClients;
  final bool syncLoans;
  final bool syncRepayments;
  final bool syncSavingsAccounts;
  final bool syncOffices;
  final bool syncStaff;
  final bool syncCharges;
  final bool syncJournalEntries;

  const FineractConfig({
    required this.baseUrl,
    required this.tenantId,
    required this.environment,
    this.fineractVersion,
    this.syncEnabled = false,
    this.syncIntervalMinutes = 30,
    this.syncClients = true,
    this.syncLoans = true,
    this.syncRepayments = true,
    this.syncSavingsAccounts = true,
    this.syncOffices = true,
    this.syncStaff = true,
    this.syncCharges = false,
    this.syncJournalEntries = false,
  });

  factory FineractConfig.fromRow(Map<String, dynamic> row) {
    return FineractConfig(
      baseUrl: row['base_url'] ?? '',
      tenantId: row['tenant_id'] ?? 'default',
      environment: row['environment'] ?? 'sandbox',
      fineractVersion: row['fineract_version'],
      syncEnabled: row['sync_enabled'] ?? false,
      syncIntervalMinutes: row['sync_interval_minutes'] ?? 30,
      syncClients: row['sync_clients'] ?? true,
      syncLoans: row['sync_loans'] ?? true,
      syncRepayments: row['sync_repayments'] ?? true,
      syncSavingsAccounts: row['sync_savings_accounts'] ?? true,
      syncOffices: row['sync_offices'] ?? true,
      syncStaff: row['sync_staff'] ?? true,
      syncCharges: row['sync_charges'] ?? false,
      syncJournalEntries: row['sync_journal_entries'] ?? false,
    );
  }

  bool get isConfigured => baseUrl.isNotEmpty && tenantId.isNotEmpty;
}
