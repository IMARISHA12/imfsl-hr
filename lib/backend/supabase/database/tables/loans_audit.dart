import '../database.dart';

class LoansAuditTable extends SupabaseTable<LoansAuditRow> {
  @override
  String get tableName => 'loans_audit';

  @override
  LoansAuditRow createRow(Map<String, dynamic> data) => LoansAuditRow(data);
}

class LoansAuditRow extends SupabaseDataRow {
  LoansAuditRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoansAuditTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String? get changedBy => getField<String>('changed_by');
  set changedBy(String? value) => setField<String>('changed_by', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  dynamic get oldRow => getField<dynamic>('old_row');
  set oldRow(dynamic value) => setField<dynamic>('old_row', value);

  dynamic get newRow => getField<dynamic>('new_row');
  set newRow(dynamic value) => setField<dynamic>('new_row', value);

  DateTime get changedAt => getField<DateTime>('changed_at')!;
  set changedAt(DateTime value) => setField<DateTime>('changed_at', value);
}
