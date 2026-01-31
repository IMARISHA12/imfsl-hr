import '../database.dart';

class PettyCashBoxesTable extends SupabaseTable<PettyCashBoxesRow> {
  @override
  String get tableName => 'petty_cash_boxes';

  @override
  PettyCashBoxesRow createRow(Map<String, dynamic> data) =>
      PettyCashBoxesRow(data);
}

class PettyCashBoxesRow extends SupabaseDataRow {
  PettyCashBoxesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PettyCashBoxesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String get boxName => getField<String>('box_name')!;
  set boxName(String value) => setField<String>('box_name', value);

  double get currentBalance => getField<double>('current_balance')!;
  set currentBalance(double value) =>
      setField<double>('current_balance', value);

  double? get openingFloat => getField<double>('opening_float');
  set openingFloat(double? value) => setField<double>('opening_float', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get custodianId => getField<String>('custodian_id');
  set custodianId(String? value) => setField<String>('custodian_id', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
