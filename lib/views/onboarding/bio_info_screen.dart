import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';
import '../../widgets/gradient_button.dart';

class BioInfoScreen extends StatefulWidget {
  const BioInfoScreen({super.key});

  @override
  State<BioInfoScreen> createState() => _BioInfoScreenState();
}

class _BioInfoScreenState extends State<BioInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();

  String _selectedGender = AppConstants.genders.first;
  String _selectedBloodGroup = AppConstants.bloodGroups.first;
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isForSelf =
        ModalRoute.of(context)?.settings.arguments as bool? ?? true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(child: _buildProgressBar(0)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildProgressBar(1)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildProgressBar(2)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildStep(isForSelf),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.glassBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text('Back',
                            style: AppTypography.button
                                .copyWith(color: AppColors.textSecondary)),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: GradientButton(
                      text: _currentStep == 2 ? 'Complete Setup' : 'Next',
                      icon: _currentStep == 2
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_rounded,
                      isLoading: _isLoading,
                      onPressed: _handleNext,
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

  Widget _buildProgressBar(int step) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: _currentStep >= step
            ? AppColors.primary
            : AppColors.surfaceLight,
      ),
    );
  }

  Widget _buildStep(bool isForSelf) {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep(isForSelf);
      case 1:
        return _buildPhysicalInfoStep();
      case 2:
        return _buildMedicalInfoStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep(bool isForSelf) {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isForSelf ? 'Tell us about\nyourself' : 'Who are you\ncaring for?',
          style: AppTypography.displayMedium,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Basic information to personalize your health experience',
          style: AppTypography.bodyMedium,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: isForSelf ? 'Your name' : 'Their name',
          icon: Icons.person_outline_rounded,
          validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _ageController,
          label: 'Age',
          hint: 'Enter age',
          icon: Icons.cake_outlined,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v?.isEmpty == true) return 'Age is required';
            final age = int.tryParse(v!);
            if (age == null || age < 0 || age > 150) return 'Enter a valid age';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Gender',
          icon: Icons.wc_rounded,
          value: _selectedGender,
          items: AppConstants.genders,
          onChanged: (v) => setState(() => _selectedGender = v!),
        ),
      ],
    );
  }

  Widget _buildPhysicalInfoStep() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Physical\nDetails', style: AppTypography.displayMedium)
            .animate()
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text('Help us calculate health metrics',
                style: AppTypography.bodyMedium)
            .animate()
            .fadeIn(delay: 100.ms),
        const SizedBox(height: 32),
        _buildDropdown(
          label: 'Blood Group',
          icon: Icons.bloodtype_rounded,
          value: _selectedBloodGroup,
          items: AppConstants.bloodGroups,
          onChanged: (v) => setState(() => _selectedBloodGroup = v!),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _heightController,
                label: 'Height (cm)',
                hint: '170',
                icon: Icons.height_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                hint: '70',
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicalInfoStep() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Medical\nHistory', style: AppTypography.displayMedium)
            .animate()
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text('Optional but helps provide better guidance',
                style: AppTypography.bodyMedium)
            .animate()
            .fadeIn(delay: 100.ms),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _allergiesController,
          label: 'Allergies',
          hint: 'e.g., Peanuts, Penicillin (comma separated)',
          icon: Icons.warning_amber_rounded,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _conditionsController,
          label: 'Chronic Conditions',
          hint: 'e.g., Diabetes, Asthma (comma separated)',
          icon: Icons.medical_information_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your health data is stored locally on your device and never shared.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceLight,
              style: AppTypography.bodyLarge,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textTertiary),
              items: items
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _handleNext() {
    if (_currentStep < 2) {
      if (_currentStep == 0 && !_formKey.currentState!.validate()) return;
      setState(() => _currentStep++);
    } else {
      _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final isForSelf =
          ModalRoute.of(context)?.settings.arguments as bool? ?? true;

      final allergies = _allergiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final conditions = _conditionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final profile = UserProfile(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 0,
        gender: _selectedGender,
        bloodGroup: _selectedBloodGroup,
        height: double.tryParse(_heightController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0,
        allergies: allergies,
        chronicConditions: conditions,
        isForSelf: isForSelf,
      );

      final db = DatabaseService();
      await db.saveUserProfile(profile.toJson());
      await db.setOnboardingDone(true);
      await db.setActiveProfileId(profile.id);

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard',
          (route) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
