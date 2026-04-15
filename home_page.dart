import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import 'cart_page.dart';
import 'products_page.dart';
import 'parcels_page.dart';
import 'select_address_map_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _brandBg = Color(0xFFE9FBF6);
  static const Color _brandPill = Color(0xFFDDF7F0);

  String _location = "Select Location (Village/Town)";

  void _openCategory(String category) {
    Navigator.pushNamed(
      context,
      ProductsPage.routeName,
      arguments: category,
    );
  }

  void _openParcels() {
    Navigator.pushNamed(context, ParcelsPage.routeName);
  }

  Future<void> _pickLocation() async {
    final picked = await Navigator.pushNamed(
      context,
      SelectAddressMapPage.routeName,
    );

    if (!mounted || picked == null) return;

    if (picked is Map) {
      final displayAddress =
          (picked['displayAddress'] ?? '').toString().trim();

      final title = (picked['title'] ?? '').toString().trim();
      final subtitle = (picked['subtitle'] ?? '').toString().trim();
      final fullAddress = (picked['fullAddress'] ?? '').toString().trim();

      if (displayAddress.isNotEmpty) {
        setState(() => _location = displayAddress);
        return;
      }

      if (title.isNotEmpty && subtitle.isNotEmpty) {
        setState(() => _location = "$title, $subtitle");
        return;
      }

      if (fullAddress.isNotEmpty) {
        setState(() => _location = fullAddress);
        return;
      }

      setState(() => _location = "Selected on map");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: _brandBg,
      appBar: AppBar(
        title: const Text("RuralGo"),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () =>
                    Navigator.pushNamed(context, CartPage.routeName),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _brandPill,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _brandGreen.withOpacity(0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Good day 👋",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickLocation,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _location,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            "What would you like today?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 16),

          _CirclesRow(
            children: [
              _CircleButton(
                title: "Restaurants",
                icon: Icons.restaurant,
                onTap: () => _openCategory("Restaurants"),
                brandGreen: _brandGreen,
              ),
              _CircleButton(
                title: "Farm Produce",
                icon: Icons.agriculture,
                onTap: () => _openCategory("Farm Produce"),
                brandGreen: _brandGreen,
              ),
              _CircleButton(
                title: "Supermarket",
                icon: Icons.shopping_cart_outlined,
                onTap: () => _openCategory("Supermarket"),
                brandGreen: _brandGreen,
              ),
            ],
          ),

          const SizedBox(height: 14),

          _CirclesRow(
            children: [
              _CircleButton(
                title: "Clothing",
                icon: Icons.checkroom,
                onTap: () => _openCategory("Clothing"),
                brandGreen: _brandGreen,
              ),
              _CircleButton(
                title: "Parcels &\nRelocation Assistant",
                icon: Icons.local_shipping,
                onTap: _openParcels,
                maxLines: 2,
                brandGreen: _brandGreen,
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            "Recommended for you",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 14),

          const Row(
            children: [
              Expanded(
                child: _MiniFeatureCard(
                  title: "Hot Meals",
                  subtitle: "Fast delivery",
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniFeatureCard(
                  title: "Fresh Tomatoes",
                  subtitle: "Direct from farm",
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _brandPill,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.eco, color: _brandGreen),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "RuralGo Prime — save more on deliveries and market runs.",
                    style: TextStyle(fontWeight: FontWeight.w800),
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

class _CirclesRow extends StatelessWidget {
  final List<Widget> children;

  const _CirclesRow({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(children.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: i == children.length - 1 ? 0 : 12,
            ),
            child: children[i],
          ),
        );
      }),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final int maxLines;
  final Color brandGreen;

  const _CircleButton({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.brandGreen,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    brandGreen.withOpacity(0.18),
                    brandGreen.withOpacity(0.30),
                  ],
                ),
                border: Border.all(
                  color: brandGreen.withOpacity(0.25),
                ),
              ),
              child: Icon(
                icon,
                color: brandGreen,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _MiniFeatureCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF00A082);

    return Container(
      height: 92,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: brandGreen.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: brandGreen.withOpacity(0.95),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}