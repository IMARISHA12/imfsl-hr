import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// CustomerProfileWidget - Profile & settings screen for the IMFSL customer mobile app.
///
/// Displays customer personal information, account details, employment & income,
/// security settings, and notification preferences. Supports inline editing of
/// permitted fields with save/cancel, password change dialog, 2FA toggle, and logout.
class CustomerProfileWidget extends StatefulWidget {
  final Map<String, dynamic> customerData;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> updates)?
      onSaveProfile;
  final Future<bool> Function(String oldPassword, String newPassword)?
      onChangePassword;
  final Future<bool> Function(bool enable)? onToggle2FA;
  final Function(String type, bool enabled)? onToggleNotification;
  final VoidCallback? onLogout;

  const CustomerProfileWidget({
    super.key,
    this.customerData = const {},
    this.onSaveProfile,
    this.onChangePassword,
    this.onToggle2FA,
    this.onToggleNotification,
    this.onLogout,
  });

  @override
  State<CustomerProfileWidget> createState() => _CustomerProfileWidgetState();
}

class _CustomerProfileWidgetState extends State<CustomerProfileWidget> {
  static const Color _primaryColor = Color(0xFF1565C0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  bool _isEditMode = false;
  bool _isSaving = false;

  // Editable field controllers
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _occupationController;
  late TextEditingController _monthlyIncomeController;

  // Original values for change detection
  String _originalPhone = '';
  String _originalEmail = '';
  String _originalAddress = '';
  String _originalOccupation = '';
  String _originalMonthlyIncome = '';

  // Local display data (updated after successful save)
  late Map<String, dynamic> _displayData;

  // Form key for edit mode validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Security
  bool _is2FAEnabled = false;

  // Notification preferences
  bool _loanUpdates = true;
  bool _paymentReminders = true;
  bool _promotional = true;
  bool _securityAlerts = true;

  @override
  void initState() {
    super.initState();
    _displayData = Map<String, dynamic>.from(widget.customerData);
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant CustomerProfileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customerData != oldWidget.customerData) {
      _displayData = Map<String, dynamic>.from(widget.customerData);
      if (!_isEditMode) {
        _initControllers();
      }
    }
  }

  void _initControllers() {
    final phone = _displayData['phone_number']?.toString() ?? '';
    final email = _displayData['email']?.toString() ?? '';
    final address = _displayData['address']?.toString() ?? '';
    final occupation = _displayData['occupation']?.toString() ?? '';
    final income = _displayData['monthly_income']?.toString() ?? '';

    _phoneController = TextEditingController(text: phone);
    _emailController = TextEditingController(text: email);
    _addressController = TextEditingController(text: address);
    _occupationController = TextEditingController(text: occupation);
    _monthlyIncomeController = TextEditingController(text: income);

    _originalPhone = phone;
    _originalEmail = email;
    _originalAddress = address;
    _originalOccupation = occupation;
    _originalMonthlyIncome = income;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _monthlyIncomeController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '??';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return _currencyFormat.format(0);
    final num parsed =
        value is num ? value : num.tryParse(value.toString()) ?? 0;
    return _currencyFormat.format(parsed);
  }

