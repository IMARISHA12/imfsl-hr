import '../database.dart';

class FraudRulesTable extends SupabaseTable<FraudRulesRow> {
  @override
  String get tableName => 'fraud_rules';

  @override
  FraudRulesRow createRow(Map<String, dynamic> data) => FraudRulesRow(data);
}

class FraudRulesRow extends SupabaseDataRow {
  FraudRulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FraudRulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get ruleCode => getField<String>('rule_code')!;
  set ruleCode(String value) => setField<String>('rule_code', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get alertType => getField<String>('alert_type')!;
  set alertType(String value) => setField<String>('alert_type', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  dynamic get conditions => getField<dynamic>('conditions')!;
  set conditions(dynamic value) => setField<dynamic>('conditions', value);

  bool? get autoBlock => getField<bool>('auto_block');
  set autoBlock(bool? value) => setField<bool>('auto_block', value);

  bool? get autoNotifyManager => getField<bool>('auto_notify_manager');
  set autoNotifyManager(bool? value) =>
      setField<bool>('auto_notify_manager', value);

  bool? get autoNotifyDirector => getField<bool>('auto_notify_director');
  set autoNotifyDirector(bool? value) =>
      setField<bool>('auto_notify_director', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
