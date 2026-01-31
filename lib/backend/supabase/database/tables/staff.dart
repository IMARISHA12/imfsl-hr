import '../database.dart';

class StaffTable extends SupabaseTable<StaffRow> {
  @override
  String get tableName => 'staff';

  @override
  StaffRow createRow(Map<String, dynamic> data) => StaffRow(data);
}

class StaffRow extends SupabaseDataRow {
  StaffRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get fullName => getField<String>('full_name')!;
  set fullName(String value) => setField<String>('full_name', value);

  bool get active => getField<bool>('active')!;
  set active(bool value) => setField<bool>('active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);
}
