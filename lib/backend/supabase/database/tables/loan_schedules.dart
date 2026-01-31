import '../database.dart';

class LoanSchedulesTable extends SupabaseTable<LoanSchedulesRow> {
  @override
  String get tableName => 'loan_schedules';

  @override
  LoanSchedulesRow createRow(Map<String, dynamic> data) =>
      LoanSchedulesRow(data);
}

class LoanSchedulesRow extends SupabaseDataRow {
  LoanSchedulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanSchedulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  int get installmentNumber => getField<int>('installment_number')!;
  set installmentNumber(int value) =>
      setField<int>('installment_number', value);

  DateTime get dueDate => getField<DateTime>('due_date')!;
  set dueDate(DateTime value) => setField<DateTime>('due_date', value);

  double get principalDue => getField<double>('principal_due')!;
  set principalDue(double value) => setField<double>('principal_due', value);

  double get interestDue => getField<double>('interest_due')!;
  set interestDue(double value) => setField<double>('interest_due', value);

  double get totalDue => getField<double>('total_due')!;
  set totalDue(double value) => setField<double>('total_due', value);

  double get amountPaid => getField<double>('amount_paid')!;
  set amountPaid(double value) => setField<double>('amount_paid', value);

  double get balanceAfter => getField<double>('balance_after')!;
  set balanceAfter(double value) => setField<double>('balance_after', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get paidDate => getField<DateTime>('paid_date');
  set paidDate(DateTime? value) => setField<DateTime>('paid_date', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  double? get penaltyDue => getField<double>('penalty_due');
  set penaltyDue(double? value) => setField<double>('penalty_due', value);

  double? get penaltyPaid => getField<double>('penalty_paid');
  set penaltyPaid(double? value) => setField<double>('penalty_paid', value);
}
