import '../database.dart';

class AccountsReceivableTable extends SupabaseTable<AccountsReceivableRow> {
  @override
  String get tableName => 'accounts_receivable';

  @override
  AccountsReceivableRow createRow(Map<String, dynamic> data) =>
      AccountsReceivableRow(data);
}

class AccountsReceivableRow extends SupabaseDataRow {
  AccountsReceivableRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AccountsReceivableTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get customerId => getField<String>('customer_id')!;
  set customerId(String value) => setField<String>('customer_id', value);

  String get invoiceNo => getField<String>('invoice_no')!;
  set invoiceNo(String value) => setField<String>('invoice_no', value);

  DateTime get invoiceDate => getField<DateTime>('invoice_date')!;
  set invoiceDate(DateTime value) => setField<DateTime>('invoice_date', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  double? get receivedAmount => getField<double>('received_amount');
  set receivedAmount(double? value) =>
      setField<double>('received_amount', value);

  DateTime get dueDate => getField<DateTime>('due_date')!;
  set dueDate(DateTime value) => setField<DateTime>('due_date', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get journalId => getField<String>('journal_id');
  set journalId(String? value) => setField<String>('journal_id', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  dynamic get lineItems => getField<dynamic>('line_items');
  set lineItems(dynamic value) => setField<dynamic>('line_items', value);

  String? get qboId => getField<String>('qbo_id');
  set qboId(String? value) => setField<String>('qbo_id', value);

  String? get qboDocNumber => getField<String>('qbo_doc_number');
  set qboDocNumber(String? value) => setField<String>('qbo_doc_number', value);

  String? get qboSyncToken => getField<String>('qbo_sync_token');
  set qboSyncToken(String? value) => setField<String>('qbo_sync_token', value);

  bool? get aiReviewed => getField<bool>('ai_reviewed');
  set aiReviewed(bool? value) => setField<bool>('ai_reviewed', value);

  String? get submittedBy => getField<String>('submitted_by');
  set submittedBy(String? value) => setField<String>('submitted_by', value);

  DateTime? get submittedAt => getField<DateTime>('submitted_at');
  set submittedAt(DateTime? value) => setField<DateTime>('submitted_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String? get rejectReason => getField<String>('reject_reason');
  set rejectReason(String? value) => setField<String>('reject_reason', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String get orgId => getField<String>('org_id')!;
  set orgId(String value) => setField<String>('org_id', value);
}
