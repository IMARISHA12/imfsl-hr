import '../database.dart';

class CollateralRegistryTable extends SupabaseTable<CollateralRegistryRow> {
  @override
  String get tableName => 'collateral_registry';

  @override
  CollateralRegistryRow createRow(Map<String, dynamic> data) =>
      CollateralRegistryRow(data);
}

class CollateralRegistryRow extends SupabaseDataRow {
  CollateralRegistryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollateralRegistryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String get uniqueIdentifier => getField<String>('unique_identifier')!;
  set uniqueIdentifier(String value) =>
      setField<String>('unique_identifier', value);

  double get marketValue => getField<double>('market_value')!;
  set marketValue(double value) => setField<double>('market_value', value);

  double? get forcedSaleValue => getField<double>('forced_sale_value');
  set forcedSaleValue(double? value) =>
      setField<double>('forced_sale_value', value);

  String get ownerName => getField<String>('owner_name')!;
  set ownerName(String value) => setField<String>('owner_name', value);

  String? get locationGps => getField<String>('location_gps');
  set locationGps(String? value) => setField<String>('location_gps', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
