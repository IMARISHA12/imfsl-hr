import '../database.dart';

class VStaffCsatSummaryTable extends SupabaseTable<VStaffCsatSummaryRow> {
  @override
  String get tableName => 'v_staff_csat_summary';

  @override
  VStaffCsatSummaryRow createRow(Map<String, dynamic> data) =>
      VStaffCsatSummaryRow(data);
}

class VStaffCsatSummaryRow extends SupabaseDataRow {
  VStaffCsatSummaryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VStaffCsatSummaryTable();

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  int? get totalResponses => getField<int>('total_responses');
  set totalResponses(int? value) => setField<int>('total_responses', value);

  double? get avgSatisfactionScore =>
      getField<double>('avg_satisfaction_score');
  set avgSatisfactionScore(double? value) =>
      setField<double>('avg_satisfaction_score', value);

  int? get promoters => getField<int>('promoters');
  set promoters(int? value) => setField<int>('promoters', value);

  int? get detractors => getField<int>('detractors');
  set detractors(int? value) => setField<int>('detractors', value);

  int? get satisfiedCount => getField<int>('satisfied_count');
  set satisfiedCount(int? value) => setField<int>('satisfied_count', value);

  int? get dissatisfiedCount => getField<int>('dissatisfied_count');
  set dissatisfiedCount(int? value) =>
      setField<int>('dissatisfied_count', value);

  double? get npsScore => getField<double>('nps_score');
  set npsScore(double? value) => setField<double>('nps_score', value);
}
