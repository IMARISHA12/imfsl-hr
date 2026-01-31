import '../database.dart';

class StaffPointsLedgerTable extends SupabaseTable<StaffPointsLedgerRow> {
  @override
  String get tableName => 'staff_points_ledger';

  @override
  StaffPointsLedgerRow createRow(Map<String, dynamic> data) =>
      StaffPointsLedgerRow(data);
}

class StaffPointsLedgerRow extends SupabaseDataRow {
  StaffPointsLedgerRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffPointsLedgerTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  int get points => getField<int>('points')!;
  set points(int value) => setField<int>('points', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime get eventAt => getField<DateTime>('event_at')!;
  set eventAt(DateTime value) => setField<DateTime>('event_at', value);

  DateTime get eventDate => getField<DateTime>('event_date')!;
  set eventDate(DateTime value) => setField<DateTime>('event_date', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
