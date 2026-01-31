import '../database.dart';

class VendorTrustMatrixTable extends SupabaseTable<VendorTrustMatrixRow> {
  @override
  String get tableName => 'vendor_trust_matrix';

  @override
  VendorTrustMatrixRow createRow(Map<String, dynamic> data) =>
      VendorTrustMatrixRow(data);
}

class VendorTrustMatrixRow extends SupabaseDataRow {
  VendorTrustMatrixRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VendorTrustMatrixTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get vendorId => getField<String>('vendor_id')!;
  set vendorId(String value) => setField<String>('vendor_id', value);

  double? get overallScore => getField<double>('overall_score');
  set overallScore(double? value) => setField<double>('overall_score', value);

  double? get deliveryScore => getField<double>('delivery_score');
  set deliveryScore(double? value) => setField<double>('delivery_score', value);

  double? get qualityScore => getField<double>('quality_score');
  set qualityScore(double? value) => setField<double>('quality_score', value);

  double? get pricingScore => getField<double>('pricing_score');
  set pricingScore(double? value) => setField<double>('pricing_score', value);

  double? get complianceScore => getField<double>('compliance_score');
  set complianceScore(double? value) =>
      setField<double>('compliance_score', value);

  double? get communicationScore => getField<double>('communication_score');
  set communicationScore(double? value) =>
      setField<double>('communication_score', value);

  String? get tier => getField<String>('tier');
  set tier(String? value) => setField<String>('tier', value);

  bool? get blacklistStatus => getField<bool>('blacklist_status');
  set blacklistStatus(bool? value) => setField<bool>('blacklist_status', value);

  String? get blacklistReason => getField<String>('blacklist_reason');
  set blacklistReason(String? value) =>
      setField<String>('blacklist_reason', value);

  DateTime? get lastReviewDate => getField<DateTime>('last_review_date');
  set lastReviewDate(DateTime? value) =>
      setField<DateTime>('last_review_date', value);

  DateTime? get nextReviewDate => getField<DateTime>('next_review_date');
  set nextReviewDate(DateTime? value) =>
      setField<DateTime>('next_review_date', value);

  String? get reviewNotes => getField<String>('review_notes');
  set reviewNotes(String? value) => setField<String>('review_notes', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  dynamic get factors => getField<dynamic>('factors');
  set factors(dynamic value) => setField<dynamic>('factors', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
