import '../database.dart';

class ZArchiveAssetCategoriesTable
    extends SupabaseTable<ZArchiveAssetCategoriesRow> {
  @override
  String get tableName => 'z_archive_asset_categories';

  @override
  ZArchiveAssetCategoriesRow createRow(Map<String, dynamic> data) =>
      ZArchiveAssetCategoriesRow(data);
}

class ZArchiveAssetCategoriesRow extends SupabaseDataRow {
  ZArchiveAssetCategoriesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveAssetCategoriesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get depreciationMethod => getField<String>('depreciation_method');
  set depreciationMethod(String? value) =>
      setField<String>('depreciation_method', value);

  int? get defaultUsefulLifeYears => getField<int>('default_useful_life_years');
  set defaultUsefulLifeYears(int? value) =>
      setField<int>('default_useful_life_years', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  double? get defaultResidualPercentage =>
      getField<double>('default_residual_percentage');
  set defaultResidualPercentage(double? value) =>
      setField<double>('default_residual_percentage', value);
}
