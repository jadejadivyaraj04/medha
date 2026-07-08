// lib/app/routes.dart
// ignore_for_file: constant_identifier_names

abstract class Routes {
  Routes._();

  // Onboarding
  static const SPLASH = '/splash';
  static const VALUE_INTRO = '/value-intro';
  static const LANGUAGE_SELECT = '/language-select';
  static const PERMISSION_SLIDE = '/permission-slide';
  static const PERMISSION_SUMMARY = '/permission-summary';
  static const CREATE_PROFILE = '/create-profile';

  // Main shell
  static const HOME = '/home';
  static const MEDICINES = '/medicines';
  static const REMINDERS = '/reminders';
  static const PROFILE = '/profile';

  // Scan & parse
  static const SCAN = '/scan';
  static const AI_PARSING = '/ai-parsing';
  static const VERIFY_EDIT = '/verify-edit';
  static const SCHEDULE_SUMMARY = '/schedule-summary';

  // Medicines
  static const MEDICINE_DETAILS = '/medicine-details';

  // Reminders
  static const REMINDER_ALERT = '/reminder-alert';
  static const ADHERENCE_HISTORY = '/adherence-history';

  // Settings
  static const SETTINGS = '/settings';

  // Interactions (Phase 2)
  static const INTERACTION_ALERT = '/interaction-alert';

  // Voice doubt (offline Gemma audio)
  static const DOUBT_QUERY = '/doubt-query';

  // Phase 3 — caregiver + doctor export
  static const CAREGIVER = '/caregiver';
  static const DOCTOR_EXPORT = '/doctor-export';
}
