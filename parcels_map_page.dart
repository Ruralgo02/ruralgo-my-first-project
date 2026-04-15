import 'package:flutter/material.dart';

class ParcelsMapPage extends StatefulWidget {
  static const String routeName = '/parcels-map';
  const ParcelsMapPage({super.key});

  @override
  State<ParcelsMapPage> createState() => _ParcelsMapPageState();
}

class _ParcelsMapPageState extends State<ParcelsMapPage> {
  final List<String> _locations = const [
    "Select Location (Village/Town)",
    "Abuja",
    "Lagos",
    "Enugu",
    "Kaduna",
  ];

  String _selectedLocation = "Select Location (Village/Town)";

  @override
  Widget build(BuildContext context) {
    // Light green background like your screenshot
    const bg = Color(0xFFEFF8EF);
    const circleBg = Color(0xFFD7EFD7);
    const darkGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Map"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          children: [
            // ✅ TOP ROW: location pill + calendar icon (like screenshot)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.green.shade200, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.green),
                        const SizedBox(width: 8),

                        // Dropdown
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLocation,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.green),
                              items: _locations
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                          color: e == _locations.first ? Colors.black54 : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _selectedLocation = v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200, width: 1.2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.calendar_month_outlined, color: Colors.green),
                    onPressed: () {
                      // You can later add booking date/time here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking date feature coming soon")),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ✅ ROUND CATEGORY BUTTONS (like screenshot)
            Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [
                _CircleCategory(
                  label: "Restaurants",
                  icon: Icons.restaurant,
                  bg: circleBg,
                  iconColor: darkGreen,
                  onTap: () {},
                ),
                _CircleCategory(
                  label: "Farm Produce",
                  icon: Icons.agriculture,
                  bg: circleBg,
                  iconColor: darkGreen,
                  onTap: () {},
                ),
                _CircleCategory(
                  label: "Supermarket",
                  icon: Icons.shopping_cart_outlined,
                  bg: circleBg,
                  iconColor: darkGreen,
                  onTap: () {},
                ),
                _CircleCategory(
                  label: "Clothing",
                  icon: Icons.checkroom_outlined,
                  bg: circleBg,
                  iconColor: darkGreen,
                  onTap: () {},
                ),
                _CircleCategory(
                  label: "Parcels",
                  icon: Icons.local_shipping_outlined,
                  bg: circleBg,
                  iconColor: darkGreen,
                  onTap: () {
                    Navigator.pop(context); // back to parcels page (optional)
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ✅ SECTION TITLE
            const Text(
              "These are for you",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkGreen),
            ),

            const SizedBox(height: 12),

            // ✅ 2 FEATURE CARDS ROW (like screenshot)
            Row(
              children: [
                Expanded(
                  child: _MiniCard(
                    title: "Hot Meals",
                    subtitle: "Fast delivery",
                    borderColor: Colors.green.shade200,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniCard(
                    title: "Fresh Tomatoes",
                    subtitle: "Direct from farm",
                    borderColor: Colors.green.shade200,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ✅ PRIME BANNER (like screenshot)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: circleBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco_outlined, color: darkGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "RuralGo Prime: Save on deliveries and market runs.",
                      style: TextStyle(fontWeight: FontWeight.w800, color: darkGreen),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ✅ OPTIONAL: Map placeholder area (so it still looks like a “map page”)
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Center(
                child: Text(
                  "Map view will appear here\n(we can connect Google Maps next)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleCategory extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleCategory({
    required this.label,
    required this.icon,
    required this.bg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade200, width: 1.2),
            ),
            child: Icon(icon, size: 38, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color borderColor;

  const _MiniCard({
    required this.title,
    required this.subtitle,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}