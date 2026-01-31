import '../database.dart';

class KycVerificationsTable extends SupabaseTable<KycVerificationsRow> {
  @override
  String get tableName => 'kyc_verifications';

  @override
  KycVerificationsRow createRow(Map<String, dynamic> data) =>
      KycVerificationsRow(data);
}

class KycVerificationsRow extends SupabaseDataRow {
  KycVerificationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => KycVerificationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get applicantNida => getField<String>('applicant_nida')!;
  set applicantNida(String value) => setField<String>('applicant_nida', value);

  String? get verifiedFirstName => getField<String>('verified_first_name');
  set verifiedFirstName(String? value) =>
      setField<String>('verified_first_name', value);

  String? get verifiedLastName => getField<String>('verified_last_name');
  set verifiedLastName(String? value) =>
      setField<String>('verified_last_name', value);

  DateTime? get verifiedDob => getField<DateTime>('verified_dob');
  set verifiedDob(DateTime? value) => setField<DateTime>('verified_dob', value);

  String? get verifiedGender => getField<String>('verified_gender');
  set verifiedGender(String? value) =>
      setField<String>('verified_gender', value);

  String? get verifiedPhotoBase64 => getField<String>('verified_photo_base64');
  set verifiedPhotoBase64(String? value) =>
      setField<String>('verified_photo_base64', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get failureReason => getField<String>('failure_reason');
  set failureReason(String? value) => setField<String>('failure_reason', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
