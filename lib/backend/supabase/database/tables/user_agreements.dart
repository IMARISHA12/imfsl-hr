import '../database.dart';

class UserAgreementsTable extends SupabaseTable<UserAgreementsRow> {
  @override
  String get tableName => 'user_agreements';

  @override
  UserAgreementsRow createRow(Map<String, dynamic> data) =>
      UserAgreementsRow(data);
}

class UserAgreementsRow extends SupabaseDataRow {
  UserAgreementsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserAgreementsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get agreementVersion => getField<String>('agreement_version');
  set agreementVersion(String? value) =>
      setField<String>('agreement_version', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  String? get deviceInfo => getField<String>('device_info');
  set deviceInfo(String? value) => setField<String>('device_info', value);

  DateTime? get signedAt => getField<DateTime>('signed_at');
  set signedAt(DateTime? value) => setField<DateTime>('signed_at', value);
}
