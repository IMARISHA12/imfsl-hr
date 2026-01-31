import '../database.dart';

class PartnerTermsAcknowledgmentsTable
    extends SupabaseTable<PartnerTermsAcknowledgmentsRow> {
  @override
  String get tableName => 'partner_terms_acknowledgments';

  @override
  PartnerTermsAcknowledgmentsRow createRow(Map<String, dynamic> data) =>
      PartnerTermsAcknowledgmentsRow(data);
}

class PartnerTermsAcknowledgmentsRow extends SupabaseDataRow {
  PartnerTermsAcknowledgmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PartnerTermsAcknowledgmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  int get termsVersion => getField<int>('terms_version')!;
  set termsVersion(int value) => setField<int>('terms_version', value);

  DateTime get acceptedAt => getField<DateTime>('accepted_at')!;
  set acceptedAt(DateTime value) => setField<DateTime>('accepted_at', value);
}
