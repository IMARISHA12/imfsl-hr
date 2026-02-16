import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class SubmitLeaveRequestCall {
  static Future<ApiCallResponse> call({
    String? pLeaveType = '',
    String? pStartDate = '',
    String? pEndDate = '',
    String? pReason = '',
    String? pAttachmentUrl = '',
    String? pPhotoCapturedAt = '',
  }) async {
    final ffApiRequestBody = '''
{"p_leave_type": "{{p_leave_type}}", "p_start_date": "{{p_start_date}}", "p_end_date": "{{p_end_date}}", "p_reason": "{{p_reason}}", "p_attachment_url": "{{p_attachment_url}}", "p_photo_captured_at": "{{p_photo_captured_at}}"}''';
    return ApiManager.instance.makeApiCall(
      callName: 'submitLeaveRequest',
      apiUrl:
          'https://api.admin-imarishamaisha.co.tz/rest/v1/rpc/fn_submit_leave_request',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6eWl4YXpqcXVvdWljZnNmenp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY2NDMxNDAsImV4cCI6MjA3MjIxOTE0MH0.2HD_QpH1qug5ieerXukAtEP9bCxbSVBht7khyUGtaz8',
        'Authorization':
            'Bearer  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6eWl4YXpqcXVvdWljZnNmenp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY2NDMxNDAsImV4cCI6MjA3MjIxOTE0MH0.2HD_QpH1qug5ieerXukAtEP9bCxbSVBht7khyUGtaz8',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetStaffMonthlyStatsCall {
  static Future<ApiCallResponse> call({
    String? staffId = 'b162dab4-07ec-4471-a63c-0df31feff5d7',
  }) async {
    final ffApiRequestBody = '''
{
  "p_staff_id": "\$staffId"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getStaffMonthlyStats',
      apiUrl:
          'https://api.admin-imarishamaisha.co.tz/rest/v1/rpc/fn_get_staff_monthly_stats',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6eWl4YXpqcXVvdWljZnNmenp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY2NDMxNDAsImV4cCI6MjA3MjIxOTE0MH0.2HD_QpH1qug5ieerXukAtEP9bCxbSVBht7khyUGtaz8',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6eWl4YXpqcXVvdWljZnNmenp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY2NDMxNDAsImV4cCI6MjA3MjIxOTE0MH0.2HD_QpH1qug5ieerXukAtEP9bCxbSVBht7khyUGtaz8',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============================================================================
// MALI YA KAMPUNI - Company Assets & Technology Monitoring API Calls
// ============================================================================

const _kSupabaseApiKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6eWl4YXpqcXVvdWljZnNmenp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY2NDMxNDAsImV4cCI6MjA3MjIxOTE0MH0.2HD_QpH1qug5ieerXukAtEP9bCxbSVBht7khyUGtaz8';
const _kSupabaseBaseUrl = 'https://api.admin-imarishamaisha.co.tz';

Map<String, String> _supabaseHeaders() => {
      'apikey': _kSupabaseApiKey,
      'Authorization': 'Bearer $_kSupabaseApiKey',
      'Content-Type': 'application/json',
    };

/// Get Company Asset KPIs (Total Value, Depreciation, Maintenance Due, etc.)
class GetCompanyAssetKpisCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'getCompanyAssetKpis',
      apiUrl: '$_kSupabaseBaseUrl/rest/v1/rpc/fn_company_asset_kpis',
      callType: ApiCallType.POST,
      headers: _supabaseHeaders(),
      params: {},
      body: '{}',
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// Register a new company asset
class RegisterCompanyAssetCall {
  static Future<ApiCallResponse> call({
    required String pAssetName,
    required String pAssetCategory,
    String? pSerialNumber,
    String? pRegistrationNumber,
    String? pPurchaseDate,
    double pPurchasePrice = 0,
    int pUsefulLifeYears = 5,
    String pDepreciationMethod = 'straight_line',
    String? pLocationDescription,
    String? pAssignedDepartment,
    String? pDescription,
    String? pPhotoUrl,
  }) async {
    final ffApiRequestBody = json.encode({
      'p_asset_name': pAssetName,
      'p_asset_category': pAssetCategory,
      'p_serial_number': pSerialNumber,
      'p_registration_number': pRegistrationNumber,
      'p_purchase_date': pPurchaseDate ?? DateTime.now().toIso8601String().split('T').first,
      'p_purchase_price': pPurchasePrice,
      'p_useful_life_years': pUsefulLifeYears,
      'p_depreciation_method': pDepreciationMethod,
      'p_location_description': pLocationDescription,
      'p_assigned_department': pAssignedDepartment,
      'p_description': pDescription,
      'p_photo_url': pPhotoUrl,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'registerCompanyAsset',
      apiUrl: '$_kSupabaseBaseUrl/rest/v1/rpc/fn_register_company_asset',
      callType: ApiCallType.POST,
      headers: _supabaseHeaders(),
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// Calculate asset depreciation
class CalculateAssetDepreciationCall {
  static Future<ApiCallResponse> call({
    required String pAssetId,
  }) async {
    final ffApiRequestBody = json.encode({
      'p_asset_id': pAssetId,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'calculateAssetDepreciation',
      apiUrl: '$_kSupabaseBaseUrl/rest/v1/rpc/fn_calculate_asset_depreciation',
      callType: ApiCallType.POST,
      headers: _supabaseHeaders(),
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// Run AI OCR Fraud Analysis on a scan
class RunOcrFraudAnalysisCall {
  static Future<ApiCallResponse> call({
    required String pScanId,
  }) async {
    final ffApiRequestBody = json.encode({
      'p_scan_id': pScanId,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'runOcrFraudAnalysis',
      apiUrl: '$_kSupabaseBaseUrl/rest/v1/rpc/fn_ocr_fraud_analysis',
      callType: ApiCallType.POST,
      headers: _supabaseHeaders(),
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// Get Technology Health Dashboard
class GetTechHealthDashboardCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'getTechHealthDashboard',
      apiUrl: '$_kSupabaseBaseUrl/rest/v1/rpc/fn_tech_health_dashboard',
      callType: ApiCallType.POST,
      headers: _supabaseHeaders(),
      params: {},
      body: '{}',
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// Get Fleet GPS Summary
class GetFleetGpsSummaryCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'getFleetGpsSummary',
      apiUrl: '$_kSupabaseBaseUrl/rest/v1/rpc/fn_fleet_gps_summary',
      callType: ApiCallType.POST,
      headers: _supabaseHeaders(),
      params: {},
      body: '{}',
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
