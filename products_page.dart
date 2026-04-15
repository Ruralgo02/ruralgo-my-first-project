import 'package:flutter/material.dart';
import 'store_page.dart';

class ProductsPage extends StatelessWidget {
  static const routeName = '/products';

  final String category;
  final String? searchQuery;

  const ProductsPage({
    super.key,
    required this.category,
    this.searchQuery,
  });

  List<String> _storesFor(String cat) {
    switch (cat) {
      case 'Restaurants':
        return ['Mama Put', 'Village Kitchen', 'Jollof Spot', 'Suya & Grill'];
      case 'Farm Produce':
        return ['Green Harvest', 'Fresh Basket', 'Local Farmers Hub'];
      case 'Supermarket':
        return ['Rural Mart', 'Daily Needs', 'Household Store'];
      case 'Clothing':
        return ['Exquisite Wears', 'Shoes & Bags', 'Perfumes & Jewellery'];
      default:
        return ['RuralGo Store 1', 'RuralGo Store 2'];
    }
  }

  List<String> _filteredStores() {
    final stores = _storesFor(category);

    final q = (searchQuery ?? '').trim().toLowerCase();
    if (q.isEmpty) return stores;

    final filtered = stores.where((store) {
      return store.toLowerCase().contains(q);
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final stores = _filteredStores();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (searchQuery != null && searchQuery!.trim().isNotEmpty)
              ? '$category'
              : category,
        ),
      ),
      body: stores.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 58,
                      color: Colors.black45,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'No matching store found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      searchQuery == null || searchQuery!.trim().isEmpty
                          ? 'No stores available right now.'
                          : 'No result for "${searchQuery!.trim()}" in $category.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: stores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                return Card(
                  child: ListTile(
                    title: Text(
                      stores[i],
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      searchQuery != null && searchQuery!.trim().isNotEmpty
                          ? 'Matched in $category'
                          : 'Tap to open',
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => Navigator.pushNamed(
                      context,
                      StorePage.routeName,
                      arguments: {
                        'storeName': stores[i],
                        'category': category,
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}