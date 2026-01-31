import '../database.dart';

class PettyCashRequestsTable extends SupabaseTable<PettyCashRequestsRow> {
  @override
  String get tableName => 'petty_cash_requests';

  @override
  PettyCashRequestsRow createRow(Map<String, dynamic> data) =>
      PettyCashRequestsRow(data);
}

class PettyCashRequestsRow extends SupabaseDataRow {
  PettyCashRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PettyCashRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get registerId => getField<String>('register_id');
  set registerId(String? value) => setField<String>('register_id', value);

  String? get boxId => getField<String>('box_id');
  set boxId(String? value) => setField<String>('box_id', value);

  String get requestType => getField<String>('request_type')!;
  set requestType(String value) => setField<String>('request_type', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get requestedByEmployeeId =>
      getField<String>('requested_by_employee_id')!;
  set requestedByEmployeeId(String value) =>
      setField<String>('requested_by_employee_id', value);

  String? get approvedByEmployeeId =>
      getField<String>('approved_by_employee_id');
  set approvedByEmployeeId(String? value) =>
      setField<String>('approved_by_employee_id', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  String? get receiptUrl => getField<String>('receipt_url');
  set receiptUrl(String? value) => setField<String>('receipt_url', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
