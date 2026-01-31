import '../database.dart';

class ViewDailyTrialBalanceTable
    extends SupabaseTable<ViewDailyTrialBalanceRow> {
  @override
  String get tableName => 'view_daily_trial_balance';

  @override
  ViewDailyTrialBalanceRow createRow(Map<String, dynamic> data) =>
      ViewDailyTrialBalanceRow(data);
}

class ViewDailyTrialBalanceRow extends SupabaseDataRow {
  ViewDailyTrialBalanceRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ViewDailyTrialBalanceTable();

  DateTime? get entryDate => getField<DateTime>('entry_date');
  set entryDate(DateTime? value) => setField<DateTime>('entry_date', value);

  String? get accountCode => getField<String>('account_code');
  set accountCode(String? value) => setField<String>('account_code', value);

  double? get openingBalance => getField<double>('opening_balance');
  set openingBalance(double? value) =>
      setField<double>('opening_balance', value);

  double? get totalDebit => getField<double>('total_debit');
  set totalDebit(double? value) => setField<double>('total_debit', value);

  double? get totalCredit => getField<double>('total_credit');
  set totalCredit(double? value) => setField<double>('total_credit', value);

  double? get closingBalance => getField<double>('closing_balance');
  set closingBalance(double? value) =>
      setField<double>('closing_balance', value);

  bool? get checkBalanced => getField<bool>('check_balanced');
  set checkBalanced(bool? value) => setField<bool>('check_balanced', value);
}
