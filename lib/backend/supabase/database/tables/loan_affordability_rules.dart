import '../database.dart';

class LoanAffordabilityRulesTable
    extends SupabaseTable<LoanAffordabilityRulesRow> {
  @override
  String get tableName => 'loan_affordability_rules';

  @override
  LoanAffordabilityRulesRow createRow(Map<String, dynamic> data) =>
      LoanAffordabilityRulesRow(data);
}

class LoanAffordabilityRulesRow extends SupabaseDataRow {
  LoanAffordabilityRulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanAffordabilityRulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get ruleName => getField<String>('rule_name')!;
  set ruleName(String value) => setField<String>('rule_name', value);

  double get minTakeHomeRatio => getField<double>('min_take_home_ratio')!;
  set minTakeHomeRatio(double value) =>
      setField<double>('min_take_home_ratio', value);

  int get maxDurationMonths => getField<int>('max_duration_months')!;
  set maxDurationMonths(int value) =>
      setField<int>('max_duration_months', value);

  double? get maxDtiRatio => getField<double>('max_dti_ratio');
  set maxDtiRatio(double? value) => setField<double>('max_dti_ratio', value);

  double? get minServiceYears => getField<double>('min_service_years');
  set minServiceYears(double? value) =>
      setField<double>('min_service_years', value);

  int? get maxLoanToRetirementMonths =>
      getField<int>('max_loan_to_retirement_months');
  set maxLoanToRetirementMonths(int? value) =>
      setField<int>('max_loan_to_retirement_months', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
