import '../database.dart';

class StaffBadgesTable extends SupabaseTable<StaffBadgesRow> {
  @override
  String get tableName => 'staff_badges';

  @override
  StaffBadgesRow createRow(Map<String, dynamic> data) => StaffBadgesRow(data);
}

class StaffBadgesRow extends SupabaseDataRow {
  StaffBadgesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffBadgesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get badgeName => getField<String>('badge_name')!;
  set badgeName(String value) => setField<String>('badge_name', value);

  String? get icon => getField<String>('icon');
  set icon(String? value) => setField<String>('icon', value);

  DateTime get earnedAt => getField<DateTime>('earned_at')!;
  set earnedAt(DateTime value) => setField<DateTime>('earned_at', value);

  DateTime get earnedDate => getField<DateTime>('earned_date')!;
  set earnedDate(DateTime value) => setField<DateTime>('earned_date', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
