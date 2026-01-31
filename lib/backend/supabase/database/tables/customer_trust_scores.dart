import '../database.dart';

class CustomerTrustScoresTable extends SupabaseTable<CustomerTrustScoresRow> {
  @override
  String get tableName => 'customer_trust_scores';

  @override
  CustomerTrustScoresRow createRow(Map<String, dynamic> data) =>
      CustomerTrustScoresRow(data);
}

class CustomerTrustScoresRow extends SupabaseDataRow {
  CustomerTrustScoresRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CustomerTrustScoresTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get customerId => getField<String>('customer_id')!;
  set customerId(String value) => setField<String>('customer_id', value);

  double? get trustScore => getField<double>('trust_score');
  set trustScore(double? value) => setField<double>('trust_score', value);

  double? get paymentHistoryScore => getField<double>('payment_history_score');
  set paymentHistoryScore(double? value) =>
      setField<double>('payment_history_score', value);

  double? get loanPerformanceScore =>
      getField<double>('loan_performance_score');
  set loanPerformanceScore(double? value) =>
      setField<double>('loan_performance_score', value);

  double? get documentComplianceScore =>
      getField<double>('document_compliance_score');
  set documentComplianceScore(double? value) =>
      setField<double>('document_compliance_score', value);

  double? get referralScore => getField<double>('referral_score');
  set referralScore(double? value) => setField<double>('referral_score', value);

  String? get riskLevel => getField<String>('risk_level');
  set riskLevel(String? value) => setField<String>('risk_level', value);

  DateTime? get lastCalculatedAt => getField<DateTime>('last_calculated_at');
  set lastCalculatedAt(DateTime? value) =>
      setField<DateTime>('last_calculated_at', value);

  dynamic get factors => getField<dynamic>('factors');
  set factors(dynamic value) => setField<dynamic>('factors', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
