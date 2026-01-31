import '../database.dart';

class ZArchiveImfslBranchesTable
    extends SupabaseTable<ZArchiveImfslBranchesRow> {
  @override
  String get tableName => 'z_archive_imfsl_branches';

  @override
  ZArchiveImfslBranchesRow createRow(Map<String, dynamic> data) =>
      ZArchiveImfslBranchesRow(data);
}

class ZArchiveImfslBranchesRow extends SupabaseDataRow {
  ZArchiveImfslBranchesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveImfslBranchesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  String get region => getField<String>('region')!;
  set region(String value) => setField<String>('region', value);

  String get address => getField<String>('address')!;
  set address(String value) => setField<String>('address', value);

  String get managerName => getField<String>('manager_name')!;
  set managerName(String value) => setField<String>('manager_name', value);

  String? get managerPhone => getField<String>('manager_phone');
  set managerPhone(String? value) => setField<String>('manager_phone', value);

  String? get managerEmail => getField<String>('manager_email');
  set managerEmail(String? value) => setField<String>('manager_email', value);

  DateTime get establishmentDate => getField<DateTime>('establishment_date')!;
  set establishmentDate(DateTime value) =>
      setField<DateTime>('establishment_date', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  int? get staffCount => getField<int>('staff_count');
  set staffCount(int? value) => setField<int>('staff_count', value);

  int? get clientBase => getField<int>('client_base');
  set clientBase(int? value) => setField<int>('client_base', value);

  double? get monthlyRevenue => getField<double>('monthly_revenue');
  set monthlyRevenue(double? value) =>
      setField<double>('monthly_revenue', value);

  int? get performanceScore => getField<int>('performance_score');
  set performanceScore(int? value) => setField<int>('performance_score', value);

  String? get complianceStatus => getField<String>('compliance_status');
  set complianceStatus(String? value) =>
      setField<String>('compliance_status', value);

  DateTime? get lastAuditDate => getField<DateTime>('last_audit_date');
  set lastAuditDate(DateTime? value) =>
      setField<DateTime>('last_audit_date', value);

  DateTime? get nextAuditDate => getField<DateTime>('next_audit_date');
  set nextAuditDate(DateTime? value) =>
      setField<DateTime>('next_audit_date', value);

  List<String> get servicesOffered => getListField<String>('services_offered');
  set servicesOffered(List<String>? value) =>
      setListField<String>('services_offered', value);

  String? get operatingHours => getField<String>('operating_hours');
  set operatingHours(String? value) =>
      setField<String>('operating_hours', value);

  String? get licenseNumber => getField<String>('license_number');
  set licenseNumber(String? value) => setField<String>('license_number', value);

  DateTime? get licenseExpiry => getField<DateTime>('license_expiry');
  set licenseExpiry(DateTime? value) =>
      setField<DateTime>('license_expiry', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);

  int get radiusM => getField<int>('radius_m')!;
  set radiusM(int value) => setField<int>('radius_m', value);
}
