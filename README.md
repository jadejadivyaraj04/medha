# Medha — Cursor IDE Rules Guide

> Complete guide for developers using these `.mdc` rule files in Cursor IDE.
> **Prompt shortcut definitions live in `.cursorrules`** — this README only
> summarizes them for quick reference.

---

## 📁 Setup — One Time Only

### Step 1 — Place rule files

> ⚠️ **IMPORTANT** — `.cursorrules` and `.mdc` files go in DIFFERENT locations.

```
your_project/
├── .cursorrules              ← PROJECT ROOT (with leading dot — master entry)
└── .cursor/
    └── rules/
        ├── project.mdc
        ├── flutter.mdc
        ├── getx.mdc
        ├── ui-design.mdc
        ├── ui-ux-agent.mdc
        ├── testing.mdc
        ├── app_theme.mdc
        ├── mock_images.mdc
        └── references/
            └── smart-widgets-reference.md   ← keep alongside (ui-design references it)
```

#### 🟡 `.cursorrules` setup (master entry — must do this correctly)

1. Take the generated file named `cursorrules` (no dot, no extension).
2. **Rename it to `.cursorrules`** (with a leading dot).
3. **Place it in your project root** — same level as `pubspec.yaml`, NOT inside `.cursor/rules/`.
4. Cursor IDE auto-loads `.cursorrules` from the project root before every other rule file.

**Why the leading dot?** Cursor IDE only recognizes the file as a rules file when it's named exactly `.cursorrules`. Without the dot, it's ignored.

**Verify placement:**
```bash
# From project root:
ls -la .cursorrules           # should exist
ls .cursor/rules/             # should list 8 .mdc files (no cursorrules here)
```

#### 🟢 `.mdc` files setup

