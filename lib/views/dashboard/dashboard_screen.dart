import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_card.dart';
import '../chat/chat_screen.dart';
import '../hospital/hospital_finder_screen.dart';
import '../records/records_screen.dart';
import '../history/history_screen.dart';
import '../medicine/medicine_screen.dart';
import '../emergency/emergency_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const ChatScreen(),
    const RecordsScreen(),
    const MedicineScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request location permission
    LocationPermission locationPerm = await Geolocator.checkPermission();
    if (locationPerm == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    // Request notification permission
    await ph.Permission.notification.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.glassBorder, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _buildNavItem(1, Icons.chat_rounded, Icons.chat_outlined, 'AI Chat'),
                _buildNavItem(2, Icons.folder_rounded, Icons.folder_outlined, 'Records'),
                _buildNavItem(3, Icons.medication_rounded, Icons.medication_outlined, 'Medicine'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final db = DatabaseService();
    final data = db.getUserProfile();
    if (data != null) {
      setState(() => _profile = UserProfile.fromJson(data));
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Greeting
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()} 👋',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profile?.name ?? 'User',
                        style: AppTypography.displayMedium,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                    if (mounted) _loadProfile();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        (_profile?.name.isNotEmpty == true)
                            ? _profile!.name[0].toUpperCase()
                            : 'U',
                        style: AppTypography.headlineMedium
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: 28),

            // Quick Health Summary
            if (_profile != null && _profile!.height > 0 && _profile!.weight > 0)
              GlassCard(
                gradientColors: AppColors.primaryGradient,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Health Summary',
                              style: AppTypography.titleMedium),
                          const SizedBox(height: 12),
                          _buildHealthStat('BMI',
                              _profile!.bmi.toStringAsFixed(1)),
                          const SizedBox(height: 6),
                          _buildHealthStat('Status', _profile!.bmiCategory),
                          const SizedBox(height: 6),
                          _buildHealthStat(
                              'Blood', _profile!.bloodGroup),
                        ],
                      ),
                    ),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _profile!.bmi.toStringAsFixed(1),
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quick Actions', style: AppTypography.headlineMedium),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/hospital-search'),
                  icon: Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                  label: Text('Search', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
              children: [
                _buildFeatureCard(
                  icon: Icons.chat_rounded,
                  title: 'AI Chat',
                  subtitle: 'Symptom analysis',
                  colors: AppColors.chatGradient,
                  onTap: () => _navigateTo(const ChatScreen()),
                  delay: 400,
                ),
                _buildFeatureCard(
                  icon: Icons.local_hospital_rounded,
                  title: 'Hospitals',
                  subtitle: 'Find nearby',
                  colors: AppColors.hospitalGradient,
                  onTap: () => _navigateTo(const HospitalFinderScreen()),
                  delay: 500,
                ),
                _buildFeatureCard(
                  icon: Icons.history_rounded,
                  title: 'History',
                  subtitle: 'Health timeline',
                  colors: AppColors.historyGradient,
                  onTap: () => _navigateTo(const HistoryScreen()),
                  delay: 600,
                ),
                _buildFeatureCard(
                  icon: Icons.emergency_rounded,
                  title: 'Emergency',
                  subtitle: 'Quick help',
                  colors: AppColors.emergencyGradient,
                  onTap: () => _navigateTo(const EmergencyScreen()),
                  delay: 700,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Emergency Button
            GlassCard(
              onTap: () => _navigateTo(const EmergencyScreen()),
              gradientColors: AppColors.emergencyGradient,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.emergency.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.sos_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency Mode',
                            style: AppTypography.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Quick access to hospitals & emergency contacts',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.textTertiary, size: 18),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStat(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: AppTypography.bodySmall),
        Text(value,
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GlassCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLarge),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.bodySmall),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms).slideY(begin: 0.15);
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
