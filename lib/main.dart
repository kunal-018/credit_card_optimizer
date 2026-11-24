import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'background/workmanager_callback.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/payment_reminder_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await NotificationService.requestPermission();
  await PaymentReminderService.checkPendingPayments();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  await Workmanager().registerPeriodicTask(
    paymentReminderTask,
    paymentReminderTask,
    frequency: const Duration(hours: 24),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );

  runApp(const MyApp());
}
