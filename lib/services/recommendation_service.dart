import 'package:credit_card_optimizer/models/card_model.dart';
import 'package:credit_card_optimizer/models/recommendation_result.dart';
import 'package:credit_card_optimizer/models/payment_event.dart';

class RecommendationService {

static DateTime getNextBillingDate(
  DateTime today,
  int billingDay,
) {
  DateTime billingDate = _safeDate(
    today.year,
    today.month,
    billingDay,
  );

  if (!billingDate.isBefore(today)) {
    return billingDate;
  }

  int nextMonth = today.month + 1;
  int year = today.year;

  if (nextMonth > 12) {
    nextMonth = 1;
    year++;
  }

  return _safeDate(
    year,
    nextMonth,
    billingDay,
  );
}
static DateTime getUpcomingDueDate(
  DateTime today,
  int dueDay,
) {
  int year = today.year;
  int month = today.month;

  if (today.day > dueDay) {
    month++;

    if (month > 12) {
      month = 1;
      year++;
    }
  }

  return _safeDate(
    year,
    month,
    dueDay,
  );
}
static DateTime getDueDateForBilling(
  DateTime billingDate,
  int dueDay,
) {
  int year = billingDate.year;
  int month = billingDate.month;

  if (dueDay < billingDate.day) {
    month++;

    if (month > 12) {
      month = 1;
      year++;
    }
  }

  return _safeDate(
    year,
    month,
    dueDay,
  );
}
static int getInterestFreeDays(
  DateTime today,
  CardModel card,
) {
  final billingDate = getNextBillingDate(
    today,
    card.billingDay,
  );

  final dueDate = getDueDateForBilling(
  billingDate,
  card.dueDay,
);

  return dueDate.difference(today).inDays;
}
static List<RecommendationResult> getRecommendations(
  List<CardModel> cards,
  DateTime today,
) {
  final recommendations = <RecommendationResult>[];

  for (final card in cards) {
    recommendations.add(
      RecommendationResult(
        card: card,
        interestFreeDays: getInterestFreeDays(
          today,
          card,
        ),
      ),
    );
  }

  recommendations.sort(
    (a, b) => b.interestFreeDays.compareTo(
      a.interestFreeDays,
    ),
  );

  return recommendations;
}
static List<PaymentEvent> getUpcomingPayments(
  List<CardModel> cards,
  DateTime today,
) {
  final List<PaymentEvent> payments = [];

  for (final card in cards) {
    final dueDate =
        RecommendationService.getUpcomingDueDate(
      today,
      card.dueDay,
    );

    payments.add(
      PaymentEvent(
        card: card,
        dueDate: dueDate,
        daysRemaining:
            dueDate.difference(today).inDays,
      ),
    );
  }

  payments.sort(
    (a, b) => a.dueDate.compareTo(b.dueDate),
  );

  return payments;
}
static DateTime _safeDate(
  int year,
  int month,
  int day,
) {
  // Last day of the requested month
  final lastDay = DateTime(year, month + 1, 0).day;

  return DateTime(
    year,
    month,
    day > lastDay ? lastDay : day,
  );
}
}
