import '../database.dart';

class CustomersCoreTable extends SupabaseTable<CustomersCoreRow> {
  @override
  String get tableName => 'customers_core';

  @override
  CustomersCoreRow createRow(Map<String, dynamic> data) =>
      CustomersCoreRow(data);
}

class CustomersCoreRow extends SupabaseDataRow {
  CustomersCoreRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CustomersCoreTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get fullName => getField<String>('full_name')!;
  set fullName(String value) => setField<String>('full_name', value);

  String get phoneNumber => getField<String>('phone_number')!;
  set phoneNumber(String value) => setField<String>('phone_number', value);

  String? get nidaNumber => getField<String>('nida_number');
  set nidaNumber(String? value) => setField<String>('nida_number', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  double? get riskScore => getField<double>('risk_score');
  set riskScore(double? value) => setField<double>('risk_score', value);

  String? get kycStatus => getField<String>('kyc_status');
  set kycStatus(String? value) => setField<String>('kyc_status', value);

  String? get customerSegment => getField<String>('customer_segment');
  set customerSegment(String? value) =>
      setField<String>('customer_segment', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
