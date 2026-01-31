import '../database.dart';

class VJournalBalancesTable extends SupabaseTable<VJournalBalancesRow> {
  @override
  String get tableName => 'v_journal_balances';

  @override
  VJournalBalancesRow createRow(Map<String, dynamic> data) =>
      VJournalBalancesRow(data);
}

class VJournalBalancesRow extends SupabaseDataRow {
  VJournalBalancesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VJournalBalancesTable();

  String? get journalId => getField<String>('journal_id');
  set journalId(String? value) => setField<String>('journal_id', value);

  DateTime? get journalDate => getField<DateTime>('journal_date');
  set journalDate(DateTime? value) => setField<DateTime>('journal_date', value);

  String? get referenceType => getField<String>('reference_type');
  set referenceType(String? value) => setField<String>('reference_type', value);

  String? get referenceId => getField<String>('reference_id');
  set referenceId(String? value) => setField<String>('reference_id', value);

  double? get totalDebit => getField<double>('total_debit');
  set totalDebit(double? value) => setField<double>('total_debit', value);

  double? get totalCredit => getField<double>('total_credit');
  set totalCredit(double? value) => setField<double>('total_credit', value);

  double? get balanceDiff => getField<double>('balance_diff');
  set balanceDiff(double? value) => setField<double>('balance_diff', value);

  int? get lineCount => getField<int>('line_count');
  set lineCount(int? value) => setField<int>('line_count', value);

  DateTime? get firstPostedAt => getField<DateTime>('first_posted_at');
  set firstPostedAt(DateTime? value) =>
      setField<DateTime>('first_posted_at', value);

  DateTime? get lastPostedAt => getField<DateTime>('last_posted_at');
  set lastPostedAt(DateTime? value) =>
      setField<DateTime>('last_posted_at', value);
}
