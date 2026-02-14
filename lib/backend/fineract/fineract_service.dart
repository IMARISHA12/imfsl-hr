import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '/backend/supabase/supabase.dart';
import 'fineract_config.dart';

/// Entity types that can be synced with Apache Fineract.
enum FineractEntityType {
  client,
  loan,
  repayment,
  savingsAccount,
  office,
  staff,
  charge,
  journalEntry,
}

/// High-level service for the Apache Fineract integration.
///
/// Handles configuration loading from the `fineract_integrations` table,
/// sync run management, entity mapping lookups, and access logging.
/// Actual Fineract API calls are proxied through Firebase Cloud Functions
/// (see `firebase/functions/fineract_client.js`).
class FineractService {
  FineractService._();

  static FineractService? _instance;
  static FineractService get instance => _instance ??= FineractService._();

  FineractConfig? _config;
  String? _integrationId;

  SupabaseClient get _client => SupaFlow.client;

  /// Whether the integration has been loaded and configured.
  bool get isConfigured => _config?.isConfigured ?? false;

  /// Current configuration (null until [loadConfig] succeeds).
  FineractConfig? get config => _config;

  // ── Configuration ───────────────────────────────────────────────────

  /// Loads the active Fineract integration configuration from Supabase.
  /// Returns `true` if a valid, active integration was found.
  Future<bool> loadConfig() async {
    try {
      final response = await _client
          .from('fineract_integrations')
          .select()
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      if (response == null) return false;

      _integrationId = response['id'] as String;
      _config = FineractConfig.fromRow(response);
      return _config!.isConfigured;
    } catch (_) {
      return false;
    }
  }

  // ── Sync Runs ───────────────────────────────────────────────────────

  /// Creates a new sync run record and returns its ID.
  Future<String?> startSyncRun({
    required String runType,
    required List<FineractEntityType> entityTypes,
    String? triggeredBy,
  }) async {
    if (_integrationId == null) return null;

    try {
      final response = await _client
          .from('fineract_sync_runs')
          .insert({
            'integration_id': _integrationId,
            'run_type': runType,
            'started_at': DateTime.now().toUtc().toIso8601String(),
            'status': 'running',
            'entity_types':
                entityTypes.map((e) => e.name).toList(),
            'triggered_by': triggeredBy,
          })
          .select('id')
          .single();
      return response['id'] as String;
    } catch (_) {
      return null;
    }
  }

  /// Marks a sync run as completed (or failed).
  Future<void> completeSyncRun({
    required String syncRunId,
    required String status,
    int recordsFetched = 0,
    int recordsCreated = 0,
    int recordsUpdated = 0,
    int recordsSkipped = 0,
    int recordsFailed = 0,
    String? errorMessage,
    dynamic errorDetails,
  }) async {
    await _client.from('fineract_sync_runs').update({
      'completed_at': DateTime.now().toUtc().toIso8601String(),
      'status': status,
      'records_fetched': recordsFetched,
      'records_created': recordsCreated,
      'records_updated': recordsUpdated,
      'records_skipped': recordsSkipped,
      'records_failed': recordsFailed,
      if (errorMessage != null) 'error_message': errorMessage,
      if (errorDetails != null) 'error_details': errorDetails,
    }).eq('id', syncRunId);
  }

  /// Fetches the most recent sync runs for display in the UI.
  Future<List<Map<String, dynamic>>> getRecentSyncRuns({int limit = 20}) async {
    if (_integrationId == null) return [];
    return await _client
        .from('fineract_sync_runs')
        .select()
        .eq('integration_id', _integrationId!)
        .order('started_at', ascending: false)
        .limit(limit);
  }

  // ── Sync Items ──────────────────────────────────────────────────────

  /// Inserts a batch of sync items for a given run.
  Future<void> insertSyncItems(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;
    await _client.from('fineract_sync_items').insert(items);
  }

  // ── Entity Mappings ─────────────────────────────────────────────────

  /// Looks up the local ID for a Fineract entity.
  Future<String?> getLocalId({
    required FineractEntityType entityType,
    required String fineractId,
  }) async {
    if (_integrationId == null) return null;
    final response = await _client
        .from('fineract_entity_mappings')
        .select('local_id')
        .eq('integration_id', _integrationId!)
        .eq('entity_type', entityType.name)
        .eq('fineract_id', fineractId)
        .maybeSingle();
    return response?['local_id'] as String?;
  }

  /// Creates or updates an entity mapping between Fineract and local IDs.
  Future<void> upsertEntityMapping({
    required FineractEntityType entityType,
    required String fineractId,
    required String localId,
    String? localTableName,
    String syncDirection = 'fineract_to_local',
    dynamic fineractData,
  }) async {
    if (_integrationId == null) return;
    await _client.from('fineract_entity_mappings').upsert(
      {
        'integration_id': _integrationId,
        'entity_type': entityType.name,
        'fineract_id': fineractId,
        'local_id': localId,
        'local_table_name': localTableName,
        'sync_direction': syncDirection,
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
        if (fineractData != null) 'fineract_data': fineractData,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'integration_id,entity_type,fineract_id',
    );
  }

  // ── Access Logging ──────────────────────────────────────────────────

  /// Logs a Fineract API access event for auditing.
  Future<void> logAccess({
    required String userId,
    required String action,
    String? userEmail,
    String? resource,
    String? endpoint,
    String? httpMethod,
    int? httpStatusCode,
    int? responseTimeMs,
  }) async {
    await _client.from('fineract_access_log').insert({
      'user_id': userId,
      'action': action,
      if (userEmail != null) 'user_email': userEmail,
      if (resource != null) 'resource': resource,
      if (endpoint != null) 'endpoint': endpoint,
      if (httpMethod != null) 'http_method': httpMethod,
      if (httpStatusCode != null) 'http_status_code': httpStatusCode,
      if (responseTimeMs != null) 'response_time_ms': responseTimeMs,
      'accessed_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  // ── Reconciliation ─────────────────────────────────────────────────

  /// Fetches reconciliation snapshots for review.
  Future<List<Map<String, dynamic>>> getReconciliationSnapshots({
    int limit = 10,
  }) async {
    return await _client
        .from('fineract_reconciliation_snapshots')
        .select()
        .order('reconciliation_date', ascending: false)
        .limit(limit);
  }

  // ── Integration Status ──────────────────────────────────────────────

  /// Updates the last sync timestamp and status on the integration record.
  Future<void> updateSyncStatus({
    required String status,
  }) async {
    if (_integrationId == null) return;
    await _client.from('fineract_integrations').update({
      'last_sync_at': DateTime.now().toUtc().toIso8601String(),
      'last_sync_status': status,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', _integrationId!);
  }
}
