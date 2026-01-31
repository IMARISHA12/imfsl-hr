import '../database.dart';

class StagingLoansImportTable extends SupabaseTable<StagingLoansImportRow> {
  @override
  String get tableName => 'staging_loans_import';

  @override
  StagingLoansImportRow createRow(Map<String, dynamic> data) =>
      StagingLoansImportRow(data);
}

class StagingLoansImportRow extends SupabaseDataRow {
  StagingLoansImportRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StagingLoansImportTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get batchId => getField<String>('batch_id')!;
  set batchId(String value) => setField<String>('batch_id', value);

  String? get rawClientName => getField<String>('raw_client_name');
  set rawClientName(String? value) =>
      setField<String>('raw_client_name', value);

  String? get rawNida => getField<String>('raw_nida');
  set rawNida(String? value) => setField<String>('raw_nida', value);

  String? get rawPhone => getField<String>('raw_phone');
  set rawPhone(String? value) => setField<String>('raw_phone', value);

  String? get rawLoanAmount => getField<String>('raw_loan_amount');
  set rawLoanAmount(String? value) =>
      setField<String>('raw_loan_amount', value);

  String? get rawBalanceDue => getField<String>('raw_balance_due');
  set rawBalanceDue(String? value) =>
      setField<String>('raw_balance_due', value);

  String? get rawStartDate => getField<String>('raw_start_date');
  set rawStartDate(String? value) => setField<String>('raw_start_date', value);

  String? get importStatus => getField<String>('import_status');
  set importStatus(String? value) => setField<String>('import_status', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
