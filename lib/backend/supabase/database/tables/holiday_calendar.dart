import '../database.dart';

class HolidayCalendarTable extends SupabaseTable<HolidayCalendarRow> {
  @override
  String get tableName => 'holiday_calendar';

  @override
  HolidayCalendarRow createRow(Map<String, dynamic> data) =>
      HolidayCalendarRow(data);
}

class HolidayCalendarRow extends SupabaseDataRow {
  HolidayCalendarRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => HolidayCalendarTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get region => getField<String>('region')!;
  set region(String value) => setField<String>('region', value);

  DateTime get holidayDate => getField<DateTime>('holiday_date')!;
  set holidayDate(DateTime value) => setField<DateTime>('holiday_date', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get holidayType => getField<String>('holiday_type')!;
  set holidayType(String value) => setField<String>('holiday_type', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  String get source => getField<String>('source')!;
  set source(String value) => setField<String>('source', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
