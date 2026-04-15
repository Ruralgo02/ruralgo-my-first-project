import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

/// Tracks a rider's live GPS location and writes it to Firestore.
///
/// ✅ IMPORTANT:
/// - Firestore collection name must match what your TrackOrderPage reads.
///   If your app uses "Orders" (capital O), keep it "Orders" here too.
/// - If you use "orders" everywhere, change it to "orders" here (but be consistent).
class RiderLocationTracker {
  StreamSubscription<Position>? _sub;

  /// Change this ONLY if your whole app uses a different collection name.
  static const String ordersCollection = "Orders"; // ✅ match your database

  bool get isTracking => _sub != null;

  /// Start streaming location updates for this rider + order.
  ///
  /// Writes:
  /// riderId, riderLiveLat, riderLiveLng, riderLiveUpdatedAt
  ///
  /// Optional:
  /// heading (direction), speed (m/s), accuracy (m)
  Future<void> startTracking({
    required String orderId,
    required String riderId,
  }) async {
    if (orderId.trim().isEmpty) {
      throw Exception("orderId is empty.");
    }
    if (riderId.trim().isEmpty) {
      throw Exception("riderId is empty.");
    }

    // 1) Ensure GPS is ON
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("GPS is OFF. Please turn on Location.");
    }

    // 2) Permission flow
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        "Location permission denied forever. Please enable it in Settings.",
      );
    }

    // 3) Best-practice settings for delivery apps
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // ✅ update every 10 meters
    );

    // 4) Cancel any existing stream before starting a new one
    await stopTracking();

    // 5) Start streaming positions
    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) async {
        try {
          await FirebaseFirestore.instance
              .collection(ordersCollection)
              .doc(orderId)
              .set(
            {
              "riderId": riderId,
              "riderLiveLat": pos.latitude,
              "riderLiveLng": pos.longitude,
              "riderLiveUpdatedAt": FieldValue.serverTimestamp(),

              // Optional useful fields
              "riderLiveAccuracy": pos.accuracy,
              "riderLiveSpeed": pos.speed,
              "riderLiveHeading": pos.heading,
            },
            SetOptions(merge: true),
          );
        } catch (_) {
          // keep silent: avoid crashing stream on temporary network/firestore errors
        }
      },
      onError: (_) {
        // keep silent
      },
    );
  }

  /// Stop streaming updates.
  Future<void> stopTracking() async {
    await _sub?.cancel();
    _sub = null;
  }
}