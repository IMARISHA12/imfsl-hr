import '../database.dart';

class RepaymentsTable extends SupabaseTable<RepaymentsRow> {
  @override
  String get tableName => 'repayments';

  @override
  RepaymentsRow createRow(Map<String, dynamic> data) => RepaymentsRow(data);
}

class RepaymentsRow extends SupabaseDataRow {
  RepaymentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RepaymentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  double get amountPaid => getField<double>('amount_paid')!;
  set amountPaid(double value) => setField<double>('amount_paid', value);

  String? get paymentMethod => getField<String>('payment_method');
  set paymentMethod(String? value) => setField<String>('payment_method', value);

  String? get receiptRef => getField<String>('receipt_ref');
  set receiptRef(String? value) => setField<String>('receipt_ref', value);

  String? get collectedBy => getField<String>('collected_by');
  set collectedBy(String? value) => setField<String>('collected_by', value);

  DateTime? get paidAt => getField<DateTime>('paid_at');
  set paidAt(DateTime? value) => setField<DateTime>('paid_at', value);
}
