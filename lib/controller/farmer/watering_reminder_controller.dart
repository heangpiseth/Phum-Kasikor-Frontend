import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:phum_kasikors/core/service/farmer/notifications/notification_service.dart';
import 'package:phum_kasikors/model/farmer/watering_reminder_model.dart';

class WateringReminderController extends GetxController {
  // ============================================================
  // STORAGE
  // ============================================================

  final GetStorage _storage = GetStorage();

  static const String _storageKey = 'watering_reminders';

  // How many future reminders should be scheduled.
  static const int _scheduledDays = 14;

  // ============================================================
  // STATE
  // ============================================================

  final reminders = <WateringReminderModel>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  final errorMessage = RxnString();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    loadReminders();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> loadReminders() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final storedData = _storage.read(_storageKey);

      if (storedData is! List) {
        reminders.clear();
        return;
      }

      final loadedReminders =
          <WateringReminderModel>[];

      for (final item in storedData) {
        if (item is! Map) {
          continue;
        }

        try {
          loadedReminders.add(
            WateringReminderModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (_) {
          // Ignore invalid saved data.
        }
      }

      reminders.assignAll(
        loadedReminders,
      );

      await _restoreNotifications();
    } catch (e) {
      errorMessage.value =
          _cleanError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GET REMINDER
  // ============================================================

  WateringReminderModel? getReminder(
    String cropId,
  ) {
    try {
      return reminders.firstWhere(
        (reminder) =>
            reminder.cropId == cropId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // HAS REMINDER
  // ============================================================

  bool hasReminder(
    String cropId,
  ) {
    return getReminder(cropId) != null;
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<bool> saveReminder({
    required String cropId,
    required String cropName,
    required String fieldId,
    required String fieldName,
    required bool enabled,
    required int hour,
    required int minute,
    required WateringReminderRepeat repeat,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = null;

      // ----------------------------------------------------------
      // VALIDATION
      // ----------------------------------------------------------

      if (cropId.trim().isEmpty) {
        errorMessage.value =
            'Crop information is missing.';
        return false;
      }

      if (fieldId.trim().isEmpty) {
        errorMessage.value =
            'Field information is missing.';
        return false;
      }

      if (cropName.trim().isEmpty) {
        errorMessage.value =
            'Crop name is missing.';
        return false;
      }

      if (fieldName.trim().isEmpty) {
        errorMessage.value =
            'Field name is missing.';
        return false;
      }

      if (hour < 0 || hour > 23) {
        errorMessage.value =
            'Invalid reminder hour.';
        return false;
      }

      if (minute < 0 || minute > 59) {
        errorMessage.value =
            'Invalid reminder minute.';
        return false;
      }

      // ----------------------------------------------------------
      // CANCEL OLD NOTIFICATIONS
      // ----------------------------------------------------------

      await _cancelCropNotifications(
        cropId,
      );

      // ----------------------------------------------------------
      // CREATE REMINDER
      // ----------------------------------------------------------

      final reminder =
          WateringReminderModel(
        cropId: cropId,
        cropName: cropName,
        fieldId: fieldId,
        fieldName: fieldName,
        enabled: enabled,
        hour: hour,
        minute: minute,
        repeat: repeat,
      );

      // ----------------------------------------------------------
      // UPDATE MEMORY
      // ----------------------------------------------------------

      reminders.removeWhere(
        (item) =>
            item.cropId == cropId,
      );

      reminders.add(reminder);

      reminders.refresh();

      // ----------------------------------------------------------
      // SAVE
      // ----------------------------------------------------------

      await _persistReminders();

      // ----------------------------------------------------------
      // SCHEDULE
      // ----------------------------------------------------------

      if (enabled) {
        await _scheduleFutureReminders(
          reminder,
        );
      }

      return true;
    } catch (e) {
      errorMessage.value =
          _cleanError(e);

      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // ENABLE / DISABLE
  // ============================================================

  Future<bool> setReminderEnabled({
    required String cropId,
    required bool enabled,
  }) async {
    final reminder =
        getReminder(cropId);

    if (reminder == null) {
      errorMessage.value =
          'Reminder has not been configured yet.';
      return false;
    }

    return saveReminder(
      cropId: reminder.cropId,
      cropName: reminder.cropName,
      fieldId: reminder.fieldId,
      fieldName: reminder.fieldName,
      enabled: enabled,
      hour: reminder.hour,
      minute: reminder.minute,
      repeat: reminder.repeat,
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<bool> deleteReminder(
    String cropId,
  ) async {
    try {
      isSaving.value = true;
      errorMessage.value = null;

      await _cancelCropNotifications(
        cropId,
      );

      reminders.removeWhere(
        (reminder) =>
            reminder.cropId == cropId,
      );

      reminders.refresh();

      await _persistReminders();

      return true;
    } catch (e) {
      errorMessage.value =
          _cleanError(e);

      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // CROP WATERED TODAY
  // ============================================================

  Future<void> handleCropWateredToday(
    String cropId,
  ) async {
    final reminder =
        getReminder(cropId);

    if (reminder == null ||
        !reminder.enabled) {
      return;
    }

    // Cancel all future reminders for this crop.
    await _cancelCropNotifications(
      cropId,
    );

    // Rebuild the schedule starting
    // from the next valid watering date.
    await _scheduleFutureReminders(
      reminder,
      skipToday: true,
    );
  }

  // ============================================================
  // SCHEDULE FUTURE REMINDERS
  // ============================================================

  Future<void> _scheduleFutureReminders(
    WateringReminderModel reminder, {
    bool skipToday = false,
  }) async {
    final now = DateTime.now();

    var firstDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    // If today's reminder time has already passed,
    // start with the next repeat occurrence.
    if (!firstDate.isAfter(now)) {
      firstDate = firstDate.add(
        Duration(
          days: reminder.repeat.intervalDays,
        ),
      );
    }

    // If the crop was already watered today,
    // definitely start tomorrow/next interval.
    if (skipToday) {
      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final firstDay = DateTime(
        firstDate.year,
        firstDate.month,
        firstDate.day,
      );

      if (firstDay.isAtSameMomentAs(today)) {
        firstDate = firstDate.add(
          Duration(
            days: reminder.repeat.intervalDays,
          ),
        );
      }
    }

    var scheduledDate = firstDate;

    for (var i = 0;
        i < _scheduledDays;
        i++) {
      final notificationId =
          _notificationId(
        reminder.cropId,
        occurrence: i,
      );

      await NotificationService.scheduleWateringReminder(
        notificationId: notificationId,
        cropName: reminder.cropName,
        fieldName: reminder.fieldName,
        scheduledTime: scheduledDate,
      );

      scheduledDate =
          scheduledDate.add(
        Duration(
          days:
              reminder.repeat.intervalDays,
        ),
      );
    }
  }

  // ============================================================
  // RESTORE NOTIFICATIONS
  // ============================================================

  Future<void> _restoreNotifications() async {
    for (final reminder in reminders) {
      if (!reminder.enabled) {
        continue;
      }

      await _cancelCropNotifications(
        reminder.cropId,
      );

      await _scheduleFutureReminders(
        reminder,
      );
    }
  }

  // ============================================================
  // CANCEL CROP NOTIFICATIONS
  // ============================================================

  Future<void> _cancelCropNotifications(
    String cropId,
  ) async {
    for (var i = 0;
        i < _scheduledDays;
        i++) {
      final notificationId =
          _notificationId(
        cropId,
        occurrence: i,
      );

      await NotificationService.cancelReminder(
        notificationId,
      );
    }
  }

  // ============================================================
  // PERSIST
  // ============================================================

  Future<void> _persistReminders() async {
    final data = reminders
        .map(
          (reminder) =>
              reminder.toJson(),
        )
        .toList();

    await _storage.write(
      _storageKey,
      data,
    );
  }

  // ============================================================
  // NOTIFICATION ID
  // ============================================================

  int _notificationId(
    String cropId, {
    required int occurrence,
  }) {
    var hash = 0;

    for (final character
        in cropId.codeUnits) {
      hash =
          (hash * 31 + character) &
              0x7fffffff;
    }

    // Keep each occurrence separate.
    final id =
        (hash + occurrence + 1) &
            0x7fffffff;

    return id == 0 ? 1 : id;
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(
    Object error,
  ) {
    final message =
        error.toString();

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(11);
    }

    return message;
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    errorMessage.value = null;
  }
}