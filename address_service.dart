import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  /// ================= SAVE ADDRESS =================
  static Future<void> saveAddress({
    required String label,
    required String title,
    required String subtitle,
    required String fullAddress,
    required double lat,
    required double lng,
    String? moreInfo,
  }) async {
    if (_uid == null) return;

    await _db
        .collection("users")
        .doc(_uid)
        .collection("addresses")
        .add({
      "label": label,
      "title": title,
      "subtitle": subtitle,
      "fullAddress": fullAddress,
      "moreInfo": moreInfo ?? "",
      "lat": lat,
      "lng": lng,
      "createdAt": FieldValue.serverTimestamp(),
      "lastUsedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ================= GET ADDRESSES =================
  static Stream<QuerySnapshot> getAddresses() {
    if (_uid == null) {
      return const Stream.empty();
    }

    return _db
        .collection("users")
        .doc(_uid)
        .collection("addresses")
        .orderBy("lastUsedAt", descending: true)
        .snapshots();
  }

  /// ================= MARK AS USED =================
  static Future<void> markAsUsed(String docId) async {
    if (_uid == null) return;

    await _db
        .collection("users")
        .doc(_uid)
        .collection("addresses")
        .doc(docId)
        .update({
      "lastUsedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ================= DELETE ADDRESS =================
  static Future<void> deleteAddress(String docId) async {
    if (_uid == null) return;

    await _db
        .collection("users")
        .doc(_uid)
        .collection("addresses")
        .doc(docId)
        .delete();
  }
}