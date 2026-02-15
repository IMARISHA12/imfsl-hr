import '../database.dart';

class LoanTransactionsTable extends SupabaseTable<LoanTransactionsRow> {
  @override
  String get tableName => 'loan_transactions';

  @override
  LoanTransactionsRow createRow(Map<String, dynamic> data) =>
      LoanTransactionsRow(data);
}

class LoanTransactionsRow extends SupabaseDataRow {
  LoanTransactionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanTransactionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String? get paymentMethod => getField<String>('payment_method');
  set paymentMethod(String? value) => setField<String>('payment_method', value);

  String? get collectedBy => getField<String>('collected_by');
  set collectedBy(String? value) => setField<String>('collected_by', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
