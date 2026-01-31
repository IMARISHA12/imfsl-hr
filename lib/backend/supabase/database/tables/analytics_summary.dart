import '../database.dart';

class AnalyticsSummaryTable extends SupabaseTable<AnalyticsSummaryRow> {
  @override
  String get tableName => 'analytics_summary';

  @override
  AnalyticsSummaryRow createRow(Map<String, dynamic> data) =>
      AnalyticsSummaryRow(data);
}

class AnalyticsSummaryRow extends SupabaseDataRow {
  AnalyticsSummaryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AnalyticsSummaryTable();

  String? get eventCategory => getField<String>('event_category');
  set eventCategory(String? value) => setField<String>('event_category', value);

  String? get eventType => getField<String>('event_type');
  set eventType(String? value) => setField<String>('event_type', value);

  int? get eventCount => getField<int>('event_count');
  set eventCount(int? value) => setField<int>('event_count', value);

  int? get uniqueUsers => getField<int>('unique_users');
  set uniqueUsers(int? value) => setField<int>('unique_users', value);

  DateTime? get eventDate => getField<DateTime>('event_date');
  set eventDate(DateTime? value) => setField<DateTime>('event_date', value);
}
