import '../database.dart';

class CaseAssignmentsTable extends SupabaseTable<CaseAssignmentsRow> {
  @override
  String get tableName => 'case_assignments';

  @override
  CaseAssignmentsRow createRow(Map<String, dynamic> data) =>
      CaseAssignmentsRow(data);
}

class CaseAssignmentsRow extends SupabaseDataRow {
  CaseAssignmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CaseAssignmentsTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  DateTime get assignedAt => getField<DateTime>('assigned_at')!;
  set assignedAt(DateTime value) => setField<DateTime>('assigned_at', value);
}
