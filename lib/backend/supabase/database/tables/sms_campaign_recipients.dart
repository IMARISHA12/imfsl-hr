import '../database.dart';

class SmsCampaignRecipientsTable
    extends SupabaseTable<SmsCampaignRecipientsRow> {
  @override
  String get tableName => 'sms_campaign_recipients';

  @override
  SmsCampaignRecipientsRow createRow(Map<String, dynamic> data) =>
      SmsCampaignRecipientsRow(data);
}

class SmsCampaignRecipientsRow extends SupabaseDataRow {
  SmsCampaignRecipientsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SmsCampaignRecipientsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get campaignId => getField<String>('campaign_id')!;
  set campaignId(String value) => setField<String>('campaign_id', value);

  String get clientId => getField<String>('client_id')!;
  set clientId(String value) => setField<String>('client_id', value);

  String get phoneNumber => getField<String>('phone_number')!;
  set phoneNumber(String value) => setField<String>('phone_number', value);

  String? get personalizedMessage => getField<String>('personalized_message');
  set personalizedMessage(String? value) =>
      setField<String>('personalized_message', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get communicationLogId => getField<String>('communication_log_id');
  set communicationLogId(String? value) =>
      setField<String>('communication_log_id', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  DateTime? get queuedAt => getField<DateTime>('queued_at');
  set queuedAt(DateTime? value) => setField<DateTime>('queued_at', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  DateTime? get deliveredAt => getField<DateTime>('delivered_at');
  set deliveredAt(DateTime? value) => setField<DateTime>('delivered_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  int get retryCount => getField<int>('retry_count')!;
  set retryCount(int value) => setField<int>('retry_count', value);

  DateTime? get lastRetryAt => getField<DateTime>('last_retry_at');
  set lastRetryAt(DateTime? value) =>
      setField<DateTime>('last_retry_at', value);
}
