import '../database.dart';

class SmsCampaignsTable extends SupabaseTable<SmsCampaignsRow> {
  @override
  String get tableName => 'sms_campaigns';

  @override
  SmsCampaignsRow createRow(Map<String, dynamic> data) => SmsCampaignsRow(data);
}

class SmsCampaignsRow extends SupabaseDataRow {
  SmsCampaignsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SmsCampaignsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get messageTemplate => getField<String>('message_template')!;
  set messageTemplate(String value) =>
      setField<String>('message_template', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  dynamic get filterCriteria => getField<dynamic>('filter_criteria');
  set filterCriteria(dynamic value) =>
      setField<dynamic>('filter_criteria', value);

  DateTime? get scheduledAt => getField<DateTime>('scheduled_at');
  set scheduledAt(DateTime? value) => setField<DateTime>('scheduled_at', value);

  DateTime? get startedAt => getField<DateTime>('started_at');
  set startedAt(DateTime? value) => setField<DateTime>('started_at', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);

  int? get totalRecipients => getField<int>('total_recipients');
  set totalRecipients(int? value) => setField<int>('total_recipients', value);

  int? get sentCount => getField<int>('sent_count');
  set sentCount(int? value) => setField<int>('sent_count', value);

  int? get deliveredCount => getField<int>('delivered_count');
  set deliveredCount(int? value) => setField<int>('delivered_count', value);

  int? get failedCount => getField<int>('failed_count');
  set failedCount(int? value) => setField<int>('failed_count', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String get channel => getField<String>('channel')!;
  set channel(String value) => setField<String>('channel', value);

  String? get templateId => getField<String>('template_id');
  set templateId(String? value) => setField<String>('template_id', value);

  String? get subject => getField<String>('subject');
  set subject(String? value) => setField<String>('subject', value);
}
