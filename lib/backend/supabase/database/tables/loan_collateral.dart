import '../database.dart';

class LoanCollateralTable extends SupabaseTable<LoanCollateralRow> {
  @override
  String get tableName => 'loan_collateral';

  @override
  LoanCollateralRow createRow(Map<String, dynamic> data) =>
      LoanCollateralRow(data);
}

class LoanCollateralRow extends SupabaseDataRow {
  LoanCollateralRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanCollateralTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String get itemName => getField<String>('item_name')!;
  set itemName(String value) => setField<String>('item_name', value);

  double get itemValue => getField<double>('item_value')!;
  set itemValue(double value) => setField<double>('item_value', value);

  String? get itemCondition => getField<String>('item_condition');
  set itemCondition(String? value) => setField<String>('item_condition', value);

  String? get proofImageUrl => getField<String>('proof_image_url');
  set proofImageUrl(String? value) =>
      setField<String>('proof_image_url', value);

  String? get registrationDocUrl => getField<String>('registration_doc_url');
  set registrationDocUrl(String? value) =>
      setField<String>('registration_doc_url', value);

  String? get locationGps => getField<String>('location_gps');
  set locationGps(String? value) => setField<String>('location_gps', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
