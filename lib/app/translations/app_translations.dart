// lib/app/translations/app_translations.dart

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static const supportedLocales = ['en', 'gu', 'hi'];

  static final Map<String, Map<String, String>> _keys = {};

  static Future<void> load() async {
    for (final locale in supportedLocales) {
      final jsonString =
          await rootBundle.loadString('assets/locales/$locale.json');
      final Map<String, dynamic> decoded = json.decode(jsonString);
      _keys[locale] = decoded.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    }
  }

  @override
  Map<String, Map<String, String>> get keys => _keys;
}
