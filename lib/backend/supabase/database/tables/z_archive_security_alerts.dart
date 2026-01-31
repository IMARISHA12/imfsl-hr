import '../database.dart';

class ZArchiveSecurityAlertsTable
    extends SupabaseTable<ZArchiveSecurityAlertsRow> {
  @override
  String get tableName => 'z_archive_security_alerts';

  @override
  ZArchiveSecurityAlertsRow createRow(Map<String, dynamic> data) =>
      ZArchiveSecurityAlertsRow(data);
}

class ZArchiveSecurityAlertsRow extends SupabaseDataRow {
  ZArchiveSecurityAlertsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveSecurityAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get alertType => getField<String>('alert_type')!;
  set alertType(String value) => setField<String>('alert_type', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  String get message => getField<String>('message')!;
  set message(String value) => setField<String>('message', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  bool? get resolved => getField<bool>('resolved');
  set resolved(bool? value) => setField<bool>('resolved', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) => setField<DateTime>('resolved_at', value);

  String? get resolvedBy => getField<String>('resolved_by');
  set resolvedBy(String? value) => setField<String>('resolved_by', value);
}
