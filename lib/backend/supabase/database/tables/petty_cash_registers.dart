import '../database.dart';

class PettyCashRegistersTable extends SupabaseTable<PettyCashRegistersRow> {
  @override
  String get tableName => 'petty_cash_registers';

  @override
  PettyCashRegistersRow createRow(Map<String, dynamic> data) =>
      PettyCashRegistersRow(data);
}

class PettyCashRegistersRow extends SupabaseDataRow {
  PettyCashRegistersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PettyCashRegistersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get branch => getField<String>('branch')!;
  set branch(String value) => setField<String>('branch', value);

  double get currentBalance => getField<double>('current_balance')!;
  set currentBalance(double value) =>
      setField<double>('current_balance', value);

  String? get cashierId => getField<String>('cashier_id');
  set cashierId(String? value) => setField<String>('cashier_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
