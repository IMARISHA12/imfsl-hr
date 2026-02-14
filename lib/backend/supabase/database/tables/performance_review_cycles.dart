import '../database.dart';

class PerformanceReviewCyclesTable
    extends SupabaseTable<PerformanceReviewCyclesRow> {
  @override
  String get tableName => 'performance_review_cycles';

  @override
  PerformanceReviewCyclesRow createRow(Map<String, dynamic> data) =>
      PerformanceReviewCyclesRow(data);
}

class PerformanceReviewCyclesRow extends SupabaseDataRow {
  PerformanceReviewCyclesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PerformanceReviewCyclesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get cycleName => getField<String>('cycle_name')!;
  set cycleName(String value) => setField<String>('cycle_name', value);

  String get cycleType => getField<String>('cycle_type')!;
  set cycleType(String value) => setField<String>('cycle_type', value);

  DateTime get periodStart => getField<DateTime>('period_start')!;
  set periodStart(DateTime value) =>
      setField<DateTime>('period_start', value);

  DateTime get periodEnd => getField<DateTime>('period_end')!;
  set periodEnd(DateTime value) => setField<DateTime>('period_end', value);

  DateTime? get reviewDeadline => getField<DateTime>('review_deadline');
  set reviewDeadline(DateTime? value) =>
      setField<DateTime>('review_deadline', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
