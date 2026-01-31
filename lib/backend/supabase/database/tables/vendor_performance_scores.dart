import '../database.dart';

class VendorPerformanceScoresTable
    extends SupabaseTable<VendorPerformanceScoresRow> {
  @override
  String get tableName => 'vendor_performance_scores';

  @override
  VendorPerformanceScoresRow createRow(Map<String, dynamic> data) =>
      VendorPerformanceScoresRow(data);
}

class VendorPerformanceScoresRow extends SupabaseDataRow {
  VendorPerformanceScoresRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VendorPerformanceScoresTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get vendorId => getField<String>('vendor_id')!;
  set vendorId(String value) => setField<String>('vendor_id', value);

  String get periodKey => getField<String>('period_key')!;
  set periodKey(String value) => setField<String>('period_key', value);

  double? get onTimeDeliveryRate => getField<double>('on_time_delivery_rate');
  set onTimeDeliveryRate(double? value) =>
      setField<double>('on_time_delivery_rate', value);

  int? get totalDeliveries => getField<int>('total_deliveries');
  set totalDeliveries(int? value) => setField<int>('total_deliveries', value);

  int? get lateDeliveries => getField<int>('late_deliveries');
  set lateDeliveries(int? value) => setField<int>('late_deliveries', value);

  double? get qualityScore => getField<double>('quality_score');
  set qualityScore(double? value) => setField<double>('quality_score', value);

  double? get defectRate => getField<double>('defect_rate');
  set defectRate(double? value) => setField<double>('defect_rate', value);

  double? get returnRate => getField<double>('return_rate');
  set returnRate(double? value) => setField<double>('return_rate', value);

  double? get priceCompetitiveness => getField<double>('price_competitiveness');
  set priceCompetitiveness(double? value) =>
      setField<double>('price_competitiveness', value);

  double? get responseTimeAvgHours =>
      getField<double>('response_time_avg_hours');
  set responseTimeAvgHours(double? value) =>
      setField<double>('response_time_avg_hours', value);

  double? get overallScore => getField<double>('overall_score');
  set overallScore(double? value) => setField<double>('overall_score', value);

  String? get evaluatorNotes => getField<String>('evaluator_notes');
  set evaluatorNotes(String? value) =>
      setField<String>('evaluator_notes', value);

  String? get evaluatedBy => getField<String>('evaluated_by');
  set evaluatedBy(String? value) => setField<String>('evaluated_by', value);

  DateTime? get evaluatedAt => getField<DateTime>('evaluated_at');
  set evaluatedAt(DateTime? value) => setField<DateTime>('evaluated_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
