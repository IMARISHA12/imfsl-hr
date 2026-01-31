import '../database.dart';

class AlertRulesTable extends SupabaseTable<AlertRulesRow> {
  @override
  String get tableName => 'alert_rules';

  @override
  AlertRulesRow createRow(Map<String, dynamic> data) => AlertRulesRow(data);
}

class AlertRulesRow extends SupabaseDataRow {
  AlertRulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertRulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get metric => getField<String>('metric')!;
  set metric(String value) => setField<String>('metric', value);

  String get condition => getField<String>('condition')!;
  set condition(String value) => setField<String>('condition', value);

  double get thresholdValue => getField<double>('threshold_value')!;
  set thresholdValue(double value) =>
      setField<double>('threshold_value', value);

  double? get thresholdPercentage => getField<double>('threshold_percentage');
  set thresholdPercentage(double? value) =>
      setField<double>('threshold_percentage', value);

  bool get enabled => getField<bool>('enabled')!;
  set enabled(bool value) => setField<bool>('enabled', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get groupId => getField<String>('group_id');
  set groupId(String? value) => setField<String>('group_id', value);
}
