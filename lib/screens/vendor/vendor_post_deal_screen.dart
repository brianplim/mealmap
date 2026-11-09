import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/app_models.dart';

class VendorPostDealScreen extends StatefulWidget {
  const VendorPostDealScreen({super.key});

  @override
  State<VendorPostDealScreen> createState() => _VendorPostDealScreenState();
}

class _VendorPostDealScreenState extends State<VendorPostDealScreen> {
  final _eateryNameController = TextEditingController(text: 'ACES Canteen Bites');
  final _dealTitleController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  String _imageUrl = 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=400&q=80';

  @override
  void dispose() {
    _eateryNameController.dispose();
    _dealTitleController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageUrl = pickedFile.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food photo selected from gallery!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image picker note: using preset photo (${e.toString()})')),
        );
      }
    }
  }

  void _showPresetImagePicker() {
    final presets = [
      'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Food Photo'),
          content: SizedBox(
            width: 300,
            height: 250,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final url = presets[index];
                return GestureDetector(
                  onTap: () {
                    setState(() => _imageUrl = url);
                    Navigator.pop(context);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(url, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage();
              },
              child: const Text('Upload from Gallery'),
            ),
          ],
        );
      },
    );
  }

  void _showVendorOrdersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Student Orders & Notifications'),
              content: SizedBox(
                width: 420,
                height: 420,
                child: globalOrders.isEmpty
                    ? const Center(child: Text('No student orders yet.'))
                    : ListView.builder(
                        itemCount: globalOrders.length,
                        itemBuilder: (context, index) {
                          final order = globalOrders[index];
                          final isReceived = order.status.contains('Taken') || order.status.contains('Delivered') || order.status.contains('Received');
                          final isPreparing = order.status.contains('Preparing');
                          final isDelivering = order.status.contains('Delivery') || order.status.contains('Out');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B))),
                                      const Spacer(),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: isReceived,
                                            onChanged: null,
                                            activeColor: Colors.green,
                                          ),
                                          Text(
                                            isReceived ? 'Received' : 'Not Received',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isReceived ? Colors.green : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(order.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('${order.eateryName} • ${order.price} • ${order.fulfillmentType}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text('Status: ${order.status}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E2D2A))),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: isReceived ? null : () {
                                          setState(() {
                                            order.status = 'Preparing order';
                                          });
                                          setStateDialog(() {});
                                        },
                                        icon: Icon(Icons.kitchen, size: 14, color: isReceived ? Colors.grey : (isPreparing ? const Color(0xFF0F7A5B) : Colors.grey)),
                                        label: const Text('Preparing', style: TextStyle(fontSize: 11)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isReceived ? Colors.grey : (isPreparing ? const Color(0xFF0F7A5B) : Colors.grey),
                                          side: BorderSide(color: isReceived ? Colors.grey[300]! : (isPreparing ? const Color(0xFF0F7A5B) : Colors.grey[300]!)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: isReceived ? null : () {
                                          setState(() {
                                            order.status = 'Out for Delivery';
                                          });
                                          setStateDialog(() {});
                                        },
                                        icon: Icon(Icons.delivery_dining, size: 14, color: isReceived ? Colors.grey : (isDelivering ? Colors.blue : Colors.grey)),
                                        label: const Text('Delivering', style: TextStyle(fontSize: 11)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isReceived ? Colors.grey : (isDelivering ? Colors.blue : Colors.grey),
                                          side: BorderSide(color: isReceived ? Colors.grey[300]! : (isDelivering ? Colors.blue : Colors.grey[300]!)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPostDealDialog(BuildContext context) {
    _dealTitleController.clear();
    _priceController.clear();
    _discountController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Post Daily Special & Discount'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _dealTitleController,
                        decoration: const InputDecoration(labelText: 'Daily Special / Menu Item', hintText: 'e.g. Special Pork Adobo'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price', hintText: 'e.g. ₱75'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _discountController,
                        decoration: const InputDecoration(labelText: 'Student Discount Description', hintText: 'e.g. 20% OFF with valid student ID'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Food Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          _showPresetImagePicker();
                        },
                        child: Container(
                          height: 110,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _imageUrl.startsWith('http')
                                    ? Image.network(_imageUrl, fit: BoxFit.cover)
                                    : Image.file(File(_imageUrl), fit: BoxFit.cover),
                                Container(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  child: const Center(
                                    child: Text('Tap to Change Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F7A5B), foregroundColor: Colors.white),
                  onPressed: () {
                    if (_dealTitleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter deal title')));
                      return;
                    }

                    final newEatery = Eatery(
                      id: 'vendor-${DateTime.now().millisecondsSinceEpoch}',
                      name: _eateryNameController.text.trim(),
                      cuisine: 'Local Special',
                      distance: 0.1,
                      rating: 5.0,
                      reviewsCount: 1,
                      imageUrl: _imageUrl,
                      description: _discountController.text.trim().isNotEmpty ? _discountController.text.trim() : 'Special student offer!',
                      hasStudentDiscount: true,
                      menu: [
                        MenuItem(
                          name: _dealTitleController.text.trim(),
                          price: _priceController.text.trim().isNotEmpty ? _priceController.text.trim() : '₱75',
                          imageUrl: _imageUrl,
                        ),
                      ],
                    );

                    mockEateries.insert(0, newEatery);
                    Navigator.pop(context);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deal published successfully to student feed!')),
                    );
                  },
                  child: const Text('Publish'),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    'Vendor Dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).cardColor,
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none, color: Color(0xFF0F7A5B)),
                          tooltip: 'Student Orders & Notifications',
                          onPressed: () => _showVendorOrdersDialog(context),
                        ),
                      ),
                      if (globalOrders.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${globalOrders.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Dashboard Stats Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F7A5B), Color(0xFF12A66B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront, color: Colors.white, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _eateryNameController.text.trim(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statBox('Active Deals', '${mockEateries.length}'),
                            _statBox('Student Orders', '${globalOrders.length}'),
                            _statBox('Views Today', '142'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quick Actions Grid
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E2D2A)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showPostDealDialog(context),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Post Deal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F7A5B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showVendorOrdersDialog(context),
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('View Orders'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0F7A5B),
                            side: const BorderSide(color: Color(0xFF0F7A5B)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Active Eatery Listings & Specials',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E2D2A)),
                  ),
                  const SizedBox(height: 12),
                  ...mockEateries.map((eatery) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                eatery.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => placeholderImage(width: 50, height: 50),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eatery.name,
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    eatery.description,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF6E7D79)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() {
                                  mockEateries.removeWhere((item) => item.id == eatery.id);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Removed ${eatery.name}')),
                                );
                              },
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
