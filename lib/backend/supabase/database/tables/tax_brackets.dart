import '../database.dart';

class TaxBracketsTable extends SupabaseTable<TaxBracketsRow> {
  @override
  String get tableName => 'tax_brackets';

  @override
  TaxBracketsRow createRow(Map<String, dynamic> data) => TaxBracketsRow(data);
}

class TaxBracketsRow extends SupabaseDataRow {
  TaxBracketsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TaxBracketsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get bracketName => getField<String>('bracket_name')!;
  set bracketName(String value) => setField<String>('bracket_name', value);

  double get minAmount => getField<double>('min_amount')!;
  set minAmount(double value) => setField<double>('min_amount', value);

  double? get maxAmount => getField<double>('max_amount');
  set maxAmount(double? value) => setField<double>('max_amount', value);

  double get ratePercent => getField<double>('rate_percent')!;
  set ratePercent(double value) => setField<double>('rate_percent', value);

  double get fixedAmount => getField<double>('fixed_amount')!;
  set fixedAmount(double value) => setField<double>('fixed_amount', value);

  DateTime get effectiveFrom => getField<DateTime>('effective_from')!;
  set effectiveFrom(DateTime value) =>
      setField<DateTime>('effective_from', value);

  DateTime? get effectiveTo => getField<DateTime>('effective_to');
  set effectiveTo(DateTime? value) =>
      setField<DateTime>('effective_to', value);

  String get countryCode => getField<String>('country_code')!;
  set countryCode(String value) => setField<String>('country_code', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
