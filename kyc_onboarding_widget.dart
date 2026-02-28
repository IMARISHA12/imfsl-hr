// IMFSL KYC Onboarding Widget - Customer Mobile App
// ===================================================
// 5-step KYC wizard: Personal Info -> Additional Info -> Document Capture ->
//                     Liveness Check -> Review & Submit
// Features:
// - Full form validation per step
// - Document capture placeholders with thumbnail previews
// - Liveness check integration via callback
// - Post-submission KYC status tracker (RECEIVED -> PROCESSING -> VERIFIED/REJECTED)
// - Step indicator with numbered circles and connecting lines
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KycOnboardingWidget extends StatefulWidget {
  const KycOnboardingWidget({
    super.key,
    this.onSubmitKyc,
    this.onCheckStatus,
    this.onCaptureSelfie,
    this.onLivenessCheck,
    this.onComplete,
    this.existingKycStatus,
  });

  final Future<Map<String, dynamic>> Function(Map<String, dynamic> kycData)?
      onSubmitKyc;
  final Future<Map<String, dynamic>> Function()? onCheckStatus;
  final Future<String> Function()? onCaptureSelfie;
  final Future<Map<String, dynamic>> Function()? onLivenessCheck;
  final VoidCallback? onComplete;
  final Map<String, dynamic>? existingKycStatus;

  @override
  State<KycOnboardingWidget> createState() => _KycOnboardingWidgetState();
}

class _KycOnboardingWidgetState extends State<KycOnboardingWidget> {
  static const _primaryColor = Color(0xFF1565C0);
  static const _successColor = Color(0xFF2E7D32);
  static const _errorColor = Color(0xFFC62828);

  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _hasSubmitted = false;
  Map<String, dynamic>? _submissionResult;

  // Form keys per step
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Step 1: Personal Info
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _dateOfBirth;
  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  // Step 2: Additional Info
  final _occupationController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _addressController = TextEditingController();
  final _nextOfKinNameController = TextEditingController();
  final _nextOfKinPhoneController = TextEditingController();

  // Step 3: Document Capture
  String? _idFrontImage;
  String? _idBackImage;
  String? _selfieImage;
  bool _isCapturingIdFront = false;
  bool _isCapturingIdBack = false;
  bool _isCapturingSelfie = false;

  // Step 4: Liveness Check
  bool _isRunningLiveness = false;
  Map<String, dynamic>? _livenessResult;

