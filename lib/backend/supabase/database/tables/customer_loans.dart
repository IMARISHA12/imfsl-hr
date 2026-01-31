import '../database.dart';

class CustomerLoansTable extends SupabaseTable<CustomerLoansRow> {
  @override
  String get tableName => 'customer_loans';

  @override
  CustomerLoansRow createRow(Map<String, dynamic> data) =>
      CustomerLoansRow(data);
}

class CustomerLoansRow extends SupabaseDataRow {
  CustomerLoansRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CustomerLoansTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get customerId => getField<String>('customer_id')!;
  set customerId(String value) => setField<String>('customer_id', value);

  double get amountRequested => getField<double>('amount_requested')!;
  set amountRequested(double value) =>
      setField<double>('amount_requested', value);

  double? get amountApproved => getField<double>('amount_approved');
  set amountApproved(double? value) =>
      setField<double>('amount_approved', value);

  double get interestRate => getField<double>('interest_rate')!;
  set interestRate(double value) => setField<double>('interest_rate', value);

  int get durationDays => getField<int>('duration_days')!;
  set durationDays(int value) => setField<int>('duration_days', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get disbursementChannel => getField<String>('disbursement_channel');
  set disbursementChannel(String? value) =>
      setField<String>('disbursement_channel', value);

  String? get disbursementRef => getField<String>('disbursement_ref');
  set disbursementRef(String? value) =>
      setField<String>('disbursement_ref', value);

  String? get collateralDeviceId => getField<String>('collateral_device_id');
  set collateralDeviceId(String? value) =>
      setField<String>('collateral_device_id', value);

  DateTime? get dueDate => getField<DateTime>('due_date');
  set dueDate(DateTime? value) => setField<DateTime>('due_date', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
