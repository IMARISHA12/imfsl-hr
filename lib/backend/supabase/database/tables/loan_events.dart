import '../database.dart';

class LoanEventsTable extends SupabaseTable<LoanEventsRow> {
  @override
  String get tableName => 'loan_events';

  @override
  LoanEventsRow createRow(Map<String, dynamic> data) => LoanEventsRow(data);
}

class LoanEventsRow extends SupabaseDataRow {
  LoanEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanEventsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  DateTime get eventDate => getField<DateTime>('event_date')!;
  set eventDate(DateTime value) => setField<DateTime>('event_date', value);

  DateTime? get postedAt => getField<DateTime>('posted_at');
  set postedAt(DateTime? value) => setField<DateTime>('posted_at', value);

  String get source => getField<String>('source')!;
  set source(String value) => setField<String>('source', value);

  double get amountPrincipal => getField<double>('amount_principal')!;
  set amountPrincipal(double value) =>
      setField<double>('amount_principal', value);

  double get amountInterest => getField<double>('amount_interest')!;
  set amountInterest(double value) =>
      setField<double>('amount_interest', value);

  double get amountFee => getField<double>('amount_fee')!;
  set amountFee(double value) => setField<double>('amount_fee', value);

  double get amountPenalty => getField<double>('amount_penalty')!;
  set amountPenalty(double value) => setField<double>('amount_penalty', value);

  double? get totalAmount => getField<double>('total_amount');
  set totalAmount(double? value) => setField<double>('total_amount', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  String? get referenceNo => getField<String>('reference_no');
  set referenceNo(String? value) => setField<String>('reference_no', value);

  String? get externalReference => getField<String>('external_reference');
  set externalReference(String? value) =>
      setField<String>('external_reference', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  String? get postedBy => getField<String>('posted_by');
  set postedBy(String? value) => setField<String>('posted_by', value);

  String? get rejectedBy => getField<String>('rejected_by');
  set rejectedBy(String? value) => setField<String>('rejected_by', value);

  DateTime? get rejectedAt => getField<DateTime>('rejected_at');
  set rejectedAt(DateTime? value) => setField<DateTime>('rejected_at', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  List<String> get evidenceUrls => getListField<String>('evidence_urls');
  set evidenceUrls(List<String>? value) =>
      setListField<String>('evidence_urls', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String? get journalId => getField<String>('journal_id');
  set journalId(String? value) => setField<String>('journal_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
