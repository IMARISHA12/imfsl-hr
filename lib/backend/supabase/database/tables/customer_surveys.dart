import '../database.dart';

class CustomerSurveysTable extends SupabaseTable<CustomerSurveysRow> {
  @override
  String get tableName => 'customer_surveys';

  @override
  CustomerSurveysRow createRow(Map<String, dynamic> data) =>
      CustomerSurveysRow(data);
}

class CustomerSurveysRow extends SupabaseDataRow {
  CustomerSurveysRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CustomerSurveysTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get caseId => getField<String>('case_id');
  set caseId(String? value) => setField<String>('case_id', value);

  String get clientId => getField<String>('client_id')!;
  set clientId(String value) => setField<String>('client_id', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  String get surveyType => getField<String>('survey_type')!;
  set surveyType(String value) => setField<String>('survey_type', value);

  String get channel => getField<String>('channel')!;
  set channel(String value) => setField<String>('channel', value);

  int? get satisfactionScore => getField<int>('satisfaction_score');
  set satisfactionScore(int? value) =>
      setField<int>('satisfaction_score', value);

  bool? get wouldRecommend => getField<bool>('would_recommend');
  set wouldRecommend(bool? value) => setField<bool>('would_recommend', value);

  String? get feedbackText => getField<String>('feedback_text');
  set feedbackText(String? value) => setField<String>('feedback_text', value);

  DateTime get sentAt => getField<DateTime>('sent_at')!;
  set sentAt(DateTime value) => setField<DateTime>('sent_at', value);

  DateTime? get respondedAt => getField<DateTime>('responded_at');
  set respondedAt(DateTime? value) => setField<DateTime>('responded_at', value);

  DateTime? get reminderSentAt => getField<DateTime>('reminder_sent_at');
  set reminderSentAt(DateTime? value) =>
      setField<DateTime>('reminder_sent_at', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
