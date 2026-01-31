import '../database.dart';

class CollateralStatusHistoryTable
    extends SupabaseTable<CollateralStatusHistoryRow> {
  @override
  String get tableName => 'collateral_status_history';

  @override
  CollateralStatusHistoryRow createRow(Map<String, dynamic> data) =>
      CollateralStatusHistoryRow(data);
}

class CollateralStatusHistoryRow extends SupabaseDataRow {
  CollateralStatusHistoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollateralStatusHistoryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get collateralId => getField<String>('collateral_id')!;
  set collateralId(String value) => setField<String>('collateral_id', value);

  String? get oldStatus => getField<String>('old_status');
  set oldStatus(String? value) => setField<String>('old_status', value);

  String get newStatus => getField<String>('new_status')!;
  set newStatus(String value) => setField<String>('new_status', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String? get changedBy => getField<String>('changed_by');
  set changedBy(String? value) => setField<String>('changed_by', value);

  String? get changedByName => getField<String>('changed_by_name');
  set changedByName(String? value) =>
      setField<String>('changed_by_name', value);

  DateTime get changedAt => getField<DateTime>('changed_at')!;
  set changedAt(DateTime value) => setField<DateTime>('changed_at', value);
}
