import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';
import '../../widgets/gradient_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isEditing = false;
  
  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'A+';
  
  final List<String> _allergies = [];
  final List<String> _conditions = [];

  final _newAllergyController = TextEditingController();
  final _newConditionController = TextEditingController();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  void _loadProfile() {
    final db = DatabaseService();
    final data = db.getUserProfile();
    if (data != null) {
      final profile = UserProfile.fromJson(data);
      setState(() {
        _profile = profile;
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _heightController.text = profile.height.toString();
        _weightController.text = profile.weight.toString();
        if (_genders.contains(profile.gender)) _selectedGender = profile.gender;
        if (_bloodGroups.contains(profile.bloodGroup.toUpperCase())) _selectedBloodGroup = profile.bloodGroup.toUpperCase();
        _allergies.clear();
        _allergies.addAll(profile.allergies);
        _conditions.clear();
        _conditions.addAll(profile.chronicConditions);
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _newAllergyController.dispose();
    _newConditionController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final age = int.tryParse(_ageController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0.0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;

    if (_nameController.text.isEmpty || age == 0 || height == 0 || weight == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please fill all basic basic fields properly.'), backgroundColor: AppColors.error),
      );
      return;
    }

    final newProfile = UserProfile(
      id: _profile?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      age: age,
      gender: _selectedGender,
      bloodGroup: _selectedBloodGroup,
      height: height,
      weight: weight,
      allergies: List.from(_allergies),
      chronicConditions: List.from(_conditions),
      createdAt: _profile?.createdAt,
    );

    await DatabaseService().saveUserProfile(newProfile.toJson());
    
    setState(() {
      _profile = newProfile;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Profile updated successfully'), backgroundColor: AppColors.success),
      );
    }
  }

  void _addAllergy() {
    final text = _newAllergyController.text.trim();
    if (text.isNotEmpty && !_allergies.contains(text)) {
      setState(() {
        _allergies.add(text);
        _newAllergyController.clear();
      });
    }
  }

  void _addCondition() {
    final text = _newConditionController.text.trim();
    if (text.isNotEmpty && !_conditions.contains(text)) {
      setState(() {
        _conditions.add(text);
        _newConditionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded, color: AppColors.primary),
            onPressed: () {
              if (_isEditing) {
                // Cancel edit - reload from db
                _loadProfile();
                setState(() => _isEditing = false);
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.check_rounded, color: AppColors.success),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _profile!.name.isNotEmpty ? _profile!.name[0].toUpperCase() : 'U',
                    style: AppTypography.displayMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 16),
            _buildBasicInfoForm(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Medical Conditions'),
            const SizedBox(height: 16),
            _buildListEditor('Chronic Conditions', _conditions, _newConditionController, _addCondition, Icons.health_and_safety_rounded),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Allergies'),
            const SizedBox(height: 16),
            _buildListEditor('Known Allergies', _allergies, _newAllergyController, _addAllergy, Icons.warning_amber_rounded),
            
            const SizedBox(height: 48),
            
            if (_isEditing)
              GradientButton(
                text: 'Save Changes',
                onPressed: _saveProfile,
                colors: AppColors.recordsGradient,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
    );
  }

  Widget _buildBasicInfoForm() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFieldRow('Full Name', _profile!.name, _nameController, isNumber: false),
          const Divider(color: AppColors.glassBorder, height: 24),
          _buildFieldRow('Age', '${_profile!.age} years', _ageController, isNumber: true),
          const Divider(color: AppColors.glassBorder, height: 24),
          _buildDropdownRow('Gender', _profile!.gender, _selectedGender, _genders, (v) => setState(() => _selectedGender = v!)),
          const Divider(color: AppColors.glassBorder, height: 24),
          _buildDropdownRow('Blood Group', _profile!.bloodGroup, _selectedBloodGroup, _bloodGroups, (v) => setState(() => _selectedBloodGroup = v!)),
          const Divider(color: AppColors.glassBorder, height: 24),
          _buildFieldRow('Height (cm)', '${_profile!.height} cm', _heightController, isNumber: true),
          const Divider(color: AppColors.glassBorder, height: 24),
          _buildFieldRow('Weight (kg)', '${_profile!.weight} kg', _weightController, isNumber: true),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String displayValue, TextEditingController controller, {required bool isNumber}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _isEditing
              ? TextField(
                  controller: controller,
                  keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.name,
                  style: AppTypography.bodyLarge,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.glassBorder),
                    ),
                  ),
                )
              : Text(displayValue, style: AppTypography.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildDropdownRow(String label, String displayValue, String currentValue, List<String> items, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _isEditing
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentValue,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceCard,
                      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTypography.bodyLarge))).toList(),
                      onChanged: onChanged,
                    ),
                  ),
                )
              : Text(displayValue, style: AppTypography.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildListEditor(String hint, List<String> items, TextEditingController controller, VoidCallback onAdd, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            Text('None reported', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary, fontStyle: FontStyle.italic))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) => Chip(
                label: Text(item, style: AppTypography.bodyMedium),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                deleteIcon: _isEditing ? const Icon(Icons.close_rounded, size: 16) : null,
                onDeleted: _isEditing ? () {
                  setState(() => items.remove(item));
                } : null,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              )).toList(),
            ),
            
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Add new...',
                      prefixIcon: Icon(icon, size: 20, color: AppColors.textTertiary),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                    onSubmitted: (_) => onAdd(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add_circle_rounded, color: AppColors.primary),
                  onPressed: onAdd,
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
