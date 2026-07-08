// lib/ui/onboarding/value_intro/controller/value_intro_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes.dart';
import '../../../../core/mock/mock_image_urls.dart';

class ValueIntroController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final slides = <IntroSlide>[
    IntroSlide(
      imageUrl: MockImageUrls.hero(0),
      titleKey: 'onboarding.value_intro.slide1_title',
      bodyKey: 'onboarding.value_intro.slide1_body',
    ),
    IntroSlide(
      imageUrl: MockImageUrls.hero(1),
      titleKey: 'onboarding.value_intro.slide2_title',
      bodyKey: 'onboarding.value_intro.slide2_body',
    ),
    IntroSlide(
      imageUrl: MockImageUrls.hero(2),
      titleKey: 'onboarding.value_intro.slide3_title',
      bodyKey: 'onboarding.value_intro.slide3_body',
    ),
  ];

  bool get isLastPage => currentPage.value >= slides.length - 1;

  void onPageChanged(int index) => currentPage.value = index;

  void skip() => Get.offNamed(Routes.LANGUAGE_SELECT);

  void next() {
    if (isLastPage) {
      Get.offNamed(Routes.LANGUAGE_SELECT);
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class IntroSlide {
  const IntroSlide({
    required this.imageUrl,
    required this.titleKey,
    required this.bodyKey,
  });

  final String imageUrl;
  final String titleKey;
  final String bodyKey;
}
