import '../database.dart';

class CustomerActiveLoanBalanceTable
    extends SupabaseTable<CustomerActiveLoanBalanceRow> {
  @override
  String get tableName => 'customer_active_loan_balance';

  @override
  CustomerActiveLoanBalanceRow createRow(Map<String, dynamic> data) =>
      CustomerActiveLoanBalanceRow(data);
}

class CustomerActiveLoanBalanceRow extends SupabaseDataRow {
  CustomerActiveLoanBalanceRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CustomerActiveLoanBalanceTable();

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  double? get principalAmount => getField<double>('principal_amount');
  set principalAmount(double? value) =>
      setField<double>('principal_amount', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  double? get totalPaid => getField<double>('total_paid');
  set totalPaid(double? value) => setField<double>('total_paid', value);

  double? get outstandingBalance => getField<double>('outstanding_balance');
  set outstandingBalance(double? value) =>
      setField<double>('outstanding_balance', value);
}
