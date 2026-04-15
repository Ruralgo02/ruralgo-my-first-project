import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorProductsCustomerPage extends StatelessWidget {
  final String vendorId;
  final String vendorName;

  const VendorProductsCustomerPage({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    final productsRef = FirebaseFirestore.instance
        .collection("Vendors")
        .doc(vendorId)
        .collection("products")
        .where("available", isEqualTo: true);

    return Scaffold(
      appBar: AppBar(title: Text(vendorName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("No products yet"));
          }

          final items = snap.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final data = items[i].data() as Map<String, dynamic>;
              final name = data["name"] ?? "";
              final price = data["price"] ?? 0;
              final category = data["category"] ?? "";
              final image = data["image"] ?? "";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: image.toString().isNotEmpty
                      ? Image.network(image, width: 50, fit: BoxFit.cover)
                      : const Icon(Icons.shopping_bag),
                  title: Text(name),
                  subtitle: Text(category),
                  trailing: Text(
                    "₦$price",
                    style: const TextStyle(fontWeight: FontWeight.bold),
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