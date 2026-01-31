import '../database.dart';

class ZArchiveAnalyticsEventsTable
    extends SupabaseTable<ZArchiveAnalyticsEventsRow> {
  @override
  String get tableName => 'z_archive_analytics_events';

  @override
  ZArchiveAnalyticsEventsRow createRow(Map<String, dynamic> data) =>
      ZArchiveAnalyticsEventsRow(data);
}

class ZArchiveAnalyticsEventsRow extends SupabaseDataRow {
  ZArchiveAnalyticsEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveAnalyticsEventsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  String get eventCategory => getField<String>('event_category')!;
  set eventCategory(String value) => setField<String>('event_category', value);

  dynamic get eventData => getField<dynamic>('event_data');
  set eventData(dynamic value) => setField<dynamic>('event_data', value);

  String? get sessionId => getField<String>('session_id');
  set sessionId(String? value) => setField<String>('session_id', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
