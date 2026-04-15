import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VendorProductsPage extends StatelessWidget {
  static const routeName = '/vendor-products';
  const VendorProductsPage({super.key});

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _bg = Color(0xFFE9FBF6);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login as a vendor.")),
      );
    }

    final uid = user.uid;

    final productsRef = FirebaseFirestore.instance
        .collection('vendors')
        .doc(uid)
        .collection('products')
        .orderBy('updatedAt', descending: true);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text("My Products"),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        onPressed: () => _openAddOrEditSheet(context, uid: uid),
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: productsRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 64, color: _brandGreen),
                    const SizedBox(height: 10),
                    const Text(
                      "No products yet",
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Tap Add to create your first product.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _openAddOrEditSheet(context, uid: uid),
                        child: const Text(
                          "Add product",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final d = docs[i];
              final p = d.data();

              final name = (p['name'] ?? 'Unnamed').toString();
              final category = (p['category'] ?? '').toString();
              final price = (p['price'] ?? 0);
              final available = (p['available'] ?? true) == true;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _brandGreen.withOpacity(0.18)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _brandGreen.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      available
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                      color: _brandGreen,
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (category.isNotEmpty)
                          Text(category,
                              style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(
                          "₦$price",
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'toggle') {
                        await d.reference.update({
                          'available': !available,
                          'updatedAt': FieldValue.serverTimestamp(),
                        });
                      } else if (v == 'edit') {
                        await _openAddOrEditSheet(
                          context,
                          uid: uid,
                          docId: d.id,
                          existing: p,
                        );
                      } else if (v == 'delete') {
                        await d.reference.delete();
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child:
                            Text(available ? "Mark unavailable" : "Mark available"),
                      ),
                      const PopupMenuItem(value: 'edit', child: Text("Edit")),
                      const PopupMenuItem(value: 'delete', child: Text("Delete")),
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

  Future<void> _openAddOrEditSheet(
    BuildContext context, {
    required String uid,
    String? docId,
    Map<String, dynamic>? existing,
  }) async {
    final isEdit = docId != null;

    final nameCtrl = TextEditingController(text: (existing?['name'] ?? '').toString());
    final priceCtrl =
        TextEditingController(text: (existing?['price'] ?? '').toString());
    final categoryCtrl =
        TextEditingController(text: (existing?['category'] ?? '').toString());
    bool available = (existing?['available'] ?? true) == true;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isEdit ? "Edit product" : "Add product",
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  "Food • Supermarket • Clothing • Jewelry • Farm Produce",
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Product name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Category (e.g. Food, Clothing)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price (₦)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: available,
                onChanged: (v) => available = v,
                title: const Text("Available"),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final category = categoryCtrl.text.trim();
                    final price = int.tryParse(priceCtrl.text.trim()) ?? 0;

                    if (name.isEmpty || price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Name and valid price are required."),
                        ),
                      );
                      return;
                    }

                    final col = FirebaseFirestore.instance
                        .collection('vendors')
                        .doc(uid)
                        .collection('products');

                    final payload = {
                      'name': name,
                      'category': category,
                      'price': price,
                      'available': available,
                      'updatedAt': FieldValue.serverTimestamp(),
                      if (!isEdit) 'createdAt': FieldValue.serverTimestamp(),
                    };

                    if (isEdit) {
                      await col.doc(docId).update(payload);
                    } else {
                      await col.add(payload);
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text(
                    isEdit ? "Save changes" : "Add product",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    nameCtrl.dispose();
    priceCtrl.dispose();
    categoryCtrl.dispose();
  }
}