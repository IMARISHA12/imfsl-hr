import '../database.dart';

class DailyCashCountsTable extends SupabaseTable<DailyCashCountsRow> {
  @override
  String get tableName => 'daily_cash_counts';

  @override
  DailyCashCountsRow createRow(Map<String, dynamic> data) =>
      DailyCashCountsRow(data);
}

class DailyCashCountsRow extends SupabaseDataRow {
  DailyCashCountsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DailyCashCountsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get branchId => getField<String>('branch_id')!;
  set branchId(String value) => setField<String>('branch_id', value);

  DateTime get countDate => getField<DateTime>('count_date')!;
  set countDate(DateTime value) => setField<DateTime>('count_date', value);

  int? get denom50000 => getField<int>('denom_50000');
  set denom50000(int? value) => setField<int>('denom_50000', value);

  int? get denom20000 => getField<int>('denom_20000');
  set denom20000(int? value) => setField<int>('denom_20000', value);

  int? get denom10000 => getField<int>('denom_10000');
  set denom10000(int? value) => setField<int>('denom_10000', value);

  int? get denom5000 => getField<int>('denom_5000');
  set denom5000(int? value) => setField<int>('denom_5000', value);

  int? get denom2000 => getField<int>('denom_2000');
  set denom2000(int? value) => setField<int>('denom_2000', value);

  int? get denom1000 => getField<int>('denom_1000');
  set denom1000(int? value) => setField<int>('denom_1000', value);

  int? get denom500 => getField<int>('denom_500');
  set denom500(int? value) => setField<int>('denom_500', value);

  int? get denom200 => getField<int>('denom_200');
  set denom200(int? value) => setField<int>('denom_200', value);

  int? get denom100 => getField<int>('denom_100');
  set denom100(int? value) => setField<int>('denom_100', value);

  int? get denom50 => getField<int>('denom_50');
  set denom50(int? value) => setField<int>('denom_50', value);

  double? get coinsTotal => getField<double>('coins_total');
  set coinsTotal(double? value) => setField<double>('coins_total', value);

  double? get physicalCount => getField<double>('physical_count');
  set physicalCount(double? value) => setField<double>('physical_count', value);

  double get openingBalance => getField<double>('opening_balance')!;
  set openingBalance(double value) =>
      setField<double>('opening_balance', value);

  double? get cashIn => getField<double>('cash_in');
  set cashIn(double? value) => setField<double>('cash_in', value);

  double? get cashOut => getField<double>('cash_out');
  set cashOut(double? value) => setField<double>('cash_out', value);

  double? get expectedClosing => getField<double>('expected_closing');
  set expectedClosing(double? value) =>
      setField<double>('expected_closing', value);

  double? get variance => getField<double>('variance');
  set variance(double? value) => setField<double>('variance', value);

  double? get variancePercentage => getField<double>('variance_percentage');
  set variancePercentage(double? value) =>
      setField<double>('variance_percentage', value);

  String? get varianceExplanation => getField<String>('variance_explanation');
  set varianceExplanation(String? value) =>
      setField<String>('variance_explanation', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get countedBy => getField<String>('counted_by')!;
  set countedBy(String value) => setField<String>('counted_by', value);

  DateTime? get countedAt => getField<DateTime>('counted_at');
  set countedAt(DateTime? value) => setField<DateTime>('counted_at', value);

  String? get witnessedBy => getField<String>('witnessed_by');
  set witnessedBy(String? value) => setField<String>('witnessed_by', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  List<String> get photoUrls => getListField<String>('photo_urls');
  set photoUrls(List<String>? value) =>
      setListField<String>('photo_urls', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
