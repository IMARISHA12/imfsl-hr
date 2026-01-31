import '../database.dart';

class ChartOfAccountsTable extends SupabaseTable<ChartOfAccountsRow> {
  @override
  String get tableName => 'chart_of_accounts';

  @override
  ChartOfAccountsRow createRow(Map<String, dynamic> data) =>
      ChartOfAccountsRow(data);
}

class ChartOfAccountsRow extends SupabaseDataRow {
  ChartOfAccountsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ChartOfAccountsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get accountCode => getField<String>('account_code')!;
  set accountCode(String value) => setField<String>('account_code', value);

  String get accountName => getField<String>('account_name')!;
  set accountName(String value) => setField<String>('account_name', value);

  String get accountType => getField<String>('account_type')!;
  set accountType(String value) => setField<String>('account_type', value);

  String? get parentAccountId => getField<String>('parent_account_id');
  set parentAccountId(String? value) =>
      setField<String>('parent_account_id', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double? get currentBalance => getField<double>('current_balance');
  set currentBalance(double? value) =>
      setField<double>('current_balance', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
