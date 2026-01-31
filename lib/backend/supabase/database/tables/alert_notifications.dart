import '../database.dart';

class AlertNotificationsTable extends SupabaseTable<AlertNotificationsRow> {
  @override
  String get tableName => 'alert_notifications';

  @override
  AlertNotificationsRow createRow(Map<String, dynamic> data) =>
      AlertNotificationsRow(data);
}

class AlertNotificationsRow extends SupabaseDataRow {
  AlertNotificationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertNotificationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get ruleId => getField<String>('rule_id');
  set ruleId(String? value) => setField<String>('rule_id', value);

  String get snapshotId => getField<String>('snapshot_id')!;
  set snapshotId(String value) => setField<String>('snapshot_id', value);

  String? get previousSnapshotId => getField<String>('previous_snapshot_id');
  set previousSnapshotId(String? value) =>
      setField<String>('previous_snapshot_id', value);

  double get metricValue => getField<double>('metric_value')!;
  set metricValue(double value) => setField<double>('metric_value', value);

  double? get previousValue => getField<double>('previous_value');
  set previousValue(double? value) => setField<double>('previous_value', value);

  double? get changePercentage => getField<double>('change_percentage');
  set changePercentage(double? value) =>
      setField<double>('change_percentage', value);

  String get message => getField<String>('message')!;
  set message(String value) => setField<String>('message', value);

  bool get acknowledged => getField<bool>('acknowledged')!;
  set acknowledged(bool value) => setField<bool>('acknowledged', value);

  String? get acknowledgedBy => getField<String>('acknowledged_by');
  set acknowledgedBy(String? value) =>
      setField<String>('acknowledged_by', value);

  DateTime? get acknowledgedAt => getField<DateTime>('acknowledged_at');
  set acknowledgedAt(DateTime? value) =>
      setField<DateTime>('acknowledged_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get triggeredByRuleId => getField<String>('triggered_by_rule_id');
  set triggeredByRuleId(String? value) =>
      setField<String>('triggered_by_rule_id', value);

  String? get suppressedByRuleId => getField<String>('suppressed_by_rule_id');
  set suppressedByRuleId(String? value) =>
      setField<String>('suppressed_by_rule_id', value);

  bool? get isCascaded => getField<bool>('is_cascaded');
  set isCascaded(bool? value) => setField<bool>('is_cascaded', value);
}
