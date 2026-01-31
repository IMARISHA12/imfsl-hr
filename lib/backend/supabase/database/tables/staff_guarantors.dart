import '../database.dart';

class StaffGuarantorsTable extends SupabaseTable<StaffGuarantorsRow> {
  @override
  String get tableName => 'staff_guarantors';

  @override
  StaffGuarantorsRow createRow(Map<String, dynamic> data) =>
      StaffGuarantorsRow(data);
}

class StaffGuarantorsRow extends SupabaseDataRow {
  StaffGuarantorsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffGuarantorsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  String get fullName => getField<String>('full_name')!;
  set fullName(String value) => setField<String>('full_name', value);

  String? get relation => getField<String>('relation');
  set relation(String? value) => setField<String>('relation', value);

  String get phone => getField<String>('phone')!;
  set phone(String value) => setField<String>('phone', value);

  String? get attachmentPath => getField<String>('attachment_path');
  set attachmentPath(String? value) =>
      setField<String>('attachment_path', value);

  String? get attachmentName => getField<String>('attachment_name');
  set attachmentName(String? value) =>
      setField<String>('attachment_name', value);

  String? get attachmentContentType =>
      getField<String>('attachment_content_type');
  set attachmentContentType(String? value) =>
      setField<String>('attachment_content_type', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
