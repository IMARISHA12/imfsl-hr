import '../database.dart';

class BillingRemindersTable extends SupabaseTable<BillingRemindersRow> {
  @override
  String get tableName => 'billing_reminders';

  @override
  BillingRemindersRow createRow(Map<String, dynamic> data) =>
      BillingRemindersRow(data);
}

class BillingRemindersRow extends SupabaseDataRow {
  BillingRemindersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BillingRemindersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get billingItemId => getField<String>('billing_item_id')!;
  set billingItemId(String value) => setField<String>('billing_item_id', value);

  String get reminderType => getField<String>('reminder_type')!;
  set reminderType(String value) => setField<String>('reminder_type', value);

  int? get daysUntilDue => getField<int>('days_until_due');
  set daysUntilDue(int? value) => setField<int>('days_until_due', value);

  int? get daysOverdue => getField<int>('days_overdue');
  set daysOverdue(int? value) => setField<int>('days_overdue', value);

  DateTime get sentAt => getField<DateTime>('sent_at')!;
  set sentAt(DateTime value) => setField<DateTime>('sent_at', value);

  String get sentVia => getField<String>('sent_via')!;
  set sentVia(String value) => setField<String>('sent_via', value);

  String? get recipientEmail => getField<String>('recipient_email');
  set recipientEmail(String? value) =>
      setField<String>('recipient_email', value);

  String? get recipientPhone => getField<String>('recipient_phone');
  set recipientPhone(String? value) =>
      setField<String>('recipient_phone', value);

  String? get messageContent => getField<String>('message_content');
  set messageContent(String? value) =>
      setField<String>('message_content', value);

  String? get deliveryStatus => getField<String>('delivery_status');
  set deliveryStatus(String? value) =>
      setField<String>('delivery_status', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  DateTime? get acknowledgedAt => getField<DateTime>('acknowledged_at');
  set acknowledgedAt(DateTime? value) =>
      setField<DateTime>('acknowledged_at', value);

  String? get acknowledgedBy => getField<String>('acknowledged_by');
  set acknowledgedBy(String? value) =>
      setField<String>('acknowledged_by', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  int? get retryCount => getField<int>('retry_count');
  set retryCount(int? value) => setField<int>('retry_count', value);

  int? get maxRetries => getField<int>('max_retries');
  set maxRetries(int? value) => setField<int>('max_retries', value);

  DateTime? get nextRetryAt => getField<DateTime>('next_retry_at');
  set nextRetryAt(DateTime? value) =>
      setField<DateTime>('next_retry_at', value);

  String? get externalId => getField<String>('external_id');
  set externalId(String? value) => setField<String>('external_id', value);
}
