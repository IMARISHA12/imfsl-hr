import '../database.dart';

class ZArchiveTaxRulesTable extends SupabaseTable<ZArchiveTaxRulesRow> {
  @override
  String get tableName => 'z_archive_tax_rules';

  @override
  ZArchiveTaxRulesRow createRow(Map<String, dynamic> data) =>
      ZArchiveTaxRulesRow(data);
}

class ZArchiveTaxRulesRow extends SupabaseDataRow {
  ZArchiveTaxRulesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveTaxRulesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get country => getField<String>('country');
  set country(String? value) => setField<String>('country', value);

  String? get taxType => getField<String>('tax_type');
  set taxType(String? value) => setField<String>('tax_type', value);

  String? get code => getField<String>('code');
  set code(String? value) => setField<String>('code', value);

  double? get rate => getField<double>('rate');
  set rate(double? value) => setField<double>('rate', value);

  String? get appliesTo => getField<String>('applies_to');
  set appliesTo(String? value) => setField<String>('applies_to', value);

  bool? get active => getField<bool>('active');
  set active(bool? value) => setField<bool>('active', value);

  DateTime? get effectiveFrom => getField<DateTime>('effective_from');
  set effectiveFrom(DateTime? value) =>
      setField<DateTime>('effective_from', value);

  DateTime? get effectiveTo => getField<DateTime>('effective_to');
  set effectiveTo(DateTime? value) => setField<DateTime>('effective_to', value);
}
