import '../database.dart';

class FinanceCollectionTargetsTable
    extends SupabaseTable<FinanceCollectionTargetsRow> {
  @override
  String get tableName => 'finance_collection_targets';

  @override
  FinanceCollectionTargetsRow createRow(Map<String, dynamic> data) =>
      FinanceCollectionTargetsRow(data);
}

class FinanceCollectionTargetsRow extends SupabaseDataRow {
  FinanceCollectionTargetsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FinanceCollectionTargetsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get month => getField<DateTime>('month')!;
  set month(DateTime value) => setField<DateTime>('month', value);

  double get targetAmount => getField<double>('target_amount')!;
  set targetAmount(double value) => setField<double>('target_amount', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
