import '../database.dart';

class SecurityIncidentsTable extends SupabaseTable<SecurityIncidentsRow> {
  @override
  String get tableName => 'security_incidents';

  @override
  SecurityIncidentsRow createRow(Map<String, dynamic> data) =>
      SecurityIncidentsRow(data);
}

class SecurityIncidentsRow extends SupabaseDataRow {
  SecurityIncidentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SecurityIncidentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get incidentType => getField<String>('incident_type')!;
  set incidentType(String value) => setField<String>('incident_type', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String? get affectedUserId => getField<String>('affected_user_id');
  set affectedUserId(String? value) =>
      setField<String>('affected_user_id', value);

  String? get affectedResource => getField<String>('affected_resource');
  set affectedResource(String? value) =>
      setField<String>('affected_resource', value);

  String? get sourceIp => getField<String>('source_ip');
  set sourceIp(String? value) => setField<String>('source_ip', value);

  String? get userAgent => getField<String>('user_agent');
  set userAgent(String? value) => setField<String>('user_agent', value);

  String? get investigationStatus => getField<String>('investigation_status');
  set investigationStatus(String? value) =>
      setField<String>('investigation_status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) => setField<DateTime>('resolved_at', value);

  String? get resolutionNotes => getField<String>('resolution_notes');
  set resolutionNotes(String? value) =>
      setField<String>('resolution_notes', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);
}
