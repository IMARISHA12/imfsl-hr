import '../database.dart';

class VOverdueLoansSummaryTable extends SupabaseTable<VOverdueLoansSummaryRow> {
  @override
  String get tableName => 'v_overdue_loans_summary';

  @override
  VOverdueLoansSummaryRow createRow(Map<String, dynamic> data) =>
      VOverdueLoansSummaryRow(data);
}

class VOverdueLoansSummaryRow extends SupabaseDataRow {
  VOverdueLoansSummaryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VOverdueLoansSummaryTable();

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get clientName => getField<String>('client_name');
  set clientName(String? value) => setField<String>('client_name', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  double? get balance => getField<double>('balance');
  set balance(double? value) => setField<double>('balance', value);

  DateTime? get nextPaymentDate => getField<DateTime>('next_payment_date');
  set nextPaymentDate(DateTime? value) =>
      setField<DateTime>('next_payment_date', value);

  int? get daysPastDue => getField<int>('days_past_due');
  set daysPastDue(int? value) => setField<int>('days_past_due', value);

  String? get alertLevel => getField<String>('alert_level');
  set alertLevel(String? value) => setField<String>('alert_level', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
