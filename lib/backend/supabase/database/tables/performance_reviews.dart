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
  int? get selfQuality => getField<int>('self_quality');
  set selfQuality(int? value) => setField<int>('self_quality', value);

  int? get selfProductivity => getField<int>('self_productivity');
  set selfProductivity(int? value) =>
      setField<int>('self_productivity', value);

  int? get selfTeamwork => getField<int>('self_teamwork');
  set selfTeamwork(int? value) => setField<int>('self_teamwork', value);

  int? get selfInitiative => getField<int>('self_initiative');
  set selfInitiative(int? value) => setField<int>('self_initiative', value);

  int? get selfAttendance => getField<int>('self_attendance');
  set selfAttendance(int? value) => setField<int>('self_attendance', value);

  String? get selfComments => getField<String>('self_comments');
  set selfComments(String? value) =>
      setField<String>('self_comments', value);

  // Manager assessment scores
  int? get mgrQuality => getField<int>('mgr_quality');
  set mgrQuality(int? value) => setField<int>('mgr_quality', value);

  int? get mgrProductivity => getField<int>('mgr_productivity');
  set mgrProductivity(int? value) =>
      setField<int>('mgr_productivity', value);

  int? get mgrTeamwork => getField<int>('mgr_teamwork');
  set mgrTeamwork(int? value) => setField<int>('mgr_teamwork', value);

  int? get mgrInitiative => getField<int>('mgr_initiative');
  set mgrInitiative(int? value) => setField<int>('mgr_initiative', value);

  int? get mgrAttendance => getField<int>('mgr_attendance');
  set mgrAttendance(int? value) => setField<int>('mgr_attendance', value);

  String? get mgrComments => getField<String>('mgr_comments');
  set mgrComments(String? value) => setField<String>('mgr_comments', value);

  // KPI scores (loan officers)
  int? get kpiScore => getField<int>('kpi_score');
  set kpiScore(int? value) => setField<int>('kpi_score', value);

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

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
