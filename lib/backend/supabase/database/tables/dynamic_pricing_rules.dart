import '../database.dart';

class DynamicPricingRulesTable extends SupabaseTable<DynamicPricingRulesRow> {
  @override
  String get tableName => 'dynamic_pricing_rules';

  @override
  DynamicPricingRulesRow createRow(Map<String, dynamic> data) =>
      DynamicPricingRulesRow(data);
}

class DynamicPricingRulesRow extends SupabaseDataRow {
  DynamicPricingRulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DynamicPricingRulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  double get baseRate => getField<double>('base_rate')!;
  set baseRate(double value) => setField<double>('base_rate', value);

  int? get minTrustScore => getField<int>('min_trust_score');
  set minTrustScore(int? value) => setField<int>('min_trust_score', value);

  int? get maxTrustScore => getField<int>('max_trust_score');
  set maxTrustScore(int? value) => setField<int>('max_trust_score', value);

  double get riskPremium => getField<double>('risk_premium')!;
  set riskPremium(double value) => setField<double>('risk_premium', value);

  double? get effectiveRate => getField<double>('effective_rate');
  set effectiveRate(double? value) => setField<double>('effective_rate', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
