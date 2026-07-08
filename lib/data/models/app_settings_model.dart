// lib/data/models/app_settings_model.dart

class AppSettingsModel {
  const AppSettingsModel({
    required this.languageCode,
    required this.textScale,
    required this.voiceEnabled,
  });

  final String languageCode;
  final double textScale;
  final bool voiceEnabled;

  factory AppSettingsModel.defaults() {
    return const AppSettingsModel(
      languageCode: 'en',
      textScale: 1.3,
      voiceEnabled: true,
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      languageCode: json['language_code']?.toString() ?? 'en',
      textScale: _parseScale(json['text_scale']),
      voiceEnabled: json['voice_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'language_code': languageCode,
        'text_scale': textScale,
        'voice_enabled': voiceEnabled,
      };

  AppSettingsModel copyWith({
    String? languageCode,
    double? textScale,
    bool? voiceEnabled,
  }) {
    return AppSettingsModel(
      languageCode: languageCode ?? this.languageCode,
      textScale: textScale ?? this.textScale,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
    );
  }

  static double _parseScale(dynamic value) {
    if (value is num) {
      return value.toDouble().clamp(1.3, 1.5);
    }
    return 1.3;
  }
}
