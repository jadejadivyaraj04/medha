// lib/core/interactions/interaction_helper.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/drug_interaction_model.dart';
import '../models/interaction_severity.dart';
import '../../app/routes.dart';

class InteractionHelper {
  InteractionHelper._();

  static String severityLabel(InteractionSeverity severity) {
    return switch (severity) {
      InteractionSeverity.minor => 'interactions.severity.minor'.tr,
      InteractionSeverity.moderate => 'interactions.severity.moderate'.tr,
      InteractionSeverity.major => 'interactions.severity.major'.tr,
      InteractionSeverity.contraindicated =>
        'interactions.severity.contraindicated'.tr,
    };
  }

  static String interactionTitle(DrugInteractionModel interaction) {
    return 'interactions.pair_title'.trParams({
      'drugA': interaction.drugA,
      'drugB': interaction.drugB,
    });
  }

  static List<DrugInteractionModel> dangerOnly(
    List<DrugInteractionModel> interactions,
  ) {
    return interactions.where((item) => item.isDanger).toList();
  }

  static bool medicineInDanger(
    String medicineName,
    List<DrugInteractionModel> dangers,
  ) {
    final normalized = medicineName.toLowerCase();
    for (final item in dangers) {
      if (item.drugA.toLowerCase().contains(normalized) ||
          normalized.contains(item.drugA.toLowerCase()) ||
          item.drugB.toLowerCase().contains(normalized) ||
          normalized.contains(item.drugB.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> confirmDangerInteractions(
    List<DrugInteractionModel> interactions,
  ) async {
    final dangers = dangerOnly(interactions);
    if (dangers.isEmpty) {
      return true;
    }

    final result = await Get.toNamed<bool>(
      Routes.INTERACTION_ALERT,
      arguments: {'interactions': dangers},
    );
    return result == true;
  }

  static Future<void> callDoctor() async {
    await callPhone('');
  }

  static Future<void> callPhone(String phone) async {
    final trimmed = phone.trim();
    final uri = trimmed.isEmpty
        ? Uri(scheme: 'tel')
        : Uri(scheme: 'tel', path: trimmed);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    Get.snackbar(
      trimmed.isEmpty
          ? 'interactions.doctor_call_cta'.tr
          : 'caregiver.call_cta'.tr,
      trimmed.isEmpty
          ? 'interactions.doctor_call_hint'.tr
          : 'caregiver.call_hint'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}
