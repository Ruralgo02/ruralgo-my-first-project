import 'package:flutter/material.dart';

import 'vendor_store_profile_page.dart';
import 'vendor_products_page.dart';
import 'vendor_orders_page.dart';
import 'vendor_wallet_page.dart';

class VendorDashboardPage extends StatelessWidget {
  static const routeName = '/vendor-dashboard';
  const VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Welcome, Vendor 👋',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.store),
                title: const Text('My Store Profile'),
                subtitle: const Text('Business name, location, delivery areas'),
                onTap: () => Navigator.pushNamed(
                  context,
                  VendorStoreProfilePage.routeName,
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2),
                title: const Text('Products'),
                subtitle: const Text('Add / edit products and prices'),
                onTap: () => Navigator.pushNamed(
                  context,
                  VendorProductsPage.routeName,
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Orders'),
                subtitle: const Text('See new orders and update status'),
                onTap: () => Navigator.pushNamed(
                  context,
                  VendorOrdersPage.routeName,
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.payments),
                title: const Text('Wallet / Payouts'),
                subtitle: const Text('Track earnings and withdrawals'),
                onTap: () => Navigator.pushNamed(
                  context,
                  VendorWalletPage.routeName,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}