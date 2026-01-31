import '../database.dart';

class LoanGuarantorsTable extends SupabaseTable<LoanGuarantorsRow> {
  @override
  String get tableName => 'loan_guarantors';

  @override
  LoanGuarantorsRow createRow(Map<String, dynamic> data) =>
      LoanGuarantorsRow(data);
}

class LoanGuarantorsRow extends SupabaseDataRow {
  LoanGuarantorsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanGuarantorsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String get fullName => getField<String>('full_name')!;
  set fullName(String value) => setField<String>('full_name', value);

  String? get nidaNumber => getField<String>('nida_number');
  set nidaNumber(String? value) => setField<String>('nida_number', value);

  String get phoneNumber => getField<String>('phone_number')!;
  set phoneNumber(String value) => setField<String>('phone_number', value);

  String? get relationshipToBorrower =>
      getField<String>('relationship_to_borrower');
  set relationshipToBorrower(String? value) =>
      setField<String>('relationship_to_borrower', value);

  bool? get isVerified => getField<bool>('is_verified');
  set isVerified(bool? value) => setField<bool>('is_verified', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
