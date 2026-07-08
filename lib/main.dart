// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import 'app/app_controller.dart';
import 'app/app_pages.dart';
import 'app/routes.dart';
import 'app/translations/app_translations.dart';
import 'core/ai/audio_recorder_service.dart';
import 'core/ai/gemma_service.dart';
import 'core/ai/rag_service.dart';
import 'core/ai/tts_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/storage_manager.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';

const _smartImagePlaceholder =
    'packages/smart_dev_widgets/assets/images/ic_placeholder.png';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTranslations.load();
  await StorageManager.init();
  _configureSmartImagePlaceholders();

  Get.put(AppController(), permanent: true);
  Get.put(GemmaService(), permanent: true);
  Get.put(AudioRecorderService(), permanent: true);
  Get.put(RagService(), permanent: true);
  Get.put(TtsService(), permanent: true);

  final notificationService = Get.put(NotificationService(), permanent: true);
  await notificationService.init();

  runApp(const MedhaApp());
}

bool _smartWidgetsConfigured = false;

void _configureSmartImagePlaceholders() {
  final config = SmartDevWidgetsConfig();
  config
    ..imagePlaceholderPath = _smartImagePlaceholder
    ..noDataFoundImagePath = _smartImagePlaceholder;
}

/// Maps Medha theme tokens onto [SmartDevWidgetsConfig] global defaults.
/// Must run after [ScreenUtilInit] — [AppTextStyles] uses `.sp`.
void _configureSmartDevWidgets() {
  final config = SmartDevWidgetsConfig();
  config.initialize(
    columnSpacing: 0,
    rowSpacing: 0,
    columnCrossAxisAlignment: CrossAxisAlignment.start,
    textStyle: AppTextStyles.body1,
    textIsAutoSizeText: false,
    buttonHeight: 52.0,
    buttonActiveBackgroundColor: AppColors.accent,
    buttonDisableBackgroundColor: AppColors.border,
    buttonBorderRadius: BorderRadius.circular(16),
    buttonTitleStyle: AppTextStyles.button.copyWith(color: Colors.white),
    imageFit: BoxFit.cover,
    imageLoadingAnimationType: LoadingAnimationType.shimmer,
    imageShowLoadingAnimation: true,
    imagePlaceholderPath: _smartImagePlaceholder,
  );

  // smart_dev_widgets 0.0.7 — set via properties (not yet on initialize()).
  config
    ..textFieldFillColor = AppColors.surface
    ..textFieldEnabledBorderColor = AppColors.border
    ..textFieldFocusedBorderColor = AppColors.accent
    ..textFieldErrorBorderColor = AppColors.error
    ..textFieldStyle = AppTextStyles.body1
    ..textFieldHintStyle =
        AppTextStyles.body2.copyWith(color: AppColors.textHint)
    ..appBarBackgroundColor = AppColors.surfaceElevated
    ..appBarTitleStyle = AppTextStyles.heading3
    ..checkboxActiveColor = AppColors.accent
    ..radioButtonActiveColor = AppColors.accent
    ..stepperActiveColor = AppColors.accent
    ..stepperCompletedColor = AppColors.success
    ..stepperUpcomingColor = AppColors.textHint
    ..imagePlaceholderPath = _smartImagePlaceholder
    ..noDataFoundImagePath = _smartImagePlaceholder;
}

class MedhaApp extends StatelessWidget {
  const MedhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        if (!_smartWidgetsConfigured) {
          _configureSmartDevWidgets();
          _smartWidgetsConfigured = true;
        }

        return Obx(() {
          final mediaQuery = MediaQuery.of(context);
          final baseScale = appController.textScaleFactor.value;
          final textScaler = mediaQuery.textScaler.clamp(
            minScaleFactor: baseScale,
            maxScaleFactor: double.infinity,
          );

          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: textScaler),
            child: child ?? const SizedBox.shrink(),
          );
        });
      },
      child: Obx(
        () => GetMaterialApp(
          title: 'Medha',
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 280),
          locale: Locale(appController.localeCode.value),
          fallbackLocale: const Locale('en'),
          translations: AppTranslations(),
          initialRoute: Routes.SPLASH,
          getPages: AppPages.routes,
          routingCallback: (routing) {
            if (routing?.current == Routes.HOME &&
                Get.isRegistered<NotificationService>()) {
              Get.find<NotificationService>().processPendingNavigation();
            }
          },
        ),
      ),
    );
  }
}
