import '../database.dart';

class GuarantorNetworkTable extends SupabaseTable<GuarantorNetworkRow> {
  @override
  String get tableName => 'guarantor_network';

  @override
  GuarantorNetworkRow createRow(Map<String, dynamic> data) =>
      GuarantorNetworkRow(data);
}

class GuarantorNetworkRow extends SupabaseDataRow {
  GuarantorNetworkRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GuarantorNetworkTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get guarantorNida => getField<String>('guarantor_nida')!;
  set guarantorNida(String value) => setField<String>('guarantor_nida', value);

  String? get guarantorName => getField<String>('guarantor_name');
  set guarantorName(String? value) => setField<String>('guarantor_name', value);

  String? get customerId => getField<String>('customer_id');
  set customerId(String? value) => setField<String>('customer_id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  double? get loanAmount => getField<double>('loan_amount');
  set loanAmount(double? value) => setField<double>('loan_amount', value);

  DateTime? get guaranteeDate => getField<DateTime>('guarantee_date');
  set guaranteeDate(DateTime? value) =>
      setField<DateTime>('guarantee_date', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
