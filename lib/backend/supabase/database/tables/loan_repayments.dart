import '../database.dart';

class LoanRepaymentsTable extends SupabaseTable<LoanRepaymentsRow> {
  @override
  String get tableName => 'loan_repayments';

  @override
  LoanRepaymentsRow createRow(Map<String, dynamic> data) =>
      LoanRepaymentsRow(data);
}

class LoanRepaymentsRow extends SupabaseDataRow {
  LoanRepaymentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanRepaymentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get receiptNumber => getField<String>('receipt_number')!;
  set receiptNumber(String value) => setField<String>('receipt_number', value);

  DateTime get paymentDate => getField<DateTime>('payment_date')!;
  set paymentDate(DateTime value) => setField<DateTime>('payment_date', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  double? get principalPaid => getField<double>('principal_paid');
  set principalPaid(double? value) => setField<double>('principal_paid', value);

  double? get interestPaid => getField<double>('interest_paid');
  set interestPaid(double? value) => setField<double>('interest_paid', value);

  double? get penaltyPaid => getField<double>('penalty_paid');
  set penaltyPaid(double? value) => setField<double>('penalty_paid', value);

  String get paymentMethod => getField<String>('payment_method')!;
  set paymentMethod(String value) => setField<String>('payment_method', value);

  String? get referenceNumber => getField<String>('reference_number');
  set referenceNumber(String? value) =>
      setField<String>('reference_number', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String? get processedBy => getField<String>('processed_by');
  set processedBy(String? value) => setField<String>('processed_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get voucherId => getField<String>('voucher_id');
  set voucherId(String? value) => setField<String>('voucher_id', value);
}