  Map<String, dynamic> _collectChanges() {
    final Map<String, dynamic> changes = {};
    if (_phoneController.text != _originalPhone) {
      changes['phone_number'] = _phoneController.text;
    }
    if (_emailController.text != _originalEmail) {
      changes['email'] = _emailController.text;
    }
    if (_addressController.text != _originalAddress) {
      changes['address'] = _addressController.text;
    }
    if (_occupationController.text != _originalOccupation) {
      changes['occupation'] = _occupationController.text;
    }
    if (_monthlyIncomeController.text != _originalMonthlyIncome) {
      changes['monthly_income'] =
          num.tryParse(_monthlyIncomeController.text) ??
              _monthlyIncomeController.text;
    }
    return changes;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _toggleEditMode() {
    if (_isEditMode) {
      // Cancel edit — restore original values
      _phoneController.text = _originalPhone;
      _emailController.text = _originalEmail;
      _addressController.text = _originalAddress;
      _occupationController.text = _originalOccupation;
      _monthlyIncomeController.text = _originalMonthlyIncome;
    }
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final changes = _collectChanges();
    if (changes.isEmpty) {
      setState(() => _isEditMode = false);
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.onSaveProfile != null) {
        final result = await widget.onSaveProfile!(changes);
        if (!mounted) return;

        // Merge result into display data
        _displayData.addAll(result);
      } else {
        // No callback — just apply locally
        _displayData.addAll(changes);
      }

      // Update originals so next diff is clean
      _originalPhone = _phoneController.text;
      _originalEmail = _emailController.text;
      _originalAddress = _addressController.text;
      _originalOccupation = _occupationController.text;
      _originalMonthlyIncome = _monthlyIncomeController.text;

      if (!mounted) return;
      setState(() {
        _isEditMode = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Form(
                key: dialogFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: oldCtrl,
                        obscureText: obscureOld,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(obscureOld
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setDialogState(() => obscureOld = !obscureOld),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter your current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newCtrl,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setDialogState(() => obscureNew = !obscureNew),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter a new password';
                          }
                          if (v.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmCtrl,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setDialogState(
                                () => obscureConfirm = !obscureConfirm),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Confirm your new password';
                          }
                          if (v != newCtrl.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx2),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!(dialogFormKey.currentState?.validate() ??
                              false)) return;
                          setDialogState(() => isSubmitting = true);
                          try {
                            bool success = true;
                            if (widget.onChangePassword != null) {
                              success = await widget.onChangePassword!(
                                oldCtrl.text,
                                newCtrl.text,
                              );
                            }
                            if (!ctx2.mounted) return;
                            if (success) {
                              Navigator.pop(ctx2);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Password changed successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              setDialogState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Password change failed. Check your current password.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!ctx2.mounted) return;
                            setDialogState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );

    oldCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  Future<void> _handle2FAToggle(bool value) async {
    final previous = _is2FAEnabled;
    setState(() => _is2FAEnabled = value);

    try {
      if (widget.onToggle2FA != null) {
        final success = await widget.onToggle2FA!(value);
        if (!mounted) return;
        if (!success) {
          setState(() => _is2FAEnabled = previous);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update 2FA setting'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _is2FAEnabled = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling 2FA: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleNotificationToggle(String type, bool enabled) {
    setState(() {
      switch (type) {
        case 'loan_updates':
          _loanUpdates = enabled;
          break;
        case 'payment_reminders':
          _paymentReminders = enabled;
          break;
        case 'promotional':
          _promotional = enabled;
          break;
        case 'security_alerts':
          _securityAlerts = enabled;
          break;
      }
    });
    widget.onToggleNotification?.call(type, enabled);
  }

  void _handleLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout?.call();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------------------

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!cleaned.startsWith('254')) return 'Must start with 254';
    if (cleaned.length != 12) return 'Must be 12 digits (254XXXXXXXXX)';
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) return 'Digits only';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validateIncome(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final parsed = num.tryParse(value);
    if (parsed == null || parsed < 0) return 'Enter a valid amount';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            _buildGradientHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  children: [
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 16),
                    _buildAccountDetailsSection(),
                    const SizedBox(height: 16),
                    _buildEmploymentIncomeSection(),
                    const SizedBox(height: 16),
                    _buildSecuritySection(),
                    const SizedBox(height: 16),
                    _buildNotificationPreferencesSection(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildEditFab(),
    );
  }

  // ---------------------------------------------------------------------------
  // Gradient Header
  // ---------------------------------------------------------------------------

  SliverToBoxAdapter _buildGradientHeader() {
    final fullName = _displayData['full_name']?.toString() ?? 'Customer';
    final accountNumber = _displayData['account_number']?.toString() ?? '';
    final kycStatus = _displayData['kyc_status']?.toString() ?? 'PENDING';

    return SliverToBoxAdapter(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryColor, _darkBlue],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      _getInitials(fullName),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    accountNumber.isNotEmpty ? 'A/C: $accountNumber' : '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildKycBadge(kycStatus),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKycBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status.toUpperCase()) {
      case 'VERIFIED':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        label = 'KYC Verified';
        break;
      case 'REJECTED':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
        label = 'KYC Rejected';
        break;
      case 'PENDING':
      default:
        bgColor = Colors.amber.shade100;
        textColor = Colors.amber.shade800;
        icon = Icons.hourglass_top;
        label = 'KYC Pending';
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 18, color: textColor),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      backgroundColor: bgColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  // ---------------------------------------------------------------------------
  // Edit FAB
  // ---------------------------------------------------------------------------

  Widget _buildEditFab() {
    if (_isSaving) {
      return FloatingActionButton(
        onPressed: null,
        backgroundColor: _primaryColor,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      );
    }

    if (_isEditMode) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'cancel_edit',
            onPressed: _toggleEditMode,
            backgroundColor: Colors.grey.shade600,
            mini: true,
            child: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'save_edit',
            onPressed: _saveProfile,
            backgroundColor: Colors.green,
            child: const Icon(Icons.check, color: Colors.white),
          ),
        ],
      );
    }

    return FloatingActionButton(
      heroTag: 'edit_profile',
      onPressed: _toggleEditMode,
      backgroundColor: _primaryColor,
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  // ---------------------------------------------------------------------------
  // Section Header
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Read-Only Row
  // ---------------------------------------------------------------------------

  Widget _buildReadOnlyRow(String label, String value,
      {IconData? trailingIcon, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: TextStyle(
                fontSize: 15,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Editable Row
  // ---------------------------------------------------------------------------

  Widget _buildEditableRow({
    required String label,
    required TextEditingController controller,
    required String displayValue,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
  }) {
    if (!_isEditMode) {
      return _buildReadOnlyRow(label, displayValue);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Personal Information Section
  // ---------------------------------------------------------------------------

  Widget _buildPersonalInfoSection() {
    final fullName = _displayData['full_name']?.toString() ?? '';
    final nationalId = _displayData['national_id']?.toString() ?? '';
    final dob = _displayData['date_of_birth']?.toString() ?? '';
    final gender = _displayData['gender']?.toString() ?? '';
    final phone = _displayData['phone_number']?.toString() ?? '';
    final email = _displayData['email']?.toString() ?? '';
    final address = _displayData['address']?.toString() ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Personal Information', Icons.person),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Read-only fields
            _buildReadOnlyRow('Full Name', fullName),
            _buildReadOnlyRow('National ID', nationalId,
                trailingIcon: Icons.lock),
            _buildReadOnlyRow('Date of Birth', _formatDate(dob)),
            _buildReadOnlyRow(
              'Gender',
              gender.isNotEmpty
                  ? '${gender[0].toUpperCase()}${gender.substring(1).toLowerCase()}'
                  : 'N/A',
            ),
            const Divider(height: 24),
            // Editable fields
            _buildEditableRow(
              label: 'Phone Number',
              controller: _phoneController,
              displayValue: phone,
              validator: _validatePhone,
              keyboardType: TextInputType.phone,
            ),
            _buildEditableRow(
              label: 'Email',
              controller: _emailController,
              displayValue: email,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildEditableRow(
              label: 'Address',
              controller: _addressController,
              displayValue: address,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Account Details Section
  // ---------------------------------------------------------------------------

  Widget _buildAccountDetailsSection() {
    final accountNumber = _displayData['account_number']?.toString() ?? '';
    final createdAt = _displayData['created_at']?.toString() ?? '';
    final isActive = _displayData['is_active'] ?? true;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account Details', Icons.account_balance),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _buildReadOnlyRow('Account Number', accountNumber),
            _buildReadOnlyRow('Member Since', _formatDate(createdAt)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive == true
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive == true
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 16,
                          color: isActive == true ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive == true ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isActive == true ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Employment & Income Section
  // ---------------------------------------------------------------------------

  Widget _buildEmploymentIncomeSection() {
    final occupation = _displayData['occupation']?.toString() ?? '';
    final income = _displayData['monthly_income'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Employment & Income', Icons.work),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _buildEditableRow(
              label: 'Occupation',
              controller: _occupationController,
              displayValue: occupation,
            ),
            _buildEditableRow(
              label: 'Monthly Income',
              controller: _monthlyIncomeController,
              displayValue: _formatCurrency(income),
              validator: _validateIncome,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Security Section
  // ---------------------------------------------------------------------------

  Widget _buildSecuritySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Security', Icons.shield),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: _primaryColor),
              title: const Text(
                'Change Password',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Update your login password',
                style: TextStyle(fontSize: 12),
              ),
              trailing:
                  const Icon(Icons.chevron_right, color: Colors.grey),
              contentPadding: EdgeInsets.zero,
              onTap: _showChangePasswordDialog,
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary:
                  const Icon(Icons.security, color: _primaryColor),
              title: const Text(
                'Two-Factor Authentication',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _is2FAEnabled ? 'Enabled' : 'Disabled',
                style: TextStyle(
                  fontSize: 12,
                  color: _is2FAEnabled ? Colors.green : Colors.grey,
                ),
              ),
              value: _is2FAEnabled,
              activeColor: _primaryColor,
              contentPadding: EdgeInsets.zero,
              onChanged: _handle2FAToggle,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Notification Preferences Section
  // ---------------------------------------------------------------------------

  Widget _buildNotificationPreferencesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                'Notification Preferences', Icons.notifications),
            const Divider(height: 1),
            _buildNotificationToggle(
              icon: Icons.account_balance,
              title: 'Loan Updates',
              subtitle: 'Loan approval, disbursement & status changes',
              value: _loanUpdates,
              type: 'loan_updates',
            ),
            const Divider(height: 1),
            _buildNotificationToggle(
              icon: Icons.alarm,
              title: 'Payment Reminders',
              subtitle: 'Upcoming payment due date alerts',
              value: _paymentReminders,
              type: 'payment_reminders',
            ),
            const Divider(height: 1),
            _buildNotificationToggle(
              icon: Icons.local_offer,
              title: 'Promotional',
              subtitle: 'New products, offers & announcements',
              value: _promotional,
              type: 'promotional',
            ),
            const Divider(height: 1),
            _buildNotificationToggle(
              icon: Icons.gpp_good,
              title: 'Security Alerts',
              subtitle: 'Login attempts & account activity',
              value: _securityAlerts,
              type: 'security_alerts',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required String type,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: _primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      activeColor: _primaryColor,
      contentPadding: EdgeInsets.zero,
      onChanged: (enabled) => _handleNotificationToggle(type, enabled),
    );
  }

  // ---------------------------------------------------------------------------
  // Logout Button
  // ---------------------------------------------------------------------------

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
