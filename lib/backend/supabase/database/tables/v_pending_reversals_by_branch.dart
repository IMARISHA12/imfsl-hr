import '../database.dart';

class VPendingReversalsByBranchTable
    extends SupabaseTable<VPendingReversalsByBranchRow> {
  @override
  String get tableName => 'v_pending_reversals_by_branch';

  @override
  VPendingReversalsByBranchRow createRow(Map<String, dynamic> data) =>
      VPendingReversalsByBranchRow(data);
}

class VPendingReversalsByBranchRow extends SupabaseDataRow {
  VPendingReversalsByBranchRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VPendingReversalsByBranchTable();

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  String? get reversalId => getField<String>('reversal_id');
  set reversalId(String? value) => setField<String>('reversal_id', value);

  String? get paymentId => getField<String>('payment_id');
  set paymentId(String? value) => setField<String>('payment_id', value);

  double? get amount => getField<double>('amount');
  set amount(double? value) => setField<double>('amount', value);

  DateTime? get paidAt => getField<DateTime>('paid_at');
  set paidAt(DateTime? value) => setField<DateTime>('paid_at', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get customerId => getField<String>('customer_id');
  set customerId(String? value) => setField<String>('customer_id', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  String? get requestedBy => getField<String>('requested_by');
  set requestedBy(String? value) => setField<String>('requested_by', value);

  DateTime? get requestedAt => getField<DateTime>('requested_at');
  set requestedAt(DateTime? value) => setField<DateTime>('requested_at', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
