import '../database.dart';

class CollateralAssetsTable extends SupabaseTable<CollateralAssetsRow> {
  @override
  String get tableName => 'collateral_assets';

  @override
  CollateralAssetsRow createRow(Map<String, dynamic> data) =>
      CollateralAssetsRow(data);
}

class CollateralAssetsRow extends SupabaseDataRow {
  CollateralAssetsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollateralAssetsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get customerId => getField<String>('customer_id');
  set customerId(String? value) => setField<String>('customer_id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String get assetType => getField<String>('asset_type')!;
  set assetType(String value) => setField<String>('asset_type', value);

  String get assetName => getField<String>('asset_name')!;
  set assetName(String value) => setField<String>('asset_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double get estimatedValue => getField<double>('estimated_value')!;
  set estimatedValue(double value) =>
      setField<double>('estimated_value', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String? get condition => getField<String>('condition');
  set condition(String? value) => setField<String>('condition', value);

  String? get serialNumber => getField<String>('serial_number');
  set serialNumber(String? value) => setField<String>('serial_number', value);

  String? get registrationNumber => getField<String>('registration_number');
  set registrationNumber(String? value) =>
      setField<String>('registration_number', value);

  double? get gpsLatitude => getField<double>('gps_latitude');
  set gpsLatitude(double? value) => setField<double>('gps_latitude', value);

  double? get gpsLongitude => getField<double>('gps_longitude');
  set gpsLongitude(double? value) => setField<double>('gps_longitude', value);

  String? get locationDescription => getField<String>('location_description');
  set locationDescription(String? value) =>
      setField<String>('location_description', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get valuationDate => getField<DateTime>('valuation_date');
  set valuationDate(DateTime? value) =>
      setField<DateTime>('valuation_date', value);

  String? get valuatorName => getField<String>('valuator_name');
  set valuatorName(String? value) => setField<String>('valuator_name', value);

  String? get insurancePolicy => getField<String>('insurance_policy');
  set insurancePolicy(String? value) =>
      setField<String>('insurance_policy', value);

  DateTime? get insuranceExpiry => getField<DateTime>('insurance_expiry');
  set insuranceExpiry(DateTime? value) =>
      setField<DateTime>('insurance_expiry', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) => setField<String>('verified_by', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
