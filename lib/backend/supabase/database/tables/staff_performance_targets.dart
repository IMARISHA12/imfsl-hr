import '../database.dart';

class StaffPerformanceTargetsTable
    extends SupabaseTable<StaffPerformanceTargetsRow> {
  @override
  String get tableName => 'staff_performance_targets';

  @override
  StaffPerformanceTargetsRow createRow(Map<String, dynamic> data) =>
      StaffPerformanceTargetsRow(data);
}

class StaffPerformanceTargetsRow extends SupabaseDataRow {
  StaffPerformanceTargetsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffPerformanceTargetsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get officerId => getField<String>('officer_id')!;
  set officerId(String value) => setField<String>('officer_id', value);

  DateTime get targetPeriod => getField<DateTime>('target_period')!;
  set targetPeriod(DateTime value) =>
      setField<DateTime>('target_period', value);

  double? get disbursementTarget => getField<double>('disbursement_target');
  set disbursementTarget(double? value) =>
      setField<double>('disbursement_target', value);

  double? get collectionTarget => getField<double>('collection_target');
  set collectionTarget(double? value) =>
      setField<double>('collection_target', value);

  int? get newClientsTarget => getField<int>('new_clients_target');
  set newClientsTarget(int? value) =>
      setField<int>('new_clients_target', value);

  double? get par30MaxTarget => getField<double>('par_30_max_target');
  set par30MaxTarget(double? value) =>
      setField<double>('par_30_max_target', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
