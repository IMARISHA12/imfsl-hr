import '../database.dart';

class BillingPaymentsTable extends SupabaseTable<BillingPaymentsRow> {
  @override
  String get tableName => 'billing_payments';

  @override
  BillingPaymentsRow createRow(Map<String, dynamic> data) =>
      BillingPaymentsRow(data);
}

class BillingPaymentsRow extends SupabaseDataRow {
  BillingPaymentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BillingPaymentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get billingItemId => getField<String>('billing_item_id')!;
  set billingItemId(String value) => setField<String>('billing_item_id', value);

  double get paidAmount => getField<double>('paid_amount')!;
  set paidAmount(double value) => setField<double>('paid_amount', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  DateTime get paymentDate => getField<DateTime>('payment_date')!;
  set paymentDate(DateTime value) => setField<DateTime>('payment_date', value);

  String get paymentMethod => getField<String>('payment_method')!;
  set paymentMethod(String value) => setField<String>('payment_method', value);

  String? get referenceNumber => getField<String>('reference_number');
  set referenceNumber(String? value) =>
      setField<String>('reference_number', value);

  String? get receiptDocumentId => getField<String>('receipt_document_id');
  set receiptDocumentId(String? value) =>
      setField<String>('receipt_document_id', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String get paidBy => getField<String>('paid_by')!;
  set paidBy(String value) => setField<String>('paid_by', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
