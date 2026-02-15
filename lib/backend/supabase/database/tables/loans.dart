import '../database.dart';

class LoansTable extends SupabaseTable<LoansRow> {
  @override
  String get tableName => 'loans';

  @override
  LoansRow createRow(Map<String, dynamic> data) => LoansRow(data);
}

class LoansRow extends SupabaseDataRow {
  LoansRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoansTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get borrowerId => getField<String>('borrower_id')!;
  set borrowerId(String value) => setField<String>('borrower_id', value);

  double get amountPrincipal => getField<double>('amount_principal')!;
  set amountPrincipal(double value) =>
      setField<double>('amount_principal', value);

  double get interestRate => getField<double>('interest_rate')!;
  set interestRate(double value) => setField<double>('interest_rate', value);

  int get durationMonths => getField<int>('duration_months')!;
  set durationMonths(int value) => setField<int>('duration_months', value);

  double? get totalDue => getField<double>('total_due');
  set totalDue(double? value) => setField<double>('total_due', value);

  DateTime? get startDate => getField<DateTime>('start_date');
  set startDate(DateTime? value) => setField<DateTime>('start_date', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get loanNumber => getField<String>('loan_number');
  set loanNumber(String? value) => setField<String>('loan_number', value);

  String? get officerId => getField<String>('officer_id');
  set officerId(String? value) => setField<String>('officer_id', value);

  double? get outstandingBalance => getField<double>('outstanding_balance');
  set outstandingBalance(double? value) =>
      setField<double>('outstanding_balance', value);

  double? get totalPaid => getField<double>('total_paid');
  set totalPaid(double? value) => setField<double>('total_paid', value);

  int? get daysOverdue => getField<int>('days_overdue');
  set daysOverdue(int? value) => setField<int>('days_overdue', value);

  DateTime? get lastPaymentDate => getField<DateTime>('last_payment_date');
  set lastPaymentDate(DateTime? value) =>
      setField<DateTime>('last_payment_date', value);

  String? get productType => getField<String>('product_type');
  set productType(String? value) => setField<String>('product_type', value);

  DateTime? get disbursedAt => getField<DateTime>('disbursed_at');
  set disbursedAt(DateTime? value) => setField<DateTime>('disbursed_at', value);

  String? get branch => getField<String>('branch');
  set branch(String? value) => setField<String>('branch', value);
}
