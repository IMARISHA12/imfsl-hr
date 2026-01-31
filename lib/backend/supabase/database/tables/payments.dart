import '../database.dart';

class PaymentsTable extends SupabaseTable<PaymentsRow> {
  @override
  String get tableName => 'payments';

  @override
  PaymentsRow createRow(Map<String, dynamic> data) => PaymentsRow(data);
}

class PaymentsRow extends SupabaseDataRow {
  PaymentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PaymentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  DateTime get paidAt => getField<DateTime>('paid_at')!;
  set paidAt(DateTime value) => setField<DateTime>('paid_at', value);

  String? get method => getField<String>('method');
  set method(String? value) => setField<String>('method', value);

  String? get referenceField => getField<String>('reference');
  set referenceField(String? value) => setField<String>('reference', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  bool get reversed => getField<bool>('reversed')!;
  set reversed(bool value) => setField<bool>('reversed', value);
}
