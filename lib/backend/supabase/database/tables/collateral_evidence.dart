import '../database.dart';

class CollateralEvidenceTable extends SupabaseTable<CollateralEvidenceRow> {
  @override
  String get tableName => 'collateral_evidence';

  @override
  CollateralEvidenceRow createRow(Map<String, dynamic> data) =>
      CollateralEvidenceRow(data);
}

class CollateralEvidenceRow extends SupabaseDataRow {
  CollateralEvidenceRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollateralEvidenceTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get collateralId => getField<String>('collateral_id');
  set collateralId(String? value) => setField<String>('collateral_id', value);

  String get imageUrl => getField<String>('image_url')!;
  set imageUrl(String value) => setField<String>('image_url', value);

  String get imageHash => getField<String>('image_hash')!;
  set imageHash(String value) => setField<String>('image_hash', value);

  String? get uploadedBy => getField<String>('uploaded_by');
  set uploadedBy(String? value) => setField<String>('uploaded_by', value);

  DateTime? get uploadedAt => getField<DateTime>('uploaded_at');
  set uploadedAt(DateTime? value) => setField<DateTime>('uploaded_at', value);
}
