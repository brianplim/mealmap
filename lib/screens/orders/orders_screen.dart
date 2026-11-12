import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  void _showRatingDialog(BuildContext context, FoodOrder order) {
    int selectedStars = 5;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setRatingState) {
            return AlertDialog(
              title: Text('Rate ${order.itemName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How was your food from ${order.eateryName}?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      return IconButton(
                        icon: Icon(
                          starNum <= selectedStars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setRatingState(() {
                            selectedStars = starNum;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7A5B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      order.userRating = selectedStars;
                    });

                    final matches = mockEateries.where(
                      (e) => e.name.toLowerCase().trim() == order.eateryName.toLowerCase().trim(),
                    );
                    for (var eatery in matches) {
                      eatery.reviewsCount += 1;
                      eatery.ratingSum += selectedStars;
                      eatery.rating = double.parse((eatery.ratingSum / eatery.reviewsCount).toStringAsFixed(1));
                      FirestoreService.uploadEatery(eatery, eatery.location);
                    }
                    eateryNotifier.value = List.from(mockEateries);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thank you for rating $selectedStars stars for ${order.itemName}!')),
                    );
                  },
                  child: const Text('Submit Rating'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).cardColor,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Delivery & Orders Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: globalOrders.isEmpty
                  ? Center(
                      child: Text(
                        'No active orders yet.\nTap a menu item in any eatery to order!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: globalOrders.length,
                      itemBuilder: (context, index) {
                        final order = globalOrders[index];
                        final isTakenOrDelivered = order.status.contains('Taken') || order.status.contains('Delivered');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    order.id,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Color(0xFF0F7A5B),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: order.fulfillmentType == 'Delivery'
                                          ? Colors.blue.withValues(alpha: 0.1)
                                          : Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      order.fulfillmentType,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: order.fulfillmentType == 'Delivery' ? Colors.blue : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order.itemName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${order.eateryName} • ${order.price}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6E7D79)),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECF7EF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF0F7A5B)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Estimated Ready / Arrival Time: ${order.prepTime}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    isTakenOrDelivered ? Icons.check_circle : Icons.delivery_dining,
                                    size: 18,
                                    color: isTakenOrDelivered ? Colors.green : Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Status: ${order.status}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isTakenOrDelivered ? Colors.green : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (order.userRating != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('Your Rating: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ...List.generate(5, (i) => Icon(
                                      i < order.userRating! ? Icons.star : Icons.star_border,
                                      size: 16,
                                      color: Colors.amber,
                                    )),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      if (!isTakenOrDelivered) {
                                        setState(() {
                                          order.status = 'Food Taken / Delivered Successfully';
                                        });
                                        _showRatingDialog(context, order);
                                      } else {
                                        _showRatingDialog(context, order);
                                      }
                                    },
                                    icon: Icon(
                                      isTakenOrDelivered ? Icons.star : Icons.check,
                                      size: 16,
                                      color: isTakenOrDelivered ? Colors.amber[800] : const Color(0xFF0F7A5B),
                                    ),
                                    label: Text(
                                      order.userRating != null
                                          ? 'Rated ${order.userRating}★ (Change)'
                                          : (isTakenOrDelivered ? 'Rate Order' : 'Confirm Food Taken'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isTakenOrDelivered ? Colors.amber[800] : const Color(0xFF0F7A5B),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: isTakenOrDelivered ? Colors.amber[800]! : const Color(0xFF0F7A5B),
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
