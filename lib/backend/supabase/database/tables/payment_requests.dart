import '../database.dart';

class PaymentRequestsTable extends SupabaseTable<PaymentRequestsRow> {
  @override
  String get tableName => 'payment_requests';

  @override
  PaymentRequestsRow createRow(Map<String, dynamic> data) =>
      PaymentRequestsRow(data);
}

class PaymentRequestsRow extends SupabaseDataRow {
  PaymentRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PaymentRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get requestedBy => getField<String>('requested_by')!;
  set requestedBy(String value) => setField<String>('requested_by', value);

  String get requesterType => getField<String>('requester_type')!;
  set requesterType(String value) => setField<String>('requester_type', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get reviewNote => getField<String>('review_note');
  set reviewNote(String? value) => setField<String>('review_note', value);
}
