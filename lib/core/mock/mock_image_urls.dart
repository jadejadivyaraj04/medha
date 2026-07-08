// lib/core/mock/mock_image_urls.dart

class MockImageUrls {
  MockImageUrls._();

  /// Stable picsum seeds — reliable in dev/simulator (source.unsplash.com is deprecated).
  static const List<String> heroImages = [
    'https://picsum.photos/seed/medha-hero-healthcare/800/1200',
    'https://picsum.photos/seed/medha-hero-medicine/800/1200',
    'https://picsum.photos/seed/medha-hero-wellness/800/1200',
  ];

  static const List<String> contentImages = [
    'https://picsum.photos/seed/medha-rx-document/600/450',
    'https://picsum.photos/seed/medha-clinic/600/450',
    'https://picsum.photos/seed/medha-pharmacy/600/450',
  ];

  static const List<String> avatarsStable = [
    'https://picsum.photos/seed/user1/200/200',
    'https://picsum.photos/seed/user2/200/200',
    'https://picsum.photos/seed/user3/200/200',
    'https://picsum.photos/seed/user4/200/200',
  ];

  static String hero(int index) => heroImages[index % heroImages.length];

  static String content(int index) => contentImages[index % contentImages.length];

  static String avatar(int index) => avatarsStable[index % avatarsStable.length];
}
