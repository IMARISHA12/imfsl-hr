import '../database.dart';

class EmployeeProfileCompletionTable
    extends SupabaseTable<EmployeeProfileCompletionRow> {
  @override
  String get tableName => 'employee_profile_completion';

  @override
  EmployeeProfileCompletionRow createRow(Map<String, dynamic> data) =>
      EmployeeProfileCompletionRow(data);
}

class EmployeeProfileCompletionRow extends SupabaseDataRow {
  EmployeeProfileCompletionRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmployeeProfileCompletionTable();

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  int get completionPercentage => getField<int>('completion_percentage')!;
  set completionPercentage(int value) =>
      setField<int>('completion_percentage', value);

  DateTime get lastUpdated => getField<DateTime>('last_updated')!;
  set lastUpdated(DateTime value) => setField<DateTime>('last_updated', value);
}
