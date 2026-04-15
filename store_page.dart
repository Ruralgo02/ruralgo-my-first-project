import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class StorePage extends StatelessWidget {
  static const routeName = '/store';

  final String storeName;
  final String? category;

  const StorePage({super.key, required this.storeName, this.category});

  List<_Item> _itemsFor(String? cat) {
    switch (cat) {
      case 'Restaurants':
        return const [
          _Item('Jollof Rice', 2500),
          _Item('Rice & Stew', 2000),
          _Item('Chicken', 1500),
        ];
      case 'Farm Produce':
        return const [
          _Item('Tomatoes', 1500),
          _Item('Pepper', 1200),
          _Item('Yam', 1500),
        ];
      case 'Supermarket':
        return const [
          _Item('Indomie (pack)', 1200),
          _Item('Detergent', 2500),
          _Item('Toothpaste', 1200),
        ];
      case 'Clothing':
        return const [
          _Item('Shoes', 22000),
          _Item('Perfume', 18000),
          _Item('Jewellery', 12000),
        ];
      default:
        return const [
          _Item('Item 1', 1000),
          _Item('Item 2', 2000),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final String cat = (args is Map && args['category'] != null)
        ? args['category'] as String
        : (category ?? 'Restaurants');

    final items = _itemsFor(cat);

    return Scaffold(
      appBar: AppBar(title: Text(storeName)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final p = items[i];
          return Card(
            child: ListTile(
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text("₦${p.price.toStringAsFixed(0)}"),
              trailing: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().addItem(
                        CartItem(
                          id: "$storeName-$i",
                          name: p.name,
                          price: p.price,
                          qty: 1,
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${p.name} added to cart")),
                  );
                },
                child: const Text("Add"),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Item {
  final String name;
  final double price;
  const _Item(this.name, this.price);
}