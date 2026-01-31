import '../database.dart';

class CollectionTemplatesTable extends SupabaseTable<CollectionTemplatesRow> {
  @override
  String get tableName => 'collection_templates';

  @override
  CollectionTemplatesRow createRow(Map<String, dynamic> data) =>
      CollectionTemplatesRow(data);
}

class CollectionTemplatesRow extends SupabaseDataRow {
  CollectionTemplatesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollectionTemplatesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get templateKey => getField<String>('template_key')!;
  set templateKey(String value) => setField<String>('template_key', value);

  String get templateName => getField<String>('template_name')!;
  set templateName(String value) => setField<String>('template_name', value);

  String get channel => getField<String>('channel')!;
  set channel(String value) => setField<String>('channel', value);

  String? get segmentId => getField<String>('segment_id');
  set segmentId(String? value) => setField<String>('segment_id', value);

  String? get dpdBucket => getField<String>('dpd_bucket');
  set dpdBucket(String? value) => setField<String>('dpd_bucket', value);

  String get contentEn => getField<String>('content_en')!;
  set contentEn(String value) => setField<String>('content_en', value);

  String get contentSw => getField<String>('content_sw')!;
  set contentSw(String value) => setField<String>('content_sw', value);

  String get tone => getField<String>('tone')!;
  set tone(String value) => setField<String>('tone', value);

  bool get requiresApproval => getField<bool>('requires_approval')!;
  set requiresApproval(bool value) =>
      setField<bool>('requires_approval', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  List<String> get placeholders => getListField<String>('placeholders');
  set placeholders(List<String>? value) =>
      setListField<String>('placeholders', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