  final NumberFormat _currencyFmt =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    _monthlyIncomeController.dispose();
    _addressController.dispose();
    _nextOfKinNameController.dispose();
    _nextOfKinPhoneController.dispose();
    super.dispose();
  }

  bool get _showStatusTracker =>
      widget.existingKycStatus != null || _hasSubmitted;

  String get _kycStatus {
    if (_submissionResult != null) {
      return (_submissionResult!['status'] as String?) ?? 'RECEIVED';
    }
    if (widget.existingKycStatus != null) {
      return (widget.existingKycStatus!['status'] as String?) ?? 'RECEIVED';
    }
    return 'RECEIVED';
  }

  String? get _rejectionReason {
    if (_submissionResult != null) {
      return _submissionResult!['rejection_reason'] as String?;
    }
    if (widget.existingKycStatus != null) {
      return widget.existingKycStatus!['rejection_reason'] as String?;
    }
    return null;
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return (_step1FormKey.currentState?.validate() ?? false) &&
            _dateOfBirth != null;
      case 1:
        return _step2FormKey.currentState?.validate() ?? false;
      case 2:
        return _idFrontImage != null &&
            _idBackImage != null &&
            _selfieImage != null;
      case 3:
        return _livenessResult != null &&
            (_livenessResult!['passed'] == true);
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _goToNextStep() {
    if (!_validateCurrentStep()) {
      if (_currentStep == 0 && _dateOfBirth == null) {
        _showSnackBar('Please select your date of birth');
        return;
      }
      if (_currentStep == 2) {
        _showSnackBar('Please capture all required documents');
      } else if (_currentStep == 3) {
        if (_livenessResult == null) {
          _showSnackBar('Please complete the liveness check');
        } else {
          _showSnackBar('Liveness check failed. Please try again.');
        }
      }
      return;
    }
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Map<String, dynamic> _collectAllData() {
    return {
      'full_name': _fullNameController.text.trim(),
      'national_id': _nationalIdController.text.trim(),
      'phone_number': _phoneNumberController.text.trim(),
      'email': _emailController.text.trim(),
      'date_of_birth': _dateOfBirth?.toIso8601String(),
      'gender': _selectedGender,
      'occupation': _occupationController.text.trim(),
      'monthly_income':
          double.tryParse(_monthlyIncomeController.text.trim()) ?? 0.0,
      'address': _addressController.text.trim(),
      'next_of_kin_name': _nextOfKinNameController.text.trim(),
      'next_of_kin_phone': _nextOfKinPhoneController.text.trim(),
      'id_front_image': _idFrontImage,
      'id_back_image': _idBackImage,
      'selfie_image': _selfieImage,
      'liveness_passed': _livenessResult?['passed'] ?? false,
      'liveness_score': _livenessResult?['score'],
    };
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      final data = _collectAllData();
      if (widget.onSubmitKyc != null) {
        final result = await widget.onSubmitKyc!(data);
        setState(() {
          _submissionResult = result;
          _hasSubmitted = true;
          _isSubmitting = false;
        });
      } else {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _submissionResult = {
            'status': 'RECEIVED',
            'message': 'KYC submitted successfully',
          };
          _hasSubmitted = true;
          _isSubmitting = false;
        });
      }
      widget.onComplete?.call();
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Submission failed: ${e.toString()}');
    }
  }

  Future<void> _simulateCapture(String type) async {
    switch (type) {
      case 'id_front':
        setState(() => _isCapturingIdFront = true);
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _idFrontImage =
              'id_front_captured_${DateTime.now().millisecondsSinceEpoch}';
          _isCapturingIdFront = false;
        });
        break;
      case 'id_back':
        setState(() => _isCapturingIdBack = true);
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _idBackImage =
              'id_back_captured_${DateTime.now().millisecondsSinceEpoch}';
          _isCapturingIdBack = false;
        });
        break;
      case 'selfie':
        setState(() => _isCapturingSelfie = true);
        if (widget.onCaptureSelfie != null) {
          try {
            final result = await widget.onCaptureSelfie!();
            setState(() {
              _selfieImage = result;
              _isCapturingSelfie = false;
            });
          } catch (e) {
            setState(() => _isCapturingSelfie = false);
            _showSnackBar('Selfie capture failed: ${e.toString()}');
          }
        } else {
          await Future.delayed(const Duration(milliseconds: 800));
          setState(() {
            _selfieImage =
                'selfie_captured_${DateTime.now().millisecondsSinceEpoch}';
            _isCapturingSelfie = false;
          });
        }
        break;
    }
  }

  Future<void> _handleLivenessCheck() async {
    setState(() {
      _isRunningLiveness = true;
      _livenessResult = null;
    });
    try {
      if (widget.onLivenessCheck != null) {
        final result = await widget.onLivenessCheck!();
        setState(() {
          _livenessResult = result;
          _isRunningLiveness = false;
        });
      } else {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _livenessResult = {'passed': true, 'score': 0.97};
          _isRunningLiveness = false;
        });
      }
    } catch (e) {
      setState(() {
        _livenessResult = {'passed': false, 'error': e.toString()};
        _isRunningLiveness = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_showStatusTracker) {
      return _buildStatusTrackerView();
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('KYC Verification',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _buildCurrentStep(),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // ─── Step Indicator ───────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final labels = ['Personal', 'Details', 'Documents', 'Liveness', 'Review'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.white,
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone ? _primaryColor : Colors.grey.shade300,
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? _primaryColor
                            : isActive
                                ? _primaryColor
                                : Colors.grey.shade300,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : Text('${i + 1}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.grey[600])),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(labels[i],
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                            color:
                                isActive ? _primaryColor : Colors.grey[600])),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Navigation Buttons ───────────────────────────────────────────────

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goToPreviousStep,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: const BorderSide(color: _primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: _currentStep < 4
                ? ElevatedButton.icon(
                    onPressed: _goToNextStep,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send, size: 18),
                    label:
                        Text(_isSubmitting ? 'Submitting...' : 'Submit KYC'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Step Router ──────────────────────────────────────────────────────

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1PersonalInfo();
      case 1:
        return _buildStep2AdditionalInfo();
      case 2:
        return _buildStep3DocumentCapture();
      case 3:
        return _buildStep4LivenessCheck();
      case 4:
        return _buildStep5ReviewSubmit();
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  STEP 1: Personal Info
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildStep1PersonalInfo() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              'Personal Information', 'Provide your basic personal details'),
          const SizedBox(height: 16),
          _buildFormCard(
            children: [
              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: _inputDecoration(
                  label: 'Full Name',
                  hint: 'Enter your full legal name',
                  icon: Icons.person_outline,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  if (v.trim().split(' ').length < 2) {
                    return 'Please enter at least first and last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // National ID
              TextFormField(
                controller: _nationalIdController,
                decoration: _inputDecoration(
                  label: 'National ID Number',
                  hint: 'e.g. 12345678',
                  icon: Icons.badge_outlined,
                ),
                keyboardType: TextInputType.number,
                maxLength: 8,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'National ID is required';
                  }
                  final id = v.trim();
                  if (!RegExp(r'^\d{7,8}$').hasMatch(id)) {
                    return 'National ID must be 7 or 8 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneNumberController,
                decoration: _inputDecoration(
                  label: 'Phone Number',
                  hint: '254712345678',
                  icon: Icons.phone_outlined,
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  final phone = v.trim();
                  if (!RegExp(r'^254\d{9}$').hasMatch(phone)) {
                    return 'Enter phone in 254XXXXXXXXX format (12 digits)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration(
                  label: 'Email Address',
                  hint: 'name@example.com',
                  icon: Icons.email_outlined,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final email = v.trim();
                  if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(email)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth
              _buildDateOfBirthPicker(),
              const SizedBox(height: 16),

              // Gender
              _buildGenderDropdown(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthPicker() {
    final displayDate = _dateOfBirth != null
        ? DateFormat('dd MMM yyyy').format(_dateOfBirth!)
        : '';
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime(now.year - 25, 1, 1),
          firstDate: DateTime(1940),
          lastDate: DateTime(now.year - 18, now.month, now.day),
          helpText: 'Select your date of birth',
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: _primaryColor),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _dateOfBirth = picked);
        }
      },
      child: InputDecorator(
        decoration: _inputDecoration(
          label: 'Date of Birth',
          hint: 'Tap to select date',
          icon: Icons.calendar_today_outlined,
        ).copyWith(errorText: null),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayDate.isEmpty ? 'Tap to select date' : displayDate,
              style: TextStyle(
                fontSize: 16,
                color: displayDate.isEmpty ? Colors.grey[500] : Colors.black87,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: _inputDecoration(
        label: 'Gender',
        icon: Icons.wc_outlined,
      ),
      items: _genderOptions
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedGender = v);
      },
      validator: (v) =>
          v == null || v.isEmpty ? 'Please select a gender' : null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  STEP 2: Additional Info
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildStep2AdditionalInfo() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              'Additional Information', 'Employment and next-of-kin details'),
          const SizedBox(height: 16),
          _buildFormCard(
            children: [
              // Occupation
              TextFormField(
                controller: _occupationController,
                decoration: _inputDecoration(
                  label: 'Occupation',
                  hint: 'e.g. Teacher, Farmer, Business Owner',
                  icon: Icons.work_outline,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Occupation is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Monthly Income
              TextFormField(
                controller: _monthlyIncomeController,
                decoration: _inputDecoration(
                  label: 'Monthly Income (KES)',
                  hint: 'e.g. 50000',
                  icon: Icons.attach_money,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Monthly income is required';
                  }
                  final amount = double.tryParse(v.trim());
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid income amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration(
                  label: 'Residential Address',
                  hint: 'Enter your full address',
                  icon: Icons.location_on_outlined,
                ),
                maxLines: 3,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Next of Kin', 'Emergency contact information'),
          const SizedBox(height: 16),
          _buildFormCard(
            children: [
              // Next of Kin Name
              TextFormField(
                controller: _nextOfKinNameController,
                decoration: _inputDecoration(
                  label: 'Next of Kin Name',
                  hint: 'Full name of your next of kin',
                  icon: Icons.people_outline,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Next of kin name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Next of Kin Phone
              TextFormField(
                controller: _nextOfKinPhoneController,
                decoration: _inputDecoration(
                  label: 'Next of Kin Phone',
                  hint: '254712345678',
                  icon: Icons.phone_outlined,
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Next of kin phone is required';
                  }
                  final phone = v.trim();
                  if (!RegExp(r'^254\d{9}$').hasMatch(phone)) {
                    return 'Enter phone in 254XXXXXXXXX format';
                  }
                  return null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  STEP 3: Document Capture
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildStep3DocumentCapture() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Document Capture', 'Take photos of your identification documents'),
        const SizedBox(height: 16),

        // ID Front
        _buildDocumentCaptureCard(
          title: 'National ID - Front Side',
          subtitle: 'Take a clear photo of the front of your National ID',
          capturedImage: _idFrontImage,
          isCapturing: _isCapturingIdFront,
          onCapture: () => _simulateCapture('id_front'),
          onRetake: () => setState(() => _idFrontImage = null),
        ),
        const SizedBox(height: 16),

        // ID Back
        _buildDocumentCaptureCard(
          title: 'National ID - Back Side',
          subtitle: 'Take a clear photo of the back of your National ID',
          capturedImage: _idBackImage,
          isCapturing: _isCapturingIdBack,
          onCapture: () => _simulateCapture('id_back'),
          onRetake: () => setState(() => _idBackImage = null),
        ),
        const SizedBox(height: 16),

        // Selfie
        _buildDocumentCaptureCard(
          title: 'Selfie Photo',
          subtitle: 'Take a clear selfie for identity verification',
          capturedImage: _selfieImage,
          isCapturing: _isCapturingSelfie,
          onCapture: () => _simulateCapture('selfie'),
          onRetake: () => setState(() => _selfieImage = null),
          isSelfie: true,
        ),
        const SizedBox(height: 16),

        // Tips card
        _buildFormCard(
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: _primaryColor, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Tips for good document photos',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipRow(
                Icons.light_mode_outlined, 'Ensure good lighting, no shadows'),
            const SizedBox(height: 8),
            _buildTipRow(Icons.crop_free,
                'Capture the entire document within the frame'),
            const SizedBox(height: 8),
            _buildTipRow(Icons.blur_off,
                'Keep the camera steady to avoid blurry images'),
            const SizedBox(height: 8),
            _buildTipRow(Icons.visibility_outlined,
                'All text on the document must be readable'),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentCaptureCard({
    required String title,
    required String subtitle,
    required String? capturedImage,
    required bool isCapturing,
    required VoidCallback onCapture,
    required VoidCallback onRetake,
    bool isSelfie = false,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 16),
            if (capturedImage == null)
              InkWell(
                onTap: isCapturing ? null : onCapture,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: isSelfie ? 200 : 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade300, width: 2),
                  ),
                  child: isCapturing
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: _primaryColor),
                              SizedBox(height: 12),
                              Text('Capturing...',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelfie
                                  ? Icons.face_outlined
                                  : Icons.camera_alt,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isSelfie
                                  ? 'Tap to capture selfie'
                                  : 'Tap to capture ${title.contains('Front') ? 'ID front' : 'ID back'}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: isSelfie ? 200 : 160,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _successColor, width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelfie ? Icons.face : Icons.badge,
                              size: 48,
                              color: _successColor,
                            ),
                            const SizedBox(height: 8),
                            const Text('Captured successfully',
                                style: TextStyle(
                                    color: _successColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: _successColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onRetake,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  STEP 4: Liveness Check
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildStep4LivenessCheck() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Liveness Verification', 'Verify you are a real person'),
        const SizedBox(height: 16),

        // Instructions card
        _buildFormCard(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.security,
                      color: _primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Liveness Check',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('Follow the on-screen instructions carefully',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildInstructionRow(1, 'Position your face within the frame'),
            const SizedBox(height: 12),
            _buildInstructionRow(2, 'Follow the prompts to turn your head'),
            const SizedBox(height: 12),
            _buildInstructionRow(3, 'Blink when instructed'),
            const SizedBox(height: 12),
            _buildInstructionRow(
                4, 'Ensure good lighting and a plain background'),
            const SizedBox(height: 12),
            _buildInstructionRow(
                5, 'Remove hats, sunglasses, or face coverings'),
          ],
        ),
        const SizedBox(height: 24),

        // Start button
        if (_livenessResult == null && !_isRunningLiveness)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleLivenessCheck,
              icon: const Icon(Icons.play_circle_outline, size: 24),
              label: const Text('Start Liveness Check',
                  style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

        // Running indicator
        if (_isRunningLiveness)
          _buildFormCard(
            children: [
              const SizedBox(height: 20),
              const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                      strokeWidth: 4, color: _primaryColor),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('Running liveness check...',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Please wait',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ),
              const SizedBox(height: 20),
            ],
          ),

        // Result
        if (_livenessResult != null) _buildLivenessResultCard(),
      ],
    );
  }

  Widget _buildInstructionRow(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('$number',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildLivenessResultCard() {
    final passed = _livenessResult!['passed'] == true;
    final score = _livenessResult!['score'];
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: passed
                    ? _successColor.withOpacity(0.1)
                    : _errorColor.withOpacity(0.1),
              ),
              child: Icon(
                passed ? Icons.check_circle : Icons.cancel,
                size: 48,
                color: passed ? _successColor : _errorColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              passed ? 'Liveness Check Passed' : 'Liveness Check Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: passed ? _successColor : _errorColor,
              ),
            ),
            if (score != null) ...[
              const SizedBox(height: 8),
              Text(
                'Confidence: ${(score * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            if (!passed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleLivenessCheck,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry Liveness Check'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    side: const BorderSide(color: _primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  STEP 5: Review & Submit
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildStep5ReviewSubmit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Review & Submit', 'Please review your information before submitting'),
        const SizedBox(height: 16),

        // Personal Info
        _buildReviewSection(
          title: 'Personal Information',
          icon: Icons.person_outline,
          rows: [
            _buildReviewRow('Full Name', _fullNameController.text),
            _buildReviewRow('National ID', _nationalIdController.text),
            _buildReviewRow('Phone Number', _phoneNumberController.text),
            _buildReviewRow('Email', _emailController.text),
            _buildReviewRow(
                'Date of Birth',
                _dateOfBirth != null
                    ? DateFormat('dd MMM yyyy').format(_dateOfBirth!)
                    : 'Not set'),
            _buildReviewRow('Gender', _selectedGender),
          ],
        ),
        const SizedBox(height: 16),

        // Additional Info
        _buildReviewSection(
          title: 'Additional Information',
          icon: Icons.info_outline,
          rows: [
            _buildReviewRow('Occupation', _occupationController.text),
            _buildReviewRow(
                'Monthly Income',
                _currencyFmt.format(
                    double.tryParse(_monthlyIncomeController.text) ?? 0)),
            _buildReviewRow('Address', _addressController.text),
          ],
        ),
        const SizedBox(height: 16),

        // Next of Kin
        _buildReviewSection(
          title: 'Next of Kin',
          icon: Icons.people_outline,
          rows: [
            _buildReviewRow('Name', _nextOfKinNameController.text),
            _buildReviewRow('Phone', _nextOfKinPhoneController.text),
          ],
        ),
        const SizedBox(height: 16),

        // Documents
        _buildReviewSection(
          title: 'Documents',
          icon: Icons.description_outlined,
          rows: [
            _buildReviewRow(
                'ID Front', _idFrontImage != null ? 'Captured' : 'Not captured',
                isStatus: true,
                statusOk: _idFrontImage != null),
            _buildReviewRow(
                'ID Back', _idBackImage != null ? 'Captured' : 'Not captured',
                isStatus: true,
                statusOk: _idBackImage != null),
            _buildReviewRow(
                'Selfie', _selfieImage != null ? 'Captured' : 'Not captured',
                isStatus: true,
                statusOk: _selfieImage != null),
          ],
        ),
        const SizedBox(height: 16),

        // Liveness
        _buildReviewSection(
          title: 'Liveness Verification',
          icon: Icons.security,
          rows: [
            _buildReviewRow(
                'Status',
                _livenessResult != null
                    ? (_livenessResult!['passed'] == true
                        ? 'Passed'
                        : 'Failed')
                    : 'Not completed',
                isStatus: true,
                statusOk: _livenessResult?['passed'] == true),
            if (_livenessResult?['score'] != null)
              _buildReviewRow('Confidence',
                  '${(_livenessResult!['score'] * 100).toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 20),

        // Disclaimer
        Card(
          elevation: 0,
          color: Colors.amber.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.amber.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.amber[800], size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'By submitting, I confirm that all information provided is '
                    'accurate and I consent to having my identity verified by IMFSL.',
                    style: TextStyle(
                        fontSize: 13, color: Colors.amber[900], height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReviewSection({
    required String title,
    required IconData icon,
    required List<Widget> rows,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value,
      {bool isStatus = false, bool statusOk = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isStatus
                ? Row(
                    children: [
                      Icon(
                        statusOk ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: statusOk ? _successColor : _errorColor,
                      ),
                      const SizedBox(width: 6),
                      Text(value,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  statusOk ? _successColor : _errorColor)),
                    ],
                  )
                : Text(value.isEmpty ? '-' : value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  STATUS TRACKER VIEW (post-submission / existingKycStatus)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildStatusTrackerView() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('KYC Status',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.onCheckStatus != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                final result = await widget.onCheckStatus!();
                setState(() => _submissionResult = result);
              },
              tooltip: 'Refresh Status',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatusHeaderCard(),
            const SizedBox(height: 24),
            _buildStatusStepper(),
            if (_kycStatus == 'REJECTED' && _rejectionReason != null) ...[
              const SizedBox(height: 24),
              _buildRejectionCard(),
            ],
            if (_kycStatus == 'VERIFIED') ...[
              const SizedBox(height: 24),
              _buildVerifiedCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeaderCard() {
    final statusColors = <String, Color>{
      'RECEIVED': Colors.blue,
      'PROCESSING': Colors.orange,
      'VERIFIED': _successColor,
      'REJECTED': _errorColor,
    };
    final statusIcons = <String, IconData>{
      'RECEIVED': Icons.inbox,
      'PROCESSING': Icons.hourglass_top,
      'VERIFIED': Icons.verified,
      'REJECTED': Icons.block,
    };
    final color = statusColors[_kycStatus] ?? Colors.grey;
    final icon = statusIcons[_kycStatus] ?? Icons.help_outline;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text('KYC $_kycStatus',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 8),
            Text(
              _statusDescription(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _statusDescription() {
    switch (_kycStatus) {
      case 'RECEIVED':
        return 'Your KYC application has been received and is queued for review.';
      case 'PROCESSING':
        return 'Your documents are being verified. This usually takes 1-2 business days.';
      case 'VERIFIED':
        return 'Your identity has been verified successfully. You can now access all services.';
      case 'REJECTED':
        return 'Your KYC application was not approved. Please review the reason and resubmit.';
      default:
        return 'Status unknown. Please contact support.';
    }
  }

  Widget _buildStatusStepper() {
    final isRejected = _kycStatus == 'REJECTED';
    final steps = <Map<String, String>>[
      {'label': 'RECEIVED', 'subtitle': 'Application submitted'},
      {'label': 'PROCESSING', 'subtitle': 'Documents under review'},
      {
        'label': isRejected ? 'REJECTED' : 'VERIFIED',
        'subtitle': isRejected ? 'Application rejected' : 'Identity confirmed',
      },
    ];

    int activeIndex;
    switch (_kycStatus) {
      case 'RECEIVED':
        activeIndex = 0;
        break;
      case 'PROCESSING':
        activeIndex = 1;
        break;
      case 'VERIFIED':
      case 'REJECTED':
        activeIndex = 2;
        break;
      default:
        activeIndex = 0;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verification Progress',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 20),
            ...List.generate(steps.length, (i) {
              final step = steps[i];
              final isComplete = i < activeIndex;
              final isCurrent = i == activeIndex;
              final isStepRejected = isCurrent && step['label'] == 'REJECTED';
              final isLast = i == steps.length - 1;

              Color dotColor;
              if (isStepRejected) {
                dotColor = _errorColor;
              } else if (isComplete) {
                dotColor = _successColor;
              } else if (isCurrent) {
                dotColor = _primaryColor;
              } else {
                dotColor = Colors.grey.shade300;
              }

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                            child: Center(
                              child: isComplete
                                  ? const Icon(Icons.check,
                                      size: 14, color: Colors.white)
                                  : isStepRejected
                                      ? const Icon(Icons.close,
                                          size: 14, color: Colors.white)
                                      : isCurrent
                                          ? Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 40,
                              color: isComplete
                                  ? _successColor
                                  : Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['label']!,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isCurrent || isComplete
                                    ? Colors.black87
                                    : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step['subtitle']!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionCard() {
    return Card(
      elevation: 1,
      color: _errorColor.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _errorColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.error_outline, color: _errorColor, size: 22),
                SizedBox(width: 8),
                Text('Rejection Reason',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: _errorColor)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _rejectionReason ?? 'No reason provided.',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasSubmitted = false;
                    _submissionResult = null;
                    _currentStep = 0;
                  });
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Resubmit KYC'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedCard() {
    return Card(
      elevation: 1,
      color: _successColor.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _successColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.verified, color: _successColor, size: 48),
            const SizedBox(height: 12),
            const Text('Identity Verified',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: _successColor)),
            const SizedBox(height: 8),
            Text(
              'Your KYC verification is complete. You now have full access to all IMFSL services.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            if (widget.onComplete != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Continue to App'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _primaryColor)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
