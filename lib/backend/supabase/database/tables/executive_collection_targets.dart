import '../database.dart';

class ExecutiveCollectionTargetsTable
    extends SupabaseTable<ExecutiveCollectionTargetsRow> {
  @override
  String get tableName => 'executive_collection_targets';

  @override
  ExecutiveCollectionTargetsRow createRow(Map<String, dynamic> data) =>
      ExecutiveCollectionTargetsRow(data);
}

class ExecutiveCollectionTargetsRow extends SupabaseDataRow {
  ExecutiveCollectionTargetsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ExecutiveCollectionTargetsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get month => getField<DateTime>('month')!;
  set month(DateTime value) => setField<DateTime>('month', value);

  double get targetAmount => getField<double>('target_amount')!;
  set targetAmount(double value) => setField<double>('target_amount', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
