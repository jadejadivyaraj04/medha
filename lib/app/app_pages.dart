// lib/app/app_pages.dart

import 'package:get/get.dart';

import '../ui/ai_parsing/bindings/ai_parsing_binding.dart';
import '../ui/ai_parsing/view/ai_parsing_page.dart';
import '../ui/adherence_history/bindings/adherence_history_binding.dart';
import '../ui/adherence_history/view/adherence_history_page.dart';
import '../ui/doubt_query/bindings/doubt_query_binding.dart';
import '../ui/doubt_query/view/doubt_query_page.dart';
import '../ui/caregiver/bindings/caregiver_binding.dart';
import '../ui/caregiver/view/caregiver_page.dart';
import '../ui/doctor_export/bindings/doctor_export_binding.dart';
import '../ui/doctor_export/view/doctor_export_page.dart';
import '../ui/interactions/bindings/interaction_alert_binding.dart';
import '../ui/interactions/view/interaction_alert_page.dart';
import '../ui/medicine_detail/bindings/medicine_detail_binding.dart';
import '../ui/medicine_detail/view/medicine_detail_page.dart';
import '../ui/onboarding/create_profile/bindings/create_profile_binding.dart';
import '../ui/onboarding/create_profile/view/create_profile_page.dart';
import '../ui/onboarding/language/bindings/language_binding.dart';
import '../ui/onboarding/language/view/language_page.dart';
import '../ui/onboarding/permissions/bindings/permission_slide_binding.dart';
import '../ui/onboarding/permissions/bindings/permission_summary_binding.dart';
import '../ui/onboarding/permissions/view/permission_slide_page.dart';
import '../ui/onboarding/permissions/view/permission_summary_page.dart';
import '../ui/onboarding/splash/bindings/splash_binding.dart';
import '../ui/onboarding/splash/view/splash_page.dart';
import '../ui/onboarding/value_intro/bindings/value_intro_binding.dart';
import '../ui/onboarding/value_intro/view/value_intro_page.dart';
import '../ui/scan/bindings/scan_binding.dart';
import '../ui/scan/view/scan_page.dart';
import '../ui/reminder_alert/bindings/reminder_alert_binding.dart';
import '../ui/reminder_alert/view/reminder_alert_page.dart';
import '../ui/schedule_summary/bindings/schedule_summary_binding.dart';
import '../ui/schedule_summary/view/schedule_summary_page.dart';
import '../ui/settings/bindings/settings_binding.dart';
import '../ui/settings/view/settings_page.dart';
import '../ui/shell/bindings/main_shell_binding.dart';
import '../ui/shell/view/main_shell_page.dart';
import '../ui/verify_edit/bindings/verify_edit_binding.dart';
import '../ui/verify_edit/view/verify_edit_page.dart';
import 'routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.VALUE_INTRO,
      page: () => const ValueIntroPage(),
      binding: ValueIntroBinding(),
    ),
    GetPage(
      name: Routes.LANGUAGE_SELECT,
      page: () => const LanguagePage(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: Routes.PERMISSION_SLIDE,
      page: () => const PermissionSlidePage(),
      binding: PermissionSlideBinding(),
    ),
    GetPage(
      name: Routes.PERMISSION_SUMMARY,
      page: () => const PermissionSummaryPage(),
      binding: PermissionSummaryBinding(),
    ),
    GetPage(
      name: Routes.CREATE_PROFILE,
      page: () => const CreateProfilePage(),
      binding: CreateProfileBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: Routes.MEDICINES,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: Routes.REMINDERS,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: Routes.SCAN,
      page: () => const ScanPage(),
      binding: ScanBinding(),
    ),
    GetPage(
      name: Routes.AI_PARSING,
      page: () => const AiParsingPage(),
      binding: AiParsingBinding(),
    ),
    GetPage(
      name: Routes.VERIFY_EDIT,
      page: () => const VerifyEditPage(),
      binding: VerifyEditBinding(),
    ),
    GetPage(
      name: Routes.SCHEDULE_SUMMARY,
      page: () => const ScheduleSummaryPage(),
      binding: ScheduleSummaryBinding(),
    ),
    GetPage(
      name: Routes.MEDICINE_DETAILS,
      page: () => const MedicineDetailPage(),
      binding: MedicineDetailBinding(),
    ),
    GetPage(
      name: Routes.REMINDER_ALERT,
      page: () => const ReminderAlertPage(),
      binding: ReminderAlertBinding(),
    ),
    GetPage(
      name: Routes.ADHERENCE_HISTORY,
      page: () => const AdherenceHistoryPage(),
      binding: AdherenceHistoryBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.INTERACTION_ALERT,
      page: () => const InteractionAlertPage(),
      binding: InteractionAlertBinding(),
    ),
    GetPage(
      name: Routes.DOUBT_QUERY,
      page: () => const DoubtQueryPage(),
      binding: DoubtQueryBinding(),
    ),
    GetPage(
      name: Routes.CAREGIVER,
      page: () => const CaregiverPage(),
      binding: CaregiverBinding(),
    ),
    GetPage(
      name: Routes.DOCTOR_EXPORT,
      page: () => const DoctorExportPage(),
      binding: DoctorExportBinding(),
    ),
  ];
}
