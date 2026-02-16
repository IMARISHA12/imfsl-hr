import '../database.dart';

class FraudDetectionRulesTable
    extends SupabaseTable<FraudDetectionRulesRow> {
  @override
  String get tableName => 'fraud_detection_rules';

  @override
  FraudDetectionRulesRow createRow(Map<String, dynamic> data) =>
      FraudDetectionRulesRow(data);
}

class FraudDetectionRulesRow extends SupabaseDataRow {
  FraudDetectionRulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FraudDetectionRulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get ruleCode => getField<String>('rule_code')!;
  set ruleCode(String value) => setField<String>('rule_code', value);

  String get ruleName => getField<String>('rule_name')!;
  set ruleName(String value) => setField<String>('rule_name', value);

  String? get description => getField<String>('description');
  set description(String? value) =>
      setField<String>('description', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  int get riskScoreContribution =>
      getField<int>('risk_score_contribution')!;
  set riskScoreContribution(int value) =>
      setField<int>('risk_score_contribution', value);

  dynamic get thresholdConfig =>
      getField<dynamic>('threshold_config');
  set thresholdConfig(dynamic value) =>
      setField<dynamic>('threshold_config', value);

  bool get isActive => getField<bool>('is_active') ?? true;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) =>
      setField<DateTime>('created_at', value);
}
