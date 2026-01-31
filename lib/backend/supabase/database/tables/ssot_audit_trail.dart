import '../database.dart';

class SsotAuditTrailTable extends SupabaseTable<SsotAuditTrailRow> {
  @override
  String get tableName => 'ssot_audit_trail';

  @override
  SsotAuditTrailRow createRow(Map<String, dynamic> data) =>
      SsotAuditTrailRow(data);
}

class SsotAuditTrailRow extends SupabaseDataRow {
  SsotAuditTrailRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SsotAuditTrailTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String get entityType => getField<String>('entity_type')!;
  set entityType(String value) => setField<String>('entity_type', value);

  String? get entityId => getField<String>('entity_id');
  set entityId(String? value) => setField<String>('entity_id', value);

  String? get actorId => getField<String>('actor_id');
  set actorId(String? value) => setField<String>('actor_id', value);

  String? get actorRole => getField<String>('actor_role');
  set actorRole(String? value) => setField<String>('actor_role', value);

  String? get actorIp => getField<String>('actor_ip');
  set actorIp(String? value) => setField<String>('actor_ip', value);

  String? get actorUserAgent => getField<String>('actor_user_agent');
  set actorUserAgent(String? value) =>
      setField<String>('actor_user_agent', value);

  dynamic get oldData => getField<dynamic>('old_data');
  set oldData(dynamic value) => setField<dynamic>('old_data', value);

  dynamic get newData => getField<dynamic>('new_data');
  set newData(dynamic value) => setField<dynamic>('new_data', value);

  List<String> get changedFields => getListField<String>('changed_fields');
  set changedFields(List<String>? value) =>
      setListField<String>('changed_fields', value);

  String? get sessionId => getField<String>('session_id');
  set sessionId(String? value) => setField<String>('session_id', value);

  String? get requestId => getField<String>('request_id');
  set requestId(String? value) => setField<String>('request_id', value);

  String? get module => getField<String>('module');
  set module(String? value) => setField<String>('module', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  List<String> get evidenceUrls => getListField<String>('evidence_urls');
  set evidenceUrls(List<String>? value) =>
      setListField<String>('evidence_urls', value);

  DateTime get occurredAt => getField<DateTime>('occurred_at')!;
  set occurredAt(DateTime value) => setField<DateTime>('occurred_at', value);

  String? get prevHash => getField<String>('prev_hash');
  set prevHash(String? value) => setField<String>('prev_hash', value);

  String? get recordHash => getField<String>('record_hash');
  set recordHash(String? value) => setField<String>('record_hash', value);
}
