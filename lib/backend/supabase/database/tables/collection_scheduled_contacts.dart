import '../database.dart';

class CollectionScheduledContactsTable
    extends SupabaseTable<CollectionScheduledContactsRow> {
  @override
  String get tableName => 'collection_scheduled_contacts';

  @override
  CollectionScheduledContactsRow createRow(Map<String, dynamic> data) =>
      CollectionScheduledContactsRow(data);
}

class CollectionScheduledContactsRow extends SupabaseDataRow {
  CollectionScheduledContactsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollectionScheduledContactsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  String? get segmentId => getField<String>('segment_id');
  set segmentId(String? value) => setField<String>('segment_id', value);

  String? get templateId => getField<String>('template_id');
  set templateId(String? value) => setField<String>('template_id', value);

  DateTime get scheduledFor => getField<DateTime>('scheduled_for')!;
  set scheduledFor(DateTime value) =>
      setField<DateTime>('scheduled_for', value);

  String get channel => getField<String>('channel')!;
  set channel(String value) => setField<String>('channel', value);

  String? get language => getField<String>('language');
  set language(String? value) => setField<String>('language', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  String? get messageId => getField<String>('message_id');
  set messageId(String? value) => setField<String>('message_id', value);

  String? get skipReason => getField<String>('skip_reason');
  set skipReason(String? value) => setField<String>('skip_reason', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
