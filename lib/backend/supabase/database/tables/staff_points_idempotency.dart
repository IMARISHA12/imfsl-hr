import '../database.dart';

class StaffPointsIdempotencyTable
    extends SupabaseTable<StaffPointsIdempotencyRow> {
  @override
  String get tableName => 'staff_points_idempotency';

  @override
  StaffPointsIdempotencyRow createRow(Map<String, dynamic> data) =>
      StaffPointsIdempotencyRow(data);
}

class StaffPointsIdempotencyRow extends SupabaseDataRow {
  StaffPointsIdempotencyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffPointsIdempotencyTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
