import '../database.dart';

class CustomerCommunicationsTable
    extends SupabaseTable<CustomerCommunicationsRow> {
  @override
  String get tableName => 'customer_communications';

  @override
  CustomerCommunicationsRow createRow(Map<String, dynamic> data) =>
      CustomerCommunicationsRow(data);
}

class CustomerCommunicationsRow extends SupabaseDataRow {
  CustomerCommunicationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CustomerCommunicationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get customerId => getField<String>('customer_id')!;
  set customerId(String value) => setField<String>('customer_id', value);

  String get channel => getField<String>('channel')!;
  set channel(String value) => setField<String>('channel', value);

  String get direction => getField<String>('direction')!;
  set direction(String value) => setField<String>('direction', value);

  String? get subject => getField<String>('subject');
  set subject(String? value) => setField<String>('subject', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get relatedEntityType => getField<String>('related_entity_type');
  set relatedEntityType(String? value) =>
      setField<String>('related_entity_type', value);

  String? get relatedEntityId => getField<String>('related_entity_id');
  set relatedEntityId(String? value) =>
      setField<String>('related_entity_id', value);

  String? get sentBy => getField<String>('sent_by');
  set sentBy(String? value) => setField<String>('sent_by', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  DateTime? get readAt => getField<DateTime>('read_at');
  set readAt(DateTime? value) => setField<DateTime>('read_at', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
