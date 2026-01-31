import '../database.dart';

class ZArchiveSecurityIncidentWorkflowsTable
    extends SupabaseTable<ZArchiveSecurityIncidentWorkflowsRow> {
  @override
  String get tableName => 'z_archive_security_incident_workflows';

  @override
  ZArchiveSecurityIncidentWorkflowsRow createRow(Map<String, dynamic> data) =>
      ZArchiveSecurityIncidentWorkflowsRow(data);
}

class ZArchiveSecurityIncidentWorkflowsRow extends SupabaseDataRow {
  ZArchiveSecurityIncidentWorkflowsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveSecurityIncidentWorkflowsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get incidentId => getField<String>('incident_id')!;
  set incidentId(String value) => setField<String>('incident_id', value);

  String get workflowName => getField<String>('workflow_name')!;
  set workflowName(String value) => setField<String>('workflow_name', value);

  int? get currentStep => getField<int>('current_step');
  set currentStep(int? value) => setField<int>('current_step', value);

  int get totalSteps => getField<int>('total_steps')!;
  set totalSteps(int value) => setField<int>('total_steps', value);

  dynamic get stepDefinitions => getField<dynamic>('step_definitions')!;
  set stepDefinitions(dynamic value) =>
      setField<dynamic>('step_definitions', value);

  String? get currentAssignee => getField<String>('current_assignee');
  set currentAssignee(String? value) =>
      setField<String>('current_assignee', value);

  dynamic get escalationRules => getField<dynamic>('escalation_rules');
  set escalationRules(dynamic value) =>
      setField<dynamic>('escalation_rules', value);

  dynamic get automatedActions => getField<dynamic>('automated_actions');
  set automatedActions(dynamic value) =>
      setField<dynamic>('automated_actions', value);

  dynamic get manualActions => getField<dynamic>('manual_actions');
  set manualActions(dynamic value) =>
      setField<dynamic>('manual_actions', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);
}
