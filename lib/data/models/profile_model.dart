// lib/data/models/profile_model.dart

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.age,
    required this.localeCode,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final int age;
  final String localeCode;
  final String? avatarUrl;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      localeCode: json['locale_code'] as String? ?? 'en',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'locale_code': localeCode,
        'avatar_url': avatarUrl,
      };

  ProfileModel copyWith({
    String? id,
    String? name,
    int? age,
    String? localeCode,
    String? avatarUrl,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      localeCode: localeCode ?? this.localeCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
