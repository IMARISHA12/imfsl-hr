import '../database.dart';

class CommunicationLogsTable extends SupabaseTable<CommunicationLogsRow> {
  @override
  String get tableName => 'communication_logs';

  @override
  CommunicationLogsRow createRow(Map<String, dynamic> data) =>
      CommunicationLogsRow(data);
}

class CommunicationLogsRow extends SupabaseDataRow {
  CommunicationLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CommunicationLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);

  String? get direction => getField<String>('direction');
  set direction(String? value) => setField<String>('direction', value);

  String? get templateUsed => getField<String>('template_used');
  set templateUsed(String? value) => setField<String>('template_used', value);

  String? get content => getField<String>('content');
  set content(String? value) => setField<String>('content', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get providerMessageId => getField<String>('provider_message_id');
  set providerMessageId(String? value) =>
      setField<String>('provider_message_id', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get borrowerId => getField<String>('borrower_id');
  set borrowerId(String? value) => setField<String>('borrower_id', value);

  String? get channel => getField<String>('channel');
  set channel(String? value) => setField<String>('channel', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  String? get recipientPhone => getField<String>('recipient_phone');
  set recipientPhone(String? value) =>
      setField<String>('recipient_phone', value);

  String? get recipientEmail => getField<String>('recipient_email');
  set recipientEmail(String? value) =>
      setField<String>('recipient_email', value);

  String? get messageContent => getField<String>('message_content');
  set messageContent(String? value) =>
      setField<String>('message_content', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  DateTime? get deliveredAt => getField<DateTime>('delivered_at');
  set deliveredAt(DateTime? value) => setField<DateTime>('delivered_at', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  int? get retryCount => getField<int>('retry_count');
  set retryCount(int? value) => setField<int>('retry_count', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get triggerEvent => getField<String>('trigger_event');
  set triggerEvent(String? value) => setField<String>('trigger_event', value);
}
