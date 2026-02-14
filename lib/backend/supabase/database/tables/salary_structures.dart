import '../database.dart';

class SalaryStructuresTable extends SupabaseTable<SalaryStructuresRow> {
  @override
  String get tableName => 'salary_structures';

  @override
  SalaryStructuresRow createRow(Map<String, dynamic> data) =>
      SalaryStructuresRow(data);
}

class SalaryStructuresRow extends SupabaseDataRow {
  SalaryStructuresRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SalaryStructuresTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

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

  double? get grossSalary => getField<double>('gross_salary');
  set grossSalary(double? value) => setField<double>('gross_salary', value);

  DateTime get effectiveFrom => getField<DateTime>('effective_from')!;
  set effectiveFrom(DateTime value) =>
      setField<DateTime>('effective_from', value);

  DateTime? get effectiveTo => getField<DateTime>('effective_to');
  set effectiveTo(DateTime? value) =>
      setField<DateTime>('effective_to', value);

  bool get isCurrent => getField<bool>('is_current')!;
  set isCurrent(bool value) => setField<bool>('is_current', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
