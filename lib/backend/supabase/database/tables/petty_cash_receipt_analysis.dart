import '../database.dart';

class PettyCashReceiptAnalysisTable
    extends SupabaseTable<PettyCashReceiptAnalysisRow> {
  @override
  String get tableName => 'petty_cash_receipt_analysis';

  @override
  PettyCashReceiptAnalysisRow createRow(Map<String, dynamic> data) =>
      PettyCashReceiptAnalysisRow(data);
}

class PettyCashReceiptAnalysisRow extends SupabaseDataRow {
  PettyCashReceiptAnalysisRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PettyCashReceiptAnalysisTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get voucherId => getField<String>('voucher_id')!;
  set voucherId(String value) => setField<String>('voucher_id', value);

  String get receiptUrl => getField<String>('receipt_url')!;
  set receiptUrl(String value) => setField<String>('receipt_url', value);

  double? get extractedAmount => getField<double>('extracted_amount');
  set extractedAmount(double? value) =>
      setField<double>('extracted_amount', value);

  DateTime? get extractedDate => getField<DateTime>('extracted_date');
  set extractedDate(DateTime? value) =>
      setField<DateTime>('extracted_date', value);

  String? get extractedVendor => getField<String>('extracted_vendor');
  set extractedVendor(String? value) =>
      setField<String>('extracted_vendor', value);

  dynamic get extractedItems => getField<dynamic>('extracted_items');
  set extractedItems(dynamic value) =>
      setField<dynamic>('extracted_items', value);

  String? get receiptNumber => getField<String>('receipt_number');
  set receiptNumber(String? value) => setField<String>('receipt_number', value);

  int? get confidenceScore => getField<int>('confidence_score');
  set confidenceScore(int? value) => setField<int>('confidence_score', value);

  dynamic get validationResult => getField<dynamic>('validation_result');
  set validationResult(dynamic value) =>
      setField<dynamic>('validation_result', value);

  int get riskScore => getField<int>('risk_score')!;
  set riskScore(int value) => setField<int>('risk_score', value);

  String get riskLevel => getField<String>('risk_level')!;
  set riskLevel(String value) => setField<String>('risk_level', value);

  List<String> get flags => getListField<String>('flags');
  set flags(List<String>? value) => setListField<String>('flags', value);

  dynamic get rawAnalysis => getField<dynamic>('raw_analysis');
  set rawAnalysis(dynamic value) => setField<dynamic>('raw_analysis', value);

  bool? get isDuplicate => getField<bool>('is_duplicate');
  set isDuplicate(bool? value) => setField<bool>('is_duplicate', value);

  String? get duplicateOfVoucherId =>
      getField<String>('duplicate_of_voucher_id');
  set duplicateOfVoucherId(String? value) =>
      setField<String>('duplicate_of_voucher_id', value);

  DateTime get analyzedAt => getField<DateTime>('analyzed_at')!;
  set analyzedAt(DateTime value) => setField<DateTime>('analyzed_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
