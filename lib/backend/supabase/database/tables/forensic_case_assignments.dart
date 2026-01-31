import '../database.dart';

class ForensicCaseAssignmentsTable
    extends SupabaseTable<ForensicCaseAssignmentsRow> {
  @override
  String get tableName => 'forensic_case_assignments';

  @override
  ForensicCaseAssignmentsRow createRow(Map<String, dynamic> data) =>
      ForensicCaseAssignmentsRow(data);
}

class ForensicCaseAssignmentsRow extends SupabaseDataRow {
  ForensicCaseAssignmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ForensicCaseAssignmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  String get tokenHash => getField<String>('token_hash')!;
  set tokenHash(String value) => setField<String>('token_hash', value);

  DateTime get expiresAt => getField<DateTime>('expires_at')!;
  set expiresAt(DateTime value) => setField<DateTime>('expires_at', value);

  DateTime? get openedAt => getField<DateTime>('opened_at');
  set openedAt(DateTime? value) => setField<DateTime>('opened_at', value);

  DateTime? get acceptedAt => getField<DateTime>('accepted_at');
  set acceptedAt(DateTime? value) => setField<DateTime>('accepted_at', value);

  String? get assignedToUserId => getField<String>('assigned_to_user_id');
  set assignedToUserId(String? value) =>
      setField<String>('assigned_to_user_id', value);

  String? get sentTo => getField<String>('sent_to');
  set sentTo(String? value) => setField<String>('sent_to', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
