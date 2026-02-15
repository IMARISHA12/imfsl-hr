import '../database.dart';

class FinLegalConsoleTable extends SupabaseTable<FinLegalConsoleRow> {
  @override
  String get tableName => 'fin_legal_console';

  @override
  FinLegalConsoleRow createRow(Map<String, dynamic> data) =>
      FinLegalConsoleRow(data);
}

class FinLegalConsoleRow extends SupabaseDataRow {
  FinLegalConsoleRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FinLegalConsoleTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get vehicleId => getField<String>('vehicle_id');
  set vehicleId(String? value) => setField<String>('vehicle_id', value);

  String get legalOwnerName => getField<String>('legal_owner_name')!;
  set legalOwnerName(String value) =>
      setField<String>('legal_owner_name', value);

  String? get traVerificationStatus =>
      getField<String>('tra_verification_status');
  set traVerificationStatus(String? value) =>
      setField<String>('tra_verification_status', value);

  bool? get isCardPhysicallyHeld => getField<bool>('is_card_physically_held');
  set isCardPhysicallyHeld(bool? value) =>
      setField<bool>('is_card_physically_held', value);

  String? get traHoldReference => getField<String>('tra_hold_reference');
  set traHoldReference(String? value) =>
      setField<String>('tra_hold_reference', value);

  String? get insurancePolicyNo => getField<String>('insurance_policy_no');
  set insurancePolicyNo(String? value) =>
      setField<String>('insurance_policy_no', value);

  String? get insuranceProvider => getField<String>('insurance_provider');
  set insuranceProvider(String? value) =>
      setField<String>('insurance_provider', value);

  String? get insuranceType => getField<String>('insurance_type');
  set insuranceType(String? value) => setField<String>('insurance_type', value);

  DateTime get insuranceExpiry => getField<DateTime>('insurance_expiry')!;
  set insuranceExpiry(DateTime value) =>
      setField<DateTime>('insurance_expiry', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) => setField<String>('verified_by', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);
}
