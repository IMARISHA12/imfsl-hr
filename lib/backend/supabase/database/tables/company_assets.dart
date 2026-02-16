import '../database.dart';

class CompanyAssetsTable extends SupabaseTable<CompanyAssetsRow> {
  @override
  String get tableName => 'company_assets';

  @override
  CompanyAssetsRow createRow(Map<String, dynamic> data) =>
      CompanyAssetsRow(data);
}

class CompanyAssetsRow extends SupabaseDataRow {
  CompanyAssetsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CompanyAssetsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get assetTag => getField<String>('asset_tag')!;
  set assetTag(String value) => setField<String>('asset_tag', value);

  String get assetName => getField<String>('asset_name')!;
  set assetName(String value) => setField<String>('asset_name', value);

  String get assetCategory => getField<String>('asset_category')!;
  set assetCategory(String value) => setField<String>('asset_category', value);

  String? get assetSubcategory => getField<String>('asset_subcategory');
  set assetSubcategory(String? value) =>
      setField<String>('asset_subcategory', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get serialNumber => getField<String>('serial_number');
  set serialNumber(String? value) => setField<String>('serial_number', value);

  String? get registrationNumber => getField<String>('registration_number');
  set registrationNumber(String? value) =>
      setField<String>('registration_number', value);

  String? get manufacturer => getField<String>('manufacturer');
  set manufacturer(String? value) => setField<String>('manufacturer', value);

  String? get model => getField<String>('model');
  set model(String? value) => setField<String>('model', value);

  DateTime get purchaseDate => getField<DateTime>('purchase_date')!;
  set purchaseDate(DateTime value) =>
      setField<DateTime>('purchase_date', value);

  double get purchasePrice => getField<double>('purchase_price')!;
  set purchasePrice(double value) =>
      setField<double>('purchase_price', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  double? get currentValue => getField<double>('current_value');
  set currentValue(double? value) => setField<double>('current_value', value);

  String? get depreciationMethod => getField<String>('depreciation_method');
  set depreciationMethod(String? value) =>
      setField<String>('depreciation_method', value);

  int? get usefulLifeYears => getField<int>('useful_life_years');
  set usefulLifeYears(int? value) =>
      setField<int>('useful_life_years', value);

  double? get salvageValue => getField<double>('salvage_value');
  set salvageValue(double? value) => setField<double>('salvage_value', value);

  double? get annualDepreciationRate =>
      getField<double>('annual_depreciation_rate');
  set annualDepreciationRate(double? value) =>
      setField<double>('annual_depreciation_rate', value);

  double? get accumulatedDepreciation =>
      getField<double>('accumulated_depreciation');
  set accumulatedDepreciation(double? value) =>
      setField<double>('accumulated_depreciation', value);

  String? get condition => getField<String>('condition');
  set condition(String? value) => setField<String>('condition', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get locationBranchId => getField<String>('location_branch_id');
  set locationBranchId(String? value) =>
      setField<String>('location_branch_id', value);

  String? get locationDescription => getField<String>('location_description');
  set locationDescription(String? value) =>
      setField<String>('location_description', value);

  double? get gpsLatitude => getField<double>('gps_latitude');
  set gpsLatitude(double? value) => setField<double>('gps_latitude', value);

  double? get gpsLongitude => getField<double>('gps_longitude');
  set gpsLongitude(double? value) => setField<double>('gps_longitude', value);

  String? get assignedTo => getField<String>('assigned_to');
  set assignedTo(String? value) => setField<String>('assigned_to', value);

  String? get assignedDepartment => getField<String>('assigned_department');
  set assignedDepartment(String? value) =>
      setField<String>('assigned_department', value);

  DateTime? get warrantyExpiry => getField<DateTime>('warranty_expiry');
  set warrantyExpiry(DateTime? value) =>
      setField<DateTime>('warranty_expiry', value);

  String? get insurancePolicyNumber =>
      getField<String>('insurance_policy_number');
  set insurancePolicyNumber(String? value) =>
      setField<String>('insurance_policy_number', value);

  DateTime? get insuranceExpiry => getField<DateTime>('insurance_expiry');
  set insuranceExpiry(DateTime? value) =>
      setField<DateTime>('insurance_expiry', value);

  DateTime? get lastMaintenanceDate =>
      getField<DateTime>('last_maintenance_date');
  set lastMaintenanceDate(DateTime? value) =>
      setField<DateTime>('last_maintenance_date', value);

  DateTime? get nextMaintenanceDate =>
      getField<DateTime>('next_maintenance_date');
  set nextMaintenanceDate(DateTime? value) =>
      setField<DateTime>('next_maintenance_date', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  dynamic get documentsJson => getField<dynamic>('documents_json');
  set documentsJson(dynamic value) =>
      setField<dynamic>('documents_json', value);

  bool? get ocrVerified => getField<bool>('ocr_verified');
  set ocrVerified(bool? value) => setField<bool>('ocr_verified', value);

  String? get ocrVerificationId => getField<String>('ocr_verification_id');
  set ocrVerificationId(String? value) =>
      setField<String>('ocr_verification_id', value);

  String? get fraudCheckStatus => getField<String>('fraud_check_status');
  set fraudCheckStatus(String? value) =>
      setField<String>('fraud_check_status', value);

  int? get fraudRiskScore => getField<int>('fraud_risk_score');
  set fraudRiskScore(int? value) => setField<int>('fraud_risk_score', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
