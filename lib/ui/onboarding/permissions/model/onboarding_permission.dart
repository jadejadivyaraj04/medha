// lib/ui/onboarding/permissions/model/onboarding_permission.dart

enum OnboardingPermission {
  camera(
    id: 'camera',
    iconName: 'camera',
    slideIndex: 0,
  ),
  notifications(
    id: 'notifications',
    iconName: 'notifications',
    slideIndex: 1,
  ),
  photos(
    id: 'photos',
    iconName: 'photos',
    slideIndex: 2,
  ),
  microphone(
    id: 'microphone',
    iconName: 'microphone',
    slideIndex: 3,
  );

  const OnboardingPermission({
    required this.id,
    required this.iconName,
    required this.slideIndex,
  });

  static const routeArgKey = 'permissionId';

  final String id;
  final String iconName;
  final int slideIndex;

  static const slideOrder = [
    OnboardingPermission.camera,
    OnboardingPermission.notifications,
    OnboardingPermission.photos,
    OnboardingPermission.microphone,
  ];

  static OnboardingPermission get first => slideOrder.first;

  static OnboardingPermission? fromId(String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }
    for (final permission in slideOrder) {
      if (permission.id == id) {
        return permission;
      }
    }
    return null;
  }

  static OnboardingPermission? fromArguments(dynamic arguments) {
    if (arguments is! Map) {
      return null;
    }
    return fromId(arguments[routeArgKey] as String?);
  }

  OnboardingPermission? get next {
    final index = slideOrder.indexOf(this);
    if (index < 0 || index >= slideOrder.length - 1) {
      return null;
    }
    return slideOrder[index + 1];
  }

  static int get totalSlides => slideOrder.length;
}
