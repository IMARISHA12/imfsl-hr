import '../database.dart';

class GovernanceAlertTrendsWeeklyTable
    extends SupabaseTable<GovernanceAlertTrendsWeeklyRow> {
  @override
  String get tableName => 'governance_alert_trends_weekly';

  @override
  GovernanceAlertTrendsWeeklyRow createRow(Map<String, dynamic> data) =>
      GovernanceAlertTrendsWeeklyRow(data);
}

class GovernanceAlertTrendsWeeklyRow extends SupabaseDataRow {
  GovernanceAlertTrendsWeeklyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GovernanceAlertTrendsWeeklyTable();

  DateTime? get weekStart => getField<DateTime>('week_start');
  set weekStart(DateTime? value) => setField<DateTime>('week_start', value);

  String? get severity => getField<String>('severity');
  set severity(String? value) => setField<String>('severity', value);

  String? get checkName => getField<String>('check_name');
  set checkName(String? value) => setField<String>('check_name', value);

  int? get alertCount => getField<int>('alert_count');
  set alertCount(int? value) => setField<int>('alert_count', value);
}
