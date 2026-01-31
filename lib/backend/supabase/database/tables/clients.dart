import '../database.dart';

class ClientsTable extends SupabaseTable<ClientsRow> {
  @override
  String get tableName => 'clients';

  @override
  ClientsRow createRow(Map<String, dynamic> data) => ClientsRow(data);
}

class ClientsRow extends SupabaseDataRow {
  ClientsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ClientsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get firstName => getField<String>('first_name')!;
  set firstName(String value) => setField<String>('first_name', value);

  String? get middleName => getField<String>('middle_name');
  set middleName(String? value) => setField<String>('middle_name', value);

  String get lastName => getField<String>('last_name')!;
  set lastName(String value) => setField<String>('last_name', value);

  String get phoneNumber => getField<String>('phone_number')!;
  set phoneNumber(String value) => setField<String>('phone_number', value);

  String? get nidaNumber => getField<String>('nida_number');
  set nidaNumber(String? value) => setField<String>('nida_number', value);

  String? get businessType => getField<String>('business_type');
  set businessType(String? value) => setField<String>('business_type', value);

  String? get businessLocation => getField<String>('business_location');
  set businessLocation(String? value) =>
      setField<String>('business_location', value);

  double? get revenueEstimate => getField<double>('revenue_estimate');
  set revenueEstimate(double? value) =>
      setField<double>('revenue_estimate', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get externalReferenceId => getField<String>('external_reference_id');
  set externalReferenceId(String? value) =>
      setField<String>('external_reference_id', value);

  String? get nextOfKinName => getField<String>('next_of_kin_name');
  set nextOfKinName(String? value) =>
      setField<String>('next_of_kin_name', value);

  String? get nextOfKinRelationship =>
      getField<String>('next_of_kin_relationship');
  set nextOfKinRelationship(String? value) =>
      setField<String>('next_of_kin_relationship', value);

  String? get nextOfKinPhone => getField<String>('next_of_kin_phone');
  set nextOfKinPhone(String? value) =>
      setField<String>('next_of_kin_phone', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get region => getField<String>('region');
  set region(String? value) => setField<String>('region', value);

  String? get district => getField<String>('district');
  set district(String? value) => setField<String>('district', value);

  String? get street => getField<String>('street');
  set street(String? value) => setField<String>('street', value);

  String? get legacyId => getField<String>('legacy_id');
  set legacyId(String? value) => setField<String>('legacy_id', value);

  int? get creditScore => getField<int>('credit_score');
  set creditScore(int? value) => setField<int>('credit_score', value);

  String? get riskLevel => getField<String>('risk_level');
  set riskLevel(String? value) => setField<String>('risk_level', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  double? get preApprovedLimit => getField<double>('pre_approved_limit');
  set preApprovedLimit(double? value) =>
      setField<double>('pre_approved_limit', value);

  double? get gpsLatitude => getField<double>('gps_latitude');
  set gpsLatitude(double? value) => setField<double>('gps_latitude', value);

  double? get gpsLongitude => getField<double>('gps_longitude');
  set gpsLongitude(double? value) => setField<double>('gps_longitude', value);

  double? get gpsAccuracy => getField<double>('gps_accuracy');
  set gpsAccuracy(double? value) => setField<double>('gps_accuracy', value);

  DateTime? get gpsCapturedAt => getField<DateTime>('gps_captured_at');
  set gpsCapturedAt(DateTime? value) =>
      setField<DateTime>('gps_captured_at', value);
}
