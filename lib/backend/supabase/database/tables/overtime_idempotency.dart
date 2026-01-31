import '../database.dart';

class OvertimeIdempotencyTable extends SupabaseTable<OvertimeIdempotencyRow> {
  @override
  String get tableName => 'overtime_idempotency';

  @override
  OvertimeIdempotencyRow createRow(Map<String, dynamic> data) =>
      OvertimeIdempotencyRow(data);
}

class OvertimeIdempotencyRow extends SupabaseDataRow {
  OvertimeIdempotencyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OvertimeIdempotencyTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get requestKey => getField<String>('request_key')!;
  set requestKey(String value) => setField<String>('request_key', value);

  DateTime? get processedAt => getField<DateTime>('processed_at');
  set processedAt(DateTime? value) => setField<DateTime>('processed_at', value);

  dynamic get result => getField<dynamic>('result');
  set result(dynamic value) => setField<dynamic>('result', value);
}
