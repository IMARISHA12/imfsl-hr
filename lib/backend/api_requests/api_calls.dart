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
