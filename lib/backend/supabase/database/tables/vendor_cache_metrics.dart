import '../database.dart';

class VendorCacheMetricsTable extends SupabaseTable<VendorCacheMetricsRow> {
  @override
  String get tableName => 'vendor_cache_metrics';

  @override
  VendorCacheMetricsRow createRow(Map<String, dynamic> data) =>
      VendorCacheMetricsRow(data);
}

class VendorCacheMetricsRow extends SupabaseDataRow {
  VendorCacheMetricsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VendorCacheMetricsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get refreshTime => getField<DateTime>('refresh_time');
  set refreshTime(DateTime? value) => setField<DateTime>('refresh_time', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  double? get durationMs => getField<double>('duration_ms');
  set durationMs(double? value) => setField<double>('duration_ms', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
