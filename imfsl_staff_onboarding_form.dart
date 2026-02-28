// IMFSL Staff Onboarding Form - FlutterFlow Custom Widget
// ========================================================
// 3-step wizard form for staff onboarding:
// - Step 1: Select approved KYC submission (auto-fills personal info)
// - Step 2: Employment details and credentials
// - Step 3: Review summary and submit
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslStaffOnboardingForm extends StatefulWidget {
  const ImfslStaffOnboardingForm({
    super.key,
    this.approvedKycSubmissions = const [],
    this.isLoading = false,
    this.onSubmit,
    this.onCancel,
  });

  final List<Map<String, dynamic>> approvedKycSubmissions;
  final bool isLoading;
  final Function(Map<String, dynamic>)? onSubmit;
  final VoidCallback? onCancel;

  @override
  State<ImfslStaffOnboardingForm> createState() =>
      _ImfslStaffOnboardingFormState();
}

class _ImfslStaffOnboardingFormState extends State<ImfslStaffOnboardingForm> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1: KYC selection
  Map<String, dynamic>? _selectedKyc;

  // Step 2: Employment details
  final _employeeIdController = TextEditingController();
  final _branchCodeController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'OFFICER';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Form keys for validation
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  static const Color _primaryColor = Color(0xFF1565C0);
  static const List<String> _roles = [
    'ADMIN',
    'MANAGER',
    'OFFICER',
    'AUDITOR',
    'TELLER',
  ];

  // -- safe data access helpers --

  String _string(Map<String, dynamic> m, String key) =>
      (m[key] as String?) ?? '';

  @override
  void dispose() {
    _employeeIdController.dispose();
    _branchCodeController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Staff Onboarding',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        controlsBuilder: _buildStepControls,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: [
          Step(
            title: const Text('Select KYC Submission'),
            subtitle: _selectedKyc != null
                ? Text(_string(_selectedKyc!, 'full_name'))
                : null,
            content: _buildStep1(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Employment Details'),
            subtitle: _employeeIdController.text.isNotEmpty
                ? Text('ID: ${_employeeIdController.text}')
                : null,
            content: _buildStep2(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Review & Submit'),
            content: _buildStep3(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }

  // ========== STEP CONTROLS ==========

  Widget _buildStepControls(BuildContext context, ControlsDetails details) {
    final isLastStep = _currentStep == 2;
    final isFirstStep = _currentStep == 0;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (isLastStep)
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit'),
              ),
            )
          else
            Expanded(
              child: ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Continue'),
              ),
            ),
          const SizedBox(width: 12),
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: details.onStepCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back'),
              ),
            ),
        ],
      ),
    );
  }

  // ========== STEP NAVIGATION ==========

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_step1Key.currentState?.validate() != true) return;
      if (_selectedKyc == null) return;
    } else if (_currentStep == 1) {
      if (_step2Key.currentState?.validate() != true) return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _handleSubmit() {
    setState(() => _isSubmitting = true);

    final formData = <String, dynamic>{
      'kyc_id': _string(_selectedKyc!, 'kyc_id').isNotEmpty
          ? _string(_selectedKyc!, 'kyc_id')
          : _string(_selectedKyc!, 'id'),
      'employee_id': _employeeIdController.text.trim(),
      'system_role': _selectedRole,
      'branch_code': _branchCodeController.text.trim(),
      'position': _positionController.text.trim(),
      'department': _departmentController.text.trim(),
      'password_hash': _passwordController.text,
    };

    widget.onSubmit?.call(formData);

    // Reset submitting state after callback (parent controls actual loading)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    });
  }

  // ========== STEP 1: SELECT KYC ==========

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select an approved KYC submission to link to this staff account.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          _buildKycDropdown(),
          const SizedBox(height: 16),
          if (_selectedKyc != null) _buildKycPreview(),
        ],
      ),
    );
  }

  Widget _buildKycDropdown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedKyc,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Approved KYC Submission',
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      items: widget.approvedKycSubmissions.map((kyc) {
        final name = _string(kyc, 'full_name');
        final nationalId = _string(kyc, 'national_id');
        return DropdownMenuItem<Map<String, dynamic>>(
          value: kyc,
          child: Text(
            '$name - $nationalId',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      validator: (val) => val == null ? 'Please select a KYC submission' : null,
      onChanged: (val) {
        setState(() => _selectedKyc = val);
      },
    );
  }

  Widget _buildKycPreview() {
    final kyc = _selectedKyc!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Auto-filled from KYC',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildReadOnlyField('Full Name', _string(kyc, 'full_name')),
          _buildReadOnlyField('National ID', _string(kyc, 'national_id')),
          _buildReadOnlyField('Phone', _string(kyc, 'phone')),
          _buildReadOnlyField('Email', _string(kyc, 'email')),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ========== STEP 2: EMPLOYMENT DETAILS ==========

  Widget _buildStep2() {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _employeeIdController,
            label: 'Employee ID',
            hint: 'e.g. EMP-001',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Employee ID is required' : null,
          ),
          const SizedBox(height: 14),
          _buildRoleDropdown(),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _branchCodeController,
            label: 'Branch Code',
            hint: 'e.g. BR-NBI-001',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Branch code is required' : null,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _positionController,
            label: 'Position',
            hint: 'e.g. Loan Officer',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Position is required' : null,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _departmentController,
            label: 'Department',
            hint: 'e.g. Operations',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Department is required' : null,
          ),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _passwordController,
            label: 'Password',
            obscure: _obscurePassword,
            onToggle: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'Password must be at least 8 characters';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            obscure: _obscureConfirm,
            onToggle: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm password';
              if (v != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'System Role',
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      items: _roles
          .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r, style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() => _selectedRole = val);
        }
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey[500],
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  // ========== STEP 3: REVIEW & SUBMIT ==========

  Widget _buildStep3() {
    if (_selectedKyc == null) {
      return const Text('Please complete the previous steps first.');
    }

    final kyc = _selectedKyc!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Staff Details',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Please verify all information before submitting.',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          _buildReviewSection('Personal Information', [
            _buildReviewRow('Full Name', _string(kyc, 'full_name')),
            _buildReviewRow('National ID', _string(kyc, 'national_id')),
            _buildReviewRow('Phone', _string(kyc, 'phone')),
            _buildReviewRow('Email', _string(kyc, 'email')),
          ]),
          const Divider(height: 24),
          _buildReviewSection('Employment Details', [
            _buildReviewRow('Employee ID', _employeeIdController.text),
            _buildReviewRow('System Role', _selectedRole),
            _buildReviewRow('Branch Code', _branchCodeController.text),
            _buildReviewRow('Position', _positionController.text),
            _buildReviewRow('Department', _departmentController.text),
            _buildReviewRow(
                'Password', List.filled(_passwordController.text.length.clamp(1, 12), '*').join()),
          ]),
          if (widget.isLoading) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
