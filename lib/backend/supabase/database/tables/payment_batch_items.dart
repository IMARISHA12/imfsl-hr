import '../database.dart';

class PaymentBatchItemsTable extends SupabaseTable<PaymentBatchItemsRow> {
  @override
  String get tableName => 'payment_batch_items';

  @override
  PaymentBatchItemsRow createRow(Map<String, dynamic> data) =>
      PaymentBatchItemsRow(data);
}

class PaymentBatchItemsRow extends SupabaseDataRow {
  PaymentBatchItemsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PaymentBatchItemsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get batchId => getField<String>('batch_id')!;
  set batchId(String value) => setField<String>('batch_id', value);

  String get beneficiaryName => getField<String>('beneficiary_name')!;
  set beneficiaryName(String value) =>
      setField<String>('beneficiary_name', value);

  String get beneficiaryAccount => getField<String>('beneficiary_account')!;
  set beneficiaryAccount(String value) =>
      setField<String>('beneficiary_account', value);

  String get beneficiaryBank => getField<String>('beneficiary_bank')!;
  set beneficiaryBank(String value) =>
      setField<String>('beneficiary_bank', value);

  String? get beneficiaryBankCode => getField<String>('beneficiary_bank_code');
  set beneficiaryBankCode(String? value) =>
      setField<String>('beneficiary_bank_code', value);

  String? get beneficiaryBranch => getField<String>('beneficiary_branch');
  set beneficiaryBranch(String? value) =>
      setField<String>('beneficiary_branch', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  String get referenceField => getField<String>('reference')!;
  set referenceField(String value) => setField<String>('reference', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get sourceType => getField<String>('source_type');
  set sourceType(String? value) => setField<String>('source_type', value);

  String? get sourceId => getField<String>('source_id');
  set sourceId(String? value) => setField<String>('source_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get bankReference => getField<String>('bank_reference');
  set bankReference(String? value) => setField<String>('bank_reference', value);

  String? get failureReason => getField<String>('failure_reason');
  set failureReason(String? value) => setField<String>('failure_reason', value);

  DateTime? get reconciledAt => getField<DateTime>('reconciled_at');
  set reconciledAt(DateTime? value) =>
      setField<DateTime>('reconciled_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
