import '../database.dart';

class DepartmentsTable extends SupabaseTable<DepartmentsRow> {
  @override
  String get tableName => 'departments';

  @override
  DepartmentsRow createRow(Map<String, dynamic> data) => DepartmentsRow(data);
}

class DepartmentsRow extends SupabaseDataRow {
  DepartmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DepartmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get headId => getField<String>('head_id');
  set headId(String? value) => setField<String>('head_id', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get parentDepartmentId => getField<String>('parent_department_id');
  set parentDepartmentId(String? value) =>
      setField<String>('parent_department_id', value);

  String? get managerId => getField<String>('manager_id');
  set managerId(String? value) => setField<String>('manager_id', value);

  double? get budgetLimit => getField<double>('budget_limit');
  set budgetLimit(double? value) => setField<double>('budget_limit', value);

  double? get branchLatitude => getField<double>('branch_latitude');
  set branchLatitude(double? value) =>
      setField<double>('branch_latitude', value);

  double? get branchLongitude => getField<double>('branch_longitude');
  set branchLongitude(double? value) =>
      setField<double>('branch_longitude', value);

  int? get attendanceRadiusM => getField<int>('attendance_radius_m');
  set attendanceRadiusM(int? value) =>
      setField<int>('attendance_radius_m', value);

  bool? get isAttendanceLocation => getField<bool>('is_attendance_location');
  set isAttendanceLocation(bool? value) =>
      setField<bool>('is_attendance_location', value);
}
