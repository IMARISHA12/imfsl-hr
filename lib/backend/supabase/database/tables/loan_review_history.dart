import '../database.dart';

class LoanReviewHistoryTable extends SupabaseTable<LoanReviewHistoryRow> {
  @override
  String get tableName => 'loan_review_history';

  @override
  LoanReviewHistoryRow createRow(Map<String, dynamic> data) =>
      LoanReviewHistoryRow(data);
}

class LoanReviewHistoryRow extends SupabaseDataRow {
  LoanReviewHistoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanReviewHistoryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get reviewerId => getField<String>('reviewer_id')!;
  set reviewerId(String value) => setField<String>('reviewer_id', value);

  String get reviewerName => getField<String>('reviewer_name')!;
  set reviewerName(String value) => setField<String>('reviewer_name', value);

  String get reviewerRole => getField<String>('reviewer_role')!;
  set reviewerRole(String value) => setField<String>('reviewer_role', value);

  String get decision => getField<String>('decision')!;
  set decision(String value) => setField<String>('decision', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  dynamic get conditions => getField<dynamic>('conditions');
  set conditions(dynamic value) => setField<dynamic>('conditions', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
