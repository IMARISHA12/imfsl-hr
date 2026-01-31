import '../database.dart';

class AlertEscalationRulesTable extends SupabaseTable<AlertEscalationRulesRow> {
  @override
  String get tableName => 'alert_escalation_rules';

  @override
  AlertEscalationRulesRow createRow(Map<String, dynamic> data) =>
      AlertEscalationRulesRow(data);
}

class AlertEscalationRulesRow extends SupabaseDataRow {
  AlertEscalationRulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertEscalationRulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  dynamic get condition => getField<dynamic>('condition');
  set condition(dynamic value) => setField<dynamic>('condition', value);

  String? get escalationLevel => getField<String>('escalation_level');
  set escalationLevel(String? value) =>
      setField<String>('escalation_level', value);

  List<String> get notifyRoles => getListField<String>('notify_roles');
  set notifyRoles(List<String>? value) =>
      setListField<String>('notify_roles', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
