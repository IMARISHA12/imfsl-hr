import '../database.dart';

class LoanStatusNotificationsTable
    extends SupabaseTable<LoanStatusNotificationsRow> {
  @override
  String get tableName => 'loan_status_notifications';

  @override
  LoanStatusNotificationsRow createRow(Map<String, dynamic> data) =>
      LoanStatusNotificationsRow(data);
}

class LoanStatusNotificationsRow extends SupabaseDataRow {
  LoanStatusNotificationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanStatusNotificationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanApplicationId => getField<String>('loan_application_id')!;
  set loanApplicationId(String value) =>
      setField<String>('loan_application_id', value);

  String? get previousStatus => getField<String>('previous_status');
  set previousStatus(String? value) =>
      setField<String>('previous_status', value);

  String get newStatus => getField<String>('new_status')!;
  set newStatus(String value) => setField<String>('new_status', value);

  String get notificationType => getField<String>('notification_type')!;
  set notificationType(String value) =>
      setField<String>('notification_type', value);

  String? get recipientPhone => getField<String>('recipient_phone');
  set recipientPhone(String? value) =>
      setField<String>('recipient_phone', value);

  String? get recipientEmail => getField<String>('recipient_email');
  set recipientEmail(String? value) =>
      setField<String>('recipient_email', value);

  String? get messageContent => getField<String>('message_content');
  set messageContent(String? value) =>
      setField<String>('message_content', value);

  dynamic get webhookPayload => getField<dynamic>('webhook_payload');
  set webhookPayload(dynamic value) =>
      setField<dynamic>('webhook_payload', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  String? get deliveryStatus => getField<String>('delivery_status');
  set deliveryStatus(String? value) =>
      setField<String>('delivery_status', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
