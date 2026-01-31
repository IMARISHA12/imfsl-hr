import '../database.dart';

class StaffLoanRepaymentsTable extends SupabaseTable<StaffLoanRepaymentsRow> {
  @override
  String get tableName => 'staff_loan_repayments';

  @override
  StaffLoanRepaymentsRow createRow(Map<String, dynamic> data) =>
      StaffLoanRepaymentsRow(data);
}

class StaffLoanRepaymentsRow extends SupabaseDataRow {
  StaffLoanRepaymentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffLoanRepaymentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  int get installmentNumber => getField<int>('installment_number')!;
  set installmentNumber(int value) =>
      setField<int>('installment_number', value);

  DateTime get dueDate => getField<DateTime>('due_date')!;
  set dueDate(DateTime value) => setField<DateTime>('due_date', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  double? get paidAmount => getField<double>('paid_amount');
  set paidAmount(double? value) => setField<double>('paid_amount', value);

  DateTime? get paidDate => getField<DateTime>('paid_date');
  set paidDate(DateTime? value) => setField<DateTime>('paid_date', value);

  String? get payrollRunId => getField<String>('payroll_run_id');
  set payrollRunId(String? value) => setField<String>('payroll_run_id', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
