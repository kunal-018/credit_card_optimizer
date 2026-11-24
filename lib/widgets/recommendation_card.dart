import 'package:flutter/material.dart';
import 'package:credit_card_optimizer/models/recommendation_result.dart';
import 'package:intl/intl.dart';
import '../services/recommendation_service.dart';

class RecommendationCard extends StatefulWidget {
  final List<RecommendationResult> recommendations;

  const RecommendationCard({super.key, required this.recommendations});

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final best = widget.recommendations.first;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: Colors.amber,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Best Card Today",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                best.card.cardName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      title: "Statement",
                      value: DateFormat('dd MMM').format(
                        RecommendationService.getNextBillingDate(
                          DateTime.now(),
                          best.card.billingDay,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildInfoChip(
                      title: "Due",
                      value: DateFormat('dd MMM').format(
                        RecommendationService.getDueDateForBilling(
                          RecommendationService.getNextBillingDate(
                            DateTime.now(),
                            best.card.billingDay,
                          ),
                          best.card.dueDay,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "${best.interestFreeDays} Interest-Free Days",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _expanded
                    ? Column(
                        children: [
                          const Divider(height: 24),

                          ...List.generate(widget.recommendations.length, (
                            index,
                          ) {
                            final recommendation =
                                widget.recommendations[index];

                            final bestDays =
                                widget.recommendations.first.interestFreeDays;

                            final difference =
                                bestDays - recommendation.interestFreeDays;

                            return _buildRecommendationTile(
                              recommendation,
                              index,
                              difference,
                            );
                          }),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              // We'll add content here next
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(
  RecommendationResult recommendation,
  int index,
  int difference,
) {
  final statementDate = RecommendationService.getNextBillingDate(
    DateTime.now(),
    recommendation.card.billingDay,
  );

  final dueDate = RecommendationService.getDueDateForBilling(
    statementDate,
    recommendation.card.dueDay,
  );

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getRank(index),
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.card.cardName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Stmt ${DateFormat('dd MMM').format(statementDate)}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(width: 16),

                      const Icon(
                        Icons.event_available,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Due ${DateFormat('dd MMM').format(dueDate)}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${recommendation.interestFreeDays} d",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                if (difference > 0)
                  Text(
                    "-$difference d",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),

        if (index != widget.recommendations.length - 1)
          const Divider(height: 24),
      ],
    ),
  );
}

  String _getRank(int index) {
    switch (index) {
      case 0:
        return "🥇";
      case 1:
        return "🥈";
      case 2:
        return "🥉";
      default:
        return "${index + 1}.";
    }
  }

  Widget _buildInfoChip({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
