import '../database.dart';

class ControlNumbersTable extends SupabaseTable<ControlNumbersRow> {
  @override
  String get tableName => 'control_numbers';

  @override
  ControlNumbersRow createRow(Map<String, dynamic> data) =>
      ControlNumbersRow(data);
}

class ControlNumbersRow extends SupabaseDataRow {
  ControlNumbersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ControlNumbersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get clientId => getField<String>('client_id');
  set clientId(String? value) => setField<String>('client_id', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String get controlNumber => getField<String>('control_number')!;
  set controlNumber(String value) => setField<String>('control_number', value);

  String? get paymentStatus => getField<String>('payment_status');
  set paymentStatus(String? value) => setField<String>('payment_status', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
