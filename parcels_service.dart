import 'package:cloud_firestore/cloud_firestore.dart';

class ParcelsService {
  static final _db = FirebaseFirestore.instance;

  static Future<String> createParcelOrder({
    required Map<String, dynamic> payload,
  }) async {
    final doc = await _db.collection('parcels_orders').add({
      ...payload,
      'status': 'draft',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  static Future<void> confirmOrder(String orderId) async {
    await _db.collection('parcels_orders').doc(orderId).update({
      'status': 'confirmed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}