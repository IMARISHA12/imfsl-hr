import '../database.dart';

class LegalCasesTable extends SupabaseTable<LegalCasesRow> {
  @override
  String get tableName => 'legal_cases';

  @override
  LegalCasesRow createRow(Map<String, dynamic> data) => LegalCasesRow(data);
}

class LegalCasesRow extends SupabaseDataRow {
  LegalCasesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalCasesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get caseNumber => getField<String>('case_number');
  set caseNumber(String? value) => setField<String>('case_number', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get customerId => getField<String>('customer_id');
  set customerId(String? value) => setField<String>('customer_id', value);

  String get caseType => getField<String>('case_type')!;
  set caseType(String value) => setField<String>('case_type', value);

  String? get courtName => getField<String>('court_name');
  set courtName(String? value) => setField<String>('court_name', value);

  String? get courtCaseNumber => getField<String>('court_case_number');
  set courtCaseNumber(String? value) =>
      setField<String>('court_case_number', value);

  DateTime? get filingDate => getField<DateTime>('filing_date');
  set filingDate(DateTime? value) => setField<DateTime>('filing_date', value);

  DateTime? get hearingDate => getField<DateTime>('hearing_date');
  set hearingDate(DateTime? value) => setField<DateTime>('hearing_date', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get judgmentStatus => getField<String>('judgment_status');
  set judgmentStatus(String? value) =>
      setField<String>('judgment_status', value);

  double? get judgmentAmount => getField<double>('judgment_amount');
  set judgmentAmount(double? value) =>
      setField<double>('judgment_amount', value);

  DateTime? get judgmentDate => getField<DateTime>('judgment_date');
  set judgmentDate(DateTime? value) =>
      setField<DateTime>('judgment_date', value);

  double? get settlementAmount => getField<double>('settlement_amount');
  set settlementAmount(double? value) =>
      setField<double>('settlement_amount', value);

  DateTime? get settlementDate => getField<DateTime>('settlement_date');
  set settlementDate(DateTime? value) =>
      setField<DateTime>('settlement_date', value);

  double get outstandingAmount => getField<double>('outstanding_amount')!;
  set outstandingAmount(double value) =>
      setField<double>('outstanding_amount', value);

  String? get assignedLawyer => getField<String>('assigned_lawyer');
  set assignedLawyer(String? value) =>
      setField<String>('assigned_lawyer', value);

  String? get lawyerContact => getField<String>('lawyer_contact');
  set lawyerContact(String? value) => setField<String>('lawyer_contact', value);

  String? get internalNotes => getField<String>('internal_notes');
  set internalNotes(String? value) => setField<String>('internal_notes', value);

  String? get courtNotes => getField<String>('court_notes');
  set courtNotes(String? value) => setField<String>('court_notes', value);

  dynamic get evidenceFiles => getField<dynamic>('evidence_files');
  set evidenceFiles(dynamic value) =>
      setField<dynamic>('evidence_files', value);

  String? get nextAction => getField<String>('next_action');
  set nextAction(String? value) => setField<String>('next_action', value);

  DateTime? get nextActionDate => getField<DateTime>('next_action_date');
  set nextActionDate(DateTime? value) =>
      setField<DateTime>('next_action_date', value);

  String? get priority => getField<String>('priority');
  set priority(String? value) => setField<String>('priority', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get assignedLawyerId => getField<String>('assigned_lawyer_id');
  set assignedLawyerId(String? value) =>
      setField<String>('assigned_lawyer_id', value);
}
