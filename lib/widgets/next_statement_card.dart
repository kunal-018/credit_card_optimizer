import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_event.dart';

class NextStatementCard extends StatelessWidget {
  final DashboardEvent event;

  const NextStatementCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias, // Important
        child: Row(
          children: [
            // Left Accent Strip
            Container(width: 5, color: Colors.blue.shade700),

            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Icon(Icons.receipt_long, size: 18, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Text(
                          "Next Statement",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Card + Days
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.card.cardName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Text(
                          _daysText(event.daysRemaining),
                          style: TextStyle(
                            color: _getDaysColor(event.daysRemaining),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      DateFormat('dd MMM yyyy').format(event.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDaysColor(int days) {
    if (days <= 1) return Colors.red.shade700;
    if (days <= 3) return Colors.orange.shade700;
    if (days <= 7) return Colors.amber.shade800;
    return Colors.green.shade700;
  }

  String _daysText(int days) {
    if (days == 0) return "Today";
    if (days == 1) return "Tomorrow";
    if (days <= 7) return "In $days days";
    return "$days days";
  }
}
