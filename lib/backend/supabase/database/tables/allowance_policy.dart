import '../database.dart';

class AllowancePolicyTable extends SupabaseTable<AllowancePolicyRow> {
  @override
  String get tableName => 'allowance_policy';

  @override
  AllowancePolicyRow createRow(Map<String, dynamic> data) =>
      AllowancePolicyRow(data);
}

class AllowancePolicyRow extends SupabaseDataRow {
  AllowancePolicyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AllowancePolicyTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  int get amountCents => getField<int>('amount_cents')!;
  set amountCents(int value) => setField<int>('amount_cents', value);

  DateTime get effectiveFrom => getField<DateTime>('effective_from')!;
  set effectiveFrom(DateTime value) =>
      setField<DateTime>('effective_from', value);

  DateTime? get effectiveTo => getField<DateTime>('effective_to');
  set effectiveTo(DateTime? value) => setField<DateTime>('effective_to', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
