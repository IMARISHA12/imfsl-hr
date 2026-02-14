import '../database.dart';

class PayslipDeductionsTable extends SupabaseTable<PayslipDeductionsRow> {
  @override
  String get tableName => 'payslip_deductions';

  @override
  PayslipDeductionsRow createRow(Map<String, dynamic> data) =>
      PayslipDeductionsRow(data);
}

class PayslipDeductionsRow extends SupabaseDataRow {
  PayslipDeductionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PayslipDeductionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get payslipId => getField<String>('payslip_id')!;
  set payslipId(String value) => setField<String>('payslip_id', value);

  String get deductionCode => getField<String>('deduction_code')!;
  set deductionCode(String value) =>
      setField<String>('deduction_code', value);

  String? get deductionName => getField<String>('deduction_name');
  set deductionName(String? value) =>
      setField<String>('deduction_name', value);

  double get employeeAmount => getField<double>('employee_amount')!;
  set employeeAmount(double value) =>
      setField<double>('employee_amount', value);

  double get employerAmount => getField<double>('employer_amount')!;
  set employerAmount(double value) =>
      setField<double>('employer_amount', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
