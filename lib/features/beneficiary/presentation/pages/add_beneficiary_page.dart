import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/features/beneficiary/domain/entities/beneficiary.dart';
import 'package:fintech_app/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';

class AddBeneficiaryPage extends StatefulWidget {
  const AddBeneficiaryPage({super.key});

  @override
  State<AddBeneficiaryPage> createState() => _AddBeneficiaryPageState();
}

class _AddBeneficiaryPageState extends State<AddBeneficiaryPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountController = TextEditingController();

  String _selectedCountry = 'United States';
  String _selectedFlag = '🇺🇸';
  String _selectedCurrency = 'USD';

  static const _countries = [
    ('United States', '🇺🇸', 'USD'),
    ('United Kingdom', '🇬🇧', 'GBP'),
    ('Germany', '🇩🇪', 'EUR'),
    ('India', '🇮🇳', 'INR'),
    ('Canada', '🇨🇦', 'CAD'),
    ('Australia', '🇦🇺', 'AUD'),
    ('Japan', '🇯🇵', 'JPY'),
    ('UAE', '🇦🇪', 'AED'),
    ('Singapore', '🇸🇬', 'SGD'),
    ('Saudi Arabia', '🇸🇦', 'SAR'),
    ('Brazil', '🇧🇷', 'BRL'),
    ('South Africa', '🇿🇦', 'ZAR'),
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _bankNameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Beneficiary', style: theme.textTheme.headlineMedium),
      ),
      body: BlocListener<BeneficiaryBloc, BeneficiaryState>(
        listenWhen: (prev, curr) =>
            prev.isDuplicateWarning != curr.isDuplicateWarning,
        listener: (context, state) {
          if (state.isDuplicateWarning) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'A beneficiary with this account already exists',
                ),
                backgroundColor: AppColors.warning,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Full Name
                _buildField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'e.g. John Doe',
                  icon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (v.trim().length < 2) return 'Name is too short';
                    if (!RegExp(r'^[a-zA-Z\s\-\.]+$').hasMatch(v)) {
                      return 'Only letters, spaces, hyphens allowed';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.spacing16),

                // Nickname (optional)
                _buildField(
                  controller: _nicknameController,
                  label: 'Nickname (Optional)',
                  hint: 'e.g. Mom, Landlord',
                  icon: Icons.label_outline_rounded,
                ),

                const SizedBox(height: AppTheme.spacing16),

                // Country selector
                _buildDropdown(context, isDark),

                const SizedBox(height: AppTheme.spacing16),

                // Bank Name
                _buildField(
                  controller: _bankNameController,
                  label: 'Bank Name',
                  hint: 'e.g. Chase, HSBC, SBI',
                  icon: Icons.account_balance_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Bank name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.spacing16),

                // Account Number
                _buildField(
                  controller: _accountController,
                  label: 'Account Number / IBAN',
                  hint: 'e.g. GB29NWBK60161331926819',
                  icon: Icons.credit_card_rounded,
                  keyboardType: TextInputType.text,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Account number is required';
                    }
                    if (v.trim().length < 6) {
                      return 'Account number seems too short';
                    }
                    if (v.trim().length > 34) {
                      return 'Account number seems too long';
                    }
                    // Basic IBAN check: if it starts with 2 letters, validate format
                    if (RegExp(r'^[A-Z]{2}').hasMatch(v.toUpperCase())) {
                      if (!RegExp(
                        r'^[A-Z]{2}\d{2}[A-Z0-9]{4,30}$',
                      ).hasMatch(v.replaceAll(' ', '').toUpperCase())) {
                        return 'Invalid IBAN format';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.spacing32),

                // Submit button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Add Beneficiary'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Country',
        prefixIconConstraints: BoxConstraints(minWidth: 44),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountry,
          isDense: true,
          isExpanded: true,
          items: _countries.map((c) {
            return DropdownMenuItem(
              value: c.$1,
              child: Row(
                children: [
                  Text(c.$2, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(c.$1, style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 6),
                  Text(
                    c.$3,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val == null) return;
            final match = _countries.firstWhere((c) => c.$1 == val);
            setState(() {
              _selectedCountry = match.$1;
              _selectedFlag = match.$2;
              _selectedCurrency = match.$3;
            });
          },
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final beneficiary = Beneficiary(
      id: const Uuid().v4(),
      fullName: _fullNameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      bankName: _bankNameController.text.trim(),
      accountNumber: _accountController.text.replaceAll(' ', '').trim(),
      country: _selectedCountry,
      countryFlag: _selectedFlag,
      currency: _selectedCurrency,
      createdAt: DateTime.now(),
    );

    context.read<BeneficiaryBloc>().add(BeneficiaryAdded(beneficiary));

    Navigator.pop(context);
  }
}
