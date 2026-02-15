import '../database.dart';

class FinTransactionsTable extends SupabaseTable<FinTransactionsRow> {
  @override
  String get tableName => 'fin_transactions';

  @override
  FinTransactionsRow createRow(Map<String, dynamic> data) =>
      FinTransactionsRow(data);
}

class FinTransactionsRow extends SupabaseDataRow {
  FinTransactionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FinTransactionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get loandiskTransactionId =>
      getField<String>('loandisk_transaction_id');
  set loandiskTransactionId(String? value) =>
      setField<String>('loandisk_transaction_id', value);

  DateTime? get transactionDate => getField<DateTime>('transaction_date');
  set transactionDate(DateTime? value) =>
      setField<DateTime>('transaction_date', value);

  double? get amount => getField<double>('amount');
  set amount(double? value) => setField<double>('amount', value);

  String? get paymentMethod => getField<String>('payment_method');
  set paymentMethod(String? value) => setField<String>('payment_method', value);

  String? get receiptNumber => getField<String>('receipt_number');
  set receiptNumber(String? value) => setField<String>('receipt_number', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
