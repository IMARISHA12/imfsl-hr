import '../database.dart';

class InsurancePoliciesNewTable extends SupabaseTable<InsurancePoliciesNewRow> {
  @override
  String get tableName => 'insurance_policies_new';

  @override
  InsurancePoliciesNewRow createRow(Map<String, dynamic> data) =>
      InsurancePoliciesNewRow(data);
}

class InsurancePoliciesNewRow extends SupabaseDataRow {
  InsurancePoliciesNewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => InsurancePoliciesNewTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get customerId => getField<String>('customer_id')!;
  set customerId(String value) => setField<String>('customer_id', value);

  String get policyNumber => getField<String>('policy_number')!;
  set policyNumber(String value) => setField<String>('policy_number', value);

  String get vehicleRegNumber => getField<String>('vehicle_reg_number')!;
  set vehicleRegNumber(String value) =>
      setField<String>('vehicle_reg_number', value);

  String? get chassisNumber => getField<String>('chassis_number');
  set chassisNumber(String? value) => setField<String>('chassis_number', value);

  String? get makeModel => getField<String>('make_model');
  set makeModel(String? value) => setField<String>('make_model', value);

  String get coverType => getField<String>('cover_type')!;
  set coverType(String value) => setField<String>('cover_type', value);

  double get premiumAmount => getField<double>('premium_amount')!;
  set premiumAmount(double value) => setField<double>('premium_amount', value);

  DateTime get startDate => getField<DateTime>('start_date')!;
  set startDate(DateTime value) => setField<DateTime>('start_date', value);

  DateTime get endDate => getField<DateTime>('end_date')!;
  set endDate(DateTime value) => setField<DateTime>('end_date', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get digitalStickerUrl => getField<String>('digital_sticker_url');
  set digitalStickerUrl(String? value) =>
      setField<String>('digital_sticker_url', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
