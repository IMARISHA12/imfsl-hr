/// Configuration for the Apache Fineract integration.
///
/// Credentials and base URL are stored in the `fineract_integrations`
/// Supabase table and loaded at runtime so nothing is hard-coded.
class FineractConfig {
  final String baseUrl;
  final String tenantId;
  final String username;
  final String environment;
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
    required this.username,
    required this.environment,
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
      username: row['auth_username'] ?? '',
      environment: row['environment'] ?? 'sandbox',
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
