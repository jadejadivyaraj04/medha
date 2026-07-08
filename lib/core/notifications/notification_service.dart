// lib/core/notifications/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../../app/routes.dart';
import '../../ui/shell/controller/shell_controller.dart';
import '../models/dose_model.dart';
import 'notification_payload.dart';

/// Schedules exact local alarms and routes taps to [Routes.REMINDER_ALERT].
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  String? _pendingPayload;
  bool _initialized = false;

  static const _channelId = 'medha_reminders';
  static const _channelName = 'Medicine reminders';
  static const _refillChannelId = 'medha_refills';
  static const _refillChannelName = 'Refill reminders';
  static const _takenActionId = 'medha_taken';
  static const _snoozeActionId = 'medha_snooze';

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createAndroidChannel();
    await _createRefillAndroidChannel();
    await _captureLaunchPayload();
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    var granted = true;

    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final notificationGranted =
          await android.requestNotificationsPermission() ?? true;
      final exactGranted =
          await android.requestExactAlarmsPermission() ?? true;
      granted = notificationGranted && exactGranted;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      granted = await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          granted;
    }

    return granted;
  }

  Future<void> scheduleDoses(List<DoseModel> doses) async {
    if (!_initialized) {
      await init();
    }

    final now = DateTime.now();
    for (final dose in doses) {
      if (dose.isTaken || dose.isSkipped) {
        continue;
      }
      if (!dose.scheduledDateTime.isAfter(now)) {
        continue;
      }
      await scheduleDose(dose);
    }
  }

  Future<void> scheduleDose(DoseModel dose) async {
    if (!_initialized) {
      await init();
    }

    final scheduledDate = tz.TZDateTime.from(dose.scheduledDateTime, tz.local);
    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    final doseLabel =
        dose.dosageMg != null ? '${dose.dosageMg} mg' : 'your dose';

    await _plugin.zonedSchedule(
      id: _notificationId(dose.id),
      title: 'reminders.alert.title'.tr,
      body: 'reminders.notification.body'.trParams({
        'name': dose.medicineName,
        'dose': doseLabel,
      }),
      scheduledDate: scheduledDate,
      notificationDetails: _detailsForDose(dose),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: NotificationPayload.encodeDose(dose),
    );
  }

  Future<void> rescheduleDose(DoseModel dose) async {
    await cancelDose(dose.id);
    await scheduleDose(dose);
  }

  Future<void> cancelRefill(String medicineId) async {
    await _plugin.cancel(id: _refillNotificationId(medicineId));
  }

  Future<void> scheduleRefillAlert({
    required String medicineId,
    required String medicineName,
    required DateTime scheduledAt,
    required int remainingDays,
  }) async {
    if (!_initialized) {
      await init();
    }

    final scheduledDate = tz.TZDateTime.from(scheduledAt, tz.local);
    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _plugin.zonedSchedule(
      id: _refillNotificationId(medicineId),
      title: 'refill.notification_title'.tr,
      body: 'refill.notification_body'.trParams({
        'name': medicineName,
        'days': '$remainingDays',
      }),
      scheduledDate: scheduledDate,
      notificationDetails: _refillDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: NotificationPayload.encodeRefill(
        medicineId: medicineId,
        medicineName: medicineName,
      ),
    );
  }

  Future<void> cancelDose(String doseId) async {
    await _plugin.cancel(id: _notificationId(doseId));
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  void processPendingNavigation() {
    final payload = _pendingPayload;
    if (payload == null) {
      return;
    }
    _pendingPayload = null;
    final refill = NotificationPayload.decodeRefill(payload);
    if (refill != null) {
      _openRefillAlert(refill);
      return;
    }
    _openReminderAlert(payload);
  }

  Future<void> _createAndroidChannel() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Exact medicine dose alarms',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  Future<void> _captureLaunchPayload() async {
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _pendingPayload = launchDetails?.notificationResponse?.payload;
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }

    if (response.actionId == _takenActionId) {
      _handleQuickAction(payload, 'taken');
      return;
    }
    if (response.actionId == _snoozeActionId) {
      _handleQuickAction(payload, 'snooze');
      return;
    }

    final refill = NotificationPayload.decodeRefill(payload);
    if (refill != null) {
      _openRefillAlert(refill);
      return;
    }

    _openReminderAlert(payload);
  }

  void _openReminderAlert(String payload) {
    final dose = NotificationPayload.decodeDose(payload);
    if (dose == null) {
      return;
    }

    if (Get.key.currentState == null) {
      _pendingPayload = payload;
      return;
    }

    if (Get.currentRoute == Routes.REMINDER_ALERT) {
      return;
    }

    Get.toNamed(
      Routes.REMINDER_ALERT,
      arguments: {'dose': dose.toJson()},
    );
  }

  void _handleQuickAction(String payload, String action) {
    final dose = NotificationPayload.decodeDose(payload);
    if (dose == null) {
      return;
    }

    if (action == 'taken') {
      Get.toNamed(
        Routes.REMINDER_ALERT,
        arguments: {
          'dose': dose.toJson(),
          'autoAction': 'taken',
        },
      );
      return;
    }

    if (action == 'snooze') {
      Get.toNamed(
        Routes.REMINDER_ALERT,
        arguments: {
          'dose': dose.toJson(),
          'autoAction': 'snooze',
        },
      );
      return;
    }

    _openReminderAlert(payload);
  }

  NotificationDetails _detailsForDose(DoseModel dose) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Exact medicine dose alarms',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        actions: [
          AndroidNotificationAction(
            _takenActionId,
            'reminders.taken'.tr,
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            _snoozeActionId,
            'reminders.snooze'.tr,
            showsUserInterface: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  Future<void> _createRefillAndroidChannel() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _refillChannelId,
        _refillChannelName,
        description: 'Medicine refill nudges',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  void _openRefillAlert(Map<String, String> refill) {
    if (Get.key.currentState == null) {
      return;
    }

    final medicineId = refill['medicine_id'] ?? '';
    if (medicineId.isEmpty) {
      return;
    }

    if (Get.isRegistered<ShellController>()) {
      Get.find<ShellController>().selectTab(1);
    }

    Get.toNamed(
      Routes.MEDICINE_DETAILS,
      arguments: {'id': medicineId},
    );
  }

  NotificationDetails _refillDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _refillChannelId,
        _refillChannelName,
        channelDescription: 'Medicine refill nudges',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  int _refillNotificationId(String medicineId) =>
      'refill_$medicineId'.hashCode.abs() % 1000000000;

  int _notificationId(String doseId) => doseId.hashCode.abs() % 1000000000;
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint('Medha notification background tap: ${response.payload}');
}
