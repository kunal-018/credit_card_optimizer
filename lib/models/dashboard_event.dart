import 'package:credit_card_optimizer/models/card_model.dart';

class DashboardEvent {
  final CardModel card;
  final DateTime date;
  final int daysRemaining;

  const DashboardEvent({
    required this.card,
    required this.date,
    required this.daysRemaining,
  });
}