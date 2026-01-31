import '../database.dart';

class CasesTable extends SupabaseTable<CasesRow> {
  @override
  String get tableName => 'cases';

  @override
  CasesRow createRow(Map<String, dynamic> data) => CasesRow(data);
}

class CasesRow extends SupabaseDataRow {
  CasesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CasesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);
}
