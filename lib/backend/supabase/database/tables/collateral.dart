import '../database.dart';

class CollateralTable extends SupabaseTable<CollateralRow> {
  @override
  String get tableName => 'collateral';

  @override
  CollateralRow createRow(Map<String, dynamic> data) => CollateralRow(data);
}

class CollateralRow extends SupabaseDataRow {
  CollateralRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollateralTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get borrowerId => getField<String>('borrower_id');
  set borrowerId(String? value) => setField<String>('borrower_id', value);

  String get collateralType => getField<String>('collateral_type')!;
  set collateralType(String value) =>
      setField<String>('collateral_type', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double get estimatedValue => getField<double>('estimated_value')!;
  set estimatedValue(double value) =>
      setField<double>('estimated_value', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  DateTime? get valuationDate => getField<DateTime>('valuation_date');
  set valuationDate(DateTime? value) =>
      setField<DateTime>('valuation_date', value);

  String? get valuatedBy => getField<String>('valuated_by');
  set valuatedBy(String? value) => setField<String>('valuated_by', value);

  String? get serialNumber => getField<String>('serial_number');
  set serialNumber(String? value) => setField<String>('serial_number', value);

  String? get registrationNumber => getField<String>('registration_number');
  set registrationNumber(String? value) =>
      setField<String>('registration_number', value);

  String? get locationAddress => getField<String>('location_address');
  set locationAddress(String? value) =>
      setField<String>('location_address', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get statusNotes => getField<String>('status_notes');
  set statusNotes(String? value) => setField<String>('status_notes', value);

  List<String> get photoUrls => getListField<String>('photo_urls');
  set photoUrls(List<String>? value) =>
      setListField<String>('photo_urls', value);

  List<String> get documentUrls => getListField<String>('document_urls');
  set documentUrls(List<String>? value) =>
      setListField<String>('document_urls', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
