import '../database.dart';

class StaffPerformanceTable extends SupabaseTable<StaffPerformanceRow> {
  @override
  String get tableName => 'staff_performance';

  @override
  StaffPerformanceRow createRow(Map<String, dynamic> data) =>
      StaffPerformanceRow(data);
}

class StaffPerformanceRow extends SupabaseDataRow {
  StaffPerformanceRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffPerformanceTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  DateTime get periodStart => getField<DateTime>('period_start')!;
  set periodStart(DateTime value) => setField<DateTime>('period_start', value);

  DateTime get periodEnd => getField<DateTime>('period_end')!;
  set periodEnd(DateTime value) => setField<DateTime>('period_end', value);

  double? get actualDisbursement => getField<double>('actual_disbursement');
  set actualDisbursement(double? value) =>
      setField<double>('actual_disbursement', value);

  double? get actualCollection => getField<double>('actual_collection');
  set actualCollection(double? value) =>
      setField<double>('actual_collection', value);

  double? get currentPar30 => getField<double>('current_par_30');
  set currentPar30(double? value) => setField<double>('current_par_30', value);

  double? get ptpSuccessRate => getField<double>('ptp_success_rate');
  set ptpSuccessRate(double? value) =>
      setField<double>('ptp_success_rate', value);

  DateTime? get calculatedAt => getField<DateTime>('calculated_at');
  set calculatedAt(DateTime? value) =>
      setField<DateTime>('calculated_at', value);
}
