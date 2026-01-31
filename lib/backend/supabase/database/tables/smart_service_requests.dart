import '../database.dart';

class SmartServiceRequestsTable extends SupabaseTable<SmartServiceRequestsRow> {
  @override
  String get tableName => 'smart_service_requests';

  @override
  SmartServiceRequestsRow createRow(Map<String, dynamic> data) =>
      SmartServiceRequestsRow(data);
}

class SmartServiceRequestsRow extends SupabaseDataRow {
  SmartServiceRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SmartServiceRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get requestNumber => getField<String>('request_number');
  set requestNumber(String? value) => setField<String>('request_number', value);

  String get requesterType => getField<String>('requester_type')!;
  set requesterType(String value) => setField<String>('requester_type', value);

  String? get requesterId => getField<String>('requester_id');
  set requesterId(String? value) => setField<String>('requester_id', value);

  String get requesterName => getField<String>('requester_name')!;
  set requesterName(String value) => setField<String>('requester_name', value);

  String? get requesterContact => getField<String>('requester_contact');
  set requesterContact(String? value) =>
      setField<String>('requester_contact', value);

  String get serviceType => getField<String>('service_type')!;
  set serviceType(String value) => setField<String>('service_type', value);

  String? get priority => getField<String>('priority');
  set priority(String? value) => setField<String>('priority', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String get subject => getField<String>('subject')!;
  set subject(String value) => setField<String>('subject', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String? get resolution => getField<String>('resolution');
  set resolution(String? value) => setField<String>('resolution', value);

  DateTime? get resolutionDate => getField<DateTime>('resolution_date');
  set resolutionDate(DateTime? value) =>
      setField<DateTime>('resolution_date', value);

  DateTime? get slaDeadline => getField<DateTime>('sla_deadline');
  set slaDeadline(DateTime? value) => setField<DateTime>('sla_deadline', value);

  bool? get slaBreached => getField<bool>('sla_breached');
  set slaBreached(bool? value) => setField<bool>('sla_breached', value);

  String? get assignedTo => getField<String>('assigned_to');
  set assignedTo(String? value) => setField<String>('assigned_to', value);

  String? get assignedDepartment => getField<String>('assigned_department');
  set assignedDepartment(String? value) =>
      setField<String>('assigned_department', value);

  int? get escalationLevel => getField<int>('escalation_level');
  set escalationLevel(int? value) => setField<int>('escalation_level', value);

  int? get satisfactionRating => getField<int>('satisfaction_rating');
  set satisfactionRating(int? value) =>
      setField<int>('satisfaction_rating', value);

  String? get feedback => getField<String>('feedback');
  set feedback(String? value) => setField<String>('feedback', value);

  String? get relatedEntityType => getField<String>('related_entity_type');
  set relatedEntityType(String? value) =>
      setField<String>('related_entity_type', value);

  String? get relatedEntityId => getField<String>('related_entity_id');
  set relatedEntityId(String? value) =>
      setField<String>('related_entity_id', value);

  dynamic get attachments => getField<dynamic>('attachments');
  set attachments(dynamic value) => setField<dynamic>('attachments', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
