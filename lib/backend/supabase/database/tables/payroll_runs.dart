import '../database.dart';

class PayrollRunsTable extends SupabaseTable<PayrollRunsRow> {
  @override
  String get tableName => 'payroll_runs';

  @override
  PayrollRunsRow createRow(Map<String, dynamic> data) => PayrollRunsRow(data);
}

class PayrollRunsRow extends SupabaseDataRow {
  PayrollRunsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PayrollRunsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  int get runPeriodMonth => getField<int>('run_period_month')!;
  set runPeriodMonth(int value) => setField<int>('run_period_month', value);

  int get runPeriodYear => getField<int>('run_period_year')!;
  set runPeriodYear(int value) => setField<int>('run_period_year', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get runDate => getField<DateTime>('run_date')!;
  set runDate(DateTime value) => setField<DateTime>('run_date', value);

  String? get preparedBy => getField<String>('prepared_by');
  set preparedBy(String? value) => setField<String>('prepared_by', value);

  String? get bankExportFormat => getField<String>('bank_export_format');
  set bankExportFormat(String? value) =>
      setField<String>('bank_export_format', value);

  String? get month => getField<String>('month');
  set month(String? value) => setField<String>('month', value);

  double? get totalCost => getField<double>('total_cost');
  set totalCost(double? value) => setField<double>('total_cost', value);
}
