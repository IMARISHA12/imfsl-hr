import '../database.dart';

class GeospatialRiskZonesTable extends SupabaseTable<GeospatialRiskZonesRow> {
  @override
  String get tableName => 'geospatial_risk_zones';

  @override
  GeospatialRiskZonesRow createRow(Map<String, dynamic> data) =>
      GeospatialRiskZonesRow(data);
}

class GeospatialRiskZonesRow extends SupabaseDataRow {
  GeospatialRiskZonesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GeospatialRiskZonesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get zoneName => getField<String>('zone_name')!;
  set zoneName(String value) => setField<String>('zone_name', value);

  String get region => getField<String>('region')!;
  set region(String value) => setField<String>('region', value);

  String? get district => getField<String>('district');
  set district(String? value) => setField<String>('district', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);

  double? get radiusKm => getField<double>('radius_km');
  set radiusKm(double? value) => setField<double>('radius_km', value);

  int? get totalLoans => getField<int>('total_loans');
  set totalLoans(int? value) => setField<int>('total_loans', value);

  int? get defaultCount => getField<int>('default_count');
  set defaultCount(int? value) => setField<int>('default_count', value);

  double? get defaultRate => getField<double>('default_rate');
  set defaultRate(double? value) => setField<double>('default_rate', value);

  String? get riskLevel => getField<String>('risk_level');
  set riskLevel(String? value) => setField<String>('risk_level', value);

  bool? get isBlocked => getField<bool>('is_blocked');
  set isBlocked(bool? value) => setField<bool>('is_blocked', value);

  String? get blockedReason => getField<String>('blocked_reason');
  set blockedReason(String? value) => setField<String>('blocked_reason', value);

  DateTime? get lastAnalyzedAt => getField<DateTime>('last_analyzed_at');
  set lastAnalyzedAt(DateTime? value) =>
      setField<DateTime>('last_analyzed_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
