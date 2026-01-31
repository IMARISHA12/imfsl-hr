import '../database.dart';

class ViewGovernmentLoanPerformanceTable
    extends SupabaseTable<ViewGovernmentLoanPerformanceRow> {
  @override
  String get tableName => 'view_government_loan_performance';

  @override
  ViewGovernmentLoanPerformanceRow createRow(Map<String, dynamic> data) =>
      ViewGovernmentLoanPerformanceRow(data);
}

class ViewGovernmentLoanPerformanceRow extends SupabaseDataRow {
  ViewGovernmentLoanPerformanceRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ViewGovernmentLoanPerformanceTable();

  int? get underReview => getField<int>('under_review');
  set underReview(int? value) => setField<int>('under_review', value);

  int? get approved => getField<int>('approved');
  set approved(int? value) => setField<int>('approved', value);

  int? get rejected => getField<int>('rejected');
  set rejected(int? value) => setField<int>('rejected', value);

  int? get disbursed => getField<int>('disbursed');
  set disbursed(int? value) => setField<int>('disbursed', value);

  int? get totalApplications => getField<int>('total_applications');
  set totalApplications(int? value) =>
      setField<int>('total_applications', value);

  double? get totalDisbursedAmount =>
      getField<double>('total_disbursed_amount');
  set totalDisbursedAmount(double? value) =>
      setField<double>('total_disbursed_amount', value);

  double? get pipelineAmount => getField<double>('pipeline_amount');
  set pipelineAmount(double? value) =>
      setField<double>('pipeline_amount', value);
}
