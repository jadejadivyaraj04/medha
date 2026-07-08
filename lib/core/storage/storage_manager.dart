// lib/core/storage/storage_manager.dart

import 'package:get_storage/get_storage.dart';

class StorageManager {
  StorageManager._();

  static final GetStorage _box = GetStorage();

  static const String _activeProfileKey = 'active_profile_id';
  static const String _localeKey = 'locale';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _profileDataPrefix = 'profile_data_';
  static const String _permissionStatusKey = 'permission_status';
  static const String _medicinesPrefix = 'medicines_';
  static const String _doseLogsPrefix = 'dose_logs_';
  static const String _reminderLogsPrefix = 'reminder_logs_';
  static const String _remindersScheduledPrefix = 'reminders_scheduled_';
  static const String _profileIdsKey = 'profile_ids';
  static const String _appSettingsKey = 'app_settings';
  static const String _caregiverPrefix = 'caregiver_';
  static const String _ragCorpusVersionKey = 'rag_corpus_version';
  static const String _ragVectorIndexedKey = 'rag_vector_indexed';

  static Future<void> init() async {
    await GetStorage.init();
  }

  static String? getActiveProfile() => _box.read<String>(_activeProfileKey);

  static Future<void> saveActiveProfile(String id) async {
    await _box.write(_activeProfileKey, id);
  }

  static bool get hasProfile {
    final id = getActiveProfile();
    return id != null && id.isNotEmpty;
  }

  static String? getProfileName() {
    final id = getActiveProfile();
    if (id == null) {
      return null;
    }
    final data = getProfileData(id);
    return data?['name'] as String?;
  }

  static Future<void> saveProfileData(
    String id,
    Map<String, dynamic> json,
  ) async {
    await _box.write('$_profileDataPrefix$id', json);
  }

  static Map<String, dynamic>? getProfileData(String id) {
    final data = _box.read<Map<dynamic, dynamic>>('$_profileDataPrefix$id');
    if (data == null) {
      return null;
    }
    return Map<String, dynamic>.from(data);
  }

  static String? getLocale() => _box.read<String>(_localeKey);

  static Future<void> saveLocale(String code) async {
    await _box.write(_localeKey, code);
  }

  static bool get isOnboardingComplete =>
      _box.read<bool>(_onboardingCompleteKey) ?? false;

  static Future<void> setOnboardingComplete({required bool value}) async {
    await _box.write(_onboardingCompleteKey, value);
  }

  static Map<String, String> getPermissionStatuses() {
    final raw = _box.read<Map<dynamic, dynamic>>(_permissionStatusKey);
    if (raw == null) {
      return {};
    }
    return raw.map((key, value) => MapEntry(key.toString(), value.toString()));
  }

  static String getPermissionStatus(String permissionId) {
    return getPermissionStatuses()[permissionId] ?? 'pending';
  }

  static Future<void> savePermissionStatus(
    String permissionId,
    String status,
  ) async {
    final current = getPermissionStatuses();
    current[permissionId] = status;
    await _box.write(_permissionStatusKey, current);
  }

  static List<Map<String, dynamic>> getMedicinesForProfile(String profileId) {
    final raw = _box.read<List<dynamic>>('$_medicinesPrefix$profileId');
    if (raw == null) {
      return [];
    }
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> saveMedicinesForProfile(
    String profileId,
    List<Map<String, dynamic>> medicines,
  ) async {
    await _box.write('$_medicinesPrefix$profileId', medicines);
  }

  static List<Map<String, dynamic>> getDoseLogsForProfile(String profileId) {
    final raw = _box.read<List<dynamic>>('$_doseLogsPrefix$profileId');
    if (raw == null) {
      return [];
    }
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> saveDoseLogsForProfile(
    String profileId,
    List<Map<String, dynamic>> logs,
  ) async {
    await _box.write('$_doseLogsPrefix$profileId', logs);
  }

  static bool areRemindersScheduled(String profileId) {
    return _box.read<bool>('$_remindersScheduledPrefix$profileId') ?? false;
  }

  static Future<void> setRemindersScheduled(
    String profileId, {
    required bool value,
  }) async {
    await _box.write('$_remindersScheduledPrefix$profileId', value);
  }

  static List<Map<String, dynamic>> getReminderLogsForProfile(
    String profileId,
  ) {
    final raw = _box.read<List<dynamic>>('$_reminderLogsPrefix$profileId');
    if (raw == null) {
      return [];
    }
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> appendReminderLog(
    String profileId,
    Map<String, dynamic> log,
  ) async {
    final current = getReminderLogsForProfile(profileId);
    current.add(log);
    await _box.write('$_reminderLogsPrefix$profileId', current);
  }

  static List<String> getProfileIds() {
    final raw = _box.read<List<dynamic>>(_profileIdsKey);
    if (raw == null) {
      final active = getActiveProfile();
      return active != null && active.isNotEmpty ? [active] : [];
    }
    return raw.map((id) => id.toString()).where((id) => id.isNotEmpty).toList();
  }

  static Future<void> registerProfileId(String id) async {
    final current = getProfileIds().toSet();
    current.add(id);
    await _box.write(_profileIdsKey, current.toList());
  }

  static Map<String, dynamic> getAppSettings() {
    final raw = _box.read<Map<dynamic, dynamic>>(_appSettingsKey);
    if (raw == null) {
      return {};
    }
    return Map<String, dynamic>.from(raw);
  }

  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await _box.write(_appSettingsKey, settings);
  }

  static Map<String, dynamic>? getCaregiverForProfile(String profileId) {
    final data = _box.read<Map<dynamic, dynamic>>('$_caregiverPrefix$profileId');
    if (data == null) {
      return null;
    }
    return Map<String, dynamic>.from(data);
  }

  static Future<void> saveCaregiverForProfile(
    String profileId,
    Map<String, dynamic> json,
  ) async {
    await _box.write('$_caregiverPrefix$profileId', json);
  }

  static Future<void> deleteCaregiverForProfile(String profileId) async {
    await _box.remove('$_caregiverPrefix$profileId');
  }

  static String? getRagCorpusVersion() => _box.read<String>(_ragCorpusVersionKey);

  static Future<void> saveRagCorpusVersion(String version) async {
    await _box.write(_ragCorpusVersionKey, version);
  }

  static bool get isRagVectorIndexed =>
      _box.read<bool>(_ragVectorIndexedKey) ?? false;

  static Future<void> setRagVectorIndexed({required bool value}) async {
    await _box.write(_ragVectorIndexedKey, value);
  }

  static Future<void> clearAll() async {
    await _box.erase();
  }
}
