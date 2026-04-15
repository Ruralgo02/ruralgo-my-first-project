import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import 'cart_page.dart';

class ShopPage extends StatelessWidget {
  static const routeName = '/shop';
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final category = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'Shop';
    final cart = context.watch<CartProvider>();

    // Simple demo products by category
    final products = _productsFor(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.green,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, CartPage.routeName),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final p = products[index];
          return Card(
            elevation: 1,
            child: ListTile(
              title: Text(p['name'].toString()),
              subtitle: Text('₦${p['price']}'),
              trailing: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().addItem(
                        id: p['id'].toString(),
                        name: p['name'].toString(),
                        price: p['price'] as int,
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${p['name']} added to cart")),
                  );
                },
                child: const Text('Add'),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, Object>> _productsFor(String category) {
    if (category == 'Restaurant Parcels') {
      return [
        {'id': 'r1', 'name': 'Jollof Rice Pack', 'price': 1500},
        {'id': 'r2', 'name': 'Fried Rice + Chicken', 'price': 2500},
        {'id': 'r3', 'name': 'Pepper Soup Bowl', 'price': 3500},
      ];
    }
    if (category == 'Farm Produce') {
      return [
        {'id': 'f1', 'name': 'Fresh Tomatoes Basket', 'price': 2000},
        {'id': 'f2', 'name': 'Yam Tubers (5pcs)', 'price': 5000},
        {'id': 'f3', 'name': 'Egg Crate', 'price': 3200},
      ];
    }
    // Clothing
    return [
      {'id': 'c1', 'name': 'T-Shirt', 'price': 4000},
      {'id': 'c2', 'name': 'Jeans', 'price': 9000},
      {'id': 'c3', 'name': 'Native Wear', 'price': 15000},
    ];
  }
}