// lib/app/app_config.dart

enum AppEnvironment { mock, development, production }

class AppConfig {
  AppConfig._();

  static const environment = AppEnvironment.development;

  static bool get isMock => environment == AppEnvironment.mock;
  static bool get isDevelopment => environment == AppEnvironment.development;
  static bool get isProduction => environment == AppEnvironment.production;

  /// Phase 2 — on-device drug interaction checks before save and on detail.
  static const enableInteractionChecks = true;
}
