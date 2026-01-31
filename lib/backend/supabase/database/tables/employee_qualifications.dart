import '../database.dart';

class EmployeeQualificationsTable
    extends SupabaseTable<EmployeeQualificationsRow> {
  @override
  String get tableName => 'employee_qualifications';

  @override
  EmployeeQualificationsRow createRow(Map<String, dynamic> data) =>
      EmployeeQualificationsRow(data);
}

class EmployeeQualificationsRow extends SupabaseDataRow {
  EmployeeQualificationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmployeeQualificationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  String get qualificationName => getField<String>('qualification_name')!;
  set qualificationName(String value) =>
      setField<String>('qualification_name', value);

  String? get issuingBody => getField<String>('issuing_body');
  set issuingBody(String? value) => setField<String>('issuing_body', value);

  DateTime? get dateObtained => getField<DateTime>('date_obtained');
  set dateObtained(DateTime? value) =>
      setField<DateTime>('date_obtained', value);

  DateTime? get expiryDate => getField<DateTime>('expiry_date');
  set expiryDate(DateTime? value) => setField<DateTime>('expiry_date', value);

  String? get documentUrl => getField<String>('document_url');
  set documentUrl(String? value) => setField<String>('document_url', value);
}
