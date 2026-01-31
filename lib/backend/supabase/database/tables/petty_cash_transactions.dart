import '../database.dart';

class PettyCashTransactionsTable
    extends SupabaseTable<PettyCashTransactionsRow> {
  @override
  String get tableName => 'petty_cash_transactions';

  @override
  PettyCashTransactionsRow createRow(Map<String, dynamic> data) =>
      PettyCashTransactionsRow(data);
}

class PettyCashTransactionsRow extends SupabaseDataRow {
  PettyCashTransactionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PettyCashTransactionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get cashierEmployeeId => getField<String>('cashier_employee_id')!;
  set cashierEmployeeId(String value) =>
      setField<String>('cashier_employee_id', value);

  DateTime get transactionDate => getField<DateTime>('transaction_date')!;
  set transactionDate(DateTime value) =>
      setField<DateTime>('transaction_date', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String? get receiptUrl => getField<String>('receipt_url');
  set receiptUrl(String? value) => setField<String>('receipt_url', value);

  dynamic get aiAnalysis => getField<dynamic>('ai_analysis');
  set aiAnalysis(dynamic value) => setField<dynamic>('ai_analysis', value);

  bool? get reconciled => getField<bool>('reconciled');
  set reconciled(bool? value) => setField<bool>('reconciled', value);
}
