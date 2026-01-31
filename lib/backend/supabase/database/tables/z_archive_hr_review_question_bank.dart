import '../database.dart';

class ZArchiveHrReviewQuestionBankTable
    extends SupabaseTable<ZArchiveHrReviewQuestionBankRow> {
  @override
  String get tableName => 'z_archive_hr_review_question_bank';

  @override
  ZArchiveHrReviewQuestionBankRow createRow(Map<String, dynamic> data) =>
      ZArchiveHrReviewQuestionBankRow(data);
}

class ZArchiveHrReviewQuestionBankRow extends SupabaseDataRow {
  ZArchiveHrReviewQuestionBankRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveHrReviewQuestionBankTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get reportType => getField<String>('report_type')!;
  set reportType(String value) => setField<String>('report_type', value);

  String get questionText => getField<String>('question_text')!;
  set questionText(String value) => setField<String>('question_text', value);

  bool get required => getField<bool>('required')!;
  set required(bool value) => setField<bool>('required', value);

  int get weight => getField<int>('weight')!;
  set weight(int value) => setField<int>('weight', value);

  String? get policyRef => getField<String>('policy_ref');
  set policyRef(String? value) => setField<String>('policy_ref', value);

  bool get active => getField<bool>('active')!;
  set active(bool value) => setField<bool>('active', value);
}
