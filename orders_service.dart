import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersService {
  OrdersService._();

  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Your Firestore collection name (match your screenshot)
  static const String ordersCol = "Orders";

  static String? get _uid => _auth.currentUser?.uid;

  /// ✅ Create / Save Order (called from Checkout after user clicks Place Order)
  /// If you already generate orderId like RG-10291, pass it in.
  /// If you want Firestore to auto-generate, pass null and we create one.
  static Future<String> createOrder({
    String? orderId,
    required Map<String, dynamic> orderData,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception("User not logged in");

    final docRef = orderId == null
        ? _db.collection(ordersCol).doc()
        : _db.collection(ordersCol).doc(orderId);

    final now = FieldValue.serverTimestamp();

    final payload = <String, dynamic>{
      ...orderData,

      // ✅ always store these
      "orderId": docRef.id,
      "userId": uid,
      "createdAt": now,
      "updatedAt": now,

      // ✅ default values if not provided
      "status": orderData["status"] ?? "pending",
      "riderId": orderData["riderId"] ?? "",
      "riderName": orderData["riderName"] ?? "",
      "riderPhone": orderData["riderPhone"] ?? "",

      // Live tracking defaults
      "riderLiveLat": orderData["riderLiveLat"] ?? 0,
      "riderLiveLng": orderData["riderLiveLng"] ?? 0,
    };

    await docRef.set(payload, SetOptions(merge: true));
    return docRef.id;
  }

  /// ✅ Update entire order (merge)
  static Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    await _db.collection(ordersCol).doc(orderId).set(
          {
            ...data,
            "updatedAt": FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }

  /// ✅ Update status only
  static Future<void> updateStatus(String orderId, String status) async {
    await _db.collection(ordersCol).doc(orderId).update({
      "status": status,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Assign rider (when rider accepts)
  static Future<void> assignRider({
    required String orderId,
    required String riderId,
    required String riderName,
    required String riderPhone,
  }) async {
    await _db.collection(ordersCol).doc(orderId).update({
      "riderId": riderId,
      "riderName": riderName,
      "riderPhone": riderPhone,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Update rider live location (called often from rider app/module)
  static Future<void> updateRiderLocation({
    required String orderId,
    required double lat,
    required double lng,
  }) async {
    await _db.collection(ordersCol).doc(orderId).update({
      "riderLiveLat": lat,
      "riderLiveLng": lng,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Stream ONE order (for Order Details / Tracking page)
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamOrder(String orderId) {
    return _db.collection(ordersCol).doc(orderId).snapshots();
  }

  /// ✅ Stream user orders (for Orders page)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamMyOrders() {
    final uid = _uid;
    if (uid == null) {
      // empty stream if user is not logged in
      return const Stream.empty();
    }

    return _db
        .collection(ordersCol)
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  /// ✅ Fetch once (if you don’t want stream)
  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getMyOrdersOnce() async {
    final uid = _uid;
    if (uid == null) return [];

    final snap = await _db
        .collection(ordersCol)
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .get();

    return snap.docs;
  }
}