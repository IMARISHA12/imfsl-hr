import '../database.dart';

class TopRateLimitedUsers7dTable
    extends SupabaseTable<TopRateLimitedUsers7dRow> {
  @override
  String get tableName => 'top_rate_limited_users_7d';

  @override
  TopRateLimitedUsers7dRow createRow(Map<String, dynamic> data) =>
      TopRateLimitedUsers7dRow(data);
}

class TopRateLimitedUsers7dRow extends SupabaseDataRow {
  TopRateLimitedUsers7dRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TopRateLimitedUsers7dTable();

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get denialCount => getField<int>('denial_count');
  set denialCount(int? value) => setField<int>('denial_count', value);

  int? get uniqueIps => getField<int>('unique_ips');
  set uniqueIps(int? value) => setField<int>('unique_ips', value);

  DateTime? get firstDenial => getField<DateTime>('first_denial');
  set firstDenial(DateTime? value) => setField<DateTime>('first_denial', value);

  DateTime? get lastDenial => getField<DateTime>('last_denial');
  set lastDenial(DateTime? value) => setField<DateTime>('last_denial', value);
}
