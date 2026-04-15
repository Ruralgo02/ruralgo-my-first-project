import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiderJobsPage extends StatelessWidget {
  static const routeName = '/rider-jobs';
  const RiderJobsPage({super.key});

  Future<void> _openMap(String location) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}",
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _prettyType(String type) {
    switch (type.toLowerCase()) {
      case "food":
      case "restaurant":
        return "Restaurant Order";
      case "supermarket":
        return "Supermarket Order";
      case "goods":
        return "Store Order";
      case "parcel":
        return "Parcel Delivery";
      default:
        return type.isEmpty ? "Order" : type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobType = (ModalRoute.of(context)?.settings.arguments ?? 'parcel')
        .toString()
        .toLowerCase();

    final bool isParcelPage = jobType == 'parcel';

    return Scaffold(
      backgroundColor: const Color(0xFFE9FBF6),
      appBar: AppBar(
        title: Text(isParcelPage ? 'Parcel Jobs' : 'Store / Food Jobs'),
        backgroundColor: const Color(0xFF00A082),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("Orders")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];

          final filteredDocs = docs.where((doc) {
            final data = doc.data();
            final orderType =
                (data["orderType"] ?? "").toString().toLowerCase().trim();

            if (isParcelPage) {
              return orderType == "parcel";
            } else {
              return orderType == "goods" ||
                  orderType == "food" ||
                  orderType == "restaurant" ||
                  orderType == "supermarket";
            }
          }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(
              child: Text(
                "No jobs available yet",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDocs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final doc = filteredDocs[i];
              final data = doc.data();

              final String orderId = (data["orderId"] ?? doc.id).toString();
              final String orderType = (data["orderType"] ?? "").toString();
              final String title = (data["title"] ?? "Order").toString();
              final String itemSummary =
                  (data["itemSummary"] ?? "").toString();
              final String status = (data["status"] ?? "").toString();
              final String pickupText =
                  (data["pickupText"] ?? "").toString();
              final String dropoffText =
                  (data["dropoffText"] ?? "").toString();
              final String customerPhone =
                  (data["customerPhone"] ?? "").toString();
              final String customerName =
                  (data["customerName"] ?? "").toString();
              final String landmark =
                  (data["landmark"] ?? "").toString();
              final String stopPoint =
                  (data["stopPoint"] ?? "").toString();
              final String deliveryInstruction =
                  (data["deliveryInstruction"] ?? "").toString();
              final String note = (data["note"] ?? "").toString();
              final String total = (data["total"] ?? "0").toString();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order ID: $orderId",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      if (itemSummary.isNotEmpty) Text("Item: $itemSummary"),
                      Text("Category: ${_prettyType(orderType)}"),
                      Text("Status: $status"),
                      Text(
                        "Pickup: ${pickupText.isEmpty ? 'Not provided' : pickupText}",
                      ),
                      Text(
                        "Dropoff: ${dropoffText.isEmpty ? 'Not provided' : dropoffText}",
                      ),
                      if (customerName.isNotEmpty) Text("Customer: $customerName"),
                      if (customerPhone.isNotEmpty) Text("Phone: $customerPhone"),
                      if (landmark.isNotEmpty) Text("Landmark: $landmark"),
                      if (stopPoint.isNotEmpty) Text("Stop Point: $stopPoint"),
                      if (deliveryInstruction.isNotEmpty)
                        Text("Instruction: $deliveryInstruction"),
                      if (note.isNotEmpty) Text("Note: $note"),
                      Text("Total: ₦$total"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: pickupText.isEmpty
                                  ? null
                                  : () => _openMap(pickupText),
                              icon: const Icon(Icons.store_mall_directory),
                              label: const Text("Pickup Map"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: dropoffText.isEmpty
                                  ? null
                                  : () => _openMap(dropoffText),
                              icon: const Icon(Icons.navigation),
                              label: const Text("Dropoff Map"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}