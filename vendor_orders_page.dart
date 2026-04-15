import 'package:flutter/material.dart';

class VendorOrdersPage extends StatelessWidget {
  static const routeName = '/vendor-orders';
  const VendorOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo vendor orders (later from Firestore)
    final orders = [
      {
        "customer": "Oge",
        "items": "Rice + Stew",
        "address": "Lugbe (Opposite Primary School)",
        "status": "New",
        "amount": "₦3,500",
      },
      {
        "customer": "Ada",
        "items": "Perfume + Shoes",
        "address": "Kubwa (Behind Police Station)",
        "status": "Preparing",
        "amount": "₦12,000",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Orders')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final o = orders[i];
          return Card(
            child: ListTile(
              title: Text(
                "${o["customer"]} • ${o["amount"]}",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text("${o["items"]}\n${o["address"]}\nStatus: ${o["status"]}"),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open order details (next step)')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}