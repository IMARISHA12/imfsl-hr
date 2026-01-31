import '../database.dart';

class GuardianAlertsTable extends SupabaseTable<GuardianAlertsRow> {
  @override
  String get tableName => 'guardian_alerts';

  @override
  GuardianAlertsRow createRow(Map<String, dynamic> data) =>
      GuardianAlertsRow(data);
}

class GuardianAlertsRow extends SupabaseDataRow {
  GuardianAlertsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GuardianAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get severity => getField<String>('severity');
  set severity(String? value) => setField<String>('severity', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  bool? get isResolved => getField<bool>('is_resolved');
  set isResolved(bool? value) => setField<bool>('is_resolved', value);

  String? get resolvedBy => getField<String>('resolved_by');
  set resolvedBy(String? value) => setField<String>('resolved_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
