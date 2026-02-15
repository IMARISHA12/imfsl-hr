import '../database.dart';

class FinBorrowersTable extends SupabaseTable<FinBorrowersRow> {
  @override
  String get tableName => 'fin_borrowers';

  @override
  FinBorrowersRow createRow(Map<String, dynamic> data) => FinBorrowersRow(data);
}

class FinBorrowersRow extends SupabaseDataRow {
  FinBorrowersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FinBorrowersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get loandiskBorrowerId => getField<String>('loandisk_borrower_id');
  set loandiskBorrowerId(String? value) =>
      setField<String>('loandisk_borrower_id', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get nationalId => getField<String>('national_id');
  set nationalId(String? value) => setField<String>('national_id', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
