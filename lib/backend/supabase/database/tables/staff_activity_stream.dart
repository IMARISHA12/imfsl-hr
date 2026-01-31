import '../database.dart';

class StaffActivityStreamTable extends SupabaseTable<StaffActivityStreamRow> {
  @override
  String get tableName => 'staff_activity_stream';

  @override
  StaffActivityStreamRow createRow(Map<String, dynamic> data) =>
      StaffActivityStreamRow(data);
}

class StaffActivityStreamRow extends SupabaseDataRow {
  StaffActivityStreamRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffActivityStreamTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get activityType => getField<String>('activity_type')!;
  set activityType(String value) => setField<String>('activity_type', value);

  String? get activityDescription => getField<String>('activity_description');
  set activityDescription(String? value) =>
      setField<String>('activity_description', value);

  int? get pointsEarned => getField<int>('points_earned');
  set pointsEarned(int? value) => setField<int>('points_earned', value);

  String? get moduleName => getField<String>('module_name');
  set moduleName(String? value) => setField<String>('module_name', value);

  DateTime? get recordedAt => getField<DateTime>('recorded_at');
  set recordedAt(DateTime? value) => setField<DateTime>('recorded_at', value);

  String? get sessionId => getField<String>('session_id');
  set sessionId(String? value) => setField<String>('session_id', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);
}
