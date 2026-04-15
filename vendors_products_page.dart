import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'vendor_products_screen.dart';

class VendorsListScreen extends StatelessWidget {
  final String vendorType; // "clothing" | "farm" | "supermarket" | "restaurant"
  final String title;

  const VendorsListScreen({
    super.key,
    required this.vendorType,
    required this.title,
  });

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _brandBg = Color(0xFFE9FBF6);

  @override
  Widget build(BuildContext context) {
    final vendorsQuery = FirebaseFirestore.instance
        .collection("Vendors") // ✅ matches your Firestore (capital V)
        .where("type", isEqualTo: vendorType);

    return Scaffold(
      backgroundColor: _brandBg,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: vendorsQuery.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No $title vendors yet.",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            );
          }

          final vendors = snap.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vendors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final doc = vendors[i];
              final data = doc.data() as Map<String, dynamic>;

              final name = (data["name"] ?? "Vendor").toString();
              final address = (data["address"] ?? "").toString();
              final isOpen = (data["isOpen"] ?? true) as bool;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _brandGreen.withOpacity(0.15)),
                ),
                child: ListTile(
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    address.isEmpty ? (isOpen ? "Open" : "Closed") : address,
                    style: TextStyle(
                      color: isOpen ? Colors.black54 : Colors.redAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    // ✅ vendorDocId is doc.id (e.g. "Clothing Vendor")
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VendorProductsScreen(
                          vendorDocId: doc.id,
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