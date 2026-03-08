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

  Future<void> initialize() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox(AppConstants.userBox);
    _recordsBox = await Hive.openBox(AppConstants.recordsBox);
    _medicineBox = await Hive.openBox(AppConstants.medicineBox);
    _chatBox = await Hive.openBox(AppConstants.chatBox);
    _historyBox = await Hive.openBox(AppConstants.historyBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _emergencyContactsBox = await Hive.openBox(AppConstants.emergencyContactsBox);
  }

  // Settings
  bool get isOnboardingDone =>
      _settingsBox.get(AppConstants.keyOnboardingDone, defaultValue: false);

  Future<void> setOnboardingDone(bool value) =>
      _settingsBox.put(AppConstants.keyOnboardingDone, value);

  // User Profile
  Map<String, dynamic>? getUserProfile() {
    final data = _settingsBox.get(AppConstants.keyUserProfile);
    if (data == null) return null;
    return Map<String, dynamic>.from(jsonDecode(jsonEncode(data)));
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) =>
      _settingsBox.put(AppConstants.keyUserProfile, profile);

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
