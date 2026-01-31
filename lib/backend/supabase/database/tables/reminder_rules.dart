import '../database.dart';

class ReminderRulesTable extends SupabaseTable<ReminderRulesRow> {
  @override
  String get tableName => 'reminder_rules';

  @override
  ReminderRulesRow createRow(Map<String, dynamic> data) =>
      ReminderRulesRow(data);
}

class ReminderRulesRow extends SupabaseDataRow {
  ReminderRulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReminderRulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get ruleType => getField<String>('rule_type')!;
  set ruleType(String value) => setField<String>('rule_type', value);

  List<int> get daysBeforeDue => getListField<int>('days_before_due');
  set daysBeforeDue(List<int> value) =>
      setListField<int>('days_before_due', value);

  List<String> get channels => getListField<String>('channels');
  set channels(List<String> value) => setListField<String>('channels', value);

  List<String> get recipientRoles => getListField<String>('recipient_roles');
  set recipientRoles(List<String> value) =>
      setListField<String>('recipient_roles', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  int? get escalationDays => getField<int>('escalation_days');
  set escalationDays(int? value) => setField<int>('escalation_days', value);

  String? get escalationRole => getField<String>('escalation_role');
  set escalationRole(String? value) =>
      setField<String>('escalation_role', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
