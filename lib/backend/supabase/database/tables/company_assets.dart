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

  String get assetCode => getField<String>('asset_code')!;
  set assetCode(String value) => setField<String>('asset_code', value);

  String get assetCategory => getField<String>('asset_category')!;
  set assetCategory(String value) => setField<String>('asset_category', value);

  String get assetName => getField<String>('asset_name')!;
  set assetName(String value) => setField<String>('asset_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double get purchasePrice => getField<double>('purchase_price')!;
  set purchasePrice(double value) =>
      setField<double>('purchase_price', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  double get currentBookValue => getField<double>('current_book_value')!;
  set currentBookValue(double value) =>
      setField<double>('current_book_value', value);

  double? get salvageValue => getField<double>('salvage_value');
  set salvageValue(double? value) =>
      setField<double>('salvage_value', value);

  String get depreciationMethod =>
      getField<String>('depreciation_method')!;
  set depreciationMethod(String value) =>
      setField<String>('depreciation_method', value);

  double? get depreciationRate => getField<double>('depreciation_rate');
  set depreciationRate(double? value) =>
      setField<double>('depreciation_rate', value);

  int? get usefulLifeMonths => getField<int>('useful_life_months');
  set usefulLifeMonths(int? value) =>
      setField<int>('useful_life_months', value);

  DateTime? get purchaseDate => getField<DateTime>('purchase_date');
  set purchaseDate(DateTime? value) =>
      setField<DateTime>('purchase_date', value);

  DateTime? get warrantyExpiryDate =>
      getField<DateTime>('warranty_expiry_date');
  set warrantyExpiryDate(DateTime? value) =>
      setField<DateTime>('warranty_expiry_date', value);

  String? get serialNumber => getField<String>('serial_number');
  set serialNumber(String? value) =>
      setField<String>('serial_number', value);

  String? get modelNumber => getField<String>('model_number');
  set modelNumber(String? value) =>
      setField<String>('model_number', value);

  String? get manufacturer => getField<String>('manufacturer');
  set manufacturer(String? value) =>
      setField<String>('manufacturer', value);

  String get condition => getField<String>('condition')!;
  set condition(String value) => setField<String>('condition', value);

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  String? get departmentId => getField<String>('department_id');
  set departmentId(String? value) =>
      setField<String>('department_id', value);

  String? get assignedToEmployeeId =>
      getField<String>('assigned_to_employee_id');
  set assignedToEmployeeId(String? value) =>
      setField<String>('assigned_to_employee_id', value);

  String? get locationDescription =>
      getField<String>('location_description');
  set locationDescription(String? value) =>
      setField<String>('location_description', value);

  double? get gpsLatitude => getField<double>('gps_latitude');
  set gpsLatitude(double? value) =>
      setField<double>('gps_latitude', value);

  double? get gpsLongitude => getField<double>('gps_longitude');
  set gpsLongitude(double? value) =>
      setField<double>('gps_longitude', value);

  String? get registrationNumber =>
      getField<String>('registration_number');
  set registrationNumber(String? value) =>
      setField<String>('registration_number', value);

  String? get chassisNumber => getField<String>('chassis_number');
  set chassisNumber(String? value) =>
      setField<String>('chassis_number', value);

  String? get vehicleType => getField<String>('vehicle_type');
  set vehicleType(String? value) =>
      setField<String>('vehicle_type', value);

  String? get fuelType => getField<String>('fuel_type');
  set fuelType(String? value) => setField<String>('fuel_type', value);

  double? get mileageKm => getField<double>('mileage_km');
  set mileageKm(double? value) => setField<double>('mileage_km', value);

  String? get insurancePolicyNumber =>
      getField<String>('insurance_policy_number');
  set insurancePolicyNumber(String? value) =>
      setField<String>('insurance_policy_number', value);

  DateTime? get insuranceExpiry =>
      getField<DateTime>('insurance_expiry');
  set insuranceExpiry(DateTime? value) =>
      setField<DateTime>('insurance_expiry', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get osVersion => getField<String>('os_version');
  set osVersion(String? value) => setField<String>('os_version', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  List<String> get tags => getListField<String>('tags');
  set tags(List<String>? value) => setListField<String>('tags', value);

  dynamic get customFields => getField<dynamic>('custom_fields');
  set customFields(dynamic value) =>
      setField<dynamic>('custom_fields', value);

  List<String> get photoUrls => getListField<String>('photo_urls');
  set photoUrls(List<String>? value) =>
      setListField<String>('photo_urls', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) =>
      setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) =>
      setField<DateTime>('updated_at', value);
}
