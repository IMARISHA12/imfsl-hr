import '../database.dart';

class LoanProductsTable extends SupabaseTable<LoanProductsRow> {
  @override
  String get tableName => 'loan_products';

  @override
  LoanProductsRow createRow(Map<String, dynamic> data) => LoanProductsRow(data);
}

class LoanProductsRow extends SupabaseDataRow {
  LoanProductsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanProductsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get productName => getField<String>('product_name')!;
  set productName(String value) => setField<String>('product_name', value);

  String get productCode => getField<String>('product_code')!;
  set productCode(String value) => setField<String>('product_code', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double get minAmount => getField<double>('min_amount')!;
  set minAmount(double value) => setField<double>('min_amount', value);

  double get maxAmount => getField<double>('max_amount')!;
  set maxAmount(double value) => setField<double>('max_amount', value);

  int get minTenureMonths => getField<int>('min_tenure_months')!;
  set minTenureMonths(int value) => setField<int>('min_tenure_months', value);

  int get maxTenureMonths => getField<int>('max_tenure_months')!;
  set maxTenureMonths(int value) => setField<int>('max_tenure_months', value);

  double get interestRate => getField<double>('interest_rate')!;
  set interestRate(double value) => setField<double>('interest_rate', value);

  String get interestCalculationMethod =>
      getField<String>('interest_calculation_method')!;
  set interestCalculationMethod(String value) =>
      setField<String>('interest_calculation_method', value);

  double? get processingFeePercentage =>
      getField<double>('processing_fee_percentage');
  set processingFeePercentage(double? value) =>
      setField<double>('processing_fee_percentage', value);

  double? get penaltyRate => getField<double>('penalty_rate');
  set penaltyRate(double? value) => setField<double>('penalty_rate', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  double? get minInterest => getField<double>('min_interest');
  set minInterest(double? value) => setField<double>('min_interest', value);

  double? get maxInterest => getField<double>('max_interest');
  set maxInterest(double? value) => setField<double>('max_interest', value);
}
