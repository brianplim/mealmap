import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/app_models.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> uploadEatery(Eatery eatery, LatLng location) async {
    try {
      await _db.collection('eateries').doc(eatery.id).set({
        'id': eatery.id,
        'name': eatery.name,
        'cuisine': eatery.cuisine,
        'distance': eatery.distance,
        'rating': eatery.rating,
        'reviewsCount': eatery.reviewsCount,
        'imageUrl': eatery.imageUrl,
        'description': eatery.description,
        'hasStudentDiscount': eatery.hasStudentDiscount,
        'lat': location.latitude,
        'lng': location.longitude,
        'menu': eatery.menu.map((m) => {'name': m.name, 'price': m.price, 'imageUrl': m.imageUrl}).toList(),
      });
    } catch (e) {
      debugPrint('Firestore uploadEatery error: $e');
    }
  }

  static Future<void> deleteEatery(String id) async {
    try {
      await _db.collection('eateries').doc(id).delete();
    } catch (e) {
      debugPrint('Firestore deleteEatery error: $e');
    }
  }

  static Future<void> uploadOrder(FoodOrder order) async {
    try {
      await _db.collection('orders').doc(order.id).set({
        'id': order.id,
        'eateryName': order.eateryName,
        'itemName': order.itemName,
        'price': order.price,
        'fulfillmentType': order.fulfillmentType,
        'status': order.status,
        'timestamp': order.timestamp,
      });
    } catch (e) {
      debugPrint('Firestore uploadOrder error: $e');
    }
  }

  static Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _db.collection('orders').doc(id).update({'status': status});
    } catch (e) {
      debugPrint('Firestore updateOrderStatus error: $e');
    }
  }

  static Future<void> saveVendorProfile(String uid, String businessName, String handle, String logoUrl) async {
    try {
      await _db.collection('vendors').doc(uid).set({
        'businessName': businessName,
        'handle': handle,
        'logoUrl': logoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveVendorProfile error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getVendorProfile(String uid) async {
    try {
      final doc = await _db.collection('vendors').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Firestore getVendorProfile error: $e');
    }
    return null;
  }
}
