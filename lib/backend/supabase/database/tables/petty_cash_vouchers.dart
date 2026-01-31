import '../database.dart';

class PettyCashVouchersTable extends SupabaseTable<PettyCashVouchersRow> {
  @override
  String get tableName => 'petty_cash_vouchers';

  @override
  PettyCashVouchersRow createRow(Map<String, dynamic> data) =>
      PettyCashVouchersRow(data);
}

class PettyCashVouchersRow extends SupabaseDataRow {
  PettyCashVouchersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PettyCashVouchersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get voucherNumber => getField<String>('voucher_number')!;
  set voucherNumber(String value) => setField<String>('voucher_number', value);

  String? get boxId => getField<String>('box_id');
  set boxId(String? value) => setField<String>('box_id', value);

  DateTime get date => getField<DateTime>('date')!;
  set date(DateTime value) => setField<DateTime>('date', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get requestorId => getField<String>('requestor_id')!;
  set requestorId(String value) => setField<String>('requestor_id', value);

  String? get approverId => getField<String>('approver_id');
  set approverId(String? value) => setField<String>('approver_id', value);

  String? get secondApproverId => getField<String>('second_approver_id');
  set secondApproverId(String? value) =>
      setField<String>('second_approver_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get receiptUrl => getField<String>('receipt_url');
  set receiptUrl(String? value) => setField<String>('receipt_url', value);

  String? get expenseCategory => getField<String>('expense_category');
  set expenseCategory(String? value) =>
      setField<String>('expense_category', value);

  String? get comment => getField<String>('comment');
  set comment(String? value) => setField<String>('comment', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
