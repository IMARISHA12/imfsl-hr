import '../database.dart';

class SystemSettingsTable extends SupabaseTable<SystemSettingsRow> {
  @override
  String get tableName => 'system_settings';

  @override
  SystemSettingsRow createRow(Map<String, dynamic> data) =>
      SystemSettingsRow(data);
}

class SystemSettingsRow extends SupabaseDataRow {
  SystemSettingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SystemSettingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get companyName => getField<String>('company_name')!;
  set companyName(String value) => setField<String>('company_name', value);

  String get companyShortName => getField<String>('company_short_name')!;
  set companyShortName(String value) =>
      setField<String>('company_short_name', value);

  String? get companyRegistration => getField<String>('company_registration');
  set companyRegistration(String? value) =>
      setField<String>('company_registration', value);

  String? get companyTin => getField<String>('company_tin');
  set companyTin(String? value) => setField<String>('company_tin', value);

  String? get companyAddress => getField<String>('company_address');
  set companyAddress(String? value) =>
      setField<String>('company_address', value);

  String? get companyPhone => getField<String>('company_phone');
  set companyPhone(String? value) => setField<String>('company_phone', value);

  String? get companyEmail => getField<String>('company_email');
  set companyEmail(String? value) => setField<String>('company_email', value);

  String? get companyWebsite => getField<String>('company_website');
  set companyWebsite(String? value) =>
      setField<String>('company_website', value);

  String? get systemTitle => getField<String>('system_title');
  set systemTitle(String? value) => setField<String>('system_title', value);

  String? get timezone => getField<String>('timezone');
  set timezone(String? value) => setField<String>('timezone', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String? get language => getField<String>('language');
  set language(String? value) => setField<String>('language', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get logoUrl => getField<String>('logo_url');
  set logoUrl(String? value) => setField<String>('logo_url', value);

  double? get nssfRate => getField<double>('nssf_rate');
  set nssfRate(double? value) => setField<double>('nssf_rate', value);

  double? get nssfEmployerRate => getField<double>('nssf_employer_rate');
  set nssfEmployerRate(double? value) =>
      setField<double>('nssf_employer_rate', value);

  double? get wcfRate => getField<double>('wcf_rate');
  set wcfRate(double? value) => setField<double>('wcf_rate', value);

  double? get heslbRate => getField<double>('heslb_rate');
  set heslbRate(double? value) => setField<double>('heslb_rate', value);

  double? get sdlRate => getField<double>('sdl_rate');
  set sdlRate(double? value) => setField<double>('sdl_rate', value);

  double? get defaultInterestRate => getField<double>('default_interest_rate');
  set defaultInterestRate(double? value) =>
      setField<double>('default_interest_rate', value);

  bool? get smsNotificationsEnabled =>
      getField<bool>('sms_notifications_enabled');
  set smsNotificationsEnabled(bool? value) =>
      setField<bool>('sms_notifications_enabled', value);

  bool? get emailNotificationsEnabled =>
      getField<bool>('email_notifications_enabled');
  set emailNotificationsEnabled(bool? value) =>
      setField<bool>('email_notifications_enabled', value);

  bool? get maintenanceMode => getField<bool>('maintenance_mode');
  set maintenanceMode(bool? value) => setField<bool>('maintenance_mode', value);

  double? get dailyPenaltyRate => getField<double>('daily_penalty_rate');
  set dailyPenaltyRate(double? value) =>
      setField<double>('daily_penalty_rate', value);

  double? get autoDisburseLimit => getField<double>('auto_disburse_limit');
  set autoDisburseLimit(double? value) =>
      setField<double>('auto_disburse_limit', value);

  String? get updatedBy => getField<String>('updated_by');
  set updatedBy(String? value) => setField<String>('updated_by', value);
}
