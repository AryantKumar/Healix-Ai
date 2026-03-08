import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';

class ProfileTypeScreen extends StatefulWidget {
  const ProfileTypeScreen({super.key});

  @override
  State<ProfileTypeScreen> createState() => _ProfileTypeScreenState();
}

class _ProfileTypeScreenState extends State<ProfileTypeScreen> {
  bool? _isForSelf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Who is this\nprofile for?',
                style: AppTypography.displayLarge,
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),

              const SizedBox(height: 12),

              Text(
                'We\'ll personalize the experience based on your choice.',
                style: AppTypography.bodyMedium,
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              const SizedBox(height: 48),

              // For Myself
              _buildOption(
                icon: Icons.person_rounded,
                title: 'For Myself',
                subtitle: 'Track my own health and symptoms',
                colors: AppColors.primaryGradient,
                isSelected: _isForSelf == true,
                onTap: () => setState(() => _isForSelf = true),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // For Someone Else
              _buildOption(
                icon: Icons.people_rounded,
                title: 'For Someone Else',
                subtitle: 'Manage health of a family member or dependent',
                colors: [AppColors.accent, AppColors.accentLight],
                isSelected: _isForSelf == false,
                onTap: () => setState(() => _isForSelf = false),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1),

              const Spacer(),

              if (_isForSelf != null)
                GradientButton(
                  text: 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/bio-info',
                      arguments: _isForSelf,
                    );
                  },
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      gradientColors: isSelected ? colors : null,
      color: isSelected ? null : AppColors.surfaceCard,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headlineSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodySmall),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? colors.first : Colors.transparent,
              border: Border.all(
                color: isSelected ? colors.first : AppColors.textTertiary,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}
