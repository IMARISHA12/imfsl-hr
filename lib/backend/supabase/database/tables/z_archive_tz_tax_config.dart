import '../database.dart';

class ZArchiveTzTaxConfigTable extends SupabaseTable<ZArchiveTzTaxConfigRow> {
  @override
  String get tableName => 'z_archive_tz_tax_config';

  @override
  ZArchiveTzTaxConfigRow createRow(Map<String, dynamic> data) =>
      ZArchiveTzTaxConfigRow(data);
}

class ZArchiveTzTaxConfigRow extends SupabaseDataRow {
  ZArchiveTzTaxConfigRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveTzTaxConfigTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get taxType => getField<String>('tax_type')!;
  set taxType(String value) => setField<String>('tax_type', value);

  String get taxCode => getField<String>('tax_code')!;
  set taxCode(String value) => setField<String>('tax_code', value);

  String get taxName => getField<String>('tax_name')!;
  set taxName(String value) => setField<String>('tax_name', value);

  double get rate => getField<double>('rate')!;
  set rate(double value) => setField<double>('rate', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime get effectiveFrom => getField<DateTime>('effective_from')!;
  set effectiveFrom(DateTime value) =>
      setField<DateTime>('effective_from', value);

  DateTime? get effectiveTo => getField<DateTime>('effective_to');
  set effectiveTo(DateTime? value) => setField<DateTime>('effective_to', value);

  String? get traCode => getField<String>('tra_code');
  set traCode(String? value) => setField<String>('tra_code', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
