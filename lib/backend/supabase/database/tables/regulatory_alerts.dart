import '../database.dart';

class RegulatoryAlertsTable extends SupabaseTable<RegulatoryAlertsRow> {
  @override
  String get tableName => 'regulatory_alerts';

  @override
  RegulatoryAlertsRow createRow(Map<String, dynamic> data) =>
      RegulatoryAlertsRow(data);
}

class RegulatoryAlertsRow extends SupabaseDataRow {
  RegulatoryAlertsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RegulatoryAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get lawId => getField<String>('law_id');
  set lawId(String? value) => setField<String>('law_id', value);

  String? get severity => getField<String>('severity');
  set severity(String? value) => setField<String>('severity', value);

  String? get impactDescription => getField<String>('impact_description');
  set impactDescription(String? value) =>
      setField<String>('impact_description', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get actionTaken => getField<String>('action_taken');
  set actionTaken(String? value) => setField<String>('action_taken', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
