import '../database.dart';

class ChartOfAccountsReadonlyTable
    extends SupabaseTable<ChartOfAccountsReadonlyRow> {
  @override
  String get tableName => 'chart_of_accounts_readonly';

  @override
  ChartOfAccountsReadonlyRow createRow(Map<String, dynamic> data) =>
      ChartOfAccountsReadonlyRow(data);
}

class ChartOfAccountsReadonlyRow extends SupabaseDataRow {
  ChartOfAccountsReadonlyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ChartOfAccountsReadonlyTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get accountCode => getField<String>('account_code');
  set accountCode(String? value) => setField<String>('account_code', value);

  String? get accountName => getField<String>('account_name');
  set accountName(String? value) => setField<String>('account_name', value);

  String? get accountType => getField<String>('account_type');
  set accountType(String? value) => setField<String>('account_type', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
