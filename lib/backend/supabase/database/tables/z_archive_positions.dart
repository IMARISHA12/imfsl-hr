import '../database.dart';

class ZArchivePositionsTable extends SupabaseTable<ZArchivePositionsRow> {
  @override
  String get tableName => 'z_archive_positions';

  @override
  ZArchivePositionsRow createRow(Map<String, dynamic> data) =>
      ZArchivePositionsRow(data);
}

class ZArchivePositionsRow extends SupabaseDataRow {
  ZArchivePositionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchivePositionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get departmentId => getField<String>('department_id')!;
  set departmentId(String value) => setField<String>('department_id', value);

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  int? get level => getField<int>('level');
  set level(int? value) => setField<int>('level', value);

  double? get salaryMin => getField<double>('salary_min');
  set salaryMin(double? value) => setField<double>('salary_min', value);

  double? get salaryMax => getField<double>('salary_max');
  set salaryMax(double? value) => setField<double>('salary_max', value);

  bool? get isManagement => getField<bool>('is_management');
  set isManagement(bool? value) => setField<bool>('is_management', value);

  List<String> get requiredPermissions =>
      getListField<String>('required_permissions');
  set requiredPermissions(List<String>? value) =>
      setListField<String>('required_permissions', value);
}
