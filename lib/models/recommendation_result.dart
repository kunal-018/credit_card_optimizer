import 'package:credit_card_optimizer/models/card_model.dart';

class RecommendationResult {
  final CardModel card;
  final int interestFreeDays;

  const RecommendationResult({
    required this.card,
    required this.interestFreeDays,
  });
}