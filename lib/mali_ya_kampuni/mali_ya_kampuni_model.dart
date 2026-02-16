import '/backend/supabase/supabase.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'mali_ya_kampuni_widget.dart' show MaliYaKampuniWidget;
import 'package:flutter/material.dart';

class MaliYaKampuniModel extends FlutterFlowModel<MaliYaKampuniWidget> {
  /// Local state fields for this page.

  // Active tab: 'assets', 'monitoring', 'ocr', 'alerts'
  String activeTab = 'assets';

  // Asset category filter
  String? selectedCategory;

  // Asset status filter
  String? selectedStatus;

  // KPI data from API
  dynamic kpiData;
  bool isLoadingKpis = true;

  // Tech health data
  dynamic techHealthData;
  bool isLoadingTechHealth = true;

  // Fleet GPS data
  dynamic fleetGpsData;
  bool isLoadingFleet = true;

  // Asset list
  List<CompanyAssetsRow>? assetsList;
  bool isLoadingAssets = true;

  // Maintenance records
  List<AssetMaintenanceRecordsRow>? maintenanceList;
  bool isLoadingMaintenance = true;

  // OCR Scans
  List<AssetOcrScansRow>? ocrScansList;
  bool isLoadingOcrScans = true;

  // Alerts
  List<SystemAlertsRow>? alertsList;
  List<FraudAlertsRow>? fraudAlertsList;
  bool isLoadingAlerts = true;

  // Add Asset Form
  final addAssetFormKey = GlobalKey<FormState>();
  TextEditingController? assetNameController;
  FocusNode? assetNameFocusNode;
  TextEditingController? serialNumberController;
  FocusNode? serialNumberFocusNode;
  TextEditingController? registrationNumberController;
  FocusNode? registrationNumberFocusNode;
  TextEditingController? purchasePriceController;
  FocusNode? purchasePriceFocusNode;
  TextEditingController? descriptionController;
  FocusNode? descriptionFocusNode;
  TextEditingController? locationController;
  FocusNode? locationFocusNode;
  TextEditingController? departmentController;
  FocusNode? departmentFocusNode;
  String? addAssetCategoryValue;
  FormFieldController<String>? addAssetCategoryController;
  String? addAssetDepMethodValue;
  FormFieldController<String>? addAssetDepMethodController;
  DateTime? addAssetPurchaseDate;
  int addAssetUsefulLife = 5;

  // Upload state
  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl = '';

  // OCR Scanner state
  bool isOcrProcessing = false;
  String? ocrResultText;
  dynamic ocrExtractedFields;
  double? ocrConfidence;
  String? ocrFraudStatus;
  int ocrFraudScore = 0;
  dynamic ocrFraudIndicators;

  // Selected asset for detail view
  CompanyAssetsRow? selectedAsset;

  // Maintenance form
  final maintenanceFormKey = GlobalKey<FormState>();
  TextEditingController? maintenanceDescController;
  FocusNode? maintenanceDescFocusNode;
  TextEditingController? maintenanceCostController;
  FocusNode? maintenanceCostFocusNode;
  TextEditingController? maintenanceVendorController;
  FocusNode? maintenanceVendorFocusNode;
  String? maintenanceTypeValue;
  FormFieldController<String>? maintenanceTypeController;
  String? maintenancePriorityValue;
  FormFieldController<String>? maintenancePriorityController;
  DateTime? maintenanceScheduledDate;

  // Search
  TextEditingController? searchController;
  FocusNode? searchFocusNode;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    assetNameController?.dispose();
    assetNameFocusNode?.dispose();
    serialNumberController?.dispose();
    serialNumberFocusNode?.dispose();
    registrationNumberController?.dispose();
    registrationNumberFocusNode?.dispose();
    purchasePriceController?.dispose();
    purchasePriceFocusNode?.dispose();
    descriptionController?.dispose();
    descriptionFocusNode?.dispose();
    locationController?.dispose();
    locationFocusNode?.dispose();
    departmentController?.dispose();
    departmentFocusNode?.dispose();
    maintenanceDescController?.dispose();
    maintenanceDescFocusNode?.dispose();
    maintenanceCostController?.dispose();
    maintenanceCostFocusNode?.dispose();
    maintenanceVendorController?.dispose();
    maintenanceVendorFocusNode?.dispose();
    searchController?.dispose();
    searchFocusNode?.dispose();
  }
}
