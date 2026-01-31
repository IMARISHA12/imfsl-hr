import '../database.dart';

class VLoanPipelineAnalyticsTable
    extends SupabaseTable<VLoanPipelineAnalyticsRow> {
  @override
  String get tableName => 'v_loan_pipeline_analytics';

  @override
  VLoanPipelineAnalyticsRow createRow(Map<String, dynamic> data) =>
      VLoanPipelineAnalyticsRow(data);
}

class VLoanPipelineAnalyticsRow extends SupabaseDataRow {
  VLoanPipelineAnalyticsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VLoanPipelineAnalyticsTable();

  int? get totalApplications => getField<int>('total_applications');
  set totalApplications(int? value) =>
      setField<int>('total_applications', value);

  int? get pendingCount => getField<int>('pending_count');
  set pendingCount(int? value) => setField<int>('pending_count', value);

  int? get pendingReviewCount => getField<int>('pending_review_count');
  set pendingReviewCount(int? value) =>
      setField<int>('pending_review_count', value);

  int? get pendingManagerCount => getField<int>('pending_manager_count');
  set pendingManagerCount(int? value) =>
      setField<int>('pending_manager_count', value);

  int? get pendingDirectorCount => getField<int>('pending_director_count');
  set pendingDirectorCount(int? value) =>
      setField<int>('pending_director_count', value);

  int? get approvedCount => getField<int>('approved_count');
  set approvedCount(int? value) => setField<int>('approved_count', value);

  int? get activeCount => getField<int>('active_count');
  set activeCount(int? value) => setField<int>('active_count', value);

  int? get rejectedCount => getField<int>('rejected_count');
  set rejectedCount(int? value) => setField<int>('rejected_count', value);

  int? get cancelledCount => getField<int>('cancelled_count');
  set cancelledCount(int? value) => setField<int>('cancelled_count', value);

  int? get closedCount => getField<int>('closed_count');
  set closedCount(int? value) => setField<int>('closed_count', value);

  double? get totalPipelineAmount => getField<double>('total_pipeline_amount');
  set totalPipelineAmount(double? value) =>
      setField<double>('total_pipeline_amount', value);

  double? get pendingAmount => getField<double>('pending_amount');
  set pendingAmount(double? value) => setField<double>('pending_amount', value);

  double? get approvedAmount => getField<double>('approved_amount');
  set approvedAmount(double? value) =>
      setField<double>('approved_amount', value);

  double? get avgLoanAmount => getField<double>('avg_loan_amount');
  set avgLoanAmount(double? value) =>
      setField<double>('avg_loan_amount', value);

  int? get totalApproved => getField<int>('total_approved');
  set totalApproved(int? value) => setField<int>('total_approved', value);

  int? get totalRejected => getField<int>('total_rejected');
  set totalRejected(int? value) => setField<int>('total_rejected', value);

  int? get totalDecided => getField<int>('total_decided');
  set totalDecided(int? value) => setField<int>('total_decided', value);

  double? get approvalRate => getField<double>('approval_rate');
  set approvalRate(double? value) => setField<double>('approval_rate', value);

  double? get avgApprovalHours => getField<double>('avg_approval_hours');
  set avgApprovalHours(double? value) =>
      setField<double>('avg_approval_hours', value);

  dynamic get weeklyTrend => getField<dynamic>('weekly_trend');
  set weeklyTrend(dynamic value) => setField<dynamic>('weekly_trend', value);
}
