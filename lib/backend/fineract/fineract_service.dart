import 'package:cloud_functions/cloud_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';
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
/// Provides typed methods for every supported Fineract operation. Each call:
/// 1. Invokes the `fineractApi` Firebase callable function
/// 2. Logs the access in `fineract_access_log` for auditing
/// 3. Returns the parsed response body
///
/// Configuration, sync runs, entity mappings, and reconciliation
/// data are managed via corresponding Supabase tables.
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

  // ── Cloud Function Bridge ───────────────────────────────────────────

  /// Calls the `fineractApi` Firebase callable function and returns the
  /// response body. Automatically logs the access for auditing.
  Future<Map<String, dynamic>> _callFunction(
    String callName, {
    Map<String, dynamic> variables = const {},
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('fineractApi');
      final result = await callable.call<Map<String, dynamic>>({
        'callName': callName,
        'variables': variables,
      });

      stopwatch.stop();
      final data = Map<String, dynamic>.from(result.data);

      // Log access asynchronously — don't block the caller
      _logAccessQuietly(
        action: callName,
        endpoint: callName,
        httpMethod: _inferHttpMethod(callName),
        httpStatusCode: data['statusCode'] as int? ?? 200,
        responseTimeMs: stopwatch.elapsedMilliseconds,
      );

      return data;
    } catch (e) {
      stopwatch.stop();
      _logAccessQuietly(
        action: callName,
        endpoint: callName,
        httpMethod: _inferHttpMethod(callName),
        httpStatusCode: 500,
        responseTimeMs: stopwatch.elapsedMilliseconds,
      );
      return {
        'statusCode': 500,
        'error': e.toString(),
      };
    }
  }

  String _inferHttpMethod(String callName) {
    if (callName.startsWith('fineractCreate') ||
        callName.startsWith('fineractApprove') ||
        callName.startsWith('fineractDisburse') ||
        callName.startsWith('fineractMake')) {
      return 'POST';
    }
    return 'GET';
  }

  // ── Fineract API Calls ──────────────────────────────────────────────

  /// Fetch a paginated list of clients from Fineract.
  Future<Map<String, dynamic>> getClients({
    int? offset,
    int? limit,
    String? orderBy,
  }) async {
    return _callFunction('fineractGetClients', variables: {
      'params': {
        if (offset != null) 'offset': offset,
        if (limit != null) 'limit': limit,
        if (orderBy != null) 'orderBy': orderBy,
      },
    });
  }

  /// Fetch a single client by Fineract ID.
  Future<Map<String, dynamic>> getClient(String clientId) async {
    return _callFunction('fineractGetClient', variables: {
      'clientId': clientId,
    });
  }

  /// Create a new client in Fineract.
  Future<Map<String, dynamic>> createClient(
      Map<String, dynamic> clientData) async {
    return _callFunction('fineractCreateClient', variables: {
      'data': clientData,
    });
  }

  /// Fetch a paginated list of loans from Fineract.
  Future<Map<String, dynamic>> getLoans({
    int? offset,
    int? limit,
    String? orderBy,
  }) async {
    return _callFunction('fineractGetLoans', variables: {
      'params': {
        if (offset != null) 'offset': offset,
        if (limit != null) 'limit': limit,
        if (orderBy != null) 'orderBy': orderBy,
      },
    });
  }

  /// Fetch a single loan with all associations by Fineract ID.
  Future<Map<String, dynamic>> getLoan(
    String loanId, {
    String associations = 'all',
  }) async {
    return _callFunction('fineractGetLoan', variables: {
      'loanId': loanId,
      'associations': associations,
    });
  }

  /// Create a new loan application in Fineract.
  Future<Map<String, dynamic>> createLoan(
      Map<String, dynamic> loanData) async {
    return _callFunction('fineractCreateLoan', variables: {
      'data': loanData,
    });
  }

  /// Approve a pending loan in Fineract.
  Future<Map<String, dynamic>> approveLoan(
    String loanId, {
    Map<String, dynamic> data = const {},
  }) async {
    return _callFunction('fineractApproveLoan', variables: {
      'loanId': loanId,
      'data': data,
    });
  }

  /// Disburse an approved loan in Fineract.
  Future<Map<String, dynamic>> disburseLoan(
    String loanId, {
    Map<String, dynamic> data = const {},
  }) async {
    return _callFunction('fineractDisburseLoan', variables: {
      'loanId': loanId,
      'data': data,
    });
  }

  /// Record a repayment against a loan in Fineract.
  Future<Map<String, dynamic>> makeRepayment(
    String loanId,
    Map<String, dynamic> repaymentData,
  ) async {
    return _callFunction('fineractMakeRepayment', variables: {
      'loanId': loanId,
      'data': repaymentData,
    });
  }

  /// Fetch savings accounts from Fineract.
  Future<Map<String, dynamic>> getSavingsAccounts({
    int? offset,
    int? limit,
  }) async {
    return _callFunction('fineractGetSavingsAccounts', variables: {
      'params': {
        if (offset != null) 'offset': offset,
        if (limit != null) 'limit': limit,
      },
    });
  }

  /// Fetch all offices/branches from Fineract.
  Future<Map<String, dynamic>> getOffices() async {
    return _callFunction('fineractGetOffices');
  }

  /// Fetch staff members from Fineract.
  Future<Map<String, dynamic>> getStaff({
    int? officeId,
    String? status,
  }) async {
    return _callFunction('fineractGetStaff', variables: {
      'params': {
        if (officeId != null) 'officeId': officeId,
        if (status != null) 'status': status,
      },
    });
  }

  /// Fetch all loan products from Fineract.
  Future<Map<String, dynamic>> getLoanProducts() async {
    return _callFunction('fineractGetLoanProducts');
  }

  /// Fetch GL accounts from Fineract.
  Future<Map<String, dynamic>> getGLAccounts({String? type}) async {
    return _callFunction('fineractGetGLAccounts', variables: {
      'params': {
        if (type != null) 'type': type,
      },
    });
  }

  /// Fetch journal entries from Fineract.
  Future<Map<String, dynamic>> getJournalEntries({
    int? offset,
    int? limit,
    int? glAccountId,
  }) async {
    return _callFunction('fineractGetJournalEntries', variables: {
      'params': {
        if (offset != null) 'offset': offset,
        if (limit != null) 'limit': limit,
        if (glAccountId != null) 'glAccountId': glAccountId,
      },
    });
  }

  /// Search across Fineract entities.
  Future<Map<String, dynamic>> search(
    String query, {
    String? resource,
  }) async {
    return _callFunction('fineractSearch', variables: {
      'query': query,
      if (resource != null) 'resource': resource,
    });
  }

  /// Force-reload Fineract credentials from Firestore on the server side.
  Future<Map<String, dynamic>> refreshServerConfig() async {
    return _callFunction('fineractRefreshConfig');
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
            'entity_types': entityTypes.map((e) => e.name).toList(),
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
  Future<List<Map<String, dynamic>>> getRecentSyncRuns({
    int limit = 20,
  }) async {
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

  /// Looks up the local Supabase ID for a Fineract entity.
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

  /// Looks up the Fineract ID for a local Supabase entity.
  Future<String?> getFineractId({
    required FineractEntityType entityType,
    required String localId,
  }) async {
    if (_integrationId == null) return null;
    final response = await _client
        .from('fineract_entity_mappings')
        .select('fineract_id')
        .eq('integration_id', _integrationId!)
        .eq('entity_type', entityType.name)
        .eq('local_id', localId)
        .maybeSingle();
    return response?['fineract_id'] as String?;
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

  /// Logs a Fineract API access event, swallowing errors so it never
  /// breaks the calling code.
  void _logAccessQuietly({
    required String action,
    String? endpoint,
    String? httpMethod,
    int? httpStatusCode,
    int? responseTimeMs,
  }) {
    try {
      final uid = currentUserUid;
      if (uid.isEmpty) return;
      _client.from('fineract_access_log').insert({
        'user_id': uid,
        'action': action,
        'user_email': currentUserEmail,
        if (endpoint != null) 'endpoint': endpoint,
        if (httpMethod != null) 'http_method': httpMethod,
        if (httpStatusCode != null) 'http_status_code': httpStatusCode,
        if (responseTimeMs != null) 'response_time_ms': responseTimeMs,
        'accessed_at': DateTime.now().toUtc().toIso8601String(),
      }).then((_) {}).catchError((_) {});
    } catch (_) {
      // Never throw from logging
    }
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
  Future<void> updateSyncStatus({required String status}) async {
    if (_integrationId == null) return;
    await _client.from('fineract_integrations').update({
      'last_sync_at': DateTime.now().toUtc().toIso8601String(),
      'last_sync_status': status,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', _integrationId!);
  }
}
