import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gradient_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.health_and_safety_rounded,
      colors: AppColors.primaryGradient,
      title: 'AI Health Assistant',
      subtitle:
          'Get instant health guidance powered by AI. Describe your symptoms and receive informed analysis.',
    ),
    _OnboardingPage(
      icon: Icons.local_hospital_rounded,
      colors: AppColors.hospitalGradient,
      title: 'Find Nearby Hospitals',
      subtitle:
          'Locate healthcare facilities near you with ratings, directions, and contact information.',
    ),
    _OnboardingPage(
      icon: Icons.folder_special_rounded,
      colors: AppColors.recordsGradient,
      title: 'Medical Records',
      subtitle:
          'Securely store prescriptions, lab reports, and X-rays. Your health data stays private.',
    ),
    _OnboardingPage(
      icon: Icons.medication_rounded,
      colors: AppColors.medicineGradient,
      title: 'Medicine Reminders',
      subtitle:
          'Never miss a dose. Set smart reminders for all your medications.',
    ),
    _OnboardingPage(
      icon: Icons.wifi_off_rounded,
      colors: [AppColors.accent, AppColors.accentLight],
      title: 'Works Offline',
      subtitle:
          'Core features work without internet. Your health data is always accessible.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/profile-type'),
                child: Text(
                  'Skip',
                  style: AppTypography.labelLarge
                      .copyWith(color: AppColors.textTertiary),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: page.colors,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: page.colors.first.withOpacity(0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(page.icon, size: 50, color: Colors.white),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: 500.ms,
                              curve: Curves.easeOutBack,
                            )
                            .fadeIn(),

                        const SizedBox(height: 48),

                        Text(
                          page.title,
                          style: AppTypography.displayMedium,
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 500.ms)
                            .slideY(begin: 0.2),

                        const SizedBox(height: 16),

                        Text(
                          page.subtitle,
                          style: AppTypography.bodyMedium.copyWith(height: 1.6),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 500.ms)
                            .slideY(begin: 0.2),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? AppColors.primary
                        : AppColors.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GradientButton(
                text: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                icon: _currentPage == _pages.length - 1
                    ? Icons.arrow_forward_rounded
                    : null,
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushReplacementNamed(context, '/profile-type');
                  }
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final List<Color> colors;
  final String title;
  final String subtitle;

  _OnboardingPage({
    required this.icon,
    required this.colors,
    required this.title,
    required this.subtitle,
  });
}
