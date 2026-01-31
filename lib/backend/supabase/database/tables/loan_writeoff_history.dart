import '../database.dart';

class LoanWriteoffHistoryTable extends SupabaseTable<LoanWriteoffHistoryRow> {
  @override
  String get tableName => 'loan_writeoff_history';

  @override
  LoanWriteoffHistoryRow createRow(Map<String, dynamic> data) =>
      LoanWriteoffHistoryRow(data);
}

class LoanWriteoffHistoryRow extends SupabaseDataRow {
  LoanWriteoffHistoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanWriteoffHistoryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get requestId => getField<String>('request_id')!;
  set requestId(String value) => setField<String>('request_id', value);

  String get actorId => getField<String>('actor_id')!;
  set actorId(String value) => setField<String>('actor_id', value);

  String get actorName => getField<String>('actor_name')!;
  set actorName(String value) => setField<String>('actor_name', value);

  String get actorRole => getField<String>('actor_role')!;
  set actorRole(String value) => setField<String>('actor_role', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String? get oldStatus => getField<String>('old_status');
  set oldStatus(String? value) => setField<String>('old_status', value);

  String? get newStatus => getField<String>('new_status');
  set newStatus(String? value) => setField<String>('new_status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
