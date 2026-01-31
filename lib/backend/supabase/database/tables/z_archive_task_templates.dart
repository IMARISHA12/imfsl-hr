import '../database.dart';

class ZArchiveTaskTemplatesTable
    extends SupabaseTable<ZArchiveTaskTemplatesRow> {
  @override
  String get tableName => 'z_archive_task_templates';

  @override
  ZArchiveTaskTemplatesRow createRow(Map<String, dynamic> data) =>
      ZArchiveTaskTemplatesRow(data);
}

class ZArchiveTaskTemplatesRow extends SupabaseDataRow {
  ZArchiveTaskTemplatesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveTaskTemplatesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  String? get priority => getField<String>('priority');
  set priority(String? value) => setField<String>('priority', value);

  double? get estimatedHours => getField<double>('estimated_hours');
  set estimatedHours(double? value) =>
      setField<double>('estimated_hours', value);

  List<String> get tags => getListField<String>('tags');
  set tags(List<String>? value) => setListField<String>('tags', value);

  String? get departmentId => getField<String>('department_id');
  set departmentId(String? value) => setField<String>('department_id', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
