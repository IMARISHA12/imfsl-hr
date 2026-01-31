import '../database.dart';

class VLoansAuditSummaryTable extends SupabaseTable<VLoansAuditSummaryRow> {
  @override
  String get tableName => 'v_loans_audit_summary';

  @override
  VLoansAuditSummaryRow createRow(Map<String, dynamic> data) =>
      VLoansAuditSummaryRow(data);
}

class VLoansAuditSummaryRow extends SupabaseDataRow {
  VLoansAuditSummaryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VLoansAuditSummaryTable();

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  int? get changeCount => getField<int>('change_count');
  set changeCount(int? value) => setField<int>('change_count', value);

  DateTime? get lastChangedAt => getField<DateTime>('last_changed_at');
  set lastChangedAt(DateTime? value) =>
      setField<DateTime>('last_changed_at', value);

  String? get lastAction => getField<String>('last_action');
  set lastAction(String? value) => setField<String>('last_action', value);
}
