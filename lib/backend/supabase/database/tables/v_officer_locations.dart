import '../database.dart';

class VOfficerLocationsTable extends SupabaseTable<VOfficerLocationsRow> {
  @override
  String get tableName => 'v_officer_locations';

  @override
  VOfficerLocationsRow createRow(Map<String, dynamic> data) =>
      VOfficerLocationsRow(data);
}

class VOfficerLocationsRow extends SupabaseDataRow {
  VOfficerLocationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VOfficerLocationsTable();

  String? get officerId => getField<String>('officer_id');
  set officerId(String? value) => setField<String>('officer_id', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  String? get branch => getField<String>('branch');
  set branch(String? value) => setField<String>('branch', value);

  String? get position => getField<String>('position');
  set position(String? value) => setField<String>('position', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);

  String? get address => getField<String>('address');
  set address(String? value) => setField<String>('address', value);

  String? get visitType => getField<String>('visit_type');
  set visitType(String? value) => setField<String>('visit_type', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get lastSeen => getField<DateTime>('last_seen');
  set lastSeen(DateTime? value) => setField<DateTime>('last_seen', value);

  String? get clientId => getField<String>('client_id');
  set clientId(String? value) => setField<String>('client_id', value);

  String? get clientName => getField<String>('client_name');
  set clientName(String? value) => setField<String>('client_name', value);
}
