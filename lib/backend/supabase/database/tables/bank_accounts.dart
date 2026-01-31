import '../database.dart';

class BankAccountsTable extends SupabaseTable<BankAccountsRow> {
  @override
  String get tableName => 'bank_accounts';

  @override
  BankAccountsRow createRow(Map<String, dynamic> data) => BankAccountsRow(data);
}

class BankAccountsRow extends SupabaseDataRow {
  BankAccountsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BankAccountsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get bankName => getField<String>('bank_name')!;
  set bankName(String value) => setField<String>('bank_name', value);

  String get accountName => getField<String>('account_name')!;
  set accountName(String value) => setField<String>('account_name', value);

  String get accountNumberMasked => getField<String>('account_number_masked')!;
  set accountNumberMasked(String value) =>
      setField<String>('account_number_masked', value);

  String get accountType => getField<String>('account_type')!;
  set accountType(String value) => setField<String>('account_type', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  String? get glAccountId => getField<String>('gl_account_id');
  set glAccountId(String? value) => setField<String>('gl_account_id', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  double? get openingBalance => getField<double>('opening_balance');
  set openingBalance(double? value) =>
      setField<double>('opening_balance', value);

  double? get currentBalance => getField<double>('current_balance');
  set currentBalance(double? value) =>
      setField<double>('current_balance', value);

  DateTime? get lastReconciledDate =>
      getField<DateTime>('last_reconciled_date');
  set lastReconciledDate(DateTime? value) =>
      setField<DateTime>('last_reconciled_date', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
