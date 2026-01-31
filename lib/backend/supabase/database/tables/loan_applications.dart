import '../database.dart';

class LoanApplicationsTable extends SupabaseTable<LoanApplicationsRow> {
  @override
  String get tableName => 'loan_applications';

  @override
  LoanApplicationsRow createRow(Map<String, dynamic> data) =>
      LoanApplicationsRow(data);
}

class LoanApplicationsRow extends SupabaseDataRow {
  LoanApplicationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanApplicationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get customerName => getField<String>('customer_name')!;
  set customerName(String value) => setField<String>('customer_name', value);

  String get customerPhone => getField<String>('customer_phone')!;
  set customerPhone(String value) => setField<String>('customer_phone', value);

  String? get customerEmail => getField<String>('customer_email');
  set customerEmail(String? value) => setField<String>('customer_email', value);

  String? get customerAddress => getField<String>('customer_address');
  set customerAddress(String? value) =>
      setField<String>('customer_address', value);

  double get requestedAmount => getField<double>('requested_amount')!;
  set requestedAmount(double value) =>
      setField<double>('requested_amount', value);

  String? get loanPurpose => getField<String>('loan_purpose');
  set loanPurpose(String? value) => setField<String>('loan_purpose', value);

  String get collateralType => getField<String>('collateral_type')!;
  set collateralType(String value) =>
      setField<String>('collateral_type', value);

  String? get collateralDescription =>
      getField<String>('collateral_description');
  set collateralDescription(String? value) =>
      setField<String>('collateral_description', value);

  dynamic get documents => getField<dynamic>('documents');
  set documents(dynamic value) => setField<dynamic>('documents', value);

  List<String> get collateralPhotos =>
      getListField<String>('collateral_photos');
  set collateralPhotos(List<String>? value) =>
      setListField<String>('collateral_photos', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  dynamic get aiAnalysis => getField<dynamic>('ai_analysis');
  set aiAnalysis(dynamic value) => setField<dynamic>('ai_analysis', value);

  DateTime? get analyzedAt => getField<DateTime>('analyzed_at');
  set analyzedAt(DateTime? value) => setField<DateTime>('analyzed_at', value);

  DateTime? get decisionDate => getField<DateTime>('decision_date');
  set decisionDate(DateTime? value) =>
      setField<DateTime>('decision_date', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);
}
