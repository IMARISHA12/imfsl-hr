import '../database.dart';

class StatutoryDeductionsTable
    extends SupabaseTable<StatutoryDeductionsRow> {
  @override
  String get tableName => 'statutory_deductions';

  @override
  StatutoryDeductionsRow createRow(Map<String, dynamic> data) =>
      StatutoryDeductionsRow(data);
}

class StatutoryDeductionsRow extends SupabaseDataRow {
  StatutoryDeductionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StatutoryDeductionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get deductionCode => getField<String>('deduction_code')!;
  set deductionCode(String value) =>
      setField<String>('deduction_code', value);

  String get deductionName => getField<String>('deduction_name')!;
  set deductionName(String value) =>
      setField<String>('deduction_name', value);

  double get employeeRatePercent =>
      getField<double>('employee_rate_percent')!;
  set employeeRatePercent(double value) =>
      setField<double>('employee_rate_percent', value);

  double get employerRatePercent =>
      getField<double>('employer_rate_percent')!;
  set employerRatePercent(double value) =>
      setField<double>('employer_rate_percent', value);

  double? get maxEmployeeAmount => getField<double>('max_employee_amount');
  set maxEmployeeAmount(double? value) =>
      setField<double>('max_employee_amount', value);

  double? get maxEmployerAmount => getField<double>('max_employer_amount');
  set maxEmployerAmount(double? value) =>
      setField<double>('max_employer_amount', value);

  bool get isMandatory => getField<bool>('is_mandatory')!;
  set isMandatory(bool value) => setField<bool>('is_mandatory', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get effectiveFrom => getField<DateTime>('effective_from')!;
  set effectiveFrom(DateTime value) =>
      setField<DateTime>('effective_from', value);

  DateTime? get effectiveTo => getField<DateTime>('effective_to');
  set effectiveTo(DateTime? value) =>
      setField<DateTime>('effective_to', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
