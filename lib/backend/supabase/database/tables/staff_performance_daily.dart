import '../database.dart';

class StaffPerformanceDailyTable
    extends SupabaseTable<StaffPerformanceDailyRow> {
  @override
  String get tableName => 'staff_performance_daily';

  @override
  StaffPerformanceDailyRow createRow(Map<String, dynamic> data) =>
      StaffPerformanceDailyRow(data);
}

class StaffPerformanceDailyRow extends SupabaseDataRow {
  StaffPerformanceDailyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffPerformanceDailyTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  DateTime get performanceDate => getField<DateTime>('performance_date')!;
  set performanceDate(DateTime value) =>
      setField<DateTime>('performance_date', value);

  int? get attendanceScore => getField<int>('attendance_score');
  set attendanceScore(int? value) => setField<int>('attendance_score', value);

  PostgresTime? get clockInTime => getField<PostgresTime>('clock_in_time');
  set clockInTime(PostgresTime? value) =>
      setField<PostgresTime>('clock_in_time', value);

  PostgresTime? get clockOutTime => getField<PostgresTime>('clock_out_time');
  set clockOutTime(PostgresTime? value) =>
      setField<PostgresTime>('clock_out_time', value);

  int? get lateMinutes => getField<int>('late_minutes');
  set lateMinutes(int? value) => setField<int>('late_minutes', value);

  bool? get gpsCompliance => getField<bool>('gps_compliance');
  set gpsCompliance(bool? value) => setField<bool>('gps_compliance', value);

  double? get expectedCollection => getField<double>('expected_collection');
  set expectedCollection(double? value) =>
      setField<double>('expected_collection', value);

  double? get actualCollection => getField<double>('actual_collection');
  set actualCollection(double? value) =>
      setField<double>('actual_collection', value);

  double? get collectionRate => getField<double>('collection_rate');
  set collectionRate(double? value) =>
      setField<double>('collection_rate', value);

  int? get visitsPlanned => getField<int>('visits_planned');
  set visitsPlanned(int? value) => setField<int>('visits_planned', value);

  int? get visitsCompleted => getField<int>('visits_completed');
  set visitsCompleted(int? value) => setField<int>('visits_completed', value);

  int? get activeLoans => getField<int>('active_loans');
  set activeLoans(int? value) => setField<int>('active_loans', value);

  double? get par130 => getField<double>('par_1_30');
  set par130(double? value) => setField<double>('par_1_30', value);

  double? get par3160 => getField<double>('par_31_60');
  set par3160(double? value) => setField<double>('par_31_60', value);

  double? get par6190 => getField<double>('par_61_90');
  set par6190(double? value) => setField<double>('par_61_90', value);

  double? get par90Plus => getField<double>('par_90_plus');
  set par90Plus(double? value) => setField<double>('par_90_plus', value);

  int? get newClients => getField<int>('new_clients');
  set newClients(int? value) => setField<int>('new_clients', value);

  int? get complaintsReceived => getField<int>('complaints_received');
  set complaintsReceived(int? value) =>
      setField<int>('complaints_received', value);

  int? get dailyScore => getField<int>('daily_score');
  set dailyScore(int? value) => setField<int>('daily_score', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
