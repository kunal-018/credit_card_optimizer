import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_event.dart';

class PaymentCard extends StatelessWidget {
  final PaymentEvent payment;
  final VoidCallback onMarkPaid;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.onMarkPaid,
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
            Container(width: 5, color: Colors.green.shade700),

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
                        Icon(Icons.payment, size: 18),
                        SizedBox(width: 8),

                        const Text("Upcoming Payment"),

                        Spacer(),

                        Text(
                          _daysText(payment.daysRemaining),
                          style: TextStyle(
                            color: _getDaysColor(payment.daysRemaining),
                            fontWeight: FontWeight.bold,
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
                            payment.card.cardName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        FilledButton.tonal(
                          onPressed: onMarkPaid,
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 32),
                          ),
                          child: Text(payment.isPaid ? "Undo" : "Mark Paid"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Due: ${DateFormat('dd MMM yyyy').format(payment.dueDate)}",
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
