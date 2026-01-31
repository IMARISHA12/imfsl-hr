import '../database.dart';

class SodViolationsTable extends SupabaseTable<SodViolationsRow> {
  @override
  String get tableName => 'sod_violations';

  @override
  SodViolationsRow createRow(Map<String, dynamic> data) =>
      SodViolationsRow(data);
}

class SodViolationsRow extends SupabaseDataRow {
  SodViolationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SodViolationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get ruleId => getField<String>('rule_id')!;
  set ruleId(String value) => setField<String>('rule_id', value);

  String get actorId => getField<String>('actor_id')!;
  set actorId(String value) => setField<String>('actor_id', value);

  String get actionAttempted => getField<String>('action_attempted')!;
  set actionAttempted(String value) =>
      setField<String>('action_attempted', value);

  String get conflictingAction => getField<String>('conflicting_action')!;
  set conflictingAction(String value) =>
      setField<String>('conflicting_action', value);

  String? get entityType => getField<String>('entity_type');
  set entityType(String? value) => setField<String>('entity_type', value);

  String? get entityId => getField<String>('entity_id');
  set entityId(String? value) => setField<String>('entity_id', value);

  bool get wasBlocked => getField<bool>('was_blocked')!;
  set wasBlocked(bool value) => setField<bool>('was_blocked', value);

  String? get overrideApprovedBy => getField<String>('override_approved_by');
  set overrideApprovedBy(String? value) =>
      setField<String>('override_approved_by', value);

  String? get overrideReason => getField<String>('override_reason');
  set overrideReason(String? value) =>
      setField<String>('override_reason', value);

  DateTime? get occurredAt => getField<DateTime>('occurred_at');
  set occurredAt(DateTime? value) => setField<DateTime>('occurred_at', value);
}
