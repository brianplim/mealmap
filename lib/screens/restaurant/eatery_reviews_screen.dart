import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class EateryReviewsScreen extends StatefulWidget {
  final Eatery eatery;

  const EateryReviewsScreen({super.key, required this.eatery});

  @override
  State<EateryReviewsScreen> createState() => _EateryReviewsScreenState();
}

class _EateryReviewsScreenState extends State<EateryReviewsScreen> {
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final fetched = await FirestoreService.getAllOrders();
    if (fetched.isNotEmpty && mounted) {
      globalOrders.clear();
      globalOrders.addAll(fetched);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter reviews strictly for this eatery/merchant name only
    final eateryReviews = globalOrders.where((order) {
      final matchesEatery = order.eateryName.toLowerCase().trim() == widget.eatery.name.toLowerCase().trim();
      final hasRatingData = order.userRating != null ||
          (order.reviewComment != null && order.reviewComment!.isNotEmpty) ||
          (order.reviewImagePath != null && order.reviewImagePath!.isNotEmpty);
      return matchesEatery && hasRatingData;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${widget.eatery.name} Reviews'),
        backgroundColor: const Color(0xFF0F7A5B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Rating Banner Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF0F7A5B),
            child: Column(
              children: [
                Text(
                  widget.eatery.rating > 0 ? '${widget.eatery.rating} ★' : '0.0 ★',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${eateryReviews.length} Verified Student Reviews for ${widget.eatery.name}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: eateryReviews.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No reviews yet for ${widget.eatery.name}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first student to place an order and leave feedback with a photo!',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: eateryReviews.length,
                    itemBuilder: (context, index) {
                      final order = eateryReviews[index];
                      final rating = order.userRating ?? 5;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1.5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFFECF7EF),
                                    radius: 18,
                                    child: const Icon(Icons.person, color: Color(0xFF0F7A5B), size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Student Reviewer',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          order.itemName,
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < rating ? Icons.star : Icons.star_border,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (order.reviewComment != null && order.reviewComment!.trim().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '"${order.reviewComment}"',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                              if (order.reviewImagePath != null && order.reviewImagePath!.trim().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: order.reviewImagePath!.startsWith('http')
                                      ? Image.network(
                                          order.reviewImagePath!,
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(order.reviewImagePath!),
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
