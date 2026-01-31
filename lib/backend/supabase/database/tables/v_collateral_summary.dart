import '../database.dart';

class VCollateralSummaryTable extends SupabaseTable<VCollateralSummaryRow> {
  @override
  String get tableName => 'v_collateral_summary';

  @override
  VCollateralSummaryRow createRow(Map<String, dynamic> data) =>
      VCollateralSummaryRow(data);
}

class VCollateralSummaryRow extends SupabaseDataRow {
  VCollateralSummaryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VCollateralSummaryTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get borrowerId => getField<String>('borrower_id');
  set borrowerId(String? value) => setField<String>('borrower_id', value);

  String? get collateralType => getField<String>('collateral_type');
  set collateralType(String? value) =>
      setField<String>('collateral_type', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  double? get estimatedValue => getField<double>('estimated_value');
  set estimatedValue(double? value) =>
      setField<double>('estimated_value', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get valuationDate => getField<DateTime>('valuation_date');
  set valuationDate(DateTime? value) =>
      setField<DateTime>('valuation_date', value);

  String? get applicantName => getField<String>('applicant_name');
  set applicantName(String? value) => setField<String>('applicant_name', value);

  String? get borrowerName => getField<String>('borrower_name');
  set borrowerName(String? value) => setField<String>('borrower_name', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
