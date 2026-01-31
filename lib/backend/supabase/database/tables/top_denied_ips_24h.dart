import '../database.dart';

class TopDeniedIps24hTable extends SupabaseTable<TopDeniedIps24hRow> {
  @override
  String get tableName => 'top_denied_ips_24h';

  @override
  TopDeniedIps24hRow createRow(Map<String, dynamic> data) =>
      TopDeniedIps24hRow(data);
}

class TopDeniedIps24hRow extends SupabaseDataRow {
  TopDeniedIps24hRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TopDeniedIps24hTable();

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  int? get denialCount => getField<int>('denial_count');
  set denialCount(int? value) => setField<int>('denial_count', value);

  int? get affectedUsers => getField<int>('affected_users');
  set affectedUsers(int? value) => setField<int>('affected_users', value);

  DateTime? get lastDenial => getField<DateTime>('last_denial');
  set lastDenial(DateTime? value) => setField<DateTime>('last_denial', value);
}
