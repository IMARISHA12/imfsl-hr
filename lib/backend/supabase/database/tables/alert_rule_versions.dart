import '../database.dart';

class AlertRuleVersionsTable extends SupabaseTable<AlertRuleVersionsRow> {
  @override
  String get tableName => 'alert_rule_versions';

  @override
  AlertRuleVersionsRow createRow(Map<String, dynamic> data) =>
      AlertRuleVersionsRow(data);
}

class AlertRuleVersionsRow extends SupabaseDataRow {
  AlertRuleVersionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertRuleVersionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get ruleId => getField<String>('rule_id');
  set ruleId(String? value) => setField<String>('rule_id', value);

  int get versionNumber => getField<int>('version_number')!;
  set versionNumber(int value) => setField<int>('version_number', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get metric => getField<String>('metric');
  set metric(String? value) => setField<String>('metric', value);

  String? get condition => getField<String>('condition');
  set condition(String? value) => setField<String>('condition', value);

  double? get thresholdValue => getField<double>('threshold_value');
  set thresholdValue(double? value) =>
      setField<double>('threshold_value', value);

  double? get thresholdPercentage => getField<double>('threshold_percentage');
  set thresholdPercentage(double? value) =>
      setField<double>('threshold_percentage', value);

  bool? get enabled => getField<bool>('enabled');
  set enabled(bool? value) => setField<bool>('enabled', value);

  String? get groupId => getField<String>('group_id');
  set groupId(String? value) => setField<String>('group_id', value);

  String? get changedBy => getField<String>('changed_by');
  set changedBy(String? value) => setField<String>('changed_by', value);

  String? get changeType => getField<String>('change_type');
  set changeType(String? value) => setField<String>('change_type', value);

  dynamic get versionData => getField<dynamic>('version_data');
  set versionData(dynamic value) => setField<dynamic>('version_data', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
