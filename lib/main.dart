import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'views/splash/splash_screen.dart';
import 'views/onboarding/welcome_screen.dart';
import 'views/onboarding/profile_type_screen.dart';
import 'views/onboarding/bio_info_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/hospital/hospital_search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF111827),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  await DatabaseService().initialize();
  await NotificationService().initialize();

  runApp(const HealixApp());
}

class HealixApp extends StatelessWidget {
  const HealixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healix AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/profile-type': (_) => const ProfileTypeScreen(),
        '/bio-info': (_) => const BioInfoScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/hospital-search': (_) => const HospitalSearchScreen(),
      },
    );
  }
}
