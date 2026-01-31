import '../database.dart';

class LoanGuarantorRequestsTable
    extends SupabaseTable<LoanGuarantorRequestsRow> {
  @override
  String get tableName => 'loan_guarantor_requests';

  @override
  LoanGuarantorRequestsRow createRow(Map<String, dynamic> data) =>
      LoanGuarantorRequestsRow(data);
}

class LoanGuarantorRequestsRow extends SupabaseDataRow {
  LoanGuarantorRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanGuarantorRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get guarantorPhone => getField<String>('guarantor_phone');
  set guarantorPhone(String? value) =>
      setField<String>('guarantor_phone', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get digitalSignatureUrl => getField<String>('digital_signature_url');
  set digitalSignatureUrl(String? value) =>
      setField<String>('digital_signature_url', value);

  DateTime? get signedAt => getField<DateTime>('signed_at');
  set signedAt(DateTime? value) => setField<DateTime>('signed_at', value);
}
