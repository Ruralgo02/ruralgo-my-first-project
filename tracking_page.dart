import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingPage extends StatelessWidget {
  static const routeName = '/tracking';

  final String orderId;

  const TrackingPage({
    super.key,
    required this.orderId,
  });

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _bg = Color(0xFFE9FBF6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text("Order Status"),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("Orders")
            .doc(orderId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text("Tracking error: ${snap.error}"),
            );
          }

          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snap.data!.data();

          if (data == null) {
            return const Center(
              child: Text("Order not found."),
            );
          }

          final status = (data["status"] ?? "pending").toString();
          final ref = (data["orderId"] ?? orderId).toString();
          final vendorName = (data["vendorName"] ?? "").toString().trim();
          final orderType = (data["orderType"] ?? "goods").toString();

          final riderLat = (data["riderLiveLat"] as num?)?.toDouble();
          final riderLng = (data["riderLiveLng"] as num?)?.toDouble();

          final dropoffLat = (data["dropoffLat"] as num?)?.toDouble();
          final dropoffLng = (data["dropoffLng"] as num?)?.toDouble();

          final pickupText = (data["pickupText"] ?? "").toString().trim();
          final dropoffText = (data["dropoffText"] ?? "").toString().trim();

          final hasRealRiderLocation = riderLat != null &&
              riderLng != null &&
              !(riderLat == 0 && riderLng == 0);

          final hasDropoff = dropoffLat != null && dropoffLng != null;

          int? etaMinutes;
          if (hasRealRiderLocation && hasDropoff) {
            etaMinutes = _calculateEtaMinutes(
              riderLat!,
              riderLng!,
              dropoffLat!,
              dropoffLng!,
            );
          }

          final title = _buildTitle(vendorName, orderType);
          final subtitle = _buildSubtitle(orderType, pickupText, dropoffText);
          final step = _statusToStep(status);
          final statusText = _prettyStatus(status);
          final statusHint = _statusHint(status, hasRealRiderLocation);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _brandGreen.withOpacity(0.10)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.03),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _brandGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "Ref: #${_cleanRef(ref)}",
                        style: const TextStyle(
                          color: _brandGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _brandGreen.withOpacity(0.10)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _statusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusText,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: _statusColor(status),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusHint,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _brandGreen.withOpacity(0.10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Delivery progress",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OrderStepper(
                      step: step,
                      brandGreen: _brandGreen,
                    ),
                  ],
                ),
              ),

              if (etaMinutes != null &&
                  status.toLowerCase() != "delivered" &&
                  status.toLowerCase() != "arrived") ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _brandGreen.withOpacity(0.10)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: _brandGreen,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Estimated arrival: $etaMinutes mins",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _brandGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (pickupText.isNotEmpty || dropoffText.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _brandGreen.withOpacity(0.10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Delivery details",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      if (pickupText.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          "Pickup: $pickupText",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (dropoffText.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Drop-off: $dropoffText",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              if (hasRealRiderLocation) ...[
                const SizedBox(height: 14),
                Container(
                  height: 280,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _brandGreen.withOpacity(0.10)),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(riderLat!, riderLng!),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("rider"),
                        position: LatLng(riderLat, riderLng),
                        infoWindow: const InfoWindow(
                          title: "Rider",
                          snippet: "Live location",
                        ),
                      ),
                      if (hasDropoff)
                        Marker(
                          markerId: const MarkerId("customer"),
                          position: LatLng(dropoffLat!, dropoffLng!),
                          infoWindow: const InfoWindow(
                            title: "Delivery location",
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue,
                          ),
                        ),
                    },
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
              ],

              if (status.toLowerCase() == "arrived") ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.orange.withOpacity(0.25)),
                  ),
                  child: const Text(
                    "Your rider has arrived. Please be ready to receive your order.",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],

              if (status.toLowerCase() == "delivered") ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.green.withOpacity(0.25)),
                  ),
                  child: const Text(
                    "Order delivered successfully.",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
  static String _buildTitle(String vendorName, String orderType) {
    if (vendorName.isNotEmpty) {
      return "$vendorName Order";
    }

    final type = orderType.toLowerCase();

    if (type == "food" || type == "restaurant") return "Restaurant Order";
    if (type == "supermarket") return "Supermarket Order";
    if (type == "farm") return "Farm Produce Order";
    if (type == "clothing") return "Clothing Order";
    if (type == "parcel") return "Parcel Delivery";

    return "Order";
  }

  static String _buildSubtitle(
    String orderType,
    String pickupText,
    String dropoffText,
  ) {
    final type = orderType.toLowerCase();

    if (type == "parcel") {
      if (pickupText.isNotEmpty && dropoffText.isNotEmpty) {
        return "From pickup point to delivery location";
      }
      return "Parcel delivery in progress";
    }

    if (type == "food" || type == "restaurant") {
      return "Food order tracking";
    }
    if (type == "supermarket") {
      return "Supermarket order tracking";
    }
    if (type == "farm") {
      return "Farm produce delivery";
    }
    if (type == "clothing") {
      return "Fashion delivery tracking";
    }

    return "Live order status";
  }

  static String _cleanRef(String orderId) {
    final cleaned = orderId.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.isEmpty ? orderId : cleaned;
  }

  static int _statusToStep(String status) {
    final s = status.toLowerCase().trim();

    if (s == "pending" || s == "confirmed") return 0;
    if (s == "preparing") return 1;
    if (s == "dispatch" || s == "dispatched" || s == "out_for_delivery") {
      return 2;
    }
    if (s == "arrived" || s == "delivered") return 3;

    return 0;
  }

  static String _prettyStatus(String status) {
    final s = status.toLowerCase().trim();

    if (s == "pending") return "Pending rider pickup";
    if (s == "confirmed") return "Order confirmed";
    if (s == "preparing") return "Vendor is preparing your order";
    if (s == "dispatch" || s == "dispatched") return "Rider picked up your order";
    if (s == "out_for_delivery") return "Rider is on the way";
    if (s == "arrived") return "Driver arrived";
    if (s == "delivered") return "Delivered";
    if (s == "accepted") return "Rider accepted your order";

    return status;
  }

  static String _statusHint(String status, bool hasRealRiderLocation) {
    final s = status.toLowerCase().trim();

    if (s == "pending") {
      return hasRealRiderLocation
          ? "A rider is being positioned for your order."
          : "We are locating the nearest available rider.";
    }
    if (s == "confirmed") return "Your order has been received successfully.";
    if (s == "preparing") return "The vendor is getting your items ready.";
    if (s == "dispatch" || s == "dispatched") {
      return "Your order has left the pickup point.";
    }
    if (s == "out_for_delivery") {
      return "Your rider is heading to your delivery location.";
    }
    if (s == "arrived") return "Please get ready to receive your order.";
    if (s == "delivered") return "This order was completed successfully.";
    if (s == "accepted") return "A rider has accepted your order.";

    return "Your order is in progress.";
  }

  static Color _statusColor(String status) {
    final s = status.toLowerCase().trim();

    if (s == "pending") return Colors.orange;
    if (s == "arrived") return Colors.orange;
    if (s == "delivered") return Colors.green;
    if (s == "accepted" ||
        s == "confirmed" ||
        s == "preparing" ||
        s == "dispatch" ||
        s == "dispatched" ||
        s == "out_for_delivery") {
      return _brandGreen;
    }

    return Colors.black87;
  }

  static int _calculateEtaMinutes(
    double riderLat,
    double riderLng,
    double dropLat,
    double dropLng,
  ) {
    const earthRadius = 6371.0;

    final dLat = _degToRad(dropLat - riderLat);
    final dLng = _degToRad(dropLng - riderLng);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(riderLat)) *
            cos(_degToRad(dropLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distanceKm = earthRadius * c;

    const avgSpeedKmPerHour = 30.0;
    final minutes = ((distanceKm / avgSpeedKmPerHour) * 60).round();

    return minutes < 1 ? 1 : minutes;
  }

  static double _degToRad(double deg) {
    return deg * pi / 180;
  }
}

class OrderStepper extends StatelessWidget {
  final int step;
  final Color brandGreen;

  const OrderStepper({
    super.key,
    required this.step,
    required this.brandGreen,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ["Confirmed", "Preparing", "Dispatch", "Delivered"];

    return Row(
      children: List.generate(labels.length, (i) {
        final done = i <= step;

        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 8,
                margin: EdgeInsets.only(
                  left: i == 0 ? 0 : 6,
                  right: i == labels.length - 1 ? 0 : 6,
                ),
                decoration: BoxDecoration(
                  color: done ? brandGreen : Colors.black12,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: done ? brandGreen.withOpacity(0.95) : Colors.black45,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}