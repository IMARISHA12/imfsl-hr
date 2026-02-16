import '../database.dart';

class AssetDepreciationTable extends SupabaseTable<AssetDepreciationRow> {
  @override
  String get tableName => 'asset_depreciation';

  @override
  AssetDepreciationRow createRow(Map<String, dynamic> data) =>
      AssetDepreciationRow(data);
}

class AssetDepreciationRow extends SupabaseDataRow {
  AssetDepreciationRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AssetDepreciationTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get assetId => getField<String>('asset_id')!;
  set assetId(String value) => setField<String>('asset_id', value);

  int get periodYear => getField<int>('period_year')!;
  set periodYear(int value) => setField<int>('period_year', value);

  int get periodMonth => getField<int>('period_month')!;
  set periodMonth(int value) => setField<int>('period_month', value);

  double get openingBookValue => getField<double>('opening_book_value')!;
  set openingBookValue(double value) =>
      setField<double>('opening_book_value', value);

  double get depreciationAmount =>
      getField<double>('depreciation_amount')!;
  set depreciationAmount(double value) =>
      setField<double>('depreciation_amount', value);

  double get accumulatedDepreciation =>
      getField<double>('accumulated_depreciation')!;
  set accumulatedDepreciation(double value) =>
      setField<double>('accumulated_depreciation', value);

  double get closingBookValue => getField<double>('closing_book_value')!;
  set closingBookValue(double value) =>
      setField<double>('closing_book_value', value);

  String get depreciationMethod =>
      getField<String>('depreciation_method')!;
  set depreciationMethod(String value) =>
      setField<String>('depreciation_method', value);

  bool? get postedToGl => getField<bool>('posted_to_gl');
  set postedToGl(bool? value) => setField<bool>('posted_to_gl', value);

  DateTime get calculatedAt => getField<DateTime>('calculated_at')!;
  set calculatedAt(DateTime value) =>
      setField<DateTime>('calculated_at', value);
}
