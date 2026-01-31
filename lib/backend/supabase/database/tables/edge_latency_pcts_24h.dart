import '../database.dart';

class EdgeLatencyPcts24hTable extends SupabaseTable<EdgeLatencyPcts24hRow> {
  @override
  String get tableName => 'edge_latency_pcts_24h';

  @override
  EdgeLatencyPcts24hRow createRow(Map<String, dynamic> data) =>
      EdgeLatencyPcts24hRow(data);
}

class EdgeLatencyPcts24hRow extends SupabaseDataRow {
  EdgeLatencyPcts24hRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EdgeLatencyPcts24hTable();

  String? get functionName => getField<String>('function_name');
  set functionName(String? value) => setField<String>('function_name', value);

  int? get calls => getField<int>('calls');
  set calls(int? value) => setField<int>('calls', value);

  double? get p50Ms => getField<double>('p50_ms');
  set p50Ms(double? value) => setField<double>('p50_ms', value);

  double? get p90Ms => getField<double>('p90_ms');
  set p90Ms(double? value) => setField<double>('p90_ms', value);

  double? get p99Ms => getField<double>('p99_ms');
  set p99Ms(double? value) => setField<double>('p99_ms', value);

  DateTime? get lastSeen => getField<DateTime>('last_seen');
  set lastSeen(DateTime? value) => setField<DateTime>('last_seen', value);
}
