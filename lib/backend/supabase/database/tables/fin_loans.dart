import '../database.dart';

class FinLoansTable extends SupabaseTable<FinLoansRow> {
  @override
  String get tableName => 'fin_loans';

  @override
  FinLoansRow createRow(Map<String, dynamic> data) => FinLoansRow(data);
}

class FinLoansRow extends SupabaseDataRow {
  FinLoansRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FinLoansTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get borrowerId => getField<String>('borrower_id');
  set borrowerId(String? value) => setField<String>('borrower_id', value);

  String? get vehicleId => getField<String>('vehicle_id');
  set vehicleId(String? value) => setField<String>('vehicle_id', value);

  String? get loandiskLoanId => getField<String>('loandisk_loan_id');
  set loandiskLoanId(String? value) =>
      setField<String>('loandisk_loan_id', value);

  String? get loanProductName => getField<String>('loan_product_name');
  set loanProductName(String? value) =>
      setField<String>('loan_product_name', value);

  double? get principalAmount => getField<double>('principal_amount');
  set principalAmount(double? value) =>
      setField<double>('principal_amount', value);

  double? get interestRate => getField<double>('interest_rate');
  set interestRate(double? value) => setField<double>('interest_rate', value);

  int? get durationMonths => getField<int>('duration_months');
  set durationMonths(int? value) => setField<int>('duration_months', value);

  double? get totalDue => getField<double>('total_due');
  set totalDue(double? value) => setField<double>('total_due', value);

  double? get totalPaid => getField<double>('total_paid');
  set totalPaid(double? value) => setField<double>('total_paid', value);

  double? get balanceOutstanding => getField<double>('balance_outstanding');
  set balanceOutstanding(double? value) =>
      setField<double>('balance_outstanding', value);

  String? get loanStatus => getField<String>('loan_status');
  set loanStatus(String? value) => setField<String>('loan_status', value);

  DateTime? get releasedDate => getField<DateTime>('released_date');
  set releasedDate(DateTime? value) =>
      setField<DateTime>('released_date', value);

  DateTime? get dueDate => getField<DateTime>('due_date');
  set dueDate(DateTime? value) => setField<DateTime>('due_date', value);

  DateTime? get lastSyncedAt => getField<DateTime>('last_synced_at');
  set lastSyncedAt(DateTime? value) =>
      setField<DateTime>('last_synced_at', value);
}
