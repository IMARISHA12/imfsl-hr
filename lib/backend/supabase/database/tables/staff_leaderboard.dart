import '../database.dart';

class StaffLeaderboardTable extends SupabaseTable<StaffLeaderboardRow> {
  @override
  String get tableName => 'staff_leaderboard';

  @override
  StaffLeaderboardRow createRow(Map<String, dynamic> data) =>
      StaffLeaderboardRow(data);
}

class StaffLeaderboardRow extends SupabaseDataRow {
  StaffLeaderboardRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffLeaderboardTable();

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get totalPoints => getField<int>('total_points');
  set totalPoints(int? value) => setField<int>('total_points', value);

  int? get rank => getField<int>('rank');
  set rank(int? value) => setField<int>('rank', value);

  int? get totalStaff => getField<int>('total_staff');
  set totalStaff(int? value) => setField<int>('total_staff', value);

  DateTime? get periodStart => getField<DateTime>('period_start');
  set periodStart(DateTime? value) => setField<DateTime>('period_start', value);

  DateTime? get periodEnd => getField<DateTime>('period_end');
  set periodEnd(DateTime? value) => setField<DateTime>('period_end', value);
}
