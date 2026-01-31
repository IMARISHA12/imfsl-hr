import '../database.dart';

class CreditScoreHistoryTable extends SupabaseTable<CreditScoreHistoryRow> {
  @override
  String get tableName => 'credit_score_history';

  @override
  CreditScoreHistoryRow createRow(Map<String, dynamic> data) =>
      CreditScoreHistoryRow(data);
}

class CreditScoreHistoryRow extends SupabaseDataRow {
  CreditScoreHistoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CreditScoreHistoryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get clientId => getField<String>('client_id')!;
  set clientId(String value) => setField<String>('client_id', value);

  int? get previousScore => getField<int>('previous_score');
  set previousScore(int? value) => setField<int>('previous_score', value);

  int get newScore => getField<int>('new_score')!;
  set newScore(int value) => setField<int>('new_score', value);

  int get changeAmount => getField<int>('change_amount')!;
  set changeAmount(int value) => setField<int>('change_amount', value);

  String get changeType => getField<String>('change_type')!;
  set changeType(String value) => setField<String>('change_type', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  dynamic get calculatedFactors => getField<dynamic>('calculated_factors');
  set calculatedFactors(dynamic value) =>
      setField<dynamic>('calculated_factors', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
