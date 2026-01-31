import '../database.dart';

class ComplianceExecutionsTable extends SupabaseTable<ComplianceExecutionsRow> {
  @override
  String get tableName => 'compliance_executions';

  @override
  ComplianceExecutionsRow createRow(Map<String, dynamic> data) =>
      ComplianceExecutionsRow(data);
}

class ComplianceExecutionsRow extends SupabaseDataRow {
  ComplianceExecutionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ComplianceExecutionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get checklistId => getField<String>('checklist_id')!;
  set checklistId(String value) => setField<String>('checklist_id', value);

  String get periodKey => getField<String>('period_key')!;
  set periodKey(String value) => setField<String>('period_key', value);

  DateTime get executionDate => getField<DateTime>('execution_date')!;
  set executionDate(DateTime value) =>
      setField<DateTime>('execution_date', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  dynamic get completedItems => getField<dynamic>('completed_items');
  set completedItems(dynamic value) =>
      setField<dynamic>('completed_items', value);

  int? get totalItems => getField<int>('total_items');
  set totalItems(int? value) => setField<int>('total_items', value);

  int? get completedCount => getField<int>('completed_count');
  set completedCount(int? value) => setField<int>('completed_count', value);

  double? get completionPercentage => getField<double>('completion_percentage');
  set completionPercentage(double? value) =>
      setField<double>('completion_percentage', value);

  String? get executedBy => getField<String>('executed_by');
  set executedBy(String? value) => setField<String>('executed_by', value);

  DateTime? get executedAt => getField<DateTime>('executed_at');
  set executedAt(DateTime? value) => setField<DateTime>('executed_at', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  dynamic get issuesFound => getField<dynamic>('issues_found');
  set issuesFound(dynamic value) => setField<dynamic>('issues_found', value);

  bool? get remediationRequired => getField<bool>('remediation_required');
  set remediationRequired(bool? value) =>
      setField<bool>('remediation_required', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
