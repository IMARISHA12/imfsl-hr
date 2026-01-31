import '../database.dart';

class ZArchiveApprovalStepsTable
    extends SupabaseTable<ZArchiveApprovalStepsRow> {
  @override
  String get tableName => 'z_archive_approval_steps';

  @override
  ZArchiveApprovalStepsRow createRow(Map<String, dynamic> data) =>
      ZArchiveApprovalStepsRow(data);
}

class ZArchiveApprovalStepsRow extends SupabaseDataRow {
  ZArchiveApprovalStepsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveApprovalStepsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get flowId => getField<String>('flow_id')!;
  set flowId(String value) => setField<String>('flow_id', value);

  int get stepSequence => getField<int>('step_sequence')!;
  set stepSequence(int value) => setField<int>('step_sequence', value);

  String get stepName => getField<String>('step_name')!;
  set stepName(String value) => setField<String>('step_name', value);

  String get stepType => getField<String>('step_type')!;
  set stepType(String value) => setField<String>('step_type', value);

  String? get approverRoleKey => getField<String>('approver_role_key');
  set approverRoleKey(String? value) =>
      setField<String>('approver_role_key', value);

  String? get approverUserId => getField<String>('approver_user_id');
  set approverUserId(String? value) =>
      setField<String>('approver_user_id', value);

  dynamic get conditionRules => getField<dynamic>('condition_rules');
  set conditionRules(dynamic value) =>
      setField<dynamic>('condition_rules', value);

  bool get isMandatory => getField<bool>('is_mandatory')!;
  set isMandatory(bool value) => setField<bool>('is_mandatory', value);

  int? get escalationDays => getField<int>('escalation_days');
  set escalationDays(int? value) => setField<int>('escalation_days', value);

  String? get escalationRoleKey => getField<String>('escalation_role_key');
  set escalationRoleKey(String? value) =>
      setField<String>('escalation_role_key', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get nextStepId => getField<String>('next_step_id');
  set nextStepId(String? value) => setField<String>('next_step_id', value);

  int get position => getField<int>('position')!;
  set position(int value) => setField<int>('position', value);

  bool? get isParallel => getField<bool>('is_parallel');
  set isParallel(bool? value) => setField<bool>('is_parallel', value);

  String? get parallelGroupId => getField<String>('parallel_group_id');
  set parallelGroupId(String? value) =>
      setField<String>('parallel_group_id', value);

  String? get consensusRule => getField<String>('consensus_rule');
  set consensusRule(String? value) => setField<String>('consensus_rule', value);

  int? get consensusThreshold => getField<int>('consensus_threshold');
  set consensusThreshold(int? value) =>
      setField<int>('consensus_threshold', value);

  int? get parallelTimeoutHours => getField<int>('parallel_timeout_hours');
  set parallelTimeoutHours(int? value) =>
      setField<int>('parallel_timeout_hours', value);
}
