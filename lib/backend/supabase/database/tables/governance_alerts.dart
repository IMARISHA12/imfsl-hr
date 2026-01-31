import '../database.dart';

class GovernanceAlertsTable extends SupabaseTable<GovernanceAlertsRow> {
  @override
  String get tableName => 'governance_alerts';

  @override
  GovernanceAlertsRow createRow(Map<String, dynamic> data) =>
      GovernanceAlertsRow(data);
}

class GovernanceAlertsRow extends SupabaseDataRow {
  GovernanceAlertsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GovernanceAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get alertName => getField<String>('alert_name')!;
  set alertName(String value) => setField<String>('alert_name', value);

  String get alertType => getField<String>('alert_type')!;
  set alertType(String value) => setField<String>('alert_type', value);

  dynamic get thresholdConfig => getField<dynamic>('threshold_config')!;
  set thresholdConfig(dynamic value) =>
      setField<dynamic>('threshold_config', value);

  dynamic get notificationChannels =>
      getField<dynamic>('notification_channels')!;
  set notificationChannels(dynamic value) =>
      setField<dynamic>('notification_channels', value);

  dynamic get recipients => getField<dynamic>('recipients')!;
  set recipients(dynamic value) => setField<dynamic>('recipients', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  int? get cooldownMinutes => getField<int>('cooldown_minutes');
  set cooldownMinutes(int? value) => setField<int>('cooldown_minutes', value);

  dynamic get escalationRules => getField<dynamic>('escalation_rules');
  set escalationRules(dynamic value) =>
      setField<dynamic>('escalation_rules', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
