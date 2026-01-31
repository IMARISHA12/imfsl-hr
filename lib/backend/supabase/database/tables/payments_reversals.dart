import '../database.dart';

class PaymentsReversalsTable extends SupabaseTable<PaymentsReversalsRow> {
  @override
  String get tableName => 'payments_reversals';

  @override
  PaymentsReversalsRow createRow(Map<String, dynamic> data) =>
      PaymentsReversalsRow(data);
}

class PaymentsReversalsRow extends SupabaseDataRow {
  PaymentsReversalsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PaymentsReversalsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get paymentId => getField<String>('payment_id')!;
  set paymentId(String value) => setField<String>('payment_id', value);

  String get reason => getField<String>('reason')!;
  set reason(String value) => setField<String>('reason', value);

  String get requestedBy => getField<String>('requested_by')!;
  set requestedBy(String value) => setField<String>('requested_by', value);

  DateTime get requestedAt => getField<DateTime>('requested_at')!;
  set requestedAt(DateTime value) => setField<DateTime>('requested_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);
}
