import '../database.dart';

class StaffSalaryLoansTable extends SupabaseTable<StaffSalaryLoansRow> {
  @override
  String get tableName => 'staff_salary_loans';

  @override
  StaffSalaryLoansRow createRow(Map<String, dynamic> data) =>
      StaffSalaryLoansRow(data);
}

class StaffSalaryLoansRow extends SupabaseDataRow {
  StaffSalaryLoansRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffSalaryLoansTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  double get loanAmount => getField<double>('loan_amount')!;
  set loanAmount(double value) => setField<double>('loan_amount', value);

  double get monthlyDeduction => getField<double>('monthly_deduction')!;
  set monthlyDeduction(double value) =>
      setField<double>('monthly_deduction', value);

  double get outstandingBalance => getField<double>('outstanding_balance')!;
  set outstandingBalance(double value) =>
      setField<double>('outstanding_balance', value);

  int get tenureMonths => getField<int>('tenure_months')!;
  set tenureMonths(int value) => setField<int>('tenure_months', value);

  double get interestRate => getField<double>('interest_rate')!;
  set interestRate(double value) => setField<double>('interest_rate', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get purpose => getField<String>('purpose');
  set purpose(String? value) => setField<String>('purpose', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  DateTime get startDate => getField<DateTime>('start_date')!;
  set startDate(DateTime value) => setField<DateTime>('start_date', value);

  DateTime? get endDate => getField<DateTime>('end_date');
  set endDate(DateTime? value) => setField<DateTime>('end_date', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
