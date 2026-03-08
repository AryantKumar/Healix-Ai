class AppConstants {
  AppConstants._();

  static const String appName = 'Healix AI';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String userBox = 'user_box';
  static const String recordsBox = 'records_box';
  static const String medicineBox = 'medicine_box';
  static const String chatBox = 'chat_box';
  static const String historyBox = 'history_box';
  static const String settingsBox = 'settings_box';
  static const String emergencyContactsBox = 'emergency_contacts_box';
  static const String profilesBox = 'profiles_box';

  // Settings keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserProfile = 'user_profile';
  static const String keyActiveProfileId = 'active_profile_id';

  // API 
  static const String openRouterApiKey = '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';
  static const String placesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';

  // Disclaimer
  static const String medicalDisclaimer =
      'This AI assistant provides general health information only. '
      'It is NOT a substitute for professional medical advice, diagnosis, or treatment. '
      'Always seek the advice of your physician or other qualified health provider '
      'with any questions you may have regarding a medical condition.';

  // Blood groups
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown',
  ];

  // Genders
  static const List<String> genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  // Document types
  static const List<String> documentTypes = [
    'Prescription',
    'Lab Report',
    'X-Ray',
    'Medical Note',
    'Insurance',
    'Other',
  ];

  // Frequency options
  static const List<String> frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'Every 6 hours',
    'Every 8 hours',
    'Every 12 hours',
    'Weekly',
    'As needed',
  ];
}
