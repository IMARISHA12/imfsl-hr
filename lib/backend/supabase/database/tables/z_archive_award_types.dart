import '../database.dart';

class ZArchiveAwardTypesTable extends SupabaseTable<ZArchiveAwardTypesRow> {
  @override
  String get tableName => 'z_archive_award_types';

  @override
  ZArchiveAwardTypesRow createRow(Map<String, dynamic> data) =>
      ZArchiveAwardTypesRow(data);
}

class ZArchiveAwardTypesRow extends SupabaseDataRow {
  ZArchiveAwardTypesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveAwardTypesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get nameSw => getField<String>('name_sw')!;
  set nameSw(String value) => setField<String>('name_sw', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get descriptionSw => getField<String>('description_sw');
  set descriptionSw(String? value) => setField<String>('description_sw', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  int? get points => getField<int>('points');
  set points(int? value) => setField<int>('points', value);

  double? get monetaryValue => getField<double>('monetary_value');
  set monetaryValue(double? value) => setField<double>('monetary_value', value);

  String? get frequency => getField<String>('frequency');
  set frequency(String? value) => setField<String>('frequency', value);

  dynamic get criteria => getField<dynamic>('criteria');
  set criteria(dynamic value) => setField<dynamic>('criteria', value);

  dynamic get criteriaSw => getField<dynamic>('criteria_sw');
  set criteriaSw(dynamic value) => setField<dynamic>('criteria_sw', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
