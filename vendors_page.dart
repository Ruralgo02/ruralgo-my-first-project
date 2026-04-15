import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'vendor_products_page.dart';

class VendorsPage extends StatelessWidget {
  static const routeName = "/vendors";

  const VendorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vendorsRef =
        FirebaseFirestore.instance.collection("Vendors"); // matches Firestore

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendors"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: vendorsRef.snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No vendors available"),
            );
          }

          final vendors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vendors.length,
            itemBuilder: (context, index) {

              final vendor = vendors[index];
              final data = vendor.data() as Map<String, dynamic>;

              final name = data["name"] ?? "Vendor";
              final address = data["address"] ?? "";
              final type = data["type"] ?? "";
              final isOpen = data["isOpen"] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text("$type • $address"),
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
                        builder: (_) => VendorProductsPage(
                          vendorId: vendor.id,
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