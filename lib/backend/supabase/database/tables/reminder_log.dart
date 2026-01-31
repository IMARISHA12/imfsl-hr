import '../database.dart';

class ReminderLogTable extends SupabaseTable<ReminderLogRow> {
  @override
  String get tableName => 'reminder_log';

  @override
  ReminderLogRow createRow(Map<String, dynamic> data) => ReminderLogRow(data);
}

class ReminderLogRow extends SupabaseDataRow {
  ReminderLogRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReminderLogTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get reminderRuleId => getField<String>('reminder_rule_id');
  set reminderRuleId(String? value) =>
      setField<String>('reminder_rule_id', value);

  String get itemType => getField<String>('item_type')!;
  set itemType(String value) => setField<String>('item_type', value);

  String get itemId => getField<String>('item_id')!;
  set itemId(String value) => setField<String>('item_id', value);

  String get itemName => getField<String>('item_name')!;
  set itemName(String value) => setField<String>('item_name', value);

  DateTime get dueDate => getField<DateTime>('due_date')!;
  set dueDate(DateTime value) => setField<DateTime>('due_date', value);

  int get daysUntilDue => getField<int>('days_until_due')!;
  set daysUntilDue(int value) => setField<int>('days_until_due', value);

  String get channel => getField<String>('channel')!;
  set channel(String value) => setField<String>('channel', value);

  String? get recipientEmail => getField<String>('recipient_email');
  set recipientEmail(String? value) =>
      setField<String>('recipient_email', value);

  String? get recipientUserId => getField<String>('recipient_user_id');
  set recipientUserId(String? value) =>
      setField<String>('recipient_user_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
