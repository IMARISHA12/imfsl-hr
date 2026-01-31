import '../database.dart';

class CompanyPolicyAcknowledgmentsTable
    extends SupabaseTable<CompanyPolicyAcknowledgmentsRow> {
  @override
  String get tableName => 'company_policy_acknowledgments';

  @override
  CompanyPolicyAcknowledgmentsRow createRow(Map<String, dynamic> data) =>
      CompanyPolicyAcknowledgmentsRow(data);
}

class CompanyPolicyAcknowledgmentsRow extends SupabaseDataRow {
  CompanyPolicyAcknowledgmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CompanyPolicyAcknowledgmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get policyId => getField<String>('policy_id')!;
  set policyId(String value) => setField<String>('policy_id', value);

  int get policyVersion => getField<int>('policy_version')!;
  set policyVersion(int value) => setField<int>('policy_version', value);

  DateTime get acceptedAt => getField<DateTime>('accepted_at')!;
  set acceptedAt(DateTime value) => setField<DateTime>('accepted_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
