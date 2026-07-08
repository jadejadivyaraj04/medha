// lib/data/models/caregiver_model.dart

class CaregiverModel {
  const CaregiverModel({
    required this.profileId,
    this.name = '',
    this.phone = '',
    this.relationship = 'son',
    this.shareAdherence = false,
  });

  final String profileId;
  final String name;
  final String phone;
  final String relationship;
  final bool shareAdherence;

  bool get hasContact => name.trim().isNotEmpty && phone.trim().isNotEmpty;

  factory CaregiverModel.fromJson(Map<String, dynamic> json) {
    return CaregiverModel(
      profileId: json['profile_id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      relationship: json['relationship'] as String? ?? 'son',
      shareAdherence: json['share_adherence'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'profile_id': profileId,
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'share_adherence': shareAdherence,
      };

  CaregiverModel copyWith({
    String? profileId,
    String? name,
    String? phone,
    String? relationship,
    bool? shareAdherence,
  }) {
    return CaregiverModel(
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      shareAdherence: shareAdherence ?? this.shareAdherence,
    );
  }
}
