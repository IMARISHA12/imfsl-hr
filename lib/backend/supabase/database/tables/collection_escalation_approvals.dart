import '../database.dart';

class CollectionEscalationApprovalsTable
    extends SupabaseTable<CollectionEscalationApprovalsRow> {
  @override
  String get tableName => 'collection_escalation_approvals';

  @override
  CollectionEscalationApprovalsRow createRow(Map<String, dynamic> data) =>
      CollectionEscalationApprovalsRow(data);
}

class CollectionEscalationApprovalsRow extends SupabaseDataRow {
  CollectionEscalationApprovalsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollectionEscalationApprovalsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get escalationId => getField<String>('escalation_id')!;
  set escalationId(String value) => setField<String>('escalation_id', value);

  String get requestedBy => getField<String>('requested_by')!;
  set requestedBy(String value) => setField<String>('requested_by', value);

  DateTime get requestedAt => getField<DateTime>('requested_at')!;
  set requestedAt(DateTime value) => setField<DateTime>('requested_at', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get reviewNotes => getField<String>('review_notes');
  set reviewNotes(String? value) => setField<String>('review_notes', value);

  bool? get autoApproved => getField<bool>('auto_approved');
  set autoApproved(bool? value) => setField<bool>('auto_approved', value);

  String? get autoApprovalReason => getField<String>('auto_approval_reason');
  set autoApprovalReason(String? value) =>
      setField<String>('auto_approval_reason', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
