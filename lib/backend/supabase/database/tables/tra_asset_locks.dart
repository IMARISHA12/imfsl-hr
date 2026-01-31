import '../database.dart';

class TraAssetLocksTable extends SupabaseTable<TraAssetLocksRow> {
  @override
  String get tableName => 'tra_asset_locks';

  @override
  TraAssetLocksRow createRow(Map<String, dynamic> data) =>
      TraAssetLocksRow(data);
}

class TraAssetLocksRow extends SupabaseDataRow {
  TraAssetLocksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TraAssetLocksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get collateralId => getField<String>('collateral_id');
  set collateralId(String? value) => setField<String>('collateral_id', value);

  String get registrationNumber => getField<String>('registration_number')!;
  set registrationNumber(String value) =>
      setField<String>('registration_number', value);

  String get chassisNumber => getField<String>('chassis_number')!;
  set chassisNumber(String value) => setField<String>('chassis_number', value);

  String? get lockStatus => getField<String>('lock_status');
  set lockStatus(String? value) => setField<String>('lock_status', value);

  String? get traReferenceNo => getField<String>('tra_reference_no');
  set traReferenceNo(String? value) =>
      setField<String>('tra_reference_no', value);

  String? get formCUrl => getField<String>('form_c_url');
  set formCUrl(String? value) => setField<String>('form_c_url', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
