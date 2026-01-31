import '../database.dart';

class ZArchiveGlPeriodsTable extends SupabaseTable<ZArchiveGlPeriodsRow> {
  @override
  String get tableName => 'z_archive_gl_periods';

  @override
  ZArchiveGlPeriodsRow createRow(Map<String, dynamic> data) =>
      ZArchiveGlPeriodsRow(data);
}

class ZArchiveGlPeriodsRow extends SupabaseDataRow {
  ZArchiveGlPeriodsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveGlPeriodsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get periodId => getField<String>('period_id')!;
  set periodId(String value) => setField<String>('period_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get closedBy => getField<String>('closed_by');
  set closedBy(String? value) => setField<String>('closed_by', value);

  DateTime? get closedAt => getField<DateTime>('closed_at');
  set closedAt(DateTime? value) => setField<DateTime>('closed_at', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  DateTime? get periodStart => getField<DateTime>('period_start');
  set periodStart(DateTime? value) => setField<DateTime>('period_start', value);

  DateTime? get periodEnd => getField<DateTime>('period_end');
  set periodEnd(DateTime? value) => setField<DateTime>('period_end', value);

  int? get year => getField<int>('year');
  set year(int? value) => setField<int>('year', value);

  int? get month => getField<int>('month');
  set month(int? value) => setField<int>('month', value);
}
