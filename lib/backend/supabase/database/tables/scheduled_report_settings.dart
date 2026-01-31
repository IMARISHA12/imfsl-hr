import '../database.dart';

class ScheduledReportSettingsTable
    extends SupabaseTable<ScheduledReportSettingsRow> {
  @override
  String get tableName => 'scheduled_report_settings';

  @override
  ScheduledReportSettingsRow createRow(Map<String, dynamic> data) =>
      ScheduledReportSettingsRow(data);
}

class ScheduledReportSettingsRow extends SupabaseDataRow {
  ScheduledReportSettingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ScheduledReportSettingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get reportType => getField<String>('report_type')!;
  set reportType(String value) => setField<String>('report_type', value);

  bool get isEnabled => getField<bool>('is_enabled')!;
  set isEnabled(bool value) => setField<bool>('is_enabled', value);

  PostgresTime get sendTime => getField<PostgresTime>('send_time')!;
  set sendTime(PostgresTime value) =>
      setField<PostgresTime>('send_time', value);

  int? get sendDayOfWeek => getField<int>('send_day_of_week');
  set sendDayOfWeek(int? value) => setField<int>('send_day_of_week', value);

  int? get sendDayOfMonth => getField<int>('send_day_of_month');
  set sendDayOfMonth(int? value) => setField<int>('send_day_of_month', value);

  bool get includePortfolioSummary =>
      getField<bool>('include_portfolio_summary')!;
  set includePortfolioSummary(bool value) =>
      setField<bool>('include_portfolio_summary', value);

  bool get includeCollectionMetrics =>
      getField<bool>('include_collection_metrics')!;
  set includeCollectionMetrics(bool value) =>
      setField<bool>('include_collection_metrics', value);

  bool get includeParAnalysis => getField<bool>('include_par_analysis')!;
  set includeParAnalysis(bool value) =>
      setField<bool>('include_par_analysis', value);

  bool get includeTopPerformers => getField<bool>('include_top_performers')!;
  set includeTopPerformers(bool value) =>
      setField<bool>('include_top_performers', value);

  bool get includeOverdueAlerts => getField<bool>('include_overdue_alerts')!;
  set includeOverdueAlerts(bool value) =>
      setField<bool>('include_overdue_alerts', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
