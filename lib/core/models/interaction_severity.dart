// lib/core/models/interaction_severity.dart

enum InteractionSeverity {
  minor,
  moderate,
  major,
  contraindicated;

  bool get isDanger =>
      this == InteractionSeverity.major ||
      this == InteractionSeverity.contraindicated;

  static InteractionSeverity fromString(String raw) {
    return switch (raw.toLowerCase().trim()) {
      'minor' => InteractionSeverity.minor,
      'moderate' => InteractionSeverity.moderate,
      'major' => InteractionSeverity.major,
      'contraindicated' => InteractionSeverity.contraindicated,
      _ => InteractionSeverity.moderate,
    };
  }

  String get storageValue => name;
}
