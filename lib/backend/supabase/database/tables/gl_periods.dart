import '../database.dart';

class GlPeriodsTable extends SupabaseTable<GlPeriodsRow> {
  @override
  String get tableName => 'gl_periods';

  @override
  GlPeriodsRow createRow(Map<String, dynamic> data) => GlPeriodsRow(data);
}

class GlPeriodsRow extends SupabaseDataRow {
  GlPeriodsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GlPeriodsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get periodKey => getField<String>('period_key')!;
  set periodKey(String value) => setField<String>('period_key', value);

  int get fiscalYear => getField<int>('fiscal_year')!;
  set fiscalYear(int value) => setField<int>('fiscal_year', value);

  int get fiscalMonth => getField<int>('fiscal_month')!;
  set fiscalMonth(int value) => setField<int>('fiscal_month', value);

  DateTime get startDate => getField<DateTime>('start_date')!;
  set startDate(DateTime value) => setField<DateTime>('start_date', value);

  DateTime get endDate => getField<DateTime>('end_date')!;
  set endDate(DateTime value) => setField<DateTime>('end_date', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get softClosedBy => getField<String>('soft_closed_by');
  set softClosedBy(String? value) => setField<String>('soft_closed_by', value);

  DateTime? get softClosedAt => getField<DateTime>('soft_closed_at');
  set softClosedAt(DateTime? value) =>
      setField<DateTime>('soft_closed_at', value);

  String? get softCloseReason => getField<String>('soft_close_reason');
  set softCloseReason(String? value) =>
      setField<String>('soft_close_reason', value);

  String? get closedBy => getField<String>('closed_by');
  set closedBy(String? value) => setField<String>('closed_by', value);

  DateTime? get closedAt => getField<DateTime>('closed_at');
  set closedAt(DateTime? value) => setField<DateTime>('closed_at', value);

  dynamic get closeChecklist => getField<dynamic>('close_checklist');
  set closeChecklist(dynamic value) =>
      setField<dynamic>('close_checklist', value);

  String? get reopenedBy => getField<String>('reopened_by');
  set reopenedBy(String? value) => setField<String>('reopened_by', value);

  DateTime? get reopenedAt => getField<DateTime>('reopened_at');
  set reopenedAt(DateTime? value) => setField<DateTime>('reopened_at', value);

  String? get reopenReason => getField<String>('reopen_reason');
  set reopenReason(String? value) => setField<String>('reopen_reason', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
