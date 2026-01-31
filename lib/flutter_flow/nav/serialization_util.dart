import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:from_css_color/from_css_color.dart';

import '/backend/supabase/supabase.dart';

import '../../flutter_flow/place.dart';
import '../../flutter_flow/uploaded_file.dart';

/// SERIALIZATION HELPERS

String dateTimeRangeToString(DateTimeRange dateTimeRange) {
  final startStr = dateTimeRange.start.millisecondsSinceEpoch.toString();
  final endStr = dateTimeRange.end.millisecondsSinceEpoch.toString();
  return '$startStr|$endStr';
}

String placeToString(FFPlace place) => jsonEncode({
      'latLng': place.latLng.serialize(),
      'name': place.name,
      'address': place.address,
      'city': place.city,
      'state': place.state,
      'country': place.country,
      'zipCode': place.zipCode,
    });

String uploadedFileToString(FFUploadedFile uploadedFile) =>
    uploadedFile.serialize();

String? serializeParam(
  dynamic param,
  ParamType paramType, {
  bool isList = false,
}) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final serializedValues = (param as Iterable)
          .map((p) => serializeParam(p, paramType, isList: false))
          .where((p) => p != null)
          .map((p) => p!)
          .toList();
      return json.encode(serializedValues);
    }
    String? data;
    switch (paramType) {
      case ParamType.int:
        data = param.toString();
      case ParamType.double:
        data = param.toString();
      case ParamType.String:
        data = param;
      case ParamType.bool:
        data = param ? 'true' : 'false';
      case ParamType.DateTime:
        data = (param as DateTime).millisecondsSinceEpoch.toString();
      case ParamType.DateTimeRange:
        data = dateTimeRangeToString(param as DateTimeRange);
      case ParamType.LatLng:
        data = (param as LatLng).serialize();
      case ParamType.Color:
        data = (param as Color).toCssString();
      case ParamType.FFPlace:
        data = placeToString(param as FFPlace);
      case ParamType.FFUploadedFile:
        data = uploadedFileToString(param as FFUploadedFile);
      case ParamType.JSON:
        data = json.encode(param);

      case ParamType.SupabaseRow:
        return json.encode((param as SupabaseDataRow).data);

      default:
        data = null;
    }
    return data;
  } catch (e) {
    print('Error serializing parameter: $e');
    return null;
  }
}

/// END SERIALIZATION HELPERS

/// DESERIALIZATION HELPERS

DateTimeRange? dateTimeRangeFromString(String dateTimeRangeStr) {
  final pieces = dateTimeRangeStr.split('|');
  if (pieces.length != 2) {
    return null;
  }
  return DateTimeRange(
    start: DateTime.fromMillisecondsSinceEpoch(int.parse(pieces.first)),
    end: DateTime.fromMillisecondsSinceEpoch(int.parse(pieces.last)),
  );
}

LatLng? latLngFromString(String? latLngStr) {
  final pieces = latLngStr?.split(',');
  if (pieces == null || pieces.length != 2) {
    return null;
  }
  return LatLng(
    double.parse(pieces.first.trim()),
    double.parse(pieces.last.trim()),
  );
}

FFPlace placeFromString(String placeStr) {
  final serializedData = jsonDecode(placeStr) as Map<String, dynamic>;
  final data = {
    'latLng': serializedData.containsKey('latLng')
        ? latLngFromString(serializedData['latLng'] as String)
        : const LatLng(0.0, 0.0),
    'name': serializedData['name'] ?? '',
    'address': serializedData['address'] ?? '',
    'city': serializedData['city'] ?? '',
    'state': serializedData['state'] ?? '',
    'country': serializedData['country'] ?? '',
    'zipCode': serializedData['zipCode'] ?? '',
  };
  return FFPlace(
    latLng: data['latLng'] as LatLng,
    name: data['name'] as String,
    address: data['address'] as String,
    city: data['city'] as String,
    state: data['state'] as String,
    country: data['country'] as String,
    zipCode: data['zipCode'] as String,
  );
}

FFUploadedFile uploadedFileFromString(String uploadedFileStr) =>
    FFUploadedFile.deserialize(uploadedFileStr);

enum ParamType {
  int,
  double,
  String,
  bool,
  DateTime,
  DateTimeRange,
  LatLng,
  Color,
  FFPlace,
  FFUploadedFile,
  JSON,

  SupabaseRow,
}

