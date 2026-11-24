import 'package:credit_card_optimizer/models/card_model.dart';
import 'package:credit_card_optimizer/models/dashboard_event.dart';
import 'package:credit_card_optimizer/services/recommendation_service.dart';

class DashboardService {
static DashboardEvent? getNextStatement(
  List<CardModel> cards,
  DateTime today,
) {
  if (cards.isEmpty) return null;

  CardModel selectedCard = cards.first;

  DateTime nearestDate =
      RecommendationService.getNextBillingDate(
    today,
    selectedCard.billingDay,
  );

  for (final card in cards.skip(1)) {
    final billingDate =
        RecommendationService.getNextBillingDate(
      today,
      card.billingDay,
    );

    if (billingDate.isBefore(nearestDate)) {
      nearestDate = billingDate;
      selectedCard = card;
    }
  }

  return DashboardEvent(
    card: selectedCard,
    date: nearestDate,
    daysRemaining:
        nearestDate.difference(today).inDays,
  );
}
static DashboardEvent? getUpcomingPayment(
  List<CardModel> cards,
  DateTime today,
) {
  if (cards.isEmpty) return null;

  CardModel selectedCard = cards.first;

  DateTime nearestDueDate =
      RecommendationService.getUpcomingDueDate(
    today,
    selectedCard.dueDay,
  );

  for (final card in cards.skip(1)) {
    final dueDate =
        RecommendationService.getUpcomingDueDate(
      today,
      card.dueDay,
    );

    if (dueDate.isBefore(nearestDueDate)) {
      nearestDueDate = dueDate;
      selectedCard = card;
    }
  }

  return DashboardEvent(
    card: selectedCard,
    date: nearestDueDate,
    daysRemaining:
        nearestDueDate.difference(today).inDays,
  );
}

}