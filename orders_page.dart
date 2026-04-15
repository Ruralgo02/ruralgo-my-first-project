import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class OrdersPage extends StatelessWidget {
  static const String routeName = '/orders';
  const OrdersPage({super.key});

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _brandBg = Color(0xFFE9FBF6);
  static const Color _cardBorder = Color(0x3300A082);
  static const Color _softText = Colors.black54;

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel order"),
        content: const Text(
          "This will mark the order as cancelled. Do you want to continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, cancel"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection("Orders").doc(orderId).update({
        "status": "cancelled",
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Order cancelled successfully")),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to cancel order: $e")),
      );
    }
  }

  Future<void> _deleteOrder(BuildContext context, String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete order"),
        content: const Text(
          "This will permanently remove the order. Do you want to continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection("Orders").doc(orderId).delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Order deleted successfully")),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to delete order: $e")),
      );
    }
  }

  bool _canCancel(String status) {
    final s = status.toLowerCase().trim();
    return s == "pending" || s == "confirmed" || s == "preparing";
  }

  bool _canDelete(String status) {
    final s = status.toLowerCase().trim();
    return s == "pending" || s == "cancelled";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _brandBg,
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("Orders")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text("Error loading orders: ${snap.error}"),
            );
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text("No orders yet."),
            );
          }

          final docs = snap.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();

              final firestoreDocId = doc.id;
              final orderRef = (data["orderId"] ?? doc.id).toString();

              final rawStatus = (data["status"] ?? "pending").toString();
              final orderType = (data["orderType"] ?? "goods").toString();
              final vendorName = (data["vendorName"] ?? "").toString().trim();
              final savedEta = (data["eta"] ?? "").toString().trim();

              final total = _asInt(data["total"]) ?? 0;
              final title = _buildTitle(data, orderType, vendorName);
              final subtitle = _buildSubtitle(data, orderType, vendorName);

              final riderLat = _asDouble(data["riderLiveLat"]);
              final riderLng = _asDouble(data["riderLiveLng"]);
              final dropoffLat = _asDouble(data["dropoffLat"]);
              final dropoffLng = _asDouble(data["dropoffLng"]);

              final double? distanceMeters = _distanceMeters(
                riderLat: riderLat,
                riderLng: riderLng,
                dropoffLat: dropoffLat,
                dropoffLng: dropoffLng,
              );

              final String statusText = _prettyStatus(
                rawStatus,
                distanceMeters: distanceMeters,
              );

              final String statusHint = _statusHint(
                rawStatus,
                distanceMeters: distanceMeters,
              );

              final String etaText = _buildEtaText(
                savedEta: savedEta,
                rawStatus: rawStatus,
                distanceMeters: distanceMeters,
              );

              final int step = _statusToStep(
                rawStatus,
                distanceMeters: distanceMeters,
              );

              final canCancel = _canCancel(rawStatus);
              final canDelete = _canDelete(rawStatus);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "₦$total",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _softText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Ref: #${_cleanRef(orderRef)}",
                            style: const TextStyle(
                              color: _softText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (etaText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _brandGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              etaText,
                              style: const TextStyle(
                                color: _brandGreen,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (distanceMeters != null &&
                        rawStatus.toLowerCase().trim() != "delivered") ...[
                      const SizedBox(height: 8),
                      Text(
                        "Rider is ${_distanceLabel(distanceMeters)} away",
                        style: const TextStyle(
                          color: _softText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _brandGreen.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _brandGreen.withOpacity(0.14),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _statusColor(
                                rawStatus,
                                distanceMeters: distanceMeters,
                              ),
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
                                    color: _statusColor(
                                      rawStatus,
                                      distanceMeters: distanceMeters,
                                    ),
                                  ),
                                ),
                                if (statusHint.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    statusHint,
                                    style: const TextStyle(
                                      color: _softText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    OrderStepper(
                      step: step,
                      brandGreen: _brandGreen,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _brandGreen,
                          side: BorderSide(
                            color: _brandGreen.withOpacity(0.25),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                etaText.isEmpty
                                    ? statusText
                                    : "$statusText • $etaText",
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "View order status",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: canCancel
                                ? () => _cancelOrder(context, firestoreDocId)
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: BorderSide(
                                color: Colors.orange.withOpacity(0.35),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: canDelete
                                ? () => _deleteOrder(context, firestoreDocId)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.black12,
                              disabledForegroundColor: Colors.black38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Delete",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _buildTitle(
    Map<String, dynamic> data,
    String orderType,
    String vendorName,
  ) {
    if (vendorName.isNotEmpty) {
      return "$vendorName Order";
    }

    final type = orderType.toLowerCase();

    if (type == "food" || type == "restaurant") return "Restaurant Order";
    if (type == "supermarket") return "Supermarket Order";
    if (type == "farm") return "Farm Produce Order";
    if (type == "clothing") return "Clothing Order";
    if (type == "jewelry") return "Jewelry Order";
    if (type == "parcel") return "Parcel Delivery";

    return "Order";
  }

  static String _buildSubtitle(
    Map<String, dynamic> data,
    String orderType,
    String vendorName,
  ) {
    final items = data["items"];

    if (items is List && items.isNotEmpty) {
      final first = items.first;

      if (first is Map) {
        final name = (first["name"] ?? first["title"] ?? "").toString().trim();
        final qty = _asInt(first["qty"]) ?? _asInt(first["quantity"]) ?? 1;

        if (name.isNotEmpty) {
          if (items.length > 1) {
            return "$name ×$qty • +${items.length - 1} more item${items.length - 1 > 1 ? 's' : ''}";
          }
          return "$name ×$qty";
        }
      }
    }

    final type = orderType.toLowerCase();

    if (type == "parcel") {
      final parcelSummary = (data["parcelSummary"] ?? "").toString().trim();
      if (parcelSummary.isNotEmpty) return parcelSummary;
      return "Parcel delivery";
    }

    if (type == "food" || type == "restaurant") return "Food order";
    if (type == "supermarket") return "Household and grocery items";
    if (type == "farm") return "Fresh farm produce";
    if (type == "clothing") return "Fashion and clothing items";
    if (type == "jewelry") return "Jewelry and accessories";

    return vendorName.isNotEmpty ? "Order in progress" : "";
  }

  static int _statusToStep(String status, {double? distanceMeters}) {
    final s = status.toLowerCase().trim();

    if (s == "pending" || s == "confirmed") return 0;
    if (s == "preparing") return 1;

    if (s == "dispatch" || s == "dispatched" || s == "out_for_delivery") {
      return 2;
    }

    if (s == "arrived" || s == "delivered") return 3;
    if (s == "cancelled") return 0;

    if (distanceMeters != null && distanceMeters <= 80) return 3;
    if (distanceMeters != null) return 2;

    return 0;
  }

  static String _prettyStatus(String status, {double? distanceMeters}) {
    final s = status.toLowerCase().trim();

    if (s == "delivered") return "Delivered";
    if (s == "cancelled") return "Cancelled";

    if (distanceMeters != null && distanceMeters <= 80) {
      return "Driver arrived";
    }

    if (distanceMeters != null && distanceMeters <= 250) {
      return "Rider is close";
    }

    if (distanceMeters != null &&
        (s == "dispatch" || s == "dispatched" || s == "out_for_delivery")) {
      return "Rider is on the way";
    }

    if (s == "pending") return "Pending rider pickup";
    if (s == "confirmed") return "Order confirmed";
    if (s == "preparing") return "Vendor is preparing your order";
    if (s == "dispatch" || s == "dispatched") return "Rider picked up your order";
    if (s == "out_for_delivery") return "Rider is on the way";
    if (s == "arrived") return "Driver arrived";

    return status;
  }

  static String _statusHint(String status, {double? distanceMeters}) {
    final s = status.toLowerCase().trim();

    if (s == "delivered") {
      return "This order was completed successfully.";
    }

    if (s == "cancelled") {
      return "This order was cancelled.";
    }

    if (distanceMeters != null && distanceMeters <= 80) {
      return "Please get ready to receive your order now.";
    }

    if (distanceMeters != null && distanceMeters <= 250) {
      return "Your rider is very close to your delivery point.";
    }

    if (distanceMeters != null &&
        (s == "dispatch" || s == "dispatched" || s == "out_for_delivery")) {
      return "Your rider is heading to your delivery location.";
    }

    if (s == "pending") return "Waiting for rider assignment or pickup confirmation.";
    if (s == "confirmed") return "Your order has been received successfully.";
    if (s == "preparing") return "The vendor is getting your items ready.";
    if (s == "dispatch" || s == "dispatched") return "Your order has left the pickup point.";
    if (s == "out_for_delivery") return "Your rider is heading to your delivery location.";
    if (s == "arrived") return "Please get ready to receive your order.";

    return "";
  }

  static Color _statusColor(String status, {double? distanceMeters}) {
    final s = status.toLowerCase().trim();

    if (s == "delivered") return Colors.green;
    if (s == "cancelled") return Colors.red;
    if (distanceMeters != null && distanceMeters <= 80) return Colors.orange;
    if (distanceMeters != null && distanceMeters <= 250) return Colors.orange;
    if (distanceMeters != null) return _brandGreen;

    if (s == "pending") return Colors.orange;
    if (s == "confirmed" || s == "preparing") return _brandGreen;
    if (s == "dispatch" || s == "dispatched" || s == "out_for_delivery") {
      return _brandGreen;
    }
    if (s == "arrived") return Colors.orange;

    return Colors.black87;
  }

  static String _buildEtaText({
    required String savedEta,
    required String rawStatus,
    required double? distanceMeters,
  }) {
    if (savedEta.isNotEmpty) return savedEta;

    final s = rawStatus.toLowerCase().trim();

    if (s == "delivered" || s == "cancelled") return "";
    if (distanceMeters == null) return "";

    if (distanceMeters <= 80) return "Arrived";
    if (distanceMeters <= 250) return "Close";

    final int etaMin = _estimateEtaMinutes(distanceMeters);
    return "$etaMin min";
  }

  static int _estimateEtaMinutes(double distanceMeters) {
    const double riderMetersPerMinute = 300;
    final minutes = (distanceMeters / riderMetersPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  static String _distanceLabel(double meters) {
    if (meters < 1000) {
      return "${meters.round()}m";
    }
    return "${(meters / 1000).toStringAsFixed(1)}km";
  }

  static double? _distanceMeters({
    required double? riderLat,
    required double? riderLng,
    required double? dropoffLat,
    required double? dropoffLng,
  }) {
    if (riderLat == null ||
        riderLng == null ||
        dropoffLat == null ||
        dropoffLng == null) {
      return null;
    }

    return Geolocator.distanceBetween(
      riderLat,
      riderLng,
      dropoffLat,
      dropoffLng,
    );
  }

  static String _cleanRef(String orderId) {
    final cleaned = orderId.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.isEmpty ? orderId : cleaned;
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
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