dynamic deserializeParam<T>(
  String? param,
  ParamType paramType,
  bool isList,
) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final paramValues = json.decode(param);
      if (paramValues is! Iterable || paramValues.isEmpty) {
        return null;
      }
      return paramValues
          .where((p) => p is String)
          .map((p) => p as String)
          .map((p) => deserializeParam<T>(p, paramType, false))
          .where((p) => p != null)
          .map((p) => p! as T)
          .toList();
    }
    switch (paramType) {
      case ParamType.int:
        return int.tryParse(param);
      case ParamType.double:
        return double.tryParse(param);
      case ParamType.String:
        return param;
      case ParamType.bool:
        return param == 'true';
      case ParamType.DateTime:
        final milliseconds = int.tryParse(param);
        return milliseconds != null
            ? DateTime.fromMillisecondsSinceEpoch(milliseconds)
            : null;
      case ParamType.DateTimeRange:
        return dateTimeRangeFromString(param);
      case ParamType.LatLng:
        return latLngFromString(param);
      case ParamType.Color:
        return fromCssColor(param);
      case ParamType.FFPlace:
        return placeFromString(param);
      case ParamType.FFUploadedFile:
        return uploadedFileFromString(param);
      case ParamType.JSON:
        return json.decode(param);

      case ParamType.SupabaseRow:
        final data = json.decode(param) as Map<String, dynamic>;
        switch (T) {
          case GlPeriodsRow:
            return GlPeriodsRow(data);
          case ScheduledReportRecipientsRow:
            return ScheduledReportRecipientsRow(data);
          case GuardianAlertsRow:
            return GuardianAlertsRow(data);
          case OcrDocumentsRow:
            return OcrDocumentsRow(data);
          case SystemAlertsRow:
            return SystemAlertsRow(data);
          case PurchaseRequisitionsRow:
            return PurchaseRequisitionsRow(data);
          case ZArchiveFinancePermissionsRow:
            return ZArchiveFinancePermissionsRow(data);
          case AlertRuleVersionsRow:
            return AlertRuleVersionsRow(data);
          case LegalCasesRow:
            return LegalCasesRow(data);
          case StaffPerformanceMetricsRow:
            return StaffPerformanceMetricsRow(data);
          case MvExecParSignalRow:
            return MvExecParSignalRow(data);
          case ZArchiveAssetCategoriesRow:
            return ZArchiveAssetCategoriesRow(data);
          case StaffBadgesRow:
            return StaffBadgesRow(data);
          case PaymentsRow:
            return PaymentsRow(data);
          case PettyCashTransactionsRow:
            return PettyCashTransactionsRow(data);
          case StaffPerformanceTargetsRow:
            return StaffPerformanceTargetsRow(data);
          case StagingLoansImportRow:
            return StagingLoansImportRow(data);
          case CreditScoreHistoryRow:
            return CreditScoreHistoryRow(data);
          case UserGovernanceRolesRow:
            return UserGovernanceRolesRow(data);
          case LoanAssignmentsRow:
            return LoanAssignmentsRow(data);
          case BankReconciliationsRow:
            return BankReconciliationsRow(data);
          case AiServiceRecommendationsRow:
            return AiServiceRecommendationsRow(data);
          case OperationalRolesRow:
            return OperationalRolesRow(data);
          case ZArchiveKnowledgeBaseArticlesRow:
            return ZArchiveKnowledgeBaseArticlesRow(data);
          case ZArchivePerfMetricsRow:
            return ZArchivePerfMetricsRow(data);
          case VUnifiedNotificationsRow:
            return VUnifiedNotificationsRow(data);
          case VPendingReversalsByBranchRow:
            return VPendingReversalsByBranchRow(data);
          case ZArchiveAwardTypesRow:
            return ZArchiveAwardTypesRow(data);
          case StaffDisciplinaryActionsRow:
            return StaffDisciplinaryActionsRow(data);
          case BillingRemindersRow:
            return BillingRemindersRow(data);
          case ZArchiveLeaveApprovalMatrixRow:
            return ZArchiveLeaveApprovalMatrixRow(data);
          case GpsAssignmentsRow:
            return GpsAssignmentsRow(data);
          case VMvRefreshRunsRow:
            return VMvRefreshRunsRow(data);
          case LicenseRemindersRow:
            return LicenseRemindersRow(data);
          case ZArchiveGlPeriodsRow:
            return ZArchiveGlPeriodsRow(data);
          case LoanGuarantorsRow:
            return LoanGuarantorsRow(data);
          case LegalCaseTemplatesRow:
            return LegalCaseTemplatesRow(data);
          case ZArchivePurgeAuditRow:
            return ZArchivePurgeAuditRow(data);
          case PurgeAuditCurrentRow:
            return PurgeAuditCurrentRow(data);
          case EventDeliveryLogRow:
            return EventDeliveryLogRow(data);
          case MyTenantsRow:
            return MyTenantsRow(data);
          case CollectionCasesRow:
            return CollectionCasesRow(data);
          case EnterprisePermissionsRow:
            return EnterprisePermissionsRow(data);
          case ServiceRequestMessagesRow:
            return ServiceRequestMessagesRow(data);
          case CollectionsRow:
            return CollectionsRow(data);
          case SecurityAuditFunctionGrantsRow:
            return SecurityAuditFunctionGrantsRow(data);
          case ZArchiveSecurityPlaybooksRow:
            return ZArchiveSecurityPlaybooksRow(data);
          case LoanRestructuringHistoryRow:
            return LoanRestructuringHistoryRow(data);
          case FbiAlertsRow:
            return FbiAlertsRow(data);
          case SystemPulseMetricsRow:
            return SystemPulseMetricsRow(data);
          case VGovernanceRoleDistributionRow:
            return VGovernanceRoleDistributionRow(data);
          case EventEngineMetricsRow:
            return EventEngineMetricsRow(data);
          case LoandiskExportRequestsRow:
            return LoandiskExportRequestsRow(data);
          case LoanCollateralRow:
            return LoanCollateralRow(data);
          case UserMembershipsRow:
            return UserMembershipsRow(data);
          case AccountsPayableRow:
            return AccountsPayableRow(data);
          case VLoansAuditSummaryRow:
            return VLoansAuditSummaryRow(data);
          case CollectionEscalationApprovalsRow:
            return CollectionEscalationApprovalsRow(data);
          case OptimizedRoutesRow:
            return OptimizedRoutesRow(data);
          case VStaffPerformanceWithScoreRow:
            return VStaffPerformanceWithScoreRow(data);
          case AiDecisionStreamRow:
            return AiDecisionStreamRow(data);
          case SystemConfigurationsRow:
            return SystemConfigurationsRow(data);
          case VendorsRow:
            return VendorsRow(data);
          case FeatureDefinitionsRow:
            return FeatureDefinitionsRow(data);
          case CommunicationLogsRow:
            return CommunicationLogsRow(data);
          case PromiseToPayRow:
            return PromiseToPayRow(data);
          case GovernanceRoleConflictsRow:
            return GovernanceRoleConflictsRow(data);
          case FinanceCollectionTargetsRow:
            return FinanceCollectionTargetsRow(data);
          case VendorTrustScoresRow:
            return VendorTrustScoresRow(data);
          case LoandiskAccessLogRow:
            return LoandiskAccessLogRow(data);
          case AlertEscalationRulesRow:
            return AlertEscalationRulesRow(data);
          case ZArchiveLeaveTypesRow:
            return ZArchiveLeaveTypesRow(data);
          case VMvRefreshStatusDetailedRow:
            return VMvRefreshStatusDetailedRow(data);
          case VClientDocumentsSummaryRow:
            return VClientDocumentsSummaryRow(data);
          case ZArchiveDocumentAccessLogsRow:
            return ZArchiveDocumentAccessLogsRow(data);
          case ThreeWayMatchesRow:
            return ThreeWayMatchesRow(data);
          case CustomerCommunicationsRow:
            return CustomerCommunicationsRow(data);
          case LoanReviewHistoryRow:
            return LoanReviewHistoryRow(data);
          case ControlNumbersRow:
            return ControlNumbersRow(data);
          case SecurityAuditLogsRow:
            return SecurityAuditLogsRow(data);
          case ExecutiveDailyBriefingsRow:
            return ExecutiveDailyBriefingsRow(data);
          case InvestigationCasesRow:
            return InvestigationCasesRow(data);
          case ZArchiveAlertSuppressionMetricsRow:
            return ZArchiveAlertSuppressionMetricsRow(data);
          case LoandiskSyncItemsRow:
            return LoandiskSyncItemsRow(data);
          case JournalEntryLinesReadonlyRow:
            return JournalEntryLinesReadonlyRow(data);
          case GovernanceAlertsRow:
            return GovernanceAlertsRow(data);
          case EdgeFunctionInvocationsRow:
            return EdgeFunctionInvocationsRow(data);
          case RolePermissionsRow:
            return RolePermissionsRow(data);
          case RlsPolicyCoverageRow:
            return RlsPolicyCoverageRow(data);
          case StaffDirectoryPresetsRow:
            return StaffDirectoryPresetsRow(data);
          case PettyCashEnrichedRow:
            return PettyCashEnrichedRow(data);
          case ZArchiveFinanceRolePermissionsRow:
            return ZArchiveFinanceRolePermissionsRow(data);
          case StaffPerformanceRow:
            return StaffPerformanceRow(data);
          case VendorPerformanceScoresRow:
            return VendorPerformanceScoresRow(data);
          case ClientDocumentsRow:
            return ClientDocumentsRow(data);
          case GeneralLedgerRow:
            return GeneralLedgerRow(data);
          case VendorCacheMetricsLatestRow:
            return VendorCacheMetricsLatestRow(data);
          case LoandiskIntegrationsRow:
            return LoandiskIntegrationsRow(data);
          case UserAgreementsRow:
            return UserAgreementsRow(data);
          case ForensicCasePhotosRow:
            return ForensicCasePhotosRow(data);
          case GlPostingRulesRow:
            return GlPostingRulesRow(data);
          case AlertSuppressionOverviewRow:
            return AlertSuppressionOverviewRow(data);
          case PaymentBatchItemsRow:
            return PaymentBatchItemsRow(data);
          case GuarantorNetworkRow:
            return GuarantorNetworkRow(data);
          case ZArchiveFinanceAuditLogsOld202510151033Row:
            return ZArchiveFinanceAuditLogsOld202510151033Row(data);
          case OvertimeIdempotencyRow:
            return OvertimeIdempotencyRow(data);
          case PurgeAudit7dRow:
            return PurgeAudit7dRow(data);
          case StaffLoansRow:
            return StaffLoansRow(data);
          case StaffAttendanceV3Row:
            return StaffAttendanceV3Row(data);
          case AlertRulesRow:
            return AlertRulesRow(data);
          case PaymentsReversalsRow:
            return PaymentsReversalsRow(data);
          case ViewLiquidityForecastRow:
            return ViewLiquidityForecastRow(data);
          case AiFraudDetectionRow:
            return AiFraudDetectionRow(data);
          case ZArchiveMvRefreshStatusRow:
            return ZArchiveMvRefreshStatusRow(data);
          case VCollateralSummaryRow:
            return VCollateralSummaryRow(data);
          case SodViolationsRow:
            return SodViolationsRow(data);
          case AiInsightsRow:
            return AiInsightsRow(data);
          case ZArchiveApprovalFlowsRow:
            return ZArchiveApprovalFlowsRow(data);
          case CustomerSurveysRow:
            return CustomerSurveysRow(data);
          case RoomMessagesDemoRow:
            return RoomMessagesDemoRow(data);
          case VGovernanceSummaryRow:
            return VGovernanceSummaryRow(data);
          case PayrollRunsRow:
            return PayrollRunsRow(data);
          case AppRolesRow:
            return AppRolesRow(data);
          case FraudAlertsRow:
            return FraudAlertsRow(data);
          case VStaffCsatSummaryRow:
            return VStaffCsatSummaryRow(data);
          case ZArchiveSystemEventsRow:
            return ZArchiveSystemEventsRow(data);
          case StaffPermissionsRow:
            return StaffPermissionsRow(data);
          case CustomersRow:
            return CustomersRow(data);
          case JournalEntriesReadonlyRow:
            return JournalEntriesReadonlyRow(data);
          case LegalCaseEventsRow:
            return LegalCaseEventsRow(data);
          case ClientsRow:
            return ClientsRow(data);
          case ZArchiveBenchmarkStandardsRow:
            return ZArchiveBenchmarkStandardsRow(data);
          case DocumentFilesRow:
            return DocumentFilesRow(data);
          case EventDeadLetterQueueRow:
            return EventDeadLetterQueueRow(data);
          case CollateralValuationsRow:
            return CollateralValuationsRow(data);
          case TasksRow:
            return TasksRow(data);
          case ZArchivePerfAlertsRow:
            return ZArchivePerfAlertsRow(data);
          case CollateralStatusHistoryRow:
            return CollateralStatusHistoryRow(data);
          case ProfilesRow:
            return ProfilesRow(data);
          case SecureEmployeeViewRow:
            return SecureEmployeeViewRow(data);
          case CollectionMessagesRow:
            return CollectionMessagesRow(data);
          case ZArchiveAnalyticsEventsRow:
            return ZArchiveAnalyticsEventsRow(data);
          case StaffTargetsRow:
            return StaffTargetsRow(data);
          case ZArchiveGovernanceRoleAuditRow:
            return ZArchiveGovernanceRoleAuditRow(data);
          case CronFailureAlertsRow:
            return CronFailureAlertsRow(data);
          case ChartOfAccountsReadonlyRow:
            return ChartOfAccountsReadonlyRow(data);
          case DisciplinaryRecordsRow:
            return DisciplinaryRecordsRow(data);
          case CompanyPoliciesRow:
            return CompanyPoliciesRow(data);
          case LegalChatMessagesRow:
            return LegalChatMessagesRow(data);
          case AiDecisionsRow:
            return AiDecisionsRow(data);
          case TestReadonlyOkRow:
            return TestReadonlyOkRow(data);
          case VLoanPipelineAnalyticsRow:
            return VLoanPipelineAnalyticsRow(data);
          case InternalBillsRow:
            return InternalBillsRow(data);
          case StaffActivityStreamRow:
            return StaffActivityStreamRow(data);
          case CollateralRegistryRow:
            return CollateralRegistryRow(data);
          case LoansRow:
            return LoansRow(data);
          case CiFunctionSecurityAuditRow:
            return CiFunctionSecurityAuditRow(data);
          case DynamicPricingRulesRow:
            return DynamicPricingRulesRow(data);
          case LatestHealthStatusRow:
            return LatestHealthStatusRow(data);
          case ZArchiveSkillsMatrixRow:
            return ZArchiveSkillsMatrixRow(data);
          case WebhookEventsRow:
            return WebhookEventsRow(data);
          case LoanAffordabilityRulesRow:
            return LoanAffordabilityRulesRow(data);
          case ZArchiveTaskTemplatesRow:
            return ZArchiveTaskTemplatesRow(data);
          case OcrJobsRow:
            return OcrJobsRow(data);
          case RoomMessagesRow:
            return RoomMessagesRow(data);
          case AiStrategicInsightsRow:
            return AiStrategicInsightsRow(data);
          case StaffPerformanceMonthlyRow:
            return StaffPerformanceMonthlyRow(data);
          case ProfilesItAdminSafeRow:
            return ProfilesItAdminSafeRow(data);
          case LoanWriteoffRequestsRow:
            return LoanWriteoffRequestsRow(data);
          case LicenseTypesRow:
            return LicenseTypesRow(data);
          case ZArchiveBillingCategoriesRow:
            return ZArchiveBillingCategoriesRow(data);
          case EmployeesRow:
            return EmployeesRow(data);
          case ComplianceChecklistsRow:
            return ComplianceChecklistsRow(data);
          case LoanGuarantorRequestsRow:
            return LoanGuarantorRequestsRow(data);
          case AccountsReceivableRow:
            return AccountsReceivableRow(data);
          case LoanRestructuringRequestsRow:
            return LoanRestructuringRequestsRow(data);
          case VJournalBalancesRow:
            return VJournalBalancesRow(data);
          case GovernmentLoanEventsRow:
            return GovernmentLoanEventsRow(data);
          case CollectionEscalationsRow:
            return CollectionEscalationsRow(data);
          case BillingPaymentsRow:
            return BillingPaymentsRow(data);
          case LegalChatConversationsRow:
            return LegalChatConversationsRow(data);
          case TopRateLimitedUsers7dRow:
            return TopRateLimitedUsers7dRow(data);
          case LegalDocumentsRow:
            return LegalDocumentsRow(data);
          case StaffPointsLedgerRow:
            return StaffPointsLedgerRow(data);
          case AccessLogsRow:
            return AccessLogsRow(data);
          case ForensicRecoveryCostsRow:
            return ForensicRecoveryCostsRow(data);
          case DocumentOcrResultsRow:
            return DocumentOcrResultsRow(data);
          case StaffRow:
            return StaffRow(data);
          case MvAdminCountsRow:
            return MvAdminCountsRow(data);
          case GpsDevicesRow:
            return GpsDevicesRow(data);
          case AuditPartitionStatusRow:
            return AuditPartitionStatusRow(data);
          case LoanStatusNotificationsRow:
            return LoanStatusNotificationsRow(data);
          case PettyCashRow:
            return PettyCashRow(data);
          case TraAssetLocksRow:
            return TraAssetLocksRow(data);
          case ZArchiveEmployeeLearningModulesRow:
            return ZArchiveEmployeeLearningModulesRow(data);
          case PettyCashBoxesRow:
            return PettyCashBoxesRow(data);
          case PendingCriticalTasksRow:
            return PendingCriticalTasksRow(data);
          case ZArchiveTaxRulesRow:
            return ZArchiveTaxRulesRow(data);
          case SystemEventsRow:
            return SystemEventsRow(data);
          case ZArchiveApprovalLevelsRow:
            return ZArchiveApprovalLevelsRow(data);
          case ZArchivePiiFieldMappingsRow:
            return ZArchivePiiFieldMappingsRow(data);
          case AttendanceV2Row:
            return AttendanceV2Row(data);
          case ComplianceReportsRow:
            return ComplianceReportsRow(data);
          case PettyCashVouchersRow:
            return PettyCashVouchersRow(data);
          case LoanApplicationsRow:
            return LoanApplicationsRow(data);
          case RecentProfileUploadDenialsRow:
            return RecentProfileUploadDenialsRow(data);
          case EdgeErrorRates24hRow:
            return EdgeErrorRates24hRow(data);
          case ZArchivePerfThresholdsRow:
            return ZArchivePerfThresholdsRow(data);
          case ClientRiskPredictionsRow:
            return ClientRiskPredictionsRow(data);
          case StaffLoanRepaymentsRow:
            return StaffLoanRepaymentsRow(data);
          case RegulatoryAlertsRow:
            return RegulatoryAlertsRow(data);
          case BranchesRow:
            return BranchesRow(data);
          case LoandiskSyncRunsRow:
            return LoandiskSyncRunsRow(data);
          case AlertsMetrics7dRow:
            return AlertsMetrics7dRow(data);
          case StaffDocumentsRow:
            return StaffDocumentsRow(data);
          case EssVerificationLogsRow:
            return EssVerificationLogsRow(data);
          case ReminderRulesRow:
            return ReminderRulesRow(data);
          case AttendanceLogsRow:
            return AttendanceLogsRow(data);
          case LeaveRequestsRow:
            return LeaveRequestsRow(data);
          case EmployeeQualificationsRow:
            return EmployeeQualificationsRow(data);
          case InsurancePoliciesNewRow:
            return InsurancePoliciesNewRow(data);
          case LiquidityPredictionsRow:
            return LiquidityPredictionsRow(data);
          case ChartOfAccountsRow:
            return ChartOfAccountsRow(data);
          case CollectionSegmentsRow:
            return CollectionSegmentsRow(data);
          case ZArchiveImfslBranchesRow:
            return ZArchiveImfslBranchesRow(data);
          case CustomerTrustScoresRow:
            return CustomerTrustScoresRow(data);
          case PermissionsRow:
            return PermissionsRow(data);
          case MvExecCollectionsDisbursementsRow:
            return MvExecCollectionsDisbursementsRow(data);
          case ViewDailyTrialBalanceRow:
            return ViewDailyTrialBalanceRow(data);
          case KycVerificationsRow:
            return KycVerificationsRow(data);
          case ScheduledReportSettingsRow:
            return ScheduledReportSettingsRow(data);
          case ProfilesManagerSafeRow:
            return ProfilesManagerSafeRow(data);
          case MvExecRiskZonesRow:
            return MvExecRiskZonesRow(data);
          case LeaveBalancesRow:
            return LeaveBalancesRow(data);
          case EmployeesSecureRow:
            return EmployeesSecureRow(data);
          case CashVarianceInvestigationsRow:
            return CashVarianceInvestigationsRow(data);
          case DocumentShareLinksRow:
            return DocumentShareLinksRow(data);
          case ZArchiveEdgeFunctionMetricsRow:
            return ZArchiveEdgeFunctionMetricsRow(data);
          case ZArchiveHealthCheckReportsRow:
            return ZArchiveHealthCheckReportsRow(data);
          case ZArchiveEmployeeOnboardingStatusRow:
            return ZArchiveEmployeeOnboardingStatusRow(data);
          case VEmployeeDirectoryRow:
            return VEmployeeDirectoryRow(data);
          case AlertBaselinesRow:
            return AlertBaselinesRow(data);
          case SmartServiceRequestsRow:
            return SmartServiceRequestsRow(data);
          case VLoanProcessingByOfficerRow:
            return VLoanProcessingByOfficerRow(data);
          case StaffPerformanceDailyRow:
            return StaffPerformanceDailyRow(data);
          case VGovernanceTopUsersRow:
            return VGovernanceTopUsersRow(data);
          case LegalKnowledgeBaseRow:
            return LegalKnowledgeBaseRow(data);
          case CustomerLoansRow:
            return CustomerLoansRow(data);
          case LoandiskReconciliationSnapshotsRow:
            return LoandiskReconciliationSnapshotsRow(data);
          case GlPostedJournalsRow:
            return GlPostedJournalsRow(data);
          case BankStatementsRow:
            return BankStatementsRow(data);
          case LegalDocumentAccessLogRow:
            return LegalDocumentAccessLogRow(data);
          case ClaimsNewRow:
            return ClaimsNewRow(data);
          case AiSuggestionsRow:
            return AiSuggestionsRow(data);
          case ZArchiveSystemConfigurationRow:
            return ZArchiveSystemConfigurationRow(data);
          case EmployeeProfileCompletionRow:
            return EmployeeProfileCompletionRow(data);
          case GeofencesRow:
            return GeofencesRow(data);
          case BillingItemsRow:
            return BillingItemsRow(data);
          case LoanWriteoffHistoryRow:
            return LoanWriteoffHistoryRow(data);
          case ClientBehavioralPatternsRow:
            return ClientBehavioralPatternsRow(data);
          case CaseAssignmentsRow:
            return CaseAssignmentsRow(data);
          case PettyCashReceiptAnalysisRow:
            return PettyCashReceiptAnalysisRow(data);
          case HolidaysRow:
            return HolidaysRow(data);
          case ZArchivePermissionsRow:
            return ZArchivePermissionsRow(data);
          case PaymentRequestsRow:
            return PaymentRequestsRow(data);
          case RlsPolicyIndexCoverageRow:
            return RlsPolicyIndexCoverageRow(data);
          case ClientRiskAlertsRow:
            return ClientRiskAlertsRow(data);
          case CollateralsRow:
            return CollateralsRow(data);
          case AuditLogsNewRow:
            return AuditLogsNewRow(data);
          case AccessControlChangesRow:
            return AccessControlChangesRow(data);
          case GovernanceRoleAuditRow:
            return GovernanceRoleAuditRow(data);
          case CollectionTemplatesRow:
            return CollectionTemplatesRow(data);
          case DepartmentsRow:
            return DepartmentsRow(data);
          case SystemAuditLogsRow:
            return SystemAuditLogsRow(data);
          case KpiAssignmentsRow:
            return KpiAssignmentsRow(data);
          case CompanyLicensesRow:
            return CompanyLicensesRow(data);
          case AiDocumentAnalysisLogsRow:
            return AiDocumentAnalysisLogsRow(data);
          case CasesRow:
            return CasesRow(data);
          case AttendanceRecordsRow:
            return AttendanceRecordsRow(data);
          case ZArchivePoliciesRow:
            return ZArchivePoliciesRow(data);
          case ForensicDamageReportsRow:
            return ForensicDamageReportsRow(data);
          case OfficeLeasesRow:
            return OfficeLeasesRow(data);
          case LegalHearingReportsRow:
            return LegalHearingReportsRow(data);
          case AllowanceDailyRow:
            return AllowanceDailyRow(data);
          case SeizedAssetsRow:
            return SeizedAssetsRow(data);
          case AiChatSessionsRow:
            return AiChatSessionsRow(data);
          case CollectionPtpsRow:
            return CollectionPtpsRow(data);
          case GlPeriodTransitionsRow:
            return GlPeriodTransitionsRow(data);
          case VOfficerLocationsRow:
            return VOfficerLocationsRow(data);
          case HolidayCalendarRow:
            return HolidayCalendarRow(data);
          case VYardDashboardAssetsRow:
            return VYardDashboardAssetsRow(data);
          case UserRolesRow:
            return UserRolesRow(data);
          case VendorQuotesRow:
            return VendorQuotesRow(data);
          case RecentCronRunsRow:
            return RecentCronRunsRow(data);
          case ZArchiveTamperEvidentAuditRow:
            return ZArchiveTamperEvidentAuditRow(data);
          case CollateralRow:
            return CollateralRow(data);
          case LoansCollateralsRow:
            return LoansCollateralsRow(data);
          case LegalCaseTimelineRow:
            return LegalCaseTimelineRow(data);
          case DataRetentionPoliciesRow:
            return DataRetentionPoliciesRow(data);
          case ForensicCaseAssignmentsRow:
            return ForensicCaseAssignmentsRow(data);
          case PaymentBatchesRow:
            return PaymentBatchesRow(data);
          case PartnerTermsAcknowledgmentsRow:
            return PartnerTermsAcknowledgmentsRow(data);
          case JournalLinesRow:
            return JournalLinesRow(data);
          case GovernanceAlertTrendsWeeklyRow:
            return GovernanceAlertTrendsWeeklyRow(data);
          case GovernmentEmployeesCacheRow:
            return GovernmentEmployeesCacheRow(data);
          case LeaveRequestsV2Row:
            return LeaveRequestsV2Row(data);
          case LeaveTypesRow:
            return LeaveTypesRow(data);
          case ZArchiveN8nWorkflowsRow:
            return ZArchiveN8nWorkflowsRow(data);
          case ComplianceExecutionsRow:
            return ComplianceExecutionsRow(data);
          case SsotAuditTrailRow:
            return SsotAuditTrailRow(data);
          case AttendanceSettingsRow:
            return AttendanceSettingsRow(data);
          case LoanRepaymentsRow:
            return LoanRepaymentsRow(data);
          case ZArchiveSystemConfigurationsRow:
            return ZArchiveSystemConfigurationsRow(data);
          case CollateralAssetsRow:
            return CollateralAssetsRow(data);
          case ProcurementThresholdsRow:
            return ProcurementThresholdsRow(data);
          case LoanEventsRow:
            return LoanEventsRow(data);
          case ZArchivePolicyBackupUserGovernanceRolesRow:
            return ZArchivePolicyBackupUserGovernanceRolesRow(data);
          case VOverdueLoansSummaryRow:
            return VOverdueLoansSummaryRow(data);
          case VendorContractIntelligenceRow:
            return VendorContractIntelligenceRow(data);
          case ZArchiveSecurityIncidentWorkflowsRow:
            return ZArchiveSecurityIncidentWorkflowsRow(data);
          case ZArchiveSecurityAuditLogsRow:
            return ZArchiveSecurityAuditLogsRow(data);
          case OrganizationsRow:
            return OrganizationsRow(data);
          case VendorStatementReconciliationsRow:
            return VendorStatementReconciliationsRow(data);
          case ExecutiveTrendSnapshotsRow:
            return ExecutiveTrendSnapshotsRow(data);
          case AllowancePolicyRow:
            return AllowancePolicyRow(data);
          case VendorTransactionsRow:
            return VendorTransactionsRow(data);
          case ZArchiveAlertsMetricsRow:
            return ZArchiveAlertsMetricsRow(data);
          case PolicyCatalogRow:
            return PolicyCatalogRow(data);
          case SystemSettingsRow:
            return SystemSettingsRow(data);
          case LoansAuditRow:
            return LoansAuditRow(data);
          case SecurityIncidentsRow:
            return SecurityIncidentsRow(data);
          case StaffActionLogsRow:
            return StaffActionLogsRow(data);
          case AppBannersRow:
            return AppBannersRow(data);
          case DuplicatePoliciesAnalysisRow:
            return DuplicatePoliciesAnalysisRow(data);
          case ZArchiveSecurityDefinerAllowlistRow:
            return ZArchiveSecurityDefinerAllowlistRow(data);
          case ForensicRecoveryCasesRow:
            return ForensicRecoveryCasesRow(data);
          case JournalsRow:
            return JournalsRow(data);
          case ZArchiveMonitoringThresholdsRow:
            return ZArchiveMonitoringThresholdsRow(data);
          case SmsQueueRow:
            return SmsQueueRow(data);
          case VGovernanceRoleGrants30dRow:
            return VGovernanceRoleGrants30dRow(data);
          case AiServiceLogsRow:
            return AiServiceLogsRow(data);
          case DailyCashCountsRow:
            return DailyCashCountsRow(data);
          case ZArchiveVendorCacheMetricsRow:
            return ZArchiveVendorCacheMetricsRow(data);
          case ZArchiveEdgeMetricsRefreshAuditRow:
            return ZArchiveEdgeMetricsRefreshAuditRow(data);
          case StaffLeaderboardRow:
            return StaffLeaderboardRow(data);
          case StaffRolesRow:
            return StaffRolesRow(data);
          case AlertMetricsHealthRow:
            return AlertMetricsHealthRow(data);
          case ReminderLogRow:
            return ReminderLogRow(data);
          case AlertsMetricsDailyRow:
            return AlertsMetricsDailyRow(data);
          case AlertsMetricsRow:
            return AlertsMetricsRow(data);
          case ZArchiveDatabaseBackupsRow:
            return ZArchiveDatabaseBackupsRow(data);
          case VMvRefreshOverviewRow:
            return VMvRefreshOverviewRow(data);
          case PendingCriticalTaskResponsesRow:
            return PendingCriticalTaskResponsesRow(data);
          case VLoansAuditRow:
            return VLoansAuditRow(data);
          case DocumentsRow:
            return DocumentsRow(data);
          case OrganizationMembersRow:
            return OrganizationMembersRow(data);
          case ZArchiveAttendanceEventsRow:
            return ZArchiveAttendanceEventsRow(data);
          case LoanProductsRow:
            return LoanProductsRow(data);
          case StaffPointsIdempotencyRow:
            return StaffPointsIdempotencyRow(data);
          case AlertNotificationsRow:
            return AlertNotificationsRow(data);
          case OcrResultsRow:
            return OcrResultsRow(data);
          case VendorTrustMatrixRow:
            return VendorTrustMatrixRow(data);
          case ZArchiveIntegrationLogsRow:
            return ZArchiveIntegrationLogsRow(data);
          case GeospatialRiskZonesRow:
            return GeospatialRiskZonesRow(data);
          case LeaveRequestsV2EnrichedRow:
            return LeaveRequestsV2EnrichedRow(data);
          case BranchMembersRow:
            return BranchMembersRow(data);
          case ZArchiveRolesRow:
            return ZArchiveRolesRow(data);
          case MessageTemplatesRow:
            return MessageTemplatesRow(data);
          case AlertLogsRow:
            return AlertLogsRow(data);
          case StaffPerformanceSnapshotsRow:
            return StaffPerformanceSnapshotsRow(data);
          case CompanyPolicyAcknowledgmentsRow:
            return CompanyPolicyAcknowledgmentsRow(data);
          case FieldVisitsRow:
            return FieldVisitsRow(data);
          case LegalHearingsRow:
            return LegalHearingsRow(data);
          case StaffGuarantorsRow:
            return StaffGuarantorsRow(data);
          case EdgeFunctionMetricsRow:
            return EdgeFunctionMetricsRow(data);
          case DocumentOcrLogsRow:
            return DocumentOcrLogsRow(data);
          case ClientRequestsRow:
            return ClientRequestsRow(data);
          case AttendanceRow:
            return AttendanceRow(data);
          case EdgeMetricsRefreshStatusRow:
            return EdgeMetricsRefreshStatusRow(data);
          case EdgeLatencyPcts24hRow:
            return EdgeLatencyPcts24hRow(data);
          case ZArchiveRlsPolicyBackupCleanupRow:
            return ZArchiveRlsPolicyBackupCleanupRow(data);
          case ZArchiveTzTaxConfigRow:
            return ZArchiveTzTaxConfigRow(data);
          case UserSessionsRow:
            return UserSessionsRow(data);
          case ComplianceItemsRow:
            return ComplianceItemsRow(data);
          case EdgeRecentFailures24hRow:
            return EdgeRecentFailures24hRow(data);
          case SmsCampaignsRow:
            return SmsCampaignsRow(data);
          case CollateralEvidenceRow:
            return CollateralEvidenceRow(data);
          case GovernmentLoanApplicationsRow:
            return GovernmentLoanApplicationsRow(data);
          case RolesRow:
            return RolesRow(data);
          case HrMembersRow:
            return HrMembersRow(data);
          case BankStatementLinesRow:
            return BankStatementLinesRow(data);
          case PettyCashRequestsRow:
            return PettyCashRequestsRow(data);
          case ZArchiveTokenAuditLogsRow:
            return ZArchiveTokenAuditLogsRow(data);
          case ZArchiveApprovalStepsRow:
            return ZArchiveApprovalStepsRow(data);
          case SodRulesRow:
            return SodRulesRow(data);
          case StaffBehaviorAnomaliesRow:
            return StaffBehaviorAnomaliesRow(data);
          case ZArchivePositionsRow:
            return ZArchivePositionsRow(data);
          case JournalEntriesRow:
            return JournalEntriesRow(data);
          case EmployeeDocumentsRow:
            return EmployeeDocumentsRow(data);
          case CustomersCoreRow:
            return CustomersCoreRow(data);
          case EmployeesPublicRow:
            return EmployeesPublicRow(data);
          case JournalEntryLinesRow:
            return JournalEntryLinesRow(data);
          case PartnerContractsRow:
            return PartnerContractsRow(data);
          case ComplianceAppealsRow:
            return ComplianceAppealsRow(data);
          case ComplianceDocumentsRow:
            return ComplianceDocumentsRow(data);
          case ExecutiveCollectionTargetsRow:
            return ExecutiveCollectionTargetsRow(data);
          case ZArchiveHrReviewQuestionBankRow:
            return ZArchiveHrReviewQuestionBankRow(data);
          case VLoanStageFunnelRow:
            return VLoanStageFunnelRow(data);
          case ZArchiveRlsPolicyBackupRow:
            return ZArchiveRlsPolicyBackupRow(data);
          case AnalyticsSummaryRow:
            return AnalyticsSummaryRow(data);
          case LoanConditionsRow:
            return LoanConditionsRow(data);
          case SmsCampaignRecipientsRow:
            return SmsCampaignRecipientsRow(data);
          case BankAccountsRow:
            return BankAccountsRow(data);
          case RoleEnterprisePermissionsRow:
            return RoleEnterprisePermissionsRow(data);
          case HealthCheckReportsRow:
            return HealthCheckReportsRow(data);
          case TopDeniedIps24hRow:
            return TopDeniedIps24hRow(data);
          case CustomerActiveLoanBalanceRow:
            return CustomerActiveLoanBalanceRow(data);
          case NotificationsRow:
            return NotificationsRow(data);
          case ZArchiveEmailTemplatesRow:
            return ZArchiveEmailTemplatesRow(data);
          case OrgMembersRow:
            return OrgMembersRow(data);
          case ProfileUploadDenialsByHourRow:
            return ProfileUploadDenialsByHourRow(data);
          case ViewGovernmentLoanPerformanceRow:
            return ViewGovernmentLoanPerformanceRow(data);
          case FraudRulesRow:
            return FraudRulesRow(data);
          case AuditLogsRow:
            return AuditLogsRow(data);
          case LoanSchedulesRow:
            return LoanSchedulesRow(data);
          case AttendanceV2TodayRow:
            return AttendanceV2TodayRow(data);
          case ZArchiveSecurityAlertsRow:
            return ZArchiveSecurityAlertsRow(data);
          case CollectionScheduledContactsRow:
            return CollectionScheduledContactsRow(data);
          case VendorCacheMetricsRow:
            return VendorCacheMetricsRow(data);
          case PettyCashRegistersRow:
            return PettyCashRegistersRow(data);
          case ZArchiveRolePermissionsRow:
            return ZArchiveRolePermissionsRow(data);
          default:
            return null;
        }

      default:
        return null;
    }
  } catch (e) {
    print('Error deserializing parameter: $e');
    return null;
  }
}
