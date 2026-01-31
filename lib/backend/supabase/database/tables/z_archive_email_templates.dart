import '../database.dart';

class ZArchiveEmailTemplatesTable
    extends SupabaseTable<ZArchiveEmailTemplatesRow> {
  @override
  String get tableName => 'z_archive_email_templates';

  @override
  ZArchiveEmailTemplatesRow createRow(Map<String, dynamic> data) =>
      ZArchiveEmailTemplatesRow(data);
}

class ZArchiveEmailTemplatesRow extends SupabaseDataRow {
  ZArchiveEmailTemplatesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveEmailTemplatesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get templateKey => getField<String>('template_key')!;
  set templateKey(String value) => setField<String>('template_key', value);

  String get subject => getField<String>('subject')!;
  set subject(String value) => setField<String>('subject', value);

  String get body => getField<String>('body')!;
  set body(String value) => setField<String>('body', value);

  dynamic get variables => getField<dynamic>('variables');
  set variables(dynamic value) => setField<dynamic>('variables', value);

  String? get updatedBy => getField<String>('updated_by');
  set updatedBy(String? value) => setField<String>('updated_by', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
