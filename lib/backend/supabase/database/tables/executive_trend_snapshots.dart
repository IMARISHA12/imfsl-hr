import '../database.dart';

class ExecutiveTrendSnapshotsTable
    extends SupabaseTable<ExecutiveTrendSnapshotsRow> {
  @override
  String get tableName => 'executive_trend_snapshots';

  @override
  ExecutiveTrendSnapshotsRow createRow(Map<String, dynamic> data) =>
      ExecutiveTrendSnapshotsRow(data);
}

class ExecutiveTrendSnapshotsRow extends SupabaseDataRow {
  ExecutiveTrendSnapshotsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ExecutiveTrendSnapshotsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get snapshotDate => getField<DateTime>('snapshot_date')!;
  set snapshotDate(DateTime value) =>
      setField<DateTime>('snapshot_date', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  double get collectionsAmount => getField<double>('collections_amount')!;
  set collectionsAmount(double value) =>
      setField<double>('collections_amount', value);

  double get disbursedAmount => getField<double>('disbursed_amount')!;
  set disbursedAmount(double value) =>
      setField<double>('disbursed_amount', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
