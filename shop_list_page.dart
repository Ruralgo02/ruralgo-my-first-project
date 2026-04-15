import 'package:flutter/material.dart';
import 'shop_page.dart';

class ShopListPage extends StatelessWidget {
  final String category;

  const ShopListPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy shops per category
    final Map<String, List<Map<String, String>>> categoryShops = {
      'Groceries': [
        {
          'name': 'Chicken Republic',
          'image': 'https://i.imgur.com/8Km9tLL.jpg',
        },
        {
          'name': 'Dominos',
          'image': 'https://i.imgur.com/5QkGf6J.jpg',
        },
      ],
      'Clothing': [
        {
          'name': 'T-Shirt Store',
          'image': 'https://i.imgur.com/7r0F4Ju.jpg',
        },
        {
          'name': 'Shoe Boutique',
          'image': 'https://i.imgur.com/wlTx19D.jpg',
        },
      ],
      'Parcels': [
        {
          'name': 'Fast Delivery',
          'image': 'https://i.imgur.com/4gQf4XZ.jpg',
        },
      ],
      'Farm Produce': [
        {
          'name': 'Green Farm',
          'image': 'https://i.imgur.com/3Y3z0oS.jpg',
        },
      ],
    };

    final List<Map<String, String>> shops =
        categoryShops[category] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.green,
      ),
      body: shops.isEmpty
          ? const Center(child: Text('No shops available'))
          : ListView.builder(
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Image.network(
                      shop['image']!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.store),
                    ),
                    title: Text(shop['name']!),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShopPage(
                            shopName: shop['name']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}