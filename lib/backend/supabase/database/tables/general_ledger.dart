import '../database.dart';

class GeneralLedgerTable extends SupabaseTable<GeneralLedgerRow> {
  @override
  String get tableName => 'general_ledger';

  @override
  GeneralLedgerRow createRow(Map<String, dynamic> data) =>
      GeneralLedgerRow(data);
}

class GeneralLedgerRow extends SupabaseDataRow {
  GeneralLedgerRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GeneralLedgerTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get entryDate => getField<DateTime>('entry_date')!;
  set entryDate(DateTime value) => setField<DateTime>('entry_date', value);

  String get accountId => getField<String>('account_id')!;
  set accountId(String value) => setField<String>('account_id', value);

  String get accountCode => getField<String>('account_code')!;
  set accountCode(String value) => setField<String>('account_code', value);

  String get accountName => getField<String>('account_name')!;
  set accountName(String value) => setField<String>('account_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get referenceType => getField<String>('reference_type');
  set referenceType(String? value) => setField<String>('reference_type', value);

  String? get referenceId => getField<String>('reference_id');
  set referenceId(String? value) => setField<String>('reference_id', value);

  double get debitAmount => getField<double>('debit_amount')!;
  set debitAmount(double value) => setField<double>('debit_amount', value);

  double get creditAmount => getField<double>('credit_amount')!;
  set creditAmount(double value) => setField<double>('credit_amount', value);

  double? get balance => getField<double>('balance');
  set balance(double? value) => setField<double>('balance', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  String? get periodId => getField<String>('period_id');
  set periodId(String? value) => setField<String>('period_id', value);

  String? get journalId => getField<String>('journal_id');
  set journalId(String? value) => setField<String>('journal_id', value);

  String? get postedBy => getField<String>('posted_by');
  set postedBy(String? value) => setField<String>('posted_by', value);

  DateTime? get postedAt => getField<DateTime>('posted_at');
  set postedAt(DateTime? value) => setField<DateTime>('posted_at', value);

  bool? get isPosted => getField<bool>('is_posted');
  set isPosted(bool? value) => setField<bool>('is_posted', value);

  bool? get isReversed => getField<bool>('is_reversed');
  set isReversed(bool? value) => setField<bool>('is_reversed', value);

  String? get reversedBy => getField<String>('reversed_by');
  set reversedBy(String? value) => setField<String>('reversed_by', value);

  DateTime? get reversedAt => getField<DateTime>('reversed_at');
  set reversedAt(DateTime? value) => setField<DateTime>('reversed_at', value);

  String? get reversalReason => getField<String>('reversal_reason');
  set reversalReason(String? value) =>
      setField<String>('reversal_reason', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
