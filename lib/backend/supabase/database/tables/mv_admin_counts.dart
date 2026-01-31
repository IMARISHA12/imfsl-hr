import '../database.dart';

class MvAdminCountsTable extends SupabaseTable<MvAdminCountsRow> {
  @override
  String get tableName => 'mv_admin_counts';

  @override
  MvAdminCountsRow createRow(Map<String, dynamic> data) =>
      MvAdminCountsRow(data);
}

class MvAdminCountsRow extends SupabaseDataRow {
  MvAdminCountsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MvAdminCountsTable();

  DateTime? get refreshedAt => getField<DateTime>('refreshed_at');
  set refreshedAt(DateTime? value) => setField<DateTime>('refreshed_at', value);

  int? get employeesCount => getField<int>('employees_count');
  set employeesCount(int? value) => setField<int>('employees_count', value);

  int? get pendingLeaveCount => getField<int>('pending_leave_count');
  set pendingLeaveCount(int? value) =>
      setField<int>('pending_leave_count', value);

  int? get todayAttendanceCount => getField<int>('today_attendance_count');
  set todayAttendanceCount(int? value) =>
      setField<int>('today_attendance_count', value);
}
