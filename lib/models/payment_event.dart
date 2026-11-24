import 'card_model.dart';

class PaymentEvent {
  final CardModel card;
  final DateTime dueDate;
  final int daysRemaining;
  bool isPaid;

  PaymentEvent({
    required this.card,
    required this.dueDate,
    required this.daysRemaining,
    this.isPaid = false,
  });
}