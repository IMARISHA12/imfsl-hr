import '../database.dart';

class CollectionPtpsTable extends SupabaseTable<CollectionPtpsRow> {
  @override
  String get tableName => 'collection_ptps';

  @override
  CollectionPtpsRow createRow(Map<String, dynamic> data) =>
      CollectionPtpsRow(data);
}

class CollectionPtpsRow extends SupabaseDataRow {
  CollectionPtpsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollectionPtpsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  double get promisedAmount => getField<double>('promised_amount')!;
  set promisedAmount(double value) =>
      setField<double>('promised_amount', value);

  DateTime get promisedDate => getField<DateTime>('promised_date')!;
  set promisedDate(DateTime value) =>
      setField<DateTime>('promised_date', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  double? get actualAmount => getField<double>('actual_amount');
  set actualAmount(double? value) => setField<double>('actual_amount', value);

  DateTime? get actualDate => getField<DateTime>('actual_date');
  set actualDate(DateTime? value) => setField<DateTime>('actual_date', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) => setField<String>('verified_by', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  DateTime? get brokenAt => getField<DateTime>('broken_at');
  set brokenAt(DateTime? value) => setField<DateTime>('broken_at', value);
}
