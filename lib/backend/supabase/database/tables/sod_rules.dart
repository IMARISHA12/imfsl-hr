import '../database.dart';

class SodRulesTable extends SupabaseTable<SodRulesRow> {
  @override
  String get tableName => 'sod_rules';

  @override
  SodRulesRow createRow(Map<String, dynamic> data) => SodRulesRow(data);
}

class SodRulesRow extends SupabaseDataRow {
  SodRulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SodRulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get ruleName => getField<String>('rule_name')!;
  set ruleName(String value) => setField<String>('rule_name', value);

  String? get ruleDescription => getField<String>('rule_description');
  set ruleDescription(String? value) =>
      setField<String>('rule_description', value);

  String get actionA => getField<String>('action_a')!;
  set actionA(String value) => setField<String>('action_a', value);

  String get actionB => getField<String>('action_b')!;
  set actionB(String value) => setField<String>('action_b', value);

  String? get entityType => getField<String>('entity_type');
  set entityType(String? value) => setField<String>('entity_type', value);

  String? get module => getField<String>('module');
  set module(String? value) => setField<String>('module', value);

  String? get enforcementLevel => getField<String>('enforcement_level');
  set enforcementLevel(String? value) =>
      setField<String>('enforcement_level', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
