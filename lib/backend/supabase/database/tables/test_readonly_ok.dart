import '../database.dart';

class TestReadonlyOkTable extends SupabaseTable<TestReadonlyOkRow> {
  @override
  String get tableName => '_test_readonly_ok';

  @override
  TestReadonlyOkRow createRow(Map<String, dynamic> data) =>
      TestReadonlyOkRow(data);
}

class TestReadonlyOkRow extends SupabaseDataRow {
  TestReadonlyOkRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TestReadonlyOkTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);
}
