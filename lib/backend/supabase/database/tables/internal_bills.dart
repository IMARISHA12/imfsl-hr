import '../database.dart';

class InternalBillsTable extends SupabaseTable<InternalBillsRow> {
  @override
  String get tableName => 'internal_bills';

  @override
  InternalBillsRow createRow(Map<String, dynamic> data) =>
      InternalBillsRow(data);
}

class InternalBillsRow extends SupabaseDataRow {
  InternalBillsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => InternalBillsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get leaseId => getField<String>('lease_id')!;
  set leaseId(String value) => setField<String>('lease_id', value);

  DateTime get dueDate => getField<DateTime>('due_date')!;
  set dueDate(DateTime value) => setField<DateTime>('due_date', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get receiptPath => getField<String>('receipt_path');
  set receiptPath(String? value) => setField<String>('receipt_path', value);

  String? get paidBy => getField<String>('paid_by');
  set paidBy(String? value) => setField<String>('paid_by', value);

  DateTime? get paidAt => getField<DateTime>('paid_at');
  set paidAt(DateTime? value) => setField<DateTime>('paid_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
