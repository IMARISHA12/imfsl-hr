import '../database.dart';

class OptimizedRoutesTable extends SupabaseTable<OptimizedRoutesRow> {
  @override
  String get tableName => 'optimized_routes';

  @override
  OptimizedRoutesRow createRow(Map<String, dynamic> data) =>
      OptimizedRoutesRow(data);
}

class OptimizedRoutesRow extends SupabaseDataRow {
  OptimizedRoutesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OptimizedRoutesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get officerId => getField<String>('officer_id')!;
  set officerId(String value) => setField<String>('officer_id', value);

  DateTime get routeDate => getField<DateTime>('route_date')!;
  set routeDate(DateTime value) => setField<DateTime>('route_date', value);

  List<String> get clientIds => getListField<String>('client_ids');
  set clientIds(List<String> value) =>
      setListField<String>('client_ids', value);

  dynamic get waypoints => getField<dynamic>('waypoints')!;
  set waypoints(dynamic value) => setField<dynamic>('waypoints', value);

  double? get totalDistanceKm => getField<double>('total_distance_km');
  set totalDistanceKm(double? value) =>
      setField<double>('total_distance_km', value);

  int? get estimatedDurationMinutes =>
      getField<int>('estimated_duration_minutes');
  set estimatedDurationMinutes(int? value) =>
      setField<int>('estimated_duration_minutes', value);

  String? get optimizationMethod => getField<String>('optimization_method');
  set optimizationMethod(String? value) =>
      setField<String>('optimization_method', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
