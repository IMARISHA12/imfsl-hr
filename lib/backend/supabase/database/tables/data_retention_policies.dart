import '../database.dart';

class DataRetentionPoliciesTable
    extends SupabaseTable<DataRetentionPoliciesRow> {
  @override
  String get tableName => 'data_retention_policies';

  @override
  DataRetentionPoliciesRow createRow(Map<String, dynamic> data) =>
      DataRetentionPoliciesRow(data);
}

class DataRetentionPoliciesRow extends SupabaseDataRow {
  DataRetentionPoliciesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DataRetentionPoliciesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get policyName => getField<String>('policy_name')!;
  set policyName(String value) => setField<String>('policy_name', value);

  String get entityType => getField<String>('entity_type')!;
  set entityType(String value) => setField<String>('entity_type', value);

  int get retentionDays => getField<int>('retention_days')!;
  set retentionDays(int value) => setField<int>('retention_days', value);

  String? get retentionAction => getField<String>('retention_action');
  set retentionAction(String? value) =>
      setField<String>('retention_action', value);

  String? get conditionSql => getField<String>('condition_sql');
  set conditionSql(String? value) => setField<String>('condition_sql', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get lastExecutedAt => getField<DateTime>('last_executed_at');
  set lastExecutedAt(DateTime? value) =>
      setField<DateTime>('last_executed_at', value);

  DateTime? get nextExecutionAt => getField<DateTime>('next_execution_at');
  set nextExecutionAt(DateTime? value) =>
      setField<DateTime>('next_execution_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
