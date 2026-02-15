import '../database.dart';

class FinCollateralVehiclesTable
    extends SupabaseTable<FinCollateralVehiclesRow> {
  @override
  String get tableName => 'fin_collateral_vehicles';

  @override
  FinCollateralVehiclesRow createRow(Map<String, dynamic> data) =>
      FinCollateralVehiclesRow(data);
}

class FinCollateralVehiclesRow extends SupabaseDataRow {
  FinCollateralVehiclesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FinCollateralVehiclesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String get loanApplicationId => getField<String>('loan_application_id')!;
  set loanApplicationId(String value) =>
      setField<String>('loan_application_id', value);

  String get ownerId => getField<String>('owner_id')!;
  set ownerId(String value) => setField<String>('owner_id', value);

  String get registrationNumber => getField<String>('registration_number')!;
  set registrationNumber(String value) =>
      setField<String>('registration_number', value);

  String get chassisNumber => getField<String>('chassis_number')!;
  set chassisNumber(String value) => setField<String>('chassis_number', value);

  String get make => getField<String>('make')!;
  set make(String value) => setField<String>('make', value);

  String get model => getField<String>('model')!;
  set model(String value) => setField<String>('model', value);

  int get manufactureYear => getField<int>('manufacture_year')!;
  set manufactureYear(int value) => setField<int>('manufacture_year', value);

  String? get color => getField<String>('color');
  set color(String? value) => setField<String>('color', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
