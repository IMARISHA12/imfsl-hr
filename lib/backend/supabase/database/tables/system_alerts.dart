import '../database.dart';

class SystemAlertsTable extends SupabaseTable<SystemAlertsRow> {
  @override
  String get tableName => 'system_alerts';

  @override
  SystemAlertsRow createRow(Map<String, dynamic> data) => SystemAlertsRow(data);
}

class SystemAlertsRow extends SupabaseDataRow {
  SystemAlertsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SystemAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get alertType => getField<String>('alert_type');
  set alertType(String? value) => setField<String>('alert_type', value);

  String? get message => getField<String>('message');
  set message(String? value) => setField<String>('message', value);

  String? get severity => getField<String>('severity');
  set severity(String? value) => setField<String>('severity', value);

  bool? get acknowledged => getField<bool>('acknowledged');
  set acknowledged(bool? value) => setField<bool>('acknowledged', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
