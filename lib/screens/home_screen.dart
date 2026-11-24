import 'package:flutter/material.dart';
import 'package:credit_card_optimizer/database/database_helper.dart';
import 'package:credit_card_optimizer/models/card_model.dart';
import 'package:credit_card_optimizer/screens/add_card_screen.dart';
import 'package:credit_card_optimizer/widgets/card_tile.dart';
import 'package:credit_card_optimizer/services/recommendation_service.dart';
import 'package:credit_card_optimizer/models/recommendation_result.dart';
import 'package:credit_card_optimizer/models/dashboard_event.dart';
import 'package:credit_card_optimizer/services/dashboard_service.dart';
import 'package:credit_card_optimizer/models/payment_event.dart';
import 'package:credit_card_optimizer/widgets/next_statement_card.dart';
import 'package:credit_card_optimizer/widgets/payment_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/recommendation_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CardModel> cards = [];
  bool isLoading = true;
  int currentPage = 0;
  DashboardEvent? nextStatement;
  List<PaymentEvent> upcomingPayments = [];
  List<RecommendationResult> recommendations = [];
  final PageController _cardPageController = PageController(
    viewportFraction: 0.92,
  );
  final PageController _paymentPageController = PageController(
    viewportFraction: 0.95,
  );
  void _sortPayments() {
    upcomingPayments.sort((a, b) {
      // Unpaid payments first
      if (a.isPaid != b.isPaid) {
        return a.isPaid ? 1 : -1;
      }

      // Then sort by due date (earliest first)
      return a.dueDate.compareTo(b.dueDate);
    });
  }

  Future<void> loadCards() async {
    final data = await DatabaseHelper.instance.getAllCards();

    final bestCard = RecommendationService.getRecommendations(
      data,
      DateTime.now(),
    );
    final nextStatementEvent = DashboardService.getNextStatement(
      data,
      DateTime.now(),
    );
    final upcomingPaymentList = RecommendationService.getUpcomingPayments(
      data,
      DateTime.now(),
    );
    setState(() {
      cards = data;
      recommendations = bestCard;
      nextStatement = nextStatementEvent;
      upcomingPayments = upcomingPaymentList;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ).createShader(bounds),
              child: const Text(
                "Credit Card Optimizer",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
            Text(
              "by Kunal",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (recommendations.isNotEmpty &&
                      recommendations.first.card != false)
                    RecommendationCard(recommendations: recommendations),

                  if (nextStatement != null)
                    NextStatementCard(event: nextStatement!),
                  const SizedBox(height: 12),
                  if (upcomingPayments.isNotEmpty)
                    SizedBox(
                      height: 160,
                      child: PageView.builder(
                        controller: _paymentPageController,
                        itemCount: upcomingPayments.length,
                        itemBuilder: (context, index) {
                          return PaymentCard(
                            payment: upcomingPayments[index],
                            onMarkPaid: () async {
                              final payment = upcomingPayments[index];

                              final newStatus = !payment.isPaid;

                              await DatabaseHelper.instance.updatePaymentStatus(
                                cardId: payment.card.id!,
                                dueDate: payment.dueDate,
                                isPaid: newStatus,
                              );

                              setState(() {
                                payment.isPaid = newStatus;
                                _sortPayments();
                              });

                              final newIndex = upcomingPayments.indexOf(
                                payment,
                              );

                              if (newIndex != -1) {
                                _paymentPageController.animateToPage(
                                  newIndex,
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 6),

                  Center(
                    child: SmoothPageIndicator(
                      controller: _paymentPageController,
                      count: upcomingPayments.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 8,
                        activeDotColor: Colors.green.shade700,
                        dotColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: const [
                        Text(
                          "Your Cards",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 260,
                    child: PageView.builder(
                      controller: _cardPageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];

                        return CardTile(
                          card: card,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddCardScreen(card: card),
                              ),
                            );

                            if (result == true) {
                              await loadCards();
                            }
                          },
                          onDelete: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Delete Card"),
                                  content: Text(
                                    "Are you sure you want to delete '${card.cardName}'?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldDelete != true) return;

                            await DatabaseHelper.instance.deleteCard(card.id!);

                            await loadCards();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${card.cardName} deleted successfully",
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      cards.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == index ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? Colors.indigo
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCardScreen()),
          );

          if (result == true) {
            await loadCards();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Card added successfully"),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
