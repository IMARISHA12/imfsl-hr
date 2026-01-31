import '../database.dart';

class PaymentBatchesTable extends SupabaseTable<PaymentBatchesRow> {
  @override
  String get tableName => 'payment_batches';

  @override
  PaymentBatchesRow createRow(Map<String, dynamic> data) =>
      PaymentBatchesRow(data);
}

class PaymentBatchesRow extends SupabaseDataRow {
  PaymentBatchesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PaymentBatchesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get batchCode => getField<String>('batch_code')!;
  set batchCode(String value) => setField<String>('batch_code', value);

  String get batchType => getField<String>('batch_type')!;
  set batchType(String value) => setField<String>('batch_type', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  double get totalAmount => getField<double>('total_amount')!;
  set totalAmount(double value) => setField<double>('total_amount', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  int get itemCount => getField<int>('item_count')!;
  set itemCount(int value) => setField<int>('item_count', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get submittedBy => getField<String>('submitted_by');
  set submittedBy(String? value) => setField<String>('submitted_by', value);

  DateTime? get submittedAt => getField<DateTime>('submitted_at');
  set submittedAt(DateTime? value) => setField<DateTime>('submitted_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String? get rejectedBy => getField<String>('rejected_by');
  set rejectedBy(String? value) => setField<String>('rejected_by', value);

  DateTime? get rejectedAt => getField<DateTime>('rejected_at');
  set rejectedAt(DateTime? value) => setField<DateTime>('rejected_at', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  String? get executedBy => getField<String>('executed_by');
  set executedBy(String? value) => setField<String>('executed_by', value);

  DateTime? get executedAt => getField<DateTime>('executed_at');
  set executedAt(DateTime? value) => setField<DateTime>('executed_at', value);

  String? get bankFileUrl => getField<String>('bank_file_url');
  set bankFileUrl(String? value) => setField<String>('bank_file_url', value);

  DateTime? get bankFileGeneratedAt =>
      getField<DateTime>('bank_file_generated_at');
  set bankFileGeneratedAt(DateTime? value) =>
      setField<DateTime>('bank_file_generated_at', value);

  String? get bankReference => getField<String>('bank_reference');
  set bankReference(String? value) => setField<String>('bank_reference', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
