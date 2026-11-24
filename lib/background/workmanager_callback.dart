import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import '../services/payment_reminder_service.dart';
import '../services/notification_service.dart';

const paymentReminderTask = 'paymentReminderTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("========== WORKMANAGER STARTED ==========");
    debugPrint("Task: $task");

    await NotificationService.initialize();

    if (task == paymentReminderTask) {
      await PaymentReminderService.checkPendingPayments();
    }

    return Future.value(true);
  });
}
