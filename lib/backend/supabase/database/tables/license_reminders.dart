import '../database.dart';

class LicenseRemindersTable extends SupabaseTable<LicenseRemindersRow> {
  @override
  String get tableName => 'license_reminders';

  @override
  LicenseRemindersRow createRow(Map<String, dynamic> data) =>
      LicenseRemindersRow(data);
}

class LicenseRemindersRow extends SupabaseDataRow {
  LicenseRemindersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LicenseRemindersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get licenseId => getField<String>('license_id')!;
  set licenseId(String value) => setField<String>('license_id', value);

  String get reminderType => getField<String>('reminder_type')!;
  set reminderType(String value) => setField<String>('reminder_type', value);

  int? get daysUntilExpiry => getField<int>('days_until_expiry');
  set daysUntilExpiry(int? value) => setField<int>('days_until_expiry', value);

  int? get daysOverdue => getField<int>('days_overdue');
  set daysOverdue(int? value) => setField<int>('days_overdue', value);

  DateTime get sentAt => getField<DateTime>('sent_at')!;
  set sentAt(DateTime value) => setField<DateTime>('sent_at', value);

  String get sentVia => getField<String>('sent_via')!;
  set sentVia(String value) => setField<String>('sent_via', value);

  List<String> get recipientRoles => getListField<String>('recipient_roles');
  set recipientRoles(List<String>? value) =>
      setListField<String>('recipient_roles', value);

  List<String> get recipientEmails => getListField<String>('recipient_emails');
  set recipientEmails(List<String>? value) =>
      setListField<String>('recipient_emails', value);

  int? get escalationLevel => getField<int>('escalation_level');
  set escalationLevel(int? value) => setField<int>('escalation_level', value);

  String? get messageContent => getField<String>('message_content');
  set messageContent(String? value) =>
      setField<String>('message_content', value);

  String? get deliveryStatus => getField<String>('delivery_status');
  set deliveryStatus(String? value) =>
      setField<String>('delivery_status', value);

  DateTime? get acknowledgedAt => getField<DateTime>('acknowledged_at');
  set acknowledgedAt(DateTime? value) =>
      setField<DateTime>('acknowledged_at', value);

  String? get acknowledgedBy => getField<String>('acknowledged_by');
  set acknowledgedBy(String? value) =>
      setField<String>('acknowledged_by', value);
}
