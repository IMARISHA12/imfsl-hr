import '../database.dart';

class StaffLoansTable extends SupabaseTable<StaffLoansRow> {
  @override
  String get tableName => 'staff_loans';

  @override
  StaffLoansRow createRow(Map<String, dynamic> data) => StaffLoansRow(data);
}

class StaffLoansRow extends SupabaseDataRow {
  StaffLoansRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffLoansTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  double get requestedAmount => getField<double>('requested_amount')!;
  set requestedAmount(double value) =>
      setField<double>('requested_amount', value);

  double? get approvedAmount => getField<double>('approved_amount');
  set approvedAmount(double? value) =>
      setField<double>('approved_amount', value);

  int get repaymentMonths => getField<int>('repayment_months')!;
  set repaymentMonths(int value) => setField<int>('repayment_months', value);

  double get monthlyInstallment => getField<double>('monthly_installment')!;
  set monthlyInstallment(double value) =>
      setField<double>('monthly_installment', value);

  double? get interestRate => getField<double>('interest_rate');
  set interestRate(double? value) => setField<double>('interest_rate', value);

  String get purpose => getField<String>('purpose')!;
  set purpose(String value) => setField<String>('purpose', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  double? get remainingBalance => getField<double>('remaining_balance');
  set remainingBalance(double? value) =>
      setField<double>('remaining_balance', value);

  double? get totalPaid => getField<double>('total_paid');
  set totalPaid(double? value) => setField<double>('total_paid', value);

  String? get decisionNotes => getField<String>('decision_notes');
  set decisionNotes(String? value) => setField<String>('decision_notes', value);

  double? get counterOfferAmount => getField<double>('counter_offer_amount');
  set counterOfferAmount(double? value) =>
      setField<double>('counter_offer_amount', value);

  int? get counterOfferMonths => getField<int>('counter_offer_months');
  set counterOfferMonths(int? value) =>
      setField<int>('counter_offer_months', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  DateTime? get disbursedAt => getField<DateTime>('disbursed_at');
  set disbursedAt(DateTime? value) => setField<DateTime>('disbursed_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
