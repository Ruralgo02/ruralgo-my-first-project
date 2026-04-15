import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'vendor_products_customer_page.dart';

class VendorsByTypePage extends StatelessWidget {
  final String type; // clothing, farm, supermarket, restaurant
  final String title;

  const VendorsByTypePage({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final vendorsRef = FirebaseFirestore.instance
        .collection("Vendors")
        .where("type", isEqualTo: type);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<QuerySnapshot>(
        stream: vendorsRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("No vendors found"));
          }

          final vendors = snap.data!.docs;

          return ListView.builder(
            itemCount: vendors.length,
            itemBuilder: (context, i) {
              final doc = vendors[i];
              final data = doc.data() as Map<String, dynamic>;

              final name = data["name"] ?? "Vendor";
              final address = data["address"] ?? "";
              final isOpen = data["isOpen"] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(address),
                  trailing: Text(
                    isOpen ? "OPEN" : "CLOSED",
                    style: TextStyle(
                      color: isOpen ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VendorProductsCustomerPage(
                          vendorId: doc.id,
                          vendorName: name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}