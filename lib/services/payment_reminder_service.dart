import '../database/database_helper.dart';
import 'notification_service.dart';
import 'recommendation_service.dart';

class PaymentReminderService {
  static const List<int> reminderDays = [5, 3, 1, 0];

  static Future<void> checkPendingPayments() async {
    final today = DateTime.now();
    final todayOnly = _dateOnly(today);
    final cards = await DatabaseHelper.instance.getAllCards();
    final reminderLines = <String>[];
    final remindersToSave = <_ReminderToSave>[];

    for (final card in cards) {
      final dueDate = RecommendationService.getUpcomingDueDate(
        todayOnly,
        card.dueDay,
      );

      final daysRemaining = _dateOnly(dueDate).difference(todayOnly).inDays;

      if (!reminderDays.contains(daysRemaining)) {
        continue;
      }

      final payment = await DatabaseHelper.instance.getPayment(
        card.id!,
        dueDate,
      );

      if (payment?.isPaid ?? false) {
        continue;
      }

      final alreadySent = await DatabaseHelper.instance.reminderAlreadySent(
        cardId: card.id!,
        dueDate: dueDate,
        reminderDay: daysRemaining,
      );

      if (alreadySent) {
        continue;
      }

      final dueText = switch (daysRemaining) {
        0 => "Due Today",
        1 => "Due Tomorrow",
        _ => "Due in $daysRemaining days",
      };

      reminderLines.add(
        "- ${card.cardName} (${card.last4Digits}) - $dueText",
      );

      remindersToSave.add(
        _ReminderToSave(
          cardId: card.id!,
          dueDate: dueDate,
          reminderDay: daysRemaining,
        ),
      );
    }

    if (reminderLines.isEmpty) {
      return;
    }

    await NotificationService.showNotification(
      title: "Credit Card Optimizer (${reminderLines.length})",
      body: reminderLines.join("\n"),
    );

    for (final reminder in remindersToSave) {
      await DatabaseHelper.instance.saveReminder(
        cardId: reminder.cardId,
        dueDate: reminder.dueDate,
        reminderDay: reminder.reminderDay,
      );
    }
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _ReminderToSave {
  final int cardId;
  final DateTime dueDate;
  final int reminderDay;

  const _ReminderToSave({
    required this.cardId,
    required this.dueDate,
    required this.reminderDay,
  });
}
