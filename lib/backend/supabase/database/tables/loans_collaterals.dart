import '../database.dart';

class LoansCollateralsTable extends SupabaseTable<LoansCollateralsRow> {
  @override
  String get tableName => 'loans_collaterals';

  @override
  LoansCollateralsRow createRow(Map<String, dynamic> data) =>
      LoansCollateralsRow(data);
}

class LoansCollateralsRow extends SupabaseDataRow {
  LoansCollateralsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoansCollateralsTable();

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get collateralId => getField<String>('collateral_id')!;
  set collateralId(String value) => setField<String>('collateral_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
