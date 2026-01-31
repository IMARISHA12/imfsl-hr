import '../database.dart';

class VLoanStageFunnelTable extends SupabaseTable<VLoanStageFunnelRow> {
  @override
  String get tableName => 'v_loan_stage_funnel';

  @override
  VLoanStageFunnelRow createRow(Map<String, dynamic> data) =>
      VLoanStageFunnelRow(data);
}

class VLoanStageFunnelRow extends SupabaseDataRow {
  VLoanStageFunnelRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VLoanStageFunnelTable();

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  int? get count => getField<int>('count');
  set count(int? value) => setField<int>('count', value);

  double? get totalAmount => getField<double>('total_amount');
  set totalAmount(double? value) => setField<double>('total_amount', value);

  double? get avgAmount => getField<double>('avg_amount');
  set avgAmount(double? value) => setField<double>('avg_amount', value);

  double? get avgDaysInStage => getField<double>('avg_days_in_stage');
  set avgDaysInStage(double? value) =>
      setField<double>('avg_days_in_stage', value);
}
