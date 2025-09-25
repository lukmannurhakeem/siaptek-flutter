import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/authenticate_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_snackbar.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // Dropdown values
  String? _selectedUserGroup;
  String? _selectedDivisionId;

  // Checkbox values
  bool _passwordReset = false;
  bool _isAccountLocked = false;

  // Predefined options (you may want to fetch these from API)
  final List<String> _userGroups = ['inspector', 'admin', 'manager', 'technician', 'viewer'];

  final List<Map<String, String>> _divisions = [
    {'id': '1baf91e0-22bb-4c3f-b04b-0b6a0eef6be3', 'name': 'Main Division'},
    // Add more divisions as needed
  ];

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register User',
          style: context.topology.textTheme.titleLarge?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
      ),
      body: SingleChildScrollView(
        padding: context.paddingAll,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              context.vM,

              _buildFormField('First Name', _firstNameController, isRequired: true),
              context.vS,

              _buildFormField('Last Name', _lastNameController, isRequired: true),
              context.vS,

              _buildFormField('Username', _usernameController, isRequired: true),
              context.vS,

              _buildFormField(
                'Email',
                _emailController,
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              context.vL,

              // Account Security Section
              _buildSectionHeader('Account Security'),
              context.vM,

              _buildPasswordField(
                'Password',
                _passwordController,
                _obscurePassword,
                () => setState(() => _obscurePassword = !_obscurePassword),
                isRequired: true,
              ),
              context.vS,

              _buildPasswordField(
                'Confirm Password',
                _confirmPasswordController,
                _obscureConfirmPassword,
                () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                isRequired: true,
                validator: _validateConfirmPassword,
              ),
              context.vL,

              // Division & Access Section
              _buildSectionHeader('Division & Access'),
              context.vM,

              _buildDropdownField(
                'Division',
                _selectedDivisionId,
                _divisions
                    .map(
                      (div) =>
                          DropdownMenuItem<String>(value: div['id'], child: Text(div['name']!)),
                    )
                    .toList(),
                (value) => setState(() => _selectedDivisionId = value),
                isRequired: true,
              ),
              context.vS,

              _buildDropdownField(
                'User Group',
                _selectedUserGroup,
                _userGroups
                    .map(
                      (group) =>
                          DropdownMenuItem<String>(value: group, child: Text(group.toUpperCase())),
                    )
                    .toList(),
                (value) => setState(() => _selectedUserGroup = value),
                isRequired: true,
              ),
              context.vS,

              _buildFormField('Access Code', _codeController, hint: 'Enter verification code'),
              context.vL,

              // Account Settings Section
              _buildSectionHeader('Account Settings'),
              context.vM,

              CheckboxListTile(
                title: Text('Require Password Reset on First Login'),
                subtitle: Text('User must change password when first logging in'),
                value: _passwordReset,
                onChanged: (value) => setState(() => _passwordReset = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              CheckboxListTile(
                title: Text('Lock Account'),
                subtitle: Text('Account will be locked and cannot login'),
                value: _isAccountLocked,
                onChanged: (value) => setState(() => _isAccountLocked = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              context.vXl,

              // Submit Button
              CommonButton(
                onPressed: _isLoading ? null : _handleSubmit,
                text: _isLoading ? 'Creating Account...' : 'Create Account',
              ),

              context.vM,

              // Back to Login
              TextButton(
                onPressed: () => NavigationService().goBack(),
                child: Text(
                  'Already have an account? Back to Login',
                  style: TextStyle(color: context.colors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: context.topology.textTheme.titleMedium?.copyWith(
        color: context.colors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
        ),
        context.vXs,
        CommonTextField(
          controller: controller,
          keyboardType: keyboardType,
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          hintText: hint,
          validator:
              validator ??
              (isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle, {
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
        ),
        context.vXs,
        CommonTextField(
          controller: controller,
          obscureText: obscure,
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: onToggle,
          ),
          validator:
              validator ??
              (isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  }
                  : null),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    void Function(String?) onChanged, {
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
        ),
        context.vXs,
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registerData = _buildRegisterData();

      // Get the AuthenticateProvider
      final authProvider = Provider.of<AuthenticateProvider>(context, listen: false);

      // Call the correct registerUser method
      final success = await authProvider.registerUser(context, registerData);

      if (success) {
        CommonSnackbar.showSuccess(context, 'User registered successfully!');
        NavigationService().goBack();
      }
    } catch (e) {
      CommonSnackbar.showError(context, 'Failed to register user: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _buildRegisterData() {
    return {
      "email": _emailController.text.trim(),
      "password": _passwordController.text,
      "username": _usernameController.text.trim(),
      "divisionid": _selectedDivisionId,
      "code": _codeController.text.trim(),
      "passwordReset": _passwordReset.toString(),
      "is_account_locked": _isAccountLocked,
      "user_group": _selectedUserGroup,
      "first_name": _firstNameController.text.trim(),
      "last_name": _lastNameController.text.trim(),
    };
  }
}
