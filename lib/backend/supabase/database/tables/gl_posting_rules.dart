import '../database.dart';

class GlPostingRulesTable extends SupabaseTable<GlPostingRulesRow> {
  @override
  String get tableName => 'gl_posting_rules';

  @override
  GlPostingRulesRow createRow(Map<String, dynamic> data) =>
      GlPostingRulesRow(data);
}

class GlPostingRulesRow extends SupabaseDataRow {
  GlPostingRulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GlPostingRulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  String get ruleName => getField<String>('rule_name')!;
  set ruleName(String value) => setField<String>('rule_name', value);

  int get ruleVersion => getField<int>('rule_version')!;
  set ruleVersion(int value) => setField<int>('rule_version', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  dynamic get template => getField<dynamic>('template')!;
  set template(dynamic value) => setField<dynamic>('template', value);

  dynamic get conditions => getField<dynamic>('conditions');
  set conditions(dynamic value) => setField<dynamic>('conditions', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
