import '../database.dart';

class VendorContractIntelligenceTable
    extends SupabaseTable<VendorContractIntelligenceRow> {
  @override
  String get tableName => 'vendor_contract_intelligence';

  @override
  VendorContractIntelligenceRow createRow(Map<String, dynamic> data) =>
      VendorContractIntelligenceRow(data);
}

class VendorContractIntelligenceRow extends SupabaseDataRow {
  VendorContractIntelligenceRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VendorContractIntelligenceTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get vendorId => getField<String>('vendor_id')!;
  set vendorId(String value) => setField<String>('vendor_id', value);

  String? get contractId => getField<String>('contract_id');
  set contractId(String? value) => setField<String>('contract_id', value);

  String? get aiRiskAssessment => getField<String>('ai_risk_assessment');
  set aiRiskAssessment(String? value) =>
      setField<String>('ai_risk_assessment', value);

  dynamic get aiRecommendations => getField<dynamic>('ai_recommendations');
  set aiRecommendations(dynamic value) =>
      setField<dynamic>('ai_recommendations', value);

  dynamic get clauseAnalysis => getField<dynamic>('clause_analysis');
  set clauseAnalysis(dynamic value) =>
      setField<dynamic>('clause_analysis', value);

  String? get renewalRecommendation =>
      getField<String>('renewal_recommendation');
  set renewalRecommendation(String? value) =>
      setField<String>('renewal_recommendation', value);

  double? get costOptimizationPotential =>
      getField<double>('cost_optimization_potential');
  set costOptimizationPotential(double? value) =>
      setField<double>('cost_optimization_potential', value);

  dynamic get complianceFlags => getField<dynamic>('compliance_flags');
  set complianceFlags(dynamic value) =>
      setField<dynamic>('compliance_flags', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
