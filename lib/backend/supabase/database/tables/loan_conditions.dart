import '../database.dart';

class LoanConditionsTable extends SupabaseTable<LoanConditionsRow> {
  @override
  String get tableName => 'loan_conditions';

  @override
  LoanConditionsRow createRow(Map<String, dynamic> data) =>
      LoanConditionsRow(data);
}

class LoanConditionsRow extends SupabaseDataRow {
  LoanConditionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanConditionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get text => getField<String>('text')!;
  set text(String value) => setField<String>('text', value);

  bool get required => getField<bool>('required')!;
  set required(bool value) => setField<bool>('required', value);

  bool get fulfilled => getField<bool>('fulfilled')!;
  set fulfilled(bool value) => setField<bool>('fulfilled', value);

  DateTime? get fulfilledAt => getField<DateTime>('fulfilled_at');
  set fulfilledAt(DateTime? value) => setField<DateTime>('fulfilled_at', value);

  String? get fulfilledBy => getField<String>('fulfilled_by');
  set fulfilledBy(String? value) => setField<String>('fulfilled_by', value);

  String? get fulfilledByName => getField<String>('fulfilled_by_name');
  set fulfilledByName(String? value) =>
      setField<String>('fulfilled_by_name', value);

  String? get fulfillmentNotes => getField<String>('fulfillment_notes');
  set fulfillmentNotes(String? value) =>
      setField<String>('fulfillment_notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get createdByName => getField<String>('created_by_name');
  set createdByName(String? value) =>
      setField<String>('created_by_name', value);
}
