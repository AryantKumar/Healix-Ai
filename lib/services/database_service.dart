import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box _userBox;
  late Box _recordsBox;
  late Box _medicineBox;
  late Box _chatBox;
  late Box _historyBox;
  late Box _settingsBox;
  late Box _emergencyContactsBox;
  late Box _profilesBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox(AppConstants.userBox);
    _recordsBox = await Hive.openBox(AppConstants.recordsBox);
    _medicineBox = await Hive.openBox(AppConstants.medicineBox);
    _chatBox = await Hive.openBox(AppConstants.chatBox);
    _historyBox = await Hive.openBox(AppConstants.historyBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _emergencyContactsBox = await Hive.openBox(AppConstants.emergencyContactsBox);
    _profilesBox = await Hive.openBox(AppConstants.profilesBox);

    // Migrate: if there's an existing profile but not in profiles_box, add it
    final existingProfile = getUserProfile();
    if (existingProfile != null) {
      final id = existingProfile['id'] as String? ?? '';
      if (id.isNotEmpty && !_profilesBox.containsKey(id)) {
        await _profilesBox.put(id, existingProfile);
        await _settingsBox.put(AppConstants.keyActiveProfileId, id);
      }
    }
  }

  // Settings
  bool get isOnboardingDone =>
      _settingsBox.get(AppConstants.keyOnboardingDone, defaultValue: false);

  Future<void> setOnboardingDone(bool value) =>
      _settingsBox.put(AppConstants.keyOnboardingDone, value);

  // Active Profile ID
  String? getActiveProfileId() =>
      _settingsBox.get(AppConstants.keyActiveProfileId);

  Future<void> setActiveProfileId(String id) =>
      _settingsBox.put(AppConstants.keyActiveProfileId, id);

  // User Profile (current active)
  Map<String, dynamic>? getUserProfile() {
    final data = _settingsBox.get(AppConstants.keyUserProfile);
    if (data == null) return null;
    return Map<String, dynamic>.from(jsonDecode(jsonEncode(data)));
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _settingsBox.put(AppConstants.keyUserProfile, profile);
    // Also save/update in profiles box
    final id = profile['id'] as String? ?? '';
    if (id.isNotEmpty) {
      await _profilesBox.put(id, profile);
      await _settingsBox.put(AppConstants.keyActiveProfileId, id);
    }
  }

  // All Profiles
  List<Map<String, dynamic>> getAllProfiles() {
    return _profilesBox.values
        .map((e) => Map<String, dynamic>.from(jsonDecode(jsonEncode(e))))
        .toList();
  }

  Future<void> deleteProfile(String id) async {
    await _profilesBox.delete(id);
    // If this was the active profile, clear it
    if (getActiveProfileId() == id) {
      await _settingsBox.delete(AppConstants.keyActiveProfileId);
      await _settingsBox.delete(AppConstants.keyUserProfile);
    }
  }

  Future<void> switchToProfile(String id) async {
    final data = _profilesBox.get(id);
    if (data != null) {
      final profile = Map<String, dynamic>.from(jsonDecode(jsonEncode(data)));
      await _settingsBox.put(AppConstants.keyUserProfile, profile);
      await _settingsBox.put(AppConstants.keyActiveProfileId, id);
    }
  }

  // Health Records
  List<Map<String, dynamic>> getRecords() {
    return _recordsBox.values
        .map((e) => Map<String, dynamic>.from(jsonDecode(jsonEncode(e))))
        .toList();
  }

  Future<void> addRecord(Map<String, dynamic> record) =>
      _recordsBox.put(record['id'], record);

  Future<void> deleteRecord(String id) => _recordsBox.delete(id);

  // Medicine
  List<Map<String, dynamic>> getMedicines() {
    return _medicineBox.values
        .map((e) => Map<String, dynamic>.from(jsonDecode(jsonEncode(e))))
        .toList();
  }

  Future<void> addMedicine(Map<String, dynamic> medicine) =>
      _medicineBox.put(medicine['id'], medicine);

  Future<void> updateMedicine(String id, Map<String, dynamic> medicine) =>
      _medicineBox.put(id, medicine);

  Future<void> deleteMedicine(String id) => _medicineBox.delete(id);

  // Chat Messages
  List<Map<String, dynamic>> getChatMessages() {
    return _chatBox.values
        .map((e) => Map<String, dynamic>.from(jsonDecode(jsonEncode(e))))
        .toList();
  }

  Future<void> addChatMessage(Map<String, dynamic> message) =>
      _chatBox.put(message['id'], message);

  Future<void> clearChat() => _chatBox.clear();

  // Health History
  List<Map<String, dynamic>> getHealthHistory() {
    return _historyBox.values
        .map((e) => Map<String, dynamic>.from(jsonDecode(jsonEncode(e))))
        .toList();
  }

  Future<void> addHealthEvent(Map<String, dynamic> event) =>
      _historyBox.put(event['id'], event);

  Future<void> deleteHealthEvent(String id) => _historyBox.delete(id);

  // Emergency Contacts
  List<Map<String, dynamic>> getEmergencyContacts() {
    return _emergencyContactsBox.values
        .map((e) => Map<String, dynamic>.from(jsonDecode(jsonEncode(e))))
        .toList();
  }

  Future<void> addEmergencyContact(Map<String, dynamic> contact) =>
      _emergencyContactsBox.put(contact['id'], contact);

  Future<void> deleteEmergencyContact(String id) =>
      _emergencyContactsBox.delete(id);
}
