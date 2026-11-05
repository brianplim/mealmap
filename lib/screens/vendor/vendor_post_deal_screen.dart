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
  final _eateryNameController = TextEditingController();
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

  void _postDeal() {
    if (_eateryNameController.text.trim().isEmpty || _dealTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in eatery name and deal title')),
      );
      return;
    }

    final newEatery = Eatery(
      id: 'vendor-${DateTime.now().millisecondsSinceEpoch}',
      name: _eateryNameController.text.trim(),
      cuisine: 'Local Special',
      distance: 0.2,
      rating: 5.0,
      reviewsCount: 1,
      imageUrl: _imageUrl,
      description: _discountController.text.trim().isNotEmpty
          ? _discountController.text.trim()
          : 'Special daily offering near ACES Tagum College.',
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deal posted successfully! Now live on student feeds and map.')),
    );
    Navigator.pop(context);
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
                    'Eatery Vendor Portal',
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECF7EF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFB5E3C7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront, color: Color(0xFF0F7A5B), size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Post Daily Special & Discount',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Color(0xFF0F7A5B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Your deal will instantly broadcast to all students near ACES Tagum College!',
                                style: TextStyle(fontSize: 12, color: Color(0xFF3D554F)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _eateryNameController,
                    decoration: InputDecoration(
                      labelText: 'Eatery / Business Name',
                      hintText: 'e.g. ACES Canteen Bites',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dealTitleController,
                    decoration: InputDecoration(
                      labelText: 'Daily Special / Menu Item',
                      hintText: 'e.g. Special Pork Adobo Meal',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      hintText: 'e.g. ₱75',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      labelText: 'Student Discount Promo description',
                      hintText: 'e.g. 20% OFF with valid student ID',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Food Photo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showPresetImagePicker,
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF0F7A5B), width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _imageUrl.startsWith('http')
                                ? Image.network(_imageUrl, fit: BoxFit.cover)
                                : Image.file(File(_imageUrl), fit: BoxFit.cover),
                            Container(
                              color: Colors.black.withValues(alpha: 0.35),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.camera_alt, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Tap to Choose Food Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _postDeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F7A5B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Publish Deal to Student Feed',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
