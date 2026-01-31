import '../database.dart';

class PromiseToPayTable extends SupabaseTable<PromiseToPayRow> {
  @override
  String get tableName => 'promise_to_pay';

  @override
  PromiseToPayRow createRow(Map<String, dynamic> data) => PromiseToPayRow(data);
}

class PromiseToPayRow extends SupabaseDataRow {
  PromiseToPayRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PromiseToPayTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  DateTime get promisedDate => getField<DateTime>('promised_date')!;
  set promisedDate(DateTime value) =>
      setField<DateTime>('promised_date', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
