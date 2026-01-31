import '../database.dart';

class StaffDisciplinaryActionsTable
    extends SupabaseTable<StaffDisciplinaryActionsRow> {
  @override
  String get tableName => 'staff_disciplinary_actions';

  @override
  StaffDisciplinaryActionsRow createRow(Map<String, dynamic> data) =>
      StaffDisciplinaryActionsRow(data);
}

class StaffDisciplinaryActionsRow extends SupabaseDataRow {
  StaffDisciplinaryActionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffDisciplinaryActionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  String? get offenseType => getField<String>('offense_type');
  set offenseType(String? value) => setField<String>('offense_type', value);

  int? get warningLevel => getField<int>('warning_level');
  set warningLevel(int? value) => setField<int>('warning_level', value);

  String? get letterUrl => getField<String>('letter_url');
  set letterUrl(String? value) => setField<String>('letter_url', value);

  bool? get acknowledgedByStaff => getField<bool>('acknowledged_by_staff');
  set acknowledgedByStaff(bool? value) =>
      setField<bool>('acknowledged_by_staff', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
