import '../database.dart';

class SeizedAssetsTable extends SupabaseTable<SeizedAssetsRow> {
  @override
  String get tableName => 'seized_assets';

  @override
  SeizedAssetsRow createRow(Map<String, dynamic> data) => SeizedAssetsRow(data);
}

class SeizedAssetsRow extends SupabaseDataRow {
  SeizedAssetsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SeizedAssetsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  DateTime get seizedDate => getField<DateTime>('seized_date')!;
  set seizedDate(DateTime value) => setField<DateTime>('seized_date', value);

  double get initialValuation => getField<double>('initial_valuation')!;
  set initialValuation(double value) =>
      setField<double>('initial_valuation', value);

  double get currentValuation => getField<double>('current_valuation')!;
  set currentValuation(double value) =>
      setField<double>('current_valuation', value);

  DateTime? get lastValuationAt => getField<DateTime>('last_valuation_at');
  set lastValuationAt(DateTime? value) =>
      setField<DateTime>('last_valuation_at', value);

  String get storageLocation => getField<String>('storage_location')!;
  set storageLocation(String value) =>
      setField<String>('storage_location', value);

  String? get assignedAuctioneerId =>
      getField<String>('assigned_auctioneer_id');
  set assignedAuctioneerId(String? value) =>
      setField<String>('assigned_auctioneer_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  bool get flaggedRed => getField<bool>('flagged_red')!;
  set flaggedRed(bool value) => setField<bool>('flagged_red', value);

  DateTime? get warned15At => getField<DateTime>('warned_15_at');
  set warned15At(DateTime? value) => setField<DateTime>('warned_15_at', value);

  DateTime? get alerted30At => getField<DateTime>('alerted_30_at');
  set alerted30At(DateTime? value) =>
      setField<DateTime>('alerted_30_at', value);

  String? get itemLabel => getField<String>('item_label');
  set itemLabel(String? value) => setField<String>('item_label', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get storageLocationDetail =>
      getField<String>('storage_location_detail');
  set storageLocationDetail(String? value) =>
      setField<String>('storage_location_detail', value);

  String get assetType => getField<String>('asset_type')!;
  set assetType(String value) => setField<String>('asset_type', value);
}
