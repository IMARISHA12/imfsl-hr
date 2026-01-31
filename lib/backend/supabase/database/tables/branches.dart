import '../database.dart';

class BranchesTable extends SupabaseTable<BranchesRow> {
  @override
  String get tableName => 'branches';

  @override
  BranchesRow createRow(Map<String, dynamic> data) => BranchesRow(data);
}

class BranchesRow extends SupabaseDataRow {
  BranchesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BranchesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get location => getField<String>('location');
  set location(String? value) => setField<String>('location', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get managerId => getField<String>('manager_id');
  set managerId(String? value) => setField<String>('manager_id', value);
}
