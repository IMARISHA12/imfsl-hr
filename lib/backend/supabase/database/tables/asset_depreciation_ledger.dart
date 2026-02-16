import '../database.dart';

class AssetDepreciationLedgerTable
    extends SupabaseTable<AssetDepreciationLedgerRow> {
  @override
  String get tableName => 'asset_depreciation_ledger';

  @override
  AssetDepreciationLedgerRow createRow(Map<String, dynamic> data) =>
      AssetDepreciationLedgerRow(data);
}

class AssetDepreciationLedgerRow extends SupabaseDataRow {
  AssetDepreciationLedgerRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AssetDepreciationLedgerTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get assetId => getField<String>('asset_id')!;
  set assetId(String value) => setField<String>('asset_id', value);

  DateTime get periodStart => getField<DateTime>('period_start')!;
  set periodStart(DateTime value) =>
      setField<DateTime>('period_start', value);

  DateTime get periodEnd => getField<DateTime>('period_end')!;
  set periodEnd(DateTime value) => setField<DateTime>('period_end', value);

  double get openingValue => getField<double>('opening_value')!;
  set openingValue(double value) => setField<double>('opening_value', value);

  double get depreciationAmount => getField<double>('depreciation_amount')!;
  set depreciationAmount(double value) =>
      setField<double>('depreciation_amount', value);

  double get closingValue => getField<double>('closing_value')!;
  set closingValue(double value) => setField<double>('closing_value', value);

  double get accumulatedDepreciation =>
      getField<double>('accumulated_depreciation')!;
  set accumulatedDepreciation(double value) =>
      setField<double>('accumulated_depreciation', value);

  String get methodUsed => getField<String>('method_used')!;
  set methodUsed(String value) => setField<String>('method_used', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
