import '../database.dart';

class BorrowersTable extends SupabaseTable<BorrowersRow> {
  @override
  String get tableName => 'borrowers';

  @override
  BorrowersRow createRow(Map<String, dynamic> data) => BorrowersRow(data);
}

class BorrowersRow extends SupabaseDataRow {
  BorrowersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BorrowersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get fullName => getField<String>('full_name')!;
  set fullName(String value) => setField<String>('full_name', value);

  String get phoneNumber => getField<String>('phone_number')!;
  set phoneNumber(String value) => setField<String>('phone_number', value);

  String? get nidaNumber => getField<String>('nida_number');
  set nidaNumber(String? value) => setField<String>('nida_number', value);

  String? get locationGps => getField<String>('location_gps');
  set locationGps(String? value) => setField<String>('location_gps', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
