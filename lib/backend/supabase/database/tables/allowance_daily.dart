import '../database.dart';

class AllowanceDailyTable extends SupabaseTable<AllowanceDailyRow> {
  @override
  String get tableName => 'allowance_daily';

  @override
  AllowanceDailyRow createRow(Map<String, dynamic> data) =>
      AllowanceDailyRow(data);
}

class AllowanceDailyRow extends SupabaseDataRow {
  AllowanceDailyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AllowanceDailyTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  DateTime get workDate => getField<DateTime>('work_date')!;
  set workDate(DateTime value) => setField<DateTime>('work_date', value);

  int get allowanceCents => getField<int>('allowance_cents')!;
  set allowanceCents(int value) => setField<int>('allowance_cents', value);

  String get sourceStatus => getField<String>('source_status')!;
  set sourceStatus(String value) => setField<String>('source_status', value);

  DateTime get computedAt => getField<DateTime>('computed_at')!;
  set computedAt(DateTime value) => setField<DateTime>('computed_at', value);
}
