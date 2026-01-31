import '../database.dart';

class ZArchiveEmployeeLearningModulesTable
    extends SupabaseTable<ZArchiveEmployeeLearningModulesRow> {
  @override
  String get tableName => 'z_archive_employee_learning_modules';

  @override
  ZArchiveEmployeeLearningModulesRow createRow(Map<String, dynamic> data) =>
      ZArchiveEmployeeLearningModulesRow(data);
}

class ZArchiveEmployeeLearningModulesRow extends SupabaseDataRow {
  ZArchiveEmployeeLearningModulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveEmployeeLearningModulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get contentUrl => getField<String>('content_url');
  set contentUrl(String? value) => setField<String>('content_url', value);

  int? get durationHours => getField<int>('duration_hours');
  set durationHours(int? value) => setField<int>('duration_hours', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String? get difficultyLevel => getField<String>('difficulty_level');
  set difficultyLevel(String? value) =>
      setField<String>('difficulty_level', value);

  bool? get mandatory => getField<bool>('mandatory');
  set mandatory(bool? value) => setField<bool>('mandatory', value);

  int? get expiryMonths => getField<int>('expiry_months');
  set expiryMonths(int? value) => setField<int>('expiry_months', value);

  dynamic get prerequisites => getField<dynamic>('prerequisites');
  set prerequisites(dynamic value) =>
      setField<dynamic>('prerequisites', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
