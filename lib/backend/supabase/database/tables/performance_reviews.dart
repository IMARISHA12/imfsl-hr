import '../database.dart';

class PerformanceReviewsTable
    extends SupabaseTable<PerformanceReviewsRow> {
  @override
  String get tableName => 'performance_reviews';

  @override
  PerformanceReviewsRow createRow(Map<String, dynamic> data) =>
      PerformanceReviewsRow(data);
}

class PerformanceReviewsRow extends SupabaseDataRow {
  PerformanceReviewsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PerformanceReviewsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get cycleId => getField<String>('cycle_id')!;
  set cycleId(String value) => setField<String>('cycle_id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  String? get reviewerId => getField<String>('reviewer_id');
  set reviewerId(String? value) => setField<String>('reviewer_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  // Self-assessment scores
  int? get selfQuality => getField<int>('self_score_quality');
  set selfQuality(int? value) => setField<int>('self_score_quality', value);

  int? get selfProductivity => getField<int>('self_score_productivity');
  set selfProductivity(int? value) =>
      setField<int>('self_score_productivity', value);

  int? get selfTeamwork => getField<int>('self_score_teamwork');
  set selfTeamwork(int? value) => setField<int>('self_score_teamwork', value);

  int? get selfInitiative => getField<int>('self_score_initiative');
  set selfInitiative(int? value) => setField<int>('self_score_initiative', value);

  int? get selfAttendance => getField<int>('self_score_attendance');
  set selfAttendance(int? value) => setField<int>('self_score_attendance', value);

  String? get selfComments => getField<String>('self_comments');
  set selfComments(String? value) =>
      setField<String>('self_comments', value);

  // Manager assessment scores
  int? get mgrQuality => getField<int>('mgr_score_quality');
  set mgrQuality(int? value) => setField<int>('mgr_score_quality', value);

  int? get mgrProductivity => getField<int>('mgr_score_productivity');
  set mgrProductivity(int? value) =>
      setField<int>('mgr_score_productivity', value);

  int? get mgrTeamwork => getField<int>('mgr_score_teamwork');
  set mgrTeamwork(int? value) => setField<int>('mgr_score_teamwork', value);

  int? get mgrInitiative => getField<int>('mgr_score_initiative');
  set mgrInitiative(int? value) => setField<int>('mgr_score_initiative', value);

  int? get mgrAttendance => getField<int>('mgr_score_attendance');
  set mgrAttendance(int? value) => setField<int>('mgr_score_attendance', value);

  String? get mgrComments => getField<String>('mgr_comments');
  set mgrComments(String? value) => setField<String>('mgr_comments', value);

  // KPI-based scores (auto-calculated for loan officers)
  double? get kpiDisbursementScore =>
      getField<double>('kpi_disbursement_score');
  set kpiDisbursementScore(double? value) =>
      setField<double>('kpi_disbursement_score', value);

  double? get kpiCollectionScore => getField<double>('kpi_collection_score');
  set kpiCollectionScore(double? value) =>
      setField<double>('kpi_collection_score', value);

  double? get kpiParScore => getField<double>('kpi_par_score');
  set kpiParScore(double? value) =>
      setField<double>('kpi_par_score', value);

  double? get kpiClientGrowthScore =>
      getField<double>('kpi_client_growth_score');
  set kpiClientGrowthScore(double? value) =>
      setField<double>('kpi_client_growth_score', value);

  // Overall
  double? get overallScore => getField<double>('overall_score');
  set overallScore(double? value) =>
      setField<double>('overall_score', value);

  String? get overallGrade => getField<String>('overall_grade');
  set overallGrade(String? value) =>
      setField<String>('overall_grade', value);

  String? get recommendations => getField<String>('recommendations');
  set recommendations(String? value) =>
      setField<String>('recommendations', value);

  String? get developmentPlan => getField<String>('development_plan');
  set developmentPlan(String? value) =>
      setField<String>('development_plan', value);

  DateTime? get submittedAt => getField<DateTime>('submitted_at');
  set submittedAt(DateTime? value) =>
      setField<DateTime>('submitted_at', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) =>
      setField<DateTime>('reviewed_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
