import '../database.dart';

class PayslipsTable extends SupabaseTable<PayslipsRow> {
  @override
  String get tableName => 'payslips';

  @override
  PayslipsRow createRow(Map<String, dynamic> data) => PayslipsRow(data);
}

class PayslipsRow extends SupabaseDataRow {
  PayslipsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PayslipsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get payrollRunId => getField<String>('payroll_run_id')!;
  set payrollRunId(String value) => setField<String>('payroll_run_id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  String get employeeName => getField<String>('employee_name')!;
  set employeeName(String value) => setField<String>('employee_name', value);

  String? get employeeCode => getField<String>('employee_code');
  set employeeCode(String? value) => setField<String>('employee_code', value);

  String? get department => getField<String>('department');
  set department(String? value) => setField<String>('department', value);

  double get basicSalary => getField<double>('basic_salary')!;
  set basicSalary(double value) => setField<double>('basic_salary', value);

  double get housingAllowance => getField<double>('housing_allowance')!;
  set housingAllowance(double value) =>
      setField<double>('housing_allowance', value);

  double get transportAllowance => getField<double>('transport_allowance')!;
  set transportAllowance(double value) =>
      setField<double>('transport_allowance', value);

  double get mealAllowance => getField<double>('meal_allowance')!;
  set mealAllowance(double value) => setField<double>('meal_allowance', value);

  double get medicalAllowance => getField<double>('medical_allowance')!;
  set medicalAllowance(double value) =>
      setField<double>('medical_allowance', value);

  double get communicationAllowance =>
      getField<double>('communication_allowance')!;
  set communicationAllowance(double value) =>
      setField<double>('communication_allowance', value);

  double get otherAllowances => getField<double>('other_allowances')!;
  set otherAllowances(double value) =>
      setField<double>('other_allowances', value);

  double get overtimePay => getField<double>('overtime_pay')!;
  set overtimePay(double value) => setField<double>('overtime_pay', value);

  double get bonus => getField<double>('bonus')!;
  set bonus(double value) => setField<double>('bonus', value);

  double get grossSalary => getField<double>('gross_salary')!;
  set grossSalary(double value) => setField<double>('gross_salary', value);

  double get payeTax => getField<double>('paye_tax')!;
  set payeTax(double value) => setField<double>('paye_tax', value);

  double get nssfEmployee => getField<double>('nssf_employee')!;
  set nssfEmployee(double value) => setField<double>('nssf_employee', value);

  double get nssfEmployer => getField<double>('nssf_employer')!;
  set nssfEmployer(double value) => setField<double>('nssf_employer', value);

  double get wcfContribution => getField<double>('wcf_contribution')!;
  set wcfContribution(double value) =>
      setField<double>('wcf_contribution', value);

  double get sdlContribution => getField<double>('sdl_contribution')!;
  set sdlContribution(double value) =>
      setField<double>('sdl_contribution', value);

  double get heslbDeduction => getField<double>('heslb_deduction')!;
  set heslbDeduction(double value) =>
      setField<double>('heslb_deduction', value);

  double get loanDeduction => getField<double>('loan_deduction')!;
  set loanDeduction(double value) => setField<double>('loan_deduction', value);

  double get otherDeductions => getField<double>('other_deductions')!;
  set otherDeductions(double value) =>
      setField<double>('other_deductions', value);

  double get totalDeductions => getField<double>('total_deductions')!;
  set totalDeductions(double value) =>
      setField<double>('total_deductions', value);

  double get netSalary => getField<double>('net_salary')!;
  set netSalary(double value) => setField<double>('net_salary', value);

  String? get bankName => getField<String>('bank_name');
  set bankName(String? value) => setField<String>('bank_name', value);

  String? get bankAccountNumber => getField<String>('bank_account_number');
  set bankAccountNumber(String? value) =>
      setField<String>('bank_account_number', value);

  String get paymentStatus => getField<String>('payment_status')!;
  set paymentStatus(String value) => setField<String>('payment_status', value);

  String? get paymentReference => getField<String>('payment_reference');
  set paymentReference(String? value) =>
      setField<String>('payment_reference', value);

  DateTime? get paidAt => getField<DateTime>('paid_at');
  set paidAt(DateTime? value) => setField<DateTime>('paid_at', value);

  int? get daysWorked => getField<int>('days_worked');
  set daysWorked(int? value) => setField<int>('days_worked', value);

  int? get daysAbsent => getField<int>('days_absent');
  set daysAbsent(int? value) => setField<int>('days_absent', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
