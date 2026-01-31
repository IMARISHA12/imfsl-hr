import '../database.dart';

class VLoanProcessingByOfficerTable
    extends SupabaseTable<VLoanProcessingByOfficerRow> {
  @override
  String get tableName => 'v_loan_processing_by_officer';

  @override
  VLoanProcessingByOfficerRow createRow(Map<String, dynamic> data) =>
      VLoanProcessingByOfficerRow(data);
}

class VLoanProcessingByOfficerRow extends SupabaseDataRow {
  VLoanProcessingByOfficerRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VLoanProcessingByOfficerTable();

  String? get officerId => getField<String>('officer_id');
  set officerId(String? value) => setField<String>('officer_id', value);

  String? get officerName => getField<String>('officer_name');
  set officerName(String? value) => setField<String>('officer_name', value);

  int? get totalProcessed => getField<int>('total_processed');
  set totalProcessed(int? value) => setField<int>('total_processed', value);

  int? get approved => getField<int>('approved');
  set approved(int? value) => setField<int>('approved', value);

  int? get rejected => getField<int>('rejected');
  set rejected(int? value) => setField<int>('rejected', value);

  double? get avgProcessingHours => getField<double>('avg_processing_hours');
  set avgProcessingHours(double? value) =>
      setField<double>('avg_processing_hours', value);

  double? get approvalRate => getField<double>('approval_rate');
  set approvalRate(double? value) => setField<double>('approval_rate', value);
}
