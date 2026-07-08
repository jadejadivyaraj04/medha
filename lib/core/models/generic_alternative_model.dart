// lib/core/models/generic_alternative_model.dart

class GenericAlternativeOption {
  const GenericAlternativeOption({
    required this.name,
    required this.note,
  });

  final String name;
  final String note;
}

class GenericAlternativeModel {
  const GenericAlternativeModel({
    required this.medicineName,
    required this.genericName,
    required this.alternatives,
    required this.source,
  });

  final String medicineName;
  final String genericName;
  final List<GenericAlternativeOption> alternatives;
  final String source;

  bool get hasAlternatives =>
      genericName.trim().isNotEmpty || alternatives.isNotEmpty;
}
