import '../database.dart';

class LoanAssignmentsTable extends SupabaseTable<LoanAssignmentsRow> {
  @override
  String get tableName => 'loan_assignments';

  @override
  LoanAssignmentsRow createRow(Map<String, dynamic> data) =>
      LoanAssignmentsRow(data);
}

class LoanAssignmentsRow extends SupabaseDataRow {
  LoanAssignmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanAssignmentsTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  DateTime get assignedAt => getField<DateTime>('assigned_at')!;
  set assignedAt(DateTime value) => setField<DateTime>('assigned_at', value);
}