Place all 8 `.mdc` files inside `.cursor/rules/` (create the folder if it doesn't exist).

### Step 2 — Install dependencies
```bash
flutter pub get
```
Fonts (Lora, DM Sans) are auto-fetched and cached at runtime via the [`google_fonts`](https://pub.dev/packages/google_fonts) package — no manual download, no `assets/fonts/` folder needed.

### Step 3 — Set environment mode
```dart
// lib/app/app_config.dart
class AppConfig {
  // PROTOTYPE MODE — mock data, no backend needed (Medha runs fully on-device anyway)
  static const environment = AppEnvironment.mock;

  // API INTEGRATION MODE — real backend (only if you ever add one)
  // static const environment = AppEnvironment.development;

  // PRODUCTION
  // static const environment = AppEnvironment.production;
}
```

### Step 4 — Copy theme + mock files
From `app_theme.mdc` → copy into `lib/core/theme/`:
```
lib/core/theme/
├── app_colors.dart
├── app_gradients.dart
├── app_text_styles.dart
└── app_theme.dart
```

From `mock_images.mdc` → copy into `lib/core/mock/`:
```
lib/core/mock/
└── mock_image_urls.dart
```

---

## 🧩 Smart Widgets

This project uses [`smart_dev_widgets`](https://pub.dev/packages/smart_dev_widgets).
All UI uses `Smart*` wrappers (SmartColumn, SmartButton, SmartImage, SmartTextField, etc.)
with built-in spacing, padding, tap, loading, and image handling. See
`.cursor/rules/ui-design.mdc` for the full anti-wrap rules and forbidden raw widget list.

Requires Flutter ≥ 3.27.

---

## 🧠 On-device AI note

Medha runs Gemma3n locally via [`flutter_gemma`](https://pub.dev/packages/flutter_gemma).
No prescription image or parsed medical data leaves the device. Build on `arm64-v8a`
(Android) — set `ndk { abiFilters 'arm64-v8a' }` — and iOS 16+ with memory entitlements.
All model calls go through `lib/core/ai/gemma_service.dart`.

---

## 🧑‍💻 3 Developer Scenarios

---

### SCENARIO A — Prototype Only
> Build and demo the full app with realistic UI.
> No backend. Mock data + real Unsplash images.

**Set config:**
```dart
static const environment = AppEnvironment.mock;
```

**Command:**
```
BUILD [module_name] PROTOTYPE
```

**Examples for Medha:**
```
BUILD medicines PROTOTYPE
BUILD reminders PROTOTYPE
BUILD onboarding PROTOTYPE
BUILD scan PROTOTYPE
```

**What Cursor generates:**
- Full UI matching screen spec in `ui-ux-agent.mdc`
- Mock repository with `MockImageUrls` (real Unsplash photos, no API key)
- All 3 states: loading shimmer + error widget + empty state
- GetX controller with `.obs` state
- Binding wired to `MockMedicineRepository`
- Localization keys in `en.json` + `gu.json` + `hi.json`

---

### SCENARIO B — API Integration Only
> Only relevant if you later add an optional cloud sync/backup.
> No UI work — just connect a repository to real endpoints.

**Set config:**
```dart
static const environment = AppEnvironment.development;
```

**Command:**
```
INTEGRATE API [module_name]
```

**Examples for Medha:**
```
INTEGRATE API medicines
INTEGRATE API reminders
```

**With endpoint details:**
```
INTEGRATE API medicines
Base URL: https://api.medha.app/v1
Endpoint: GET /medicines?profileId={id}
Response shape: { data: [...], meta: { total, page } }
```

**What Cursor generates:**
- `MedicineApiService` with Dio call + `Either` error handling
- `MedicineRepositoryImpl` implementing abstract class
- Updates `Binding` to swap Mock → Real repository
- Existing UI and controller stay untouched

---

### SCENARIO C — Prototype + API Together

**Set config:**
```dart
static const environment = AppEnvironment.mock;  // test with mock first
```

**Command:**
```
BUILD [module_name] FULL
```

**Examples for Medha:**
```
BUILD medicines FULL
BUILD reminders FULL
```

**With endpoint:**
```
BUILD medicines FULL
Endpoint: GET /medicines?profileId={id}
Response: { data: [...], meta: { total, page } }
```

**What Cursor generates:**
- Full UI (same as PROTOTYPE)
- Mock repository with realistic fake data
- Real `ApiService` + `RepositoryImpl` both generated
- Binding wired to `AppConfig.isMock` toggle
- Flip ONE line in `app_config.dart` → switches mock ↔ real

---

## 🔀 Switching Mock ↔ Real API

```dart
// lib/app/app_config.dart
static const environment = AppEnvironment.mock;        // prototype
static const environment = AppEnvironment.development; // real API
static const environment = AppEnvironment.production;  // production
```

```dart
Get.lazyPut<MedicineRepository>(() =>
  AppConfig.isMock
    ? MockMedicineRepository()   // mock: Unsplash images, fake data
    : MedicineRepositoryImpl()   // real: your API
);
```

---

## 🎨 Design Commands

```
DESIGN [screen_name]
```
Full widget tree spec for any screen per `ui-ux-agent.mdc`.

**Screens in Medha:**
```
DESIGN splash
DESIGN value_intro_slider
DESIGN language_select
DESIGN permission_slide
DESIGN permission_summary
DESIGN create_profile
DESIGN home
DESIGN scan_prescription
DESIGN ai_parsing
DESIGN verify_edit
DESIGN plain_language_summary
DESIGN medicines_list
DESIGN medicine_detail
DESIGN today_schedule
DESIGN reminder_alert
DESIGN adherence_history
DESIGN settings
```

---

```
UI REVIEW [screen_name]
```
Audits existing screen against all rules. Returns pass/fail per check.

```
IMPROVE UI [screen_name]
```
Rewrites screen to fix violations found in UI REVIEW.

---

## 🧪 Testing Commands

```
WRITE TESTS [ControllerName]
```
Generates full unit test file — success, error, and loading state cases.

**Controllers in Medha:**
```
WRITE TESTS MedicineController
WRITE TESTS ReminderController
WRITE TESTS ScanController
WRITE TESTS OnboardingController
WRITE TESTS ProfileController
```

---

## ⚡ Quick Reference

| Goal | Command |
|------|---------|
| Build screen with mock data | `BUILD [module] PROTOTYPE` |
| Wire real API to existing screen | `INTEGRATE API [module]` |
| Build screen + API together | `BUILD [module] FULL` |
| Get screen widget spec | `DESIGN [screen]` |
| Audit existing screen | `UI REVIEW [screen]` |
| Fix screen violations | `IMPROVE UI [screen]` |
| Audit Smart widget usage | `SMART AUDIT [module]` |
| Generate unit tests | `WRITE TESTS [controller]` |

---

## 🗂️ What Each Rule File Does

| File | Location | Purpose | When Cursor uses it |
|------|----------|---------|---------------------|
| `.cursorrules` | **Project root** (leading dot required) | Master entry — identity, agent refs, critical rules, prompt shortcuts | Always — loaded before every other rule |
| `project.mdc` | `.cursor/rules/` | Project brain — stack, modules, business rules | Always — every file |
| `flutter.mdc` | `.cursor/rules/` | Dart/Flutter coding patterns | All `.dart` files |
| `getx.mdc` | `.cursor/rules/` | State, navigation, DI rules | Controllers, bindings, views |
| `ui-design.mdc` | `.cursor/rules/` | Colors, typography, component specs, Smart widget rules | View and widget files |
| `ui-ux-agent.mdc` | `.cursor/rules/` | Screen-by-screen design patterns | View and widget files |
| `testing.mdc` | `.cursor/rules/` | Test patterns and mock data | Test files |
| `app_theme.mdc` | `.cursor/rules/` | Ready-to-paste Dart theme code | `core/theme/` files |
| `mock_images.mdc` | `.cursor/rules/` | Unsplash image URLs for prototype | Mock repository files |

---

## ❌ Things Cursor Will Never Generate

| Wrong | Correct |
|-------|---------|
| `StatefulWidget` / `setState` | GetX `.obs` + `Obx()` |
| Raw `Column` / `Row` / `Text` | `SmartColumn` / `SmartRow` / `SmartText` |
| `Image.network()` / `CachedNetworkImage` | `SmartImage` |
| `Color(0xFF...)` hardcoded | `AppColors.*` token |
| `Text('Hardcoded string')` | `SmartText('key'.tr)` |
| `width: 120` raw number | `120.w` ScreenUtil |
| `TabBar` inside `AppBar` | `SliverPersistentHeader` in scroll body |
| `Navigator.push()` | `Get.toNamed(Routes.X)` |
| `GetStorage().write()` | `StorageManager.*` |
| Navigation in `onInit()` | Navigation in `onReady()` |
| Cloud upload of prescription/medical data | On-device only — never |
| Saving medicines before user verification | Verify gate first |
| Empty list from mock | 4–6 realistic domain items |

---

## 📦 Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  dio: ^5.4.0
  dartz: ^0.10.1
  get_storage: ^2.1.1
  flutter_screenutil: ^5.9.3
  google_fonts: ^6.2.1
  # On-device AI + reminders
  flutter_gemma: ^0.15.0
  flutter_tts: ^4.2.0
  flutter_local_notifications: ^18.0.0
  image_picker: ^1.1.2
  permission_handler: ^11.3.1
  sqlite3: ^2.4.0
  # Smart widgets stack
  smart_dev_widgets: ^0.0.6
  auto_size_text: ^3.0.0
  cached_network_image: ^3.4.1
  flutter_svg: ^2.2.4
  shimmer: ^3.0.0
  lottie: ^3.3.3
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.3
```

> Run `flutter pub get` after adding. Prefer `flutter pub add <pkg>` to pull latest compatible versions.
