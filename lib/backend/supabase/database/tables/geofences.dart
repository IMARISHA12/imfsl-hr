import '../database.dart';

class GeofencesTable extends SupabaseTable<GeofencesRow> {
  @override
  String get tableName => 'geofences';

  @override
  GeofencesRow createRow(Map<String, dynamic> data) => GeofencesRow(data);
}

class GeofencesRow extends SupabaseDataRow {
  GeofencesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GeofencesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  double get latitude => getField<double>('latitude')!;
  set latitude(double value) => setField<double>('latitude', value);

  double get longitude => getField<double>('longitude')!;
  set longitude(double value) => setField<double>('longitude', value);

  int get radiusMeters => getField<int>('radius_meters')!;
  set radiusMeters(int value) => setField<int>('radius_meters', value);

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
