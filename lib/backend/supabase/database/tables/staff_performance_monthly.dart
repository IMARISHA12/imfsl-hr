import '../database.dart';

class StaffPerformanceMonthlyTable
    extends SupabaseTable<StaffPerformanceMonthlyRow> {
  @override
  String get tableName => 'staff_performance_monthly';

  @override
  StaffPerformanceMonthlyRow createRow(Map<String, dynamic> data) =>
      StaffPerformanceMonthlyRow(data);
}

class StaffPerformanceMonthlyRow extends SupabaseDataRow {
  StaffPerformanceMonthlyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffPerformanceMonthlyTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  int get year => getField<int>('year')!;
  set year(int value) => setField<int>('year', value);

  int get month => getField<int>('month')!;
  set month(int value) => setField<int>('month', value);

  int? get attendanceScore => getField<int>('attendance_score');
  set attendanceScore(int? value) => setField<int>('attendance_score', value);

  int? get collectionScore => getField<int>('collection_score');
  set collectionScore(int? value) => setField<int>('collection_score', value);

  int? get customerSatisfactionScore =>
      getField<int>('customer_satisfaction_score');
  set customerSatisfactionScore(int? value) =>
      setField<int>('customer_satisfaction_score', value);

  int? get complianceScore => getField<int>('compliance_score');
  set complianceScore(int? value) => setField<int>('compliance_score', value);

  int? get overallScore => getField<int>('overall_score');
  set overallScore(int? value) => setField<int>('overall_score', value);

  String? get grade => getField<String>('grade');
  set grade(String? value) => setField<String>('grade', value);

  int? get daysWorked => getField<int>('days_worked');
  set daysWorked(int? value) => setField<int>('days_worked', value);

  int? get daysLate => getField<int>('days_late');
  set daysLate(int? value) => setField<int>('days_late', value);

  int? get daysAbsent => getField<int>('days_absent');
  set daysAbsent(int? value) => setField<int>('days_absent', value);

  double? get totalCollections => getField<double>('total_collections');
  set totalCollections(double? value) =>
      setField<double>('total_collections', value);

  double? get collectionTarget => getField<double>('collection_target');
  set collectionTarget(double? value) =>
      setField<double>('collection_target', value);

  String? get recommendation => getField<String>('recommendation');
  set recommendation(String? value) =>
      setField<String>('recommendation', value);

  String? get recommendationReason => getField<String>('recommendation_reason');
  set recommendationReason(String? value) =>
      setField<String>('recommendation_reason', value);

  bool? get recommendationActed => getField<bool>('recommendation_acted');
  set recommendationActed(bool? value) =>
      setField<bool>('recommendation_acted', value);

  String? get actedBy => getField<String>('acted_by');
  set actedBy(String? value) => setField<String>('acted_by', value);

  String? get actionTaken => getField<String>('action_taken');
  set actionTaken(String? value) => setField<String>('action_taken', value);

  DateTime? get actionDate => getField<DateTime>('action_date');
  set actionDate(DateTime? value) => setField<DateTime>('action_date', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
