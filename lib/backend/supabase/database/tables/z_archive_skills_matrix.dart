import '../database.dart';

class ZArchiveSkillsMatrixTable extends SupabaseTable<ZArchiveSkillsMatrixRow> {
  @override
  String get tableName => 'z_archive_skills_matrix';

  @override
  ZArchiveSkillsMatrixRow createRow(Map<String, dynamic> data) =>
      ZArchiveSkillsMatrixRow(data);
}

class ZArchiveSkillsMatrixRow extends SupabaseDataRow {
  ZArchiveSkillsMatrixRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveSkillsMatrixTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get skillName => getField<String>('skill_name')!;
  set skillName(String value) => setField<String>('skill_name', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get requiredLevel => getField<String>('required_level');
  set requiredLevel(String? value) => setField<String>('required_level', value);

  bool? get isCritical => getField<bool>('is_critical');
  set isCritical(bool? value) => setField<bool>('is_critical', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
