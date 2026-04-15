import 'package:flutter/material.dart';

import 'products_page.dart';
import 'parcels_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _softBg = Color(0xFFE9FBF6);

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    final lower = query.toLowerCase();

    if (lower.contains('parcel') || lower.contains('relocation')) {
      Navigator.pushNamed(context, ParcelsPage.routeName);
      return;
    }

    String category = 'Restaurants';

    if (lower.contains('farm') ||
        lower.contains('tomato') ||
        lower.contains('pepper') ||
        lower.contains('yam') ||
        lower.contains('vegetable')) {
      category = 'Farm Produce';
    } else if (lower.contains('supermarket') ||
        lower.contains('grocery') ||
        lower.contains('groceries') ||
        lower.contains('provision')) {
      category = 'Supermarket';
    } else if (lower.contains('cloth') ||
        lower.contains('clothing') ||
        lower.contains('shirt') ||
        lower.contains('shoe') ||
        lower.contains('fashion')) {
      category = 'Clothing';
    } else if (lower.contains('restaurant') ||
        lower.contains('food') ||
        lower.contains('mama put') ||
        lower.contains('swallow')) {
      category = 'Restaurants';
    }

    Navigator.pushNamed(
      context,
      ProductsPage.routeName,
      arguments: {
        'category': category,
        'searchQuery': query,
      },
    );
  }

  void _openCategory(String label) {
    if (label == 'Parcels & Relocation') {
      Navigator.pushNamed(context, ParcelsPage.routeName);
      return;
    }

    Navigator.pushNamed(
      context,
      ProductsPage.routeName,
      arguments: {
        'category': label,
        'searchQuery': '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softBg,
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _openSearch,
                    decoration: const InputDecoration(
                      hintText: "Search stores, food, parcels, services…",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _openSearch(_searchCtrl.text),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Popular searches",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SearchChip(
                label: "Restaurants",
                onTap: () => _openCategory("Restaurants"),
              ),
              _SearchChip(
                label: "Farm Produce",
                onTap: () => _openCategory("Farm Produce"),
              ),
              _SearchChip(
                label: "Supermarket",
                onTap: () => _openCategory("Supermarket"),
              ),
              _SearchChip(
                label: "Clothing",
                onTap: () => _openCategory("Clothing"),
              ),
              _SearchChip(
                label: "Parcels & Relocation",
                onTap: () => _openCategory("Parcels & Relocation"),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.travel_explore,
                  size: 56,
                  color: _brandGreen.withOpacity(0.85),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Find anything around you",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Search for food, groceries, parcels,\nor nearby vendors in your location.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.black.withOpacity(0.15)),
    );
  }
}