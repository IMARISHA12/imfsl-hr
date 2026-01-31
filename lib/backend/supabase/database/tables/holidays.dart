import '../database.dart';

class HolidaysTable extends SupabaseTable<HolidaysRow> {
  @override
  String get tableName => 'holidays';

  @override
  HolidaysRow createRow(Map<String, dynamic> data) => HolidaysRow(data);
}

class HolidaysRow extends SupabaseDataRow {
  HolidaysRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => HolidaysTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get date => getField<DateTime>('date')!;
  set date(DateTime value) => setField<DateTime>('date', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  bool? get isRecurring => getField<bool>('is_recurring');
  set isRecurring(bool? value) => setField<bool>('is_recurring', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
