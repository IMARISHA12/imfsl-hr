import '../database.dart';

class UserSessionsTable extends SupabaseTable<UserSessionsRow> {
  @override
  String get tableName => 'user_sessions';

  @override
  UserSessionsRow createRow(Map<String, dynamic> data) => UserSessionsRow(data);
}

class UserSessionsRow extends SupabaseDataRow {
  UserSessionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserSessionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get sessionToken => getField<String>('session_token')!;
  set sessionToken(String value) => setField<String>('session_token', value);

  String? get deviceFingerprint => getField<String>('device_fingerprint');
  set deviceFingerprint(String? value) =>
      setField<String>('device_fingerprint', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  dynamic get locationData => getField<dynamic>('location_data');
  set locationData(dynamic value) => setField<dynamic>('location_data', value);

  int? get roleBasedTimeoutMinutes =>
      getField<int>('role_based_timeout_minutes');
  set roleBasedTimeoutMinutes(int? value) =>
      setField<int>('role_based_timeout_minutes', value);

  DateTime get lastActivity => getField<DateTime>('last_activity')!;
  set lastActivity(DateTime value) =>
      setField<DateTime>('last_activity', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime? get mfaVerifiedAt => getField<DateTime>('mfa_verified_at');
  set mfaVerifiedAt(DateTime? value) =>
      setField<DateTime>('mfa_verified_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
