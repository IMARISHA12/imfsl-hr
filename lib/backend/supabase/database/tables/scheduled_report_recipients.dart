import '../database.dart';

class ScheduledReportRecipientsTable
    extends SupabaseTable<ScheduledReportRecipientsRow> {
  @override
  String get tableName => 'scheduled_report_recipients';

  @override
  ScheduledReportRecipientsRow createRow(Map<String, dynamic> data) =>
      ScheduledReportRecipientsRow(data);
}

class ScheduledReportRecipientsRow extends SupabaseDataRow {
  ScheduledReportRecipientsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ScheduledReportRecipientsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get reportSettingId => getField<String>('report_setting_id')!;
  set reportSettingId(String value) =>
      setField<String>('report_setting_id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
