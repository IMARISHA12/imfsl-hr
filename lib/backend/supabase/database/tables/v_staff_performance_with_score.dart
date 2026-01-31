import '../database.dart';

class VStaffPerformanceWithScoreTable
    extends SupabaseTable<VStaffPerformanceWithScoreRow> {
  @override
  String get tableName => 'v_staff_performance_with_score';

  @override
  VStaffPerformanceWithScoreRow createRow(Map<String, dynamic> data) =>
      VStaffPerformanceWithScoreRow(data);
}

class VStaffPerformanceWithScoreRow extends SupabaseDataRow {
  VStaffPerformanceWithScoreRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VStaffPerformanceWithScoreTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  DateTime? get periodStart => getField<DateTime>('period_start');
  set periodStart(DateTime? value) => setField<DateTime>('period_start', value);

  DateTime? get periodEnd => getField<DateTime>('period_end');
  set periodEnd(DateTime? value) => setField<DateTime>('period_end', value);

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

  double? get targetDisbursement => getField<double>('target_disbursement');
  set targetDisbursement(double? value) =>
      setField<double>('target_disbursement', value);

  double? get targetCollection => getField<double>('target_collection');
  set targetCollection(double? value) =>
      setField<double>('target_collection', value);

  double? get maxPar30 => getField<double>('max_par_30');
  set maxPar30(double? value) => setField<double>('max_par_30', value);

  double? get minPtpRate => getField<double>('min_ptp_rate');
  set minPtpRate(double? value) => setField<double>('min_ptp_rate', value);

  double? get finalScore => getField<double>('final_score');
  set finalScore(double? value) => setField<double>('final_score', value);
}